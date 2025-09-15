#ifndef _NTP_H
#define _NTP_H
/*   
   nptSupport.h
   by Matthew Ford,  2021/12/06
   (c)2021 Forward Computing and Control Pty. Ltd.
   NSW, Australia  www.forward.com.au
   This code may be freely used for both private and commerical use.
   Provide this copyright is maintained.
*/

#include <Arduino.h>
void initializeSNTP(); // initializes and starts SNTP server, stops it after first update
String getTZstr(); // get the current tz string
void resetDefaultTZstr(); // reset tz to default one
void showTimeDebug();
int haveSNTP(); // returns 1 if have sntp response else 0
String getCurrentTime_hhmm(); // returns local time as hh:mm
String getUTCTime(); // returns UTC time as hh:mm:ss
String getLocalTime_s(); // local time HH:MM:ss in sec
String getTZvalue(); // the current tz value
bool isOn(); // returns true if ON else false
bool isOffSelected();
bool isOnSelected();
bool isAutoSelected();
void setOff();
void setOn();
void setAuto();
bool missedSNTPupdate();

void setTZfromPOSIXstr(const char* tz_str); // sets flag to save config
bool saveTZconfigIfNeeded(); // saves any TZ config changes returns true if save happened
void saveOnOffTimes(int onTime, int offTime);// sets flag to save config
int getOnTime_mins();
int getOffTime_mins();
#endif
