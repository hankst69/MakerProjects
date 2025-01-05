/*
   nptSupport.cpp
   by Matthew Ford,  2021/12/06
   (c)2021 Forward Computing and Control Pty. Ltd.
   NSW, Australia  www.forward.com.au
   This code may be freely used for both private and commerical use.
   Provide this copyright is maintained.
*/

// see https://github.com/arduino/esp8266/blob/master/cores/esp8266/sntp-lwip2.c
// and https://github.com/arduino/esp8266/blob/master/cores/esp8266/time.c
// and https://github.com/esp8266/Arduino/issues/4637 etc

//   Note: carefully ESP8266 TZ env uses -ve tz offset, i.e. Sydney EST is +10 but TZ str is EST-10....

// timezone offsets range from  UTC−12:00 to UTC+14:00 in down to 15min segments
// so just use current time to set offset in range -12 to +12 this will be a day off for those tz that are +13 and +14
// +hhmm are SUBTRACTED!! fromo UTC to get local time so take UTC and subtract user's Current Time to get TZ envirmental variable tzoffset rounded to 15mins
// offsets in range -12 < offset <= +12  i.e. -11:45 is the smallest offset and +12:00 is the largest
// e.g. UTC  = 14:00,  LC (localTime) UTC=04:00  tzoffset = +10:00
//      UTC = 08:00  LC = 22:00  tzoffset =  -14 => <=-12 so add 24,  -14+24 = +10
//      UTC = 14:00  LC = 22:00  tzoffset = -8:00
//      UTC = 20:00  LC = 4:00   tzoffset = 16:00 => >12 so subtract 24,  16-24 = -8:00

#include "ntpSupport.h"
#include "DebugOut.h"
#include "LittleFSsupport.h"
#include "tzPosix.h"
#include <coredecls.h>                  // settimeofday_cb()
#include <millisDelay.h>
#include <time.h>                       // time() ctime()
#include <sys/time.h>                   // struct timeval
#include <sntp.h>                       // sntp_servermode_dhcp()
#include <IPAddress.h>

// define a weak getDefaultTZ method that can be defined elsewhere if you want to set a default TZ
const char* get_ntpSupport_DefaultTZ() __attribute__((weak));

// normally DEBUG is commented out
#define DEBUG
static Stream* debugPtr = NULL;  // local to this file

//struct timeval {
//  time_t      tv_sec;
//  suseconds_t tv_usec;
//};
// time_t is an intergal type that holds number of seconds elapsed since 00:00 hours, Jan 1, 1970 UTC (i.e., a unix timestamp).
// nullptr is a C++ null pointer literal which you can use anywhere you need to pass a null pointer.

//struct tm;
//Defined in header <time.h>
//Structure holding a calendar date and time broken down into its components.
//Member objects
//int tm_sec  seconds after the minute – [0, 61] (until C99)[0, 60] (since C99)[for leap second]
//int tm_min minutes after the hour – [0, 59]
//int tm_hour hours since midnight – [0, 23]
//int tm_mday day of the month – [1, 31]
//int tm_mon months since January – [0, 11]
//int tm_year years since 1900
//int tm_wday days since Sunday – [0, 6]
//int tm_yday days since January 1 – [0, 365]
//int tm_isdst Daylight Saving Time flag. The value is positive if DST is in effect, zero if not and negative if no information is available
//
//The Standard mandates only the presence of the aforementioned members in either order.
//The implementations usually add more data-members to this structure.

static millisDelay ntpUpdateCheck;
static const unsigned long NTP_NOT_UPDATED_MS = 70ul * 60 * 60 *1000; //70mins  or testing 10ul *1000; // 10sec

static bool needToSaveConfigFlag = false;


static const char timeZoneConfigFileName[] = "/timeZoneCfg.bin";  // binary file

//static const char tzdbURL[]  = "http://api.timezonedb.com/v2.1/get-time-zone?format=xml&by=position&key=";
//static const char latStr[] = "&lat=";
//static const char lngStr[] = "&lng=";

extern "C" int clock_gettime(clockid_t unused, struct timespec *tp);
static bool saveTimeZoneConfig(struct timeZoneConfig_struct& timeZoneConfig);
enum timerSettingEnum {OFF = 0, ON = 1, AUTO = 2};

struct timeZoneConfig_struct {
  time_t utcTime; // sec since 1/1/1970  = if not yet set by SNTP or timezonedb.com
  int onTime; // in min
  int offTime; // in min
  enum timerSettingEnum setting; // OFF, ON, AUTO, default OFF
  // POSIX tz str
  char tzStr[50]; // eg AEST-10AEDT,M10.1.0,M4.1.0/3  if empty then skip setting tzStr and just use user set local time and sntp utc to calculate tz offset
};
static struct timeZoneConfig_struct timeZoneConfig;

static bool haveSNTPresponse = false; // set true on first response
static bool haveSecondSNTPresponse = false; // got second one
static bool haveSNTPupdate = false;

static unsigned int getLocalTime_mins(); // hh:mm in mins

void setOff() {
  timeZoneConfig.setting = OFF;
  needToSaveConfigFlag = true;
}
void setOn() {
  timeZoneConfig.setting = ON;
  needToSaveConfigFlag = true;
}
void setAuto() {
  timeZoneConfig.setting = AUTO;
  needToSaveConfigFlag = true;
}

bool isOffSelected() {
  return timeZoneConfig.setting == OFF;
}
bool isOnSelected() {
  return timeZoneConfig.setting == ON;
}
bool isAutoSelected() {
  return timeZoneConfig.setting == AUTO;
}
// if setting is OFF always return false
// else returns true if and only if
// i) setting is ON
// OR setting is AUTO and
// a) have seen SNTP response since reboot
// b) Local time hh_mm is between onTime and offTime
// (if onTime == offTime stay off i.e. return false)
bool isOn() {
  if ((timeZoneConfig.setting == OFF) || (!haveSNTPresponse)) {
    return false;
  }
  if (timeZoneConfig.setting == ON) {
    return true;
  }
  // else AUTO
  if (!haveSNTPresponse) {
    return false;
  }
  if (timeZoneConfig.offTime == timeZoneConfig.onTime) {
    //    if (debugPtr) {
    //      debugPtr->println("equal On/off return false");
    //    }
    return false;
  }
  int current_mins = getLocalTime_mins();
  //  if (debugPtr) {
  //    debugPtr->print("current_mins:"); debugPtr->println(current_mins);
  //  }
  if (timeZoneConfig.offTime > timeZoneConfig.onTime) {
    // onTime then offTime
    if ((current_mins >= timeZoneConfig.onTime) && (current_mins < timeZoneConfig.offTime)) {
      //      if (debugPtr) {
      //        debugPtr->println("off>on and inside return true");
      //      }
      return true;
    } else {
      //      if (debugPtr) {
      //        debugPtr->println("off>on and outside return false");
      //      }
      return false;
    }
  } else {
    // offTime then onTime
    if ((current_mins >= timeZoneConfig.offTime) && (current_mins < timeZoneConfig.onTime)) {
      //      if (debugPtr) {
      //        debugPtr->println("off<on and inside return false");
      //      }
      return false;
    } else {
      //      if (debugPtr) {
      //        debugPtr->println("off<on and outside return true");
      //      }
      return true;
    }
  }
  return false;
}

String getTZvalue() { // the current tz value
  return String(timeZoneConfig.tzStr);
}


/** returns true if config saved */
bool saveTZconfigIfNeeded() { // saves any TZ config changes
  bool rtn = false;
  if (needToSaveConfigFlag) {
    saveTimeZoneConfig(timeZoneConfig);
    rtn = true;
    needToSaveConfigFlag = false;
  }
  return rtn;
}

void saveOnOffTimes(int onTime, int offTime) {// sets flag to save config
  timeZoneConfig.onTime = onTime;
  timeZoneConfig.offTime = offTime;
  needToSaveConfigFlag = true;
}

int getOnTime_mins() {
  return timeZoneConfig.onTime;
}
int getOffTime_mins() {
  return timeZoneConfig.offTime;
}


void setUTCconfigTime() {
  time_t now = time(nullptr);
  timeZoneConfig.utcTime = now;
};

// call cleanUpfirst
void setTZfromPOSIXstr(const char* tz_str) {
  time_t now = time(nullptr);
  timeZoneConfig.utcTime = now;
  strlcpy(timeZoneConfig.tzStr, tz_str, sizeof(timeZoneConfig.tzStr));
  if (debugPtr) {
    debugPtr->print("setTZfromPOSIXstr:"); debugPtr->println(timeZoneConfig.tzStr);
  }
  setTZ(tz_str);
  needToSaveConfigFlag = true;
}



// OPTIONAL: change SNTP update delay
// a weak function is already defined and returns 1 hour
uint32_t sntp_update_delay_MS_rfc_not_less_than_15000() {
  if (haveSecondSNTPresponse) {
    return (60UL * 60 * 60) * 1000; // 60mins
  } else {
    return 15000; // 15 sec
  }
}

// used when timeZoneConfigFileName file does not exist or is invalid
void setInitialTimeZoneConfig() {
  timeZoneConfig.utcTime = 0;
  timeZoneConfig.onTime = 0; // 00:00
  timeZoneConfig.offTime = 0;
  timeZoneConfig.setting = OFF; // default off
  timeZoneConfig.tzStr[0] = '\0'; // => GMT0 after cleanup
  if (get_ntpSupport_DefaultTZ) {
    strlcpy(timeZoneConfig.tzStr, get_ntpSupport_DefaultTZ(), sizeof(timeZoneConfig.tzStr));
  }
  // clean up
  cleanUpPosixTZStr(timeZoneConfig.tzStr, sizeof(timeZoneConfig.tzStr));
}

void resetDefaultTZstr() {
  char tzStr[sizeof(timeZoneConfig.tzStr)];
  tzStr[0] = '\0';
  if (get_ntpSupport_DefaultTZ) {
    strlcpy(tzStr, get_ntpSupport_DefaultTZ(), sizeof(tzStr));
  }
  setTZfromPOSIXstr(tzStr); // cleans up and set save flag as well
}

String getTZstr() {
  return String(timeZoneConfig.tzStr);
}

void printTimeZoneConfig(struct timeZoneConfig_struct & timeZoneConfig, Stream & out) {
  out.print("utcTime:");
  out.println(timeZoneConfig.utcTime);
  out.print("onTime:");
  out.println(timeZoneConfig.onTime);
  out.print("offTime:");
  out.println(timeZoneConfig.offTime);
  out.print("timerSetting:");
  out.println(timeZoneConfig.setting);
  out.print("tzStr:");
  out.println(timeZoneConfig.tzStr);
}


// load the last time saved before shutdown/reboot
// returns pointer to timeZoneConfig
static struct timeZoneConfig_struct* loadTimeZoneConfig() {
#ifdef DEBUG
  debugPtr = getDebugOut();
#endif
  setInitialTimeZoneConfig();
  if (!initializeFS()) {
    if (debugPtr) {
      debugPtr->println("FS failed to initialize");
    }
    return &timeZoneConfig; // returns default if cannot open FS
  }
  if (!LittleFS.exists(timeZoneConfigFileName)) {
    if (debugPtr) {
      debugPtr->print(timeZoneConfigFileName); debugPtr->println(" missing.");
    }
    saveTimeZoneConfig(timeZoneConfig);
    return &timeZoneConfig; // returns default if missing
  }
  // else load config
  File f = LittleFS.open(timeZoneConfigFileName, "r");
  if (!f) {
    if (debugPtr) {
      debugPtr->print(timeZoneConfigFileName); debugPtr->print(" did not open for read.");
    }
    LittleFS.remove(timeZoneConfigFileName);
    saveTimeZoneConfig(timeZoneConfig);
    return &timeZoneConfig; // returns default wrong size
  }
  if (f.size() != sizeof(timeZoneConfig)) {
    if (debugPtr) {
      debugPtr->print(timeZoneConfigFileName); debugPtr->print(" wrong size.");
    }
    f.close();
    saveTimeZoneConfig(timeZoneConfig);
    return &timeZoneConfig; // returns default wrong size
  }
  int bytesIn = f.read((uint8_t*)(&timeZoneConfig), sizeof(timeZoneConfig));
  if (bytesIn != sizeof(timeZoneConfig)) {
    if (debugPtr) {
      debugPtr->print(timeZoneConfigFileName); debugPtr->print(" wrong size read in.");
    }
    setInitialTimeZoneConfig(); // again
    f.close();
    saveTimeZoneConfig(timeZoneConfig);
    return &timeZoneConfig;
  }
  f.close();
  // else return settings
  // clean up tz and return
  cleanUpPosixTZStr(timeZoneConfig.tzStr, sizeof(timeZoneConfig.tzStr));
  if (debugPtr) {
    debugPtr->println("Loaded config");
    printTimeZoneConfig(timeZoneConfig, *debugPtr);
  }
  if (debugPtr) {
    String desc = timeZoneConfig.tzStr;
    struct posix_tz_data_struct posixTz;
    posixTZDataFromStr(desc,posixTz);
    buildPOSIXdescription(posixTz, desc);
    debugPtr->println("TZ description");
    debugPtr->println(desc);
  }

  return &timeZoneConfig;
}

// load the last time saved before shutdown/reboot
static bool saveTimeZoneConfig(struct timeZoneConfig_struct & timeZoneConfig) {
  if (!initializeFS()) {
    if (debugPtr) {
      debugPtr->println("FS failed to initialize");
    }
    return false;
  }
  // else save config
  File f = LittleFS.open(timeZoneConfigFileName, "w"); // create/overwrite
  if (!f) {
    if (debugPtr) {
      debugPtr->print(timeZoneConfigFileName); debugPtr->print(" did not open for write.");
    }
    return false; // returns default wrong size
  }
  setUTCconfigTime(); // update utc time
  int bytesOut = f.write((uint8_t*)(&timeZoneConfig), sizeof(struct timeZoneConfig_struct));
  if (bytesOut != sizeof(struct timeZoneConfig_struct)) {
    if (debugPtr) {
      debugPtr->print(timeZoneConfigFileName); debugPtr->print(" write failed.");
    }
    return false;
  }
  // else return settings
  f.close(); // no rturn
  if (debugPtr) {
    debugPtr->print(timeZoneConfigFileName); debugPtr->println(" config saved.");
    printTimeZoneConfig(timeZoneConfig, *debugPtr);
  }
  return true;
}

static void time_is_set(bool from_sntp /* <= this parameter is optional */) {
  if (debugPtr) {
    debugPtr->print("time_is_set from "); debugPtr->println(from_sntp ? "SNTP" : "USER");
    debugPtr->print("UTC   "); debugPtr->println(getUTCTime());
    debugPtr->print("Local "); debugPtr->println(getCurrentTime_hhmm());
  }

  if (from_sntp) {
    if (haveSNTPresponse) {
      haveSecondSNTPresponse = true;
    }
    haveSNTPresponse = true;
    haveSNTPupdate = true;
    ntpUpdateCheck.restart(); // do not timeout
    
    //    // save if not set yet
    //    if (timeZoneConfig.utcTime == 0) {
    //      timeZoneConfig.utcTime = time(nullptr);
    //      if (!saveTimeZoneConfig(timeZoneConfig)) {
    //        if (debugPtr) {
    //          debugPtr->print("saveTimeZoneConfig failed in time_is_set()"); debugPtr->println();
    //        }
    //      }
    //    }
    //    if (debugPtr) {
    //      debugPtr->print("from SNTP "); debugPtr->println();
    //    }
    //    // to sntp update so stop server now
    //    sntp_stop();
    //    if (debugPtr) {
    //      debugPtr->println(" === stopped SNTP ====");
    //    }
  }
}

/**
 * return false if missed sntp update and timer timed out.
 */
bool missedSNTPupdate() {
  if (ntpUpdateCheck.justFinished()) {
    haveSNTPupdate = false;
  }
  return !haveSNTPupdate;
}

// start sntp server and updates time and then stops server
void initializeSNTP() {
#ifdef DEBUG
  debugPtr = getDebugOut();
#endif
  if (debugPtr) {
    debugPtr->print("initializeSNTP"); debugPtr->println();
  }
  loadTimeZoneConfig(); // load timeZoneConfig global and cleans up tzStr

  // install callback - called when settimeofday is called (by SNTP or user)
  // once enabled (by DHCP), SNTP is updated every hour by default
  // ** optional boolean in callback function is true when triggered by SNTP **
  settimeofday_cb(time_is_set);
  static timeval tv;
  tv.tv_sec = timeZoneConfig.utcTime;
  tv.tv_usec = 0;
  settimeofday(&tv, nullptr);
  ntpUpdateCheck.start(NTP_NOT_UPDATED_MS); // start monitor
  // handle POSIX tz start
  cleanUpPosixTZStr(timeZoneConfig.tzStr, sizeof(timeZoneConfig.tzStr));
  configTime(timeZoneConfig.tzStr, "pool.ntp.org"); // << this starts sntp 0.pool.ntp.org does not not work??
  yield();
}

// only handles +v numbers
static void print2digits(String & result, uint num) {
  if (num < 10) {
    result += '0';
  }
  result += num;
}

String getHHMMss(struct tm * tmPtr) {
  String result; // hh:mm:ss
  print2digits(result, tmPtr->tm_hour);
  result += ':';
  print2digits(result, tmPtr->tm_min);
  result += ':';
  print2digits(result, tmPtr->tm_sec);
  return result;
}

String getHHMM(struct tm * tmPtr) {
  String result; // hh:mm:ss
  print2digits(result, tmPtr->tm_hour);
  result += ':';
  print2digits(result, tmPtr->tm_min);
  return result;
}

// local time HH:MM:ss in sec
static unsigned int getLocalTime_mins() {
  time_t now = time(nullptr);
  struct tm* tmPtr = localtime(&now);
  unsigned int rtn = (tmPtr->tm_hour);
  rtn = rtn * 60 + tmPtr->tm_min;
  return rtn;
}

int haveSNTP() {
  if (haveSNTPresponse) {
    return 1;
  }
  // else
  return 0;
}

// local time HH:MM:ss in sec
String getLocalTime_s() {
  time_t now = time(nullptr);
  struct tm* tmPtr = localtime(&now);
  uint32_t rtn = (tmPtr->tm_hour);
  rtn = rtn * 60 + tmPtr->tm_min;
  rtn = rtn * 60 + tmPtr->tm_sec;
  return String(rtn);
}

// small String <=10char) in ESP8266/ESP32 use built in char[]
String getCurrentTime_hhmm() {
  //  gettimeofday(&tv, nullptr);
  //  clock_gettime(0, &tp);
  time_t now = time(nullptr);
  struct tm* tmPtr = localtime(&now);
  return getHHMM(tmPtr);
}

String getUTCTime() {
  //  gettimeofday(&tv, nullptr);
  //  clock_gettime(0, &tp);
  time_t now = time(nullptr);
  struct tm* tmPtr = gmtime(&now);
  return getHHMMss(tmPtr);
}

#define PTM(w) \
  debugPtr->print(" " #w "="); \
  debugPtr->print(tm->tm_##w);

void printTm(const char* what, const tm * tm) {
  debugPtr->print(what);
  PTM(isdst); PTM(yday); PTM(wday);
  PTM(year);  PTM(mon);  PTM(mday);
  PTM(hour);  PTM(min);  PTM(sec);
}

void showTimeDebug() {
  if (!debugPtr) {
    return;
  }
  debugPtr->println("ShowTimeDebug");
  timeval tv;
  timespec tp;
  time_t now;
  uint32_t now_ms, now_us;

  gettimeofday(&tv, nullptr);
  clock_gettime(0, &tp);
  now = time(nullptr);
  now_ms = millis();
  now_us = micros();

  debugPtr->println();
  printTm("localtime:", localtime(&now));
  debugPtr->println();
  printTm("gmtime:   ", gmtime(&now));
  debugPtr->println();

  // time from boot
  debugPtr->print("clock:     ");
  debugPtr->print((uint32_t)tp.tv_sec);
  debugPtr->print("s + ");
  debugPtr->print((uint32_t)tp.tv_nsec);
  debugPtr->println("ns");

  // time from boot
  debugPtr->print("millis:    ");
  debugPtr->println(now_ms);
  debugPtr->print("micros:    ");
  debugPtr->println(now_us);

  // EPOCH+tz+dst
  debugPtr->print("gtod:      ");
  debugPtr->print((uint32_t)tv.tv_sec);
  debugPtr->print("s + ");
  debugPtr->print((uint32_t)tv.tv_usec);
  debugPtr->println("us");

  // EPOCH+tz+dst
  debugPtr->print("time:      ");
  debugPtr->println((uint32_t)now);

  // timezone and demo in the future
  debugPtr->printf("timezone:  %s\n", getenv("TZ") ? : "(none)");

  // human readable
  debugPtr->print("ctime:     ");
  debugPtr->print(ctime(&now));

  // lwIP v2 is able to list more details about the currently configured SNTP servers
  for (int i = 0; i < SNTP_MAX_SERVERS; i++) {
    IPAddress sntp = *sntp_getserver(i);
    const char* name = sntp_getservername(i);
    if (sntp.isSet()) {
      debugPtr->printf("sntp%d:     ", i);
      if (name) {
        debugPtr->printf("%s (%s) ", name, sntp.toString().c_str());
      } else {
        debugPtr->printf("%s ", sntp.toString().c_str());
      }
      debugPtr->printf("- IPv6: %s - Reachability: %o\n",
                       sntp.isV6() ? "Yes" : "No",
                       sntp_getreachability(i));
    }
  }

  debugPtr->println();

  // show subsecond synchronisation
  timeval prevtv;
  time_t prevtime = time(nullptr);
  gettimeofday(&prevtv, nullptr);

  while (true) {
    gettimeofday(&tv, nullptr);
    if (tv.tv_sec != prevtv.tv_sec) {
      debugPtr->printf("time(): %u   gettimeofday(): %u.%06u  seconds are unchanged\n",
                       (uint32_t)prevtime,
                       (uint32_t)prevtv.tv_sec, (uint32_t)prevtv.tv_usec);
      debugPtr->printf("time(): %u   gettimeofday(): %u.%06u  <-- seconds have changed\n",
                       (uint32_t)(prevtime = time(nullptr)),
                       (uint32_t)tv.tv_sec, (uint32_t)tv.tv_usec);
      break;
    }
    prevtv = tv;
    delay(1);
  }

  debugPtr->println();
}
