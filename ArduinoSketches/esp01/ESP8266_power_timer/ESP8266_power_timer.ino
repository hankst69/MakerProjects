/**
   ESP8266_power_timer.ino
   V1.1.0
   2022/01/11 V1.1.0 added DHCP server to wifiConfig AccessPoint

   by Matthew Ford,  2021/12/06
   (c)2021-2022 Forward Computing and Control Pty. Ltd.
   NSW, Australia  www.forward.com.au
   This code may be freely used for both private and commerical use.
   Provide this copyright is maintained.
*/

#include "DebugOut.h"
#include "millisDelay.h"
#include "LittleFSsupport.h"
#include "wifiConfig.h"
#include "webPages.h"
#include "ntpSupport.h"
#include "tzPosix.h"
#include "PinFlasher.h"
#include <ESP8266WiFi.h>

// use #define ESP_LED 2 for ESP-01S (Blue led on GPIO2)
// use #define ESP_LED 1 for ESP-01 (Blue led on TX (GPIO1), ESP-01 also has a Red power led)
#define ESP_LED 2

// for ESP-01 i.e. Blue led on TX pin, if #define DEBUG is un-commented, led will not flash
// once you have finished debugging comment out #define DEBUG to enable ESP-01 to use GPIO1 (TX) to flash Blue led
// for ESP-01S, Blue led is on GPIO2 and will flash even if debugging is enabled
//#define DEBUG
static Stream* debugPtr = NULL;  // local to this file

#include <TZ.h>  // for list of pre-generated TZ POSIX strings
// set a compiled default TZ here. Can be overrided/edited later by webpage.
#define DEFAULT_TZ TZ_Australia_Sydney

// see wifiConfig.cpp to set the AccessPoint ssid and password, default is ESP8266_wifiConfig / 1234567890

// max pin drive (source/HIGH) is 12mA. , max sink/LOW current is 20mA
// Drive capacity current of all GPIO pins total can be 16 x 12 mA.
// https://bbs.espressif.com/viewtopic.php?t=139 and ESP8266 spec for drive current
// NOTE: use 330R resistor to short GPIO0 to GND for programming to prevent shorting out GPIO0 output while being driven high
// then Reset to put into programming mode
// add 1000uF capacitor across pins 1(+ve) and 2(-ve) of the opto-isolator on the relay board to prevent the relay turning on momentarily on power up/reboot
int relayPin = 0;  // GPIO0 low to drive relay, i.e. sink
bool relayWasOn = false;
bool relayTurnedOnInAuto = false;

// Set up auto reboot to clean out any memory leaks
// if in AUTO reboot when turns off
// otherwise after ~24hrs reboot when power relay is OFF
millisDelay rebootIfOffDelay;
unsigned long REBOOT_IF_OFF_DELAY_MS = 24ul * 60 * 60 * 1000 + 10ul * 60 * 1000; // 24hrs + 10mins

static char _default_tz_[50]; // to hold the default TZ loaded from PROG memory by get_ntpSupport_DefaultTZ

// set a compiled default TZ here. Can be overrided/edited later by webpage.
// a method to give ntpSupport access to the default tz
const char *get_ntpSupport_DefaultTZ() { // magic name picked up by ntpSupport.cpp
  strncpy_P(_default_tz_, DEFAULT_TZ, sizeof(_default_tz_));
  _default_tz_[sizeof(_default_tz_) - 1] = '\0'; // terminate it incase DEFAULT_TZ was too long
  return _default_tz_; // TZ.h has #define TZ_Etc_GMTm0 PSTR("GMT0")  same as <+0>0
}

// uses ESP-LED define at the top of this file, 1 for ESP-01,  2 for ESP-01S
PinFlasher flasher(ESP_LED, true); // GPIO2, invert i.e. active LOW

// when using WiFi.config need to manually set the dns servers
// these are the GOOGLE public DNS servers
IPAddress dns1(8, 8, 8, 8);
IPAddress dns2(8, 8, 8, 4);

static millisDelay showTimeTimer;
static unsigned long SHOW_TIME_MS = 120000; // 2min

struct Wifi_CONFIG_storage_struct* wifiConfigPtr;

void setup() {
  // set relay pin
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, HIGH); // OFF
  relayWasOn = false;

  WiFi.persistent(false);
  WiFi.mode(WIFI_OFF); // force begin
  WiFi.setAutoConnect(false); // does not work for static ip see https://github.com/esp8266/Arduino/issues/2735
  WiFi.setAutoReconnect(true); // try to reconnect if we loose the connection
#ifdef DEBUG
  Serial.begin(115200);
  for (int i = 15; i > 0; i--) {
    Serial.print(i); Serial.print(' ');
    delay(1000);
  }
  Serial.println();
  debugPtr = initializeDebugOut(Serial); // only need to call this in setup
  // debugPtr = getDebugOut(); // other files call this to get debug stream
  debugPtr->println(" Debug running");
#endif
  initializeFS();
  if (debugPtr) {
    debugPtr->println(" File list before initializeWifiConfig");
    listDir("/");
  }

  wifiConfigPtr = initializeWifiConfig(); // goes into config mode called again below, also loads wifiConfig (perhaps with default settings)
  if (handleWifiConfig()) {
    return; // in config mode so skip rest of setup
  }
  if (debugPtr) {
    debugPtr->println(" File list after initializeWifiConfig");
    listDir("/");
  }
  cSFA(sfSSID, wifiConfigPtr->ssid);
  sfSSID.trim();
  if (sfSSID.isEmpty()) { // no SSID so start AP to set up wifi
    initializeWifiConfig(); //starts AP on second call
    // AP will exit and reboot after 5min so if un-attended
    // will try to connect to Wifi for 30sec ever 5 1/2mins
    return; // skip the rest of the setup
  }

  // ELSE
  // ======================= connect to router ===================
  // else connect to wifi and start webserver
  WiFi.mode(WIFI_STA);
  if (wifiConfigPtr->staticIP[0] != '\0') {
    IPAddress ip;
    bool validIp = ip.fromString(wifiConfigPtr->staticIP);
    if (validIp) {
      IPAddress gateway(ip[0], ip[1], ip[2], 1); // set gatway to ... 1
      IPAddress subnet_ip = IPAddress(255, 255, 255, 0);
      WiFi.config(ip, gateway, subnet_ip, dns1, dns2);
    } else {
      if (debugPtr) {
        debugPtr->print("Using DHCP, staticIP is invalid: "); debugPtr->println(wifiConfigPtr->staticIP);
      }
    }
  } // else leave as DHCP
  if (WiFi.status() != WL_CONNECTED) {
    WiFi.begin(wifiConfigPtr->ssid, wifiConfigPtr->password);
    flasher.setOnOff(100);
    if (debugPtr) {
      debugPtr->println("   Connecting to Wifi");
    }
  } else {
    if (debugPtr) {
      debugPtr->println("   Already connected to Wifi");
    }
  }
  // Wait for connection for 30sec
  unsigned long pulseCounter = 0;
  unsigned long maxCount = (30 * 1000) / 100; // delay below
  while ((WiFi.status() != WL_CONNECTED) && (pulseCounter < maxCount)) {
    pulseCounter++;
    delay(100); // short delay to call flasher.update() often
    flasher.update();
    if (debugPtr) {
      debugPtr->print(".");
    }
  }
  if (WiFi.status() != WL_CONNECTED) {    // start AP to fix up wifi connection
    initializeWifiConfig(); //starts AP on second call
    // AP will exit and reboot after 5min so if un-attended
    // will try to connect to Wifi for 30sec ever 5 1/2mins
    return; // skip the rest of the setup
  }
  if (debugPtr) {
    debugPtr->println("");
    debugPtr->print("Connected to ");
    debugPtr->println(wifiConfigPtr->ssid);
    debugPtr->print("IP address: ");
    debugPtr->println(WiFi.localIP());
  }
  startWebServer();
  initializeSNTP();
  showTimeTimer.start(SHOW_TIME_MS);
  showTimeDebug();
  // testPosix();
  rebootIfOffDelay.start(REBOOT_IF_OFF_DELAY_MS);
}

bool rebootWhenOff = false; // set true after 24hrs

void loop() {
  flasher.update();
  pushDebugOut(); // push as much buffereed debug data out as we can, does nothing if debug not initialized
  //  .. other code that MUST run all the time

  if (handleWifiConfig()) {
    flasher.setOnOff(1000); // ignored if already flashing at 1sec
    return;
  }

  // .. other stuf that will be skipped when in wifi config mode
  if (WiFi.status() != WL_CONNECTED) {
    flasher.setOnOff(100); // ignored if already flashing at 100ms
  } else {// (WiFi.status() == WL_CONNECTED)
    // check SNTP updates
    if (missedSNTPupdate()) { // missed a scheduled update
      flasher.setOnOff(100); // ignored if already flashing at 100ms
    } else  { // else wifi connected AND have got the scheduled ntp updates
      // so all OK make led solid ON
      flasher.setOnOff(PIN_ON); // ignored if already ON
    }
  }

  if (showTimeTimer.justFinished()) {
    showTimeTimer.repeat();
    if (debugPtr) {
      debugPtr->print("showTime");
    }
    showTimeDebug();
  }
  if (saveTZconfigIfNeeded()) {
    // saved TZ config changes
    relayTurnedOnInAuto = false; // skip reboot until next cycle
    rebootIfOffDelay.restart(); // delay reboot for 24hrs after changes
  }

  // set relay pin and reboot if turning off in auto
  if (isOn()) {
    digitalWrite(relayPin, LOW); // ON
    if (!relayWasOn) {
      relayWasOn = true;
      if (debugPtr) {
        debugPtr->println("Turned Relay On");
      }
      if (isAutoSelected()) {
        relayTurnedOnInAuto = true;
      } else {
        relayTurnedOnInAuto = false;
      }
    }
  } else {
    digitalWrite(relayPin, HIGH); // OFF
    if (relayWasOn) {
      relayWasOn = false;
      if (debugPtr) {
        debugPtr->println("Turned Relay Off");
      }
      if (isAutoSelected() && relayTurnedOnInAuto) { // is was ON in select Auto outside timer this reboots
        if (debugPtr) {
          debugPtr->println("is Auto going Off -- reboot");
          flushDebugOut();
        }
        // reboot when turned off in auto, to clear memory leaks (if any)
        ESP.restart();
      }
    }
    relayTurnedOnInAuto = false;
  }
  if (rebootIfOffDelay.justFinished()) {
    // reboot every 24hrs if off to clear memory leaks (if any)
    if (debugPtr) {
      debugPtr->println("24hr reboot triggered");
    }
    rebootWhenOff = true;
  }
  if (rebootWhenOff && (!isOn())) {
    // off so can reboot
    ESP.restart(); // see https://github.com/esp8266/Arduino/issues/1017  seems to work here
  }
}
