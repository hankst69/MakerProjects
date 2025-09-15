/**
   wifiConfig.cpp
   by Matthew Ford,  2021/12/06
   (c)2021 Forward Computing and Control Pty. Ltd.
   NSW, Australia  www.forward.com.au
   This code may be freely used for both private and commerical use.
   Provide this copyright is maintained.

*/
#include "wifiConfig.h"
#include "LittleFSsupport.h"
#include "DebugOut.h"
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <millisDelay.h>
#include <SafeString.h>

// normally DEBUG is commented out
#define DEBUG
static Stream* debugPtr = NULL;  // local to this file

// this project does not use the double reboot file
// if you uncomment the next line
// powering up then off withing 10 sec will go into wifiConfig mode on next power up
#define DOUBLE_REBOOT_CONFIG_SETUP

// replace these with your network's SSID and password and the static IP you want for this Power Timer web server.
#define wifiSSID ""
#define wifPassword ""
#define wifiStaticIP "192.168.178.255"
// NOTE: choose an IP on your network!!

#define wifiWebConfigPASSWORD "12345678"
#define wifiWebConfigAP "IOTconfigAP"

static  IPAddress local_ip = IPAddress(192, 1, 1, 1);
static  IPAddress gateway_ip = IPAddress(192, 1, 1, 1);
static  IPAddress subnet_ip = IPAddress(255, 255, 255, 0);

millisDelay endConfigTimer;
const unsigned long END_CONFIG_MS = 5ul * 60 * 1000; // 5mins to make first connection and show wifi config webpage
const unsigned long RESTART_AFTER_CONFIG_MS = 30 * 1000; // 30 sec after config set

#ifdef DOUBLE_REBOOT_CONFIG_SETUP
millisDelay doubleRebootTimer;
const unsigned long DOUBLE_REBOOT_MS = 10UL * 1000; // 10 sec
#else
bool initConfigCalled = false; // set true on first call, second call start AP for wifi config
#endif

/*
   in wifiConfig.h
  static const int MAX_SSID_LEN = 32;
  static const int MAX_PASSWORD_LEN = 64;
  static const int MAX_STATICIP_LEN = 40;

  struct Wifi_CONFIG_storage_struct {
  char ssid[MAX_SSID_LEN + 1]; // WIFI ssid + null
  char password[MAX_PASSWORD_LEN + 1]; // WiFi password,  if empyt use OPEN, else use AUTO (WEP/WPA/WPA2) + null
  char staticIP[MAX_STATICIP_LEN + 1]; // staticIP, if empty use DHCP + null
  } storage;
*/

static struct Wifi_CONFIG_storage_struct storage;

static struct Wifi_CONFIG_storage_struct* loadWifiConfig(); // returns pointer to wifi config storage or default values (if any)

// default config for testing
static void setInitialWifiConfig() {
  cSFA(sfSSID, storage.ssid);
  cSFA(sfPW, storage.password);
  cSFA(sfIP, storage.staticIP);
  sfSSID = wifiSSID;  // if this is empty config not set and the Power Time will go in not netword setup mode on power up.
  sfPW = wifPassword;
  sfIP = wifiStaticIP;
}

void printWifConfig(struct Wifi_CONFIG_storage_struct& storage, Stream& out) {
  out.print("ssid:");
  out.println(storage.ssid);
  out.print("password:");
  out.println(storage.password);
  out.print("staticIP:");
  out.println(storage.staticIP);
}

//
static void handleNotFound();
static void handleRoot();
static void handleConfig();
static void setupAP(const char* ssid_wifi, const char* password_wifi);
static bool saveWifiConfig(struct Wifi_CONFIG_storage_struct& storagePtr);
String urlDecode(const String& text); // from ESP8266 webserver code

static const char wifiConfigFileName[] = "/wifiConfig.bin";  // binary file
#ifdef DOUBLE_REBOOT_CONFIG_SETUP
static const char rebootDetectionFileName[] = "/rebootFile"; // empty
#endif

static ESP8266WebServer webserver(80);  // this just sets portNo nothing else happens until begin() is called

static bool inConfigMode = false;
cSF(sfStrongestAP, MAX_SSID_LEN);

/**
  call this in setup() only !!
  if called twice the second call will startup AP (since file will exist), if not already started
*/

struct Wifi_CONFIG_storage_struct*  initializeWifiConfig() {
#ifdef DEBUG
  debugPtr = getDebugOut();
#endif
  if (debugPtr) {
    debugPtr->print("initializeWifiConfig() "); debugPtr->println();
  }
  if (inConfigMode) {
    if (debugPtr) {
      debugPtr->print("initializeWifiConfig(), AP already started, just return "); debugPtr->println();
    }
    return &storage; // AP already started
  }
  if (!initializeFS()) {
    if (debugPtr) {
      debugPtr->print("LittleFS initialize failed "); debugPtr->println();
    }
    setInitialWifiConfig();
    return &storage;
  }
#ifndef DOUBLE_REBOOT_CONFIG_SETUP
  if (initConfigCalled) { // this is the second call start AP
    setupAP(wifiWebConfigAP, wifiWebConfigPASSWORD); // sets inConfigMode
    return &storage; // loaded by setupAP
  } else {
    initConfigCalled = true; // start AP on next call
    loadWifiConfig(); // loads global storage // set default if missing
    saveWifiConfig(storage); // save
    loadWifiConfig(); // reload global
    return &storage; // loaded by setupAP
  }
#else // DOUBLE_REBOOT_CONFIG_SETUP
  if (LittleFS.exists(rebootDetectionFileName)) {
    // double reboot so start wifi config
    clearRebootFile();
    //LittleFS.remove(rebootDetectionFileName); // continue to enter config mode
    setupAP(wifiWebConfigAP, wifiWebConfigPASSWORD); // sets inConfigMode
    return &storage; // loaded by setupAP
  } else {
    // create reboot file now
    if (debugPtr) {
      debugPtr->print("Create double reboot file "); debugPtr->println(rebootDetectionFileName);
    }
    File f = LittleFS.open(rebootDetectionFileName, "w");
    f.close();
    doubleRebootTimer.start(DOUBLE_REBOOT_MS);
    loadWifiConfig(); // loads global storage // set default if missing
    saveWifiConfig(storage); // save
    loadWifiConfig(); // reload global
    return &storage; // loaded by setupAP
  }
#endif
}

void clearRebootFile() {
#ifdef DOUBLE_REBOOT_CONFIG_SETUP
  LittleFS.remove(rebootDetectionFileName); // continue to enter config mode
#endif
}

/** call this in loop() every loop()
  returns true if in config mode
  in loop() have at the top
  void loop() {
  if (handleWifiConfig()) {
  return; // skip rest of the loop
  }
*/
bool handleWifiConfig() {
  if (!inConfigMode) {
#ifdef DOUBLE_REBOOT_CONFIG_SETUP
    // check if should delete reboot file
    if (doubleRebootTimer.justFinished()) {
      // did not reboot in 10 sec so delete reboot file
      if (debugPtr) {
        debugPtr->print("Double reboot timed out remove file "); debugPtr->println(rebootDetectionFileName);
      }
      clearRebootFile();
      //LittleFS.remove(rebootDetectionFileName); // continue to enter config mode
    }
#endif
    return false; // not doing wifi config so just ignore this call
  }
  // else in config mode
  webserver.handleClient();
  if (endConfigTimer.justFinished()) {
    ESP.restart(); // see https://github.com/esp8266/Arduino/issues/1017  seems to work here
  }
  return true;
}

// loads global storage and returns pointer to it
static struct Wifi_CONFIG_storage_struct* loadWifiConfig() {
#ifdef DEBUG
  debugPtr = getDebugOut();
#endif
  setInitialWifiConfig();
  if (!initializeFS()) {
    if (debugPtr) {
      debugPtr->println("FS failed to initialize");
    }
    if (debugPtr) {
      debugPtr->println("set config");
      printWifConfig(storage, *debugPtr);
    }
    return &storage; // returns default if cannot open FS
  }
  if (!LittleFS.exists(wifiConfigFileName)) {
    if (debugPtr) {
      debugPtr->print(wifiConfigFileName); debugPtr->print(" missing.");
    }
    if (debugPtr) {
      debugPtr->println("set config");
      printWifConfig(storage, *debugPtr);
    }
    return &storage; // returns default if missing
  }
  // else load config
  File f = LittleFS.open(wifiConfigFileName, "r");
  if (!f) {
    if (debugPtr) {
      debugPtr->print(wifiConfigFileName); debugPtr->print(" did not open for read.");
    }
    if (debugPtr) {
      debugPtr->println("set config");
      printWifConfig(storage, *debugPtr);
    }
    return &storage; // returns default wrong size
  }
  if (f.size() != sizeof(storage)) {
    if (debugPtr) {
      debugPtr->print(wifiConfigFileName); debugPtr->print(" wrong size.");
    }
    f.close();
    if (debugPtr) {
      debugPtr->println("set config");
      printWifConfig(storage, *debugPtr);
    }
    return &storage; // returns default wrong size
  }
  int bytesIn = f.read((uint8_t*)(&storage), sizeof(storage));
  if (bytesIn != sizeof(storage)) {
    if (debugPtr) {
      debugPtr->print(wifiConfigFileName); debugPtr->print(" wrong size read in.");
    }
    setInitialWifiConfig(); // again
    f.close();
    if (debugPtr) {
      debugPtr->println("set config");
      printWifConfig(storage, *debugPtr);
    }
    return &storage;
  }
  f.close();
  // else return settings
  if (debugPtr) {
    debugPtr->println("Loaded config");
    printWifConfig(storage, *debugPtr);
  }
  return &storage;
}

static bool saveWifiConfig(struct Wifi_CONFIG_storage_struct& storage) {
#ifdef DEBUG
  debugPtr = getDebugOut();
#endif
  if (!initializeFS()) {
    if (debugPtr) {
      debugPtr->println("FS failed to initialize");
    }
    return false;
  }
  // else save config
  File f = LittleFS.open(wifiConfigFileName, "w"); // create/overwrite
  if (!f) {
    if (debugPtr) {
      debugPtr->print(wifiConfigFileName); debugPtr->print(" did not open for write.");
    }
    return false; // returns default wrong size
  }
  int bytesOut = f.write((uint8_t*)(&storage), sizeof(struct Wifi_CONFIG_storage_struct));
  if (bytesOut != sizeof(struct Wifi_CONFIG_storage_struct)) {
    if (debugPtr) {
      debugPtr->print(wifiConfigFileName); debugPtr->print(" write failed.");
    }
    return false;
  }
  // else return settings
  f.close(); // no rturn
  if (debugPtr) {
    debugPtr->print(wifiConfigFileName); debugPtr->print(" config saved.");
    //    printWifConfig(storage, *debugPtr);
  }
  return true;
}


/**
   will return name of AP with strongest signal found or return empty string if none found
*/
static void scanForStrongestAP(SafeString &result) {
  result.clear();
  // WiFi.scanNetworks will return the number of networks found
  int8_t n = WiFi.scanNetworks();
  if (n <= 0) {
    if (debugPtr) {
      debugPtr->println("Wifi network scan failed");
    }
    return;
  }
  if (debugPtr) {
    debugPtr->println("Scan done");
    debugPtr->print("Found ");   debugPtr->print(n);    debugPtr->println(" networks");
  }
  int32_t maxRSSI = -10000;
  for (int8_t i = 0; i < n; ++i) {
    //const char * ssid_scan = WiFi.SSID_charPtr(i);
    int32_t rssi_scan = WiFi.RSSI(i);
    if (rssi_scan > maxRSSI) {
      maxRSSI = rssi_scan;
      String ssid = WiFi.SSID(i);
      result = ssid.c_str();
    }
    if (debugPtr) {
      debugPtr->print(result);
      debugPtr->print(" ");
      debugPtr->println(rssi_scan);
    }
    delay(0);
  }
}


/**
   sets up AP and loads current wifi settings
*/
static void setupAP(const char* ssid_wifi, const char* password_wifi) {
  /**
    Start scan WiFi networks available
    @param async         run in async mode
    @param show_hidden   show hidden networks
    @param channel       scan only this channel (0 for all channels)
    @param ssid*         scan for only this ssid (NULL for all ssid's)
    @return Number of discovered networks
  */
  inConfigMode = true; // in config mode
  if (debugPtr) {
    debugPtr->println(F("Setting up Access Point for pfodWifiWebConfig"));
  }
  // connect to temporary wifi network for setup

  scanForStrongestAP(sfStrongestAP);
  if (debugPtr) {
    debugPtr->println(F("configure pfodWifiWebConfig"));
  }

  if (debugPtr) {
    debugPtr->println(F("Access Point setup"));
  }
  WiFi.softAPConfig(local_ip, gateway_ip, subnet_ip);
  WiFi.softAP(ssid_wifi, password_wifi);

  if (debugPtr) {
    debugPtr->println("done");
    IPAddress myIP = WiFi.softAPIP();
    debugPtr->print(F("AP IP address: "));
    debugPtr->println(myIP);
  }
  delay(10);
  webserver.on ( "/", handleRoot );
  webserver.on ( "/config", handleConfig );
  webserver.onNotFound ( handleNotFound );
  webserver.begin();
  if (debugPtr) {
    debugPtr->println ( "HTTP webserver started" );
  }
  loadWifiConfig(); // sets global storage
  endConfigTimer.start(END_CONFIG_MS);
}

static void handleConfig() {
  // set defaults
  
  if (webserver.args() > 0) {
    if (debugPtr) {
      String message = "Config results\n\n";
      message += "URI: ";
      message += webserver.uri();
      message += "\nMethod: ";
      message += ( webserver.method() == HTTP_GET ) ? "GET" : "POST";
      message += "\nArguments: ";
      message += webserver.args();
      message += "\n";
      for ( uint8_t i = 0; i < webserver.args(); i++ ) {
        message += " " + webserver.argName ( i ) + ": " + webserver.arg ( i ) + "\n";
      }
      debugPtr->println(message);
      debugPtr->println();
    }

    cSFA(sfSSID, storage.ssid);
    cSFA(sfPW, storage.password);
    cSFA(sfIP, storage.staticIP);

    uint8_t numOfArgs = webserver.args();
    uint8_t i = 0;
    for (; (i < numOfArgs); i++ ) {
      // check field numbers
      if (webserver.argName(i)[0] == '1') {
        String decoded = urlDecode(webserver.arg(i)); // result is always <= source so just copy over
        decoded.trim();
        sfSSID = decoded.c_str();
      } else if (webserver.argName(i)[0] == '2') {
        String decoded = urlDecode(webserver.arg(i)); // result is always <= source so just copy over
        decoded.trim();
        if (decoded != "*") {
          // update it
          sfPW = decoded.c_str();
        }
        // if password all blanks make it empty
      } else if (webserver.argName(i)[0] == '3') {
        String decoded = urlDecode(webserver.arg(i)); // result is always <= source so just copy over
        decoded.trim();
        sfIP = decoded.c_str();
      }
    }

    if (debugPtr) {
      debugPtr->println();
      printWifConfig(storage, *debugPtr);
    }

    // store the settings
    if (!saveWifiConfig(storage)) {
      loadWifiConfig(); // re-initialize
    }
  } // else if no args just return current settings

  delay(0);
  loadWifiConfig();
  if (debugPtr) {
    debugPtr->println();
    printWifConfig(storage, *debugPtr);
  }
  String rtnMsg = "<html>"
                  "<head>"
                  "<title>ESP8266 Power Timer Wifi Network Config Setup</title>"
                  "<meta charset=\"utf-8\" />"
                  "<meta name=viewport content=\"width=device-width, initial-scale=1\">"
                  "</head>"
                  "<body>"
                  "<h2>ESP8266 Power Timer Wifi Network Config Settings saved.</h2><br>Power cycle to connect to ";
  if (storage.password[0] == '\0') {
    rtnMsg += "the open network ";
  }
  rtnMsg += "<b>";
  rtnMsg += storage.ssid;
  rtnMsg += "</b>";

  if (storage.staticIP[0] == '\0') {
    rtnMsg += "<br> using DCHP to get its IP address";
  } else { // staticIP
    IPAddress ip;
    if (!ip.fromString(storage.staticIP)) {
      rtnMsg += "<br><br> IP address entered is invalid using DHCP</b>";
    } else {
      rtnMsg += "<br> using IP addess ";
      rtnMsg += "<b>";
      rtnMsg += storage.staticIP;
      rtnMsg += "</b>";
    }
  }
  rtnMsg += "<p>";
  rtnMsg += "<b>You also need to reconnect your mobile<br> to the ";
  rtnMsg += storage.ssid;
  rtnMsg += " network</b>";
  rtnMsg += "<p>";
  rtnMsg += " ESP8266 will auto restart in 30 seconds</b>";
  rtnMsg += "</body>";
  rtnMsg += "</html>";

  webserver.send ( 200, "text/html", rtnMsg );
  endConfigTimer.start(RESTART_AFTER_CONFIG_MS); // restart in 30sec
}


static void handleRoot() {
  endConfigTimer.start(END_CONFIG_MS); // allow another 5mins stop 5min time out on first connection
  String msg;
  msg = "<html>"
        "<head>"
        "<title>ESP8266 Power Timer Wifi Network Config Setup</title>"
        "<meta charset=\"utf-8\" />"
        "<meta name=viewport content=\"width=device-width, initial-scale=1\">"
        "</head>"
        "<body>"
        "<h2>ESP8266 Power Timer Wifi Network Config Setup</h2>"
        "<p>Use this form to configure your timer to connect to your Wifi network.<br>"
        "<i>Leading and trailing spaces are trimmed.</i></p>"
        "<form class=\"form\" method=\"post\" action=\"/config\" >"
        "<p class=\"name\">"
        "<label for=\"name\">Network SSID</label><br>"
        "<input type=\"text\" name=\"1\" id=\"ssid\" placeholder=\"wifi network name\"  required "; // field 1

  if (!sfStrongestAP.isEmpty()) {
    msg += " value=\"";
    msg += sfStrongestAP.c_str();
    msg += "\" ";
  }
  msg += " />"
         "<p class=\"password\">"
         "<label for=\"password\">Password for WEP/WPA/WPA2 (enter a space if there is no password, i.e. OPEN)<br>"
         "To use existing password leave as * </label><br>"
         "<input type=\"text\" name=\"2\" id=\"password\" placeholder=\"wifi network password\" autocomplete=\"off\" required "; // field 2
  if (storage.password[0] != '\0') {
    msg += " value=\"";
    msg += "*"; //storage.password[0];
    msg += "\" ";
  }
  msg += " />"
         "</p>"
         "<p class=\"static_ip\">"
         "<label for=\"static_ip\">Set the Static IP for this device</label><br>"
         "(If this field is empty, NOT recommended, DHCP will be used to get an IP address)<br>"
         "<input type=\"text\" name=\"3\" id=\"static_ip\" placeholder=\"192.168.4.99\" minlength=\"7\" maxlength=\"15\" size=\"15\"  "  // field 3
         " pattern=\"\\b(?:(?:25[0-4]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-4]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\b\"";
  if (storage.staticIP[0] != '\0') {
    msg += " value=\"";
    msg += storage.staticIP;
    msg += "\" ";
  }
  msg += " />"
         "</p>"
         "<p class=\"submit\">"
         "<input type=\"submit\" style=\"font-size:25px;\" value=\"Configure\"  />"
         "</p>"
         "</form>"
         "The ESP8266 will auto-restart in 5 mins if current config not changed"
         "</body>"
         "</html>";

  webserver.send ( 200, "text/html", msg );
}


static void handleNotFound() {
  handleRoot();
}


String urlDecode(const String& text) {
  String decoded;
  char temp[] = "0x00";
  unsigned int len = text.length();
  unsigned int i = 0;
  while (i < len)
  {
    char decodedChar;
    char encodedChar = text.charAt(i++);
    if ((encodedChar == '%') && (i + 1 < len))
    {
      temp[2] = text.charAt(i++);
      temp[3] = text.charAt(i++);

      decodedChar = strtol(temp, NULL, 16);
    }
    else {
      if (encodedChar == '+')
      {
        decodedChar = ' ';
      }
      else {
        decodedChar = encodedChar;  // normal ascii char
      }
    }
    decoded += decodedChar;
  }
  return decoded;
}
