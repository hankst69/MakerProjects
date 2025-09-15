#ifndef _WIFI_CONFIG_H
#define _WIFI_CONFIG_H
/*   
   wifiConfig.h
   by Matthew Ford,  2021/12/06
   (c)2021 Forward Computing and Control Pty. Ltd.
   NSW, Australia  www.forward.com.au
   This code may be freely used for both private and commerical use.
   Provide this copyright is maintained.
*/
const int MAX_SSID_LEN = 32;
const int MAX_PASSWORD_LEN = 64;
const int MAX_STATICIP_LEN = 40;

struct Wifi_CONFIG_storage_struct {
  char ssid[MAX_SSID_LEN + 1]; // WIFI ssid + null
  char password[MAX_PASSWORD_LEN + 1]; // WiFi password,  if empyt use OPEN, else use AUTO (WEP/WPA/WPA2) + null
  char staticIP[MAX_STATICIP_LEN + 1]; // staticIP, if empty use DHCP + null
};


struct Wifi_CONFIG_storage_struct* initializeWifiConfig(); // start AP for config call handleWifiConfig() from loop to handle web page results
bool handleWifiConfig();
void clearRebootFile();
/* e.g.
void setup() {
  Serial.begin(115200);
  .. setup stuff that MUST be done always 
  struct Wifi_CONFIG_storage_struct* wifiConfigPtr = initializeWifiConfig(); // go into config mode if double reboot
  if (handleWifiConfig()) {
   return; // in config mode so skip rest of setup
  }
  ... other setup stuff that should be skipped if in wifi configMode
  // else use values in wifiConfigPtr->
}

void loop() {
  pushDebugOut(); // push as much buffereed debug data out as we can, does nothing if debug not initialized
  .. other code that MUST run all the time
 if (handleWifiConfig()) {
  return;
 }
 .. other stuf that will be skipped when in wifi config mode
}
**/
#endif
