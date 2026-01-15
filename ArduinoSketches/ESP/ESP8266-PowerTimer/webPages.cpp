/**
   webPages.cpp
   by Matthew Ford,  2021/12/06
   (c)2021 Forward Computing and Control Pty. Ltd.
   NSW, Australia  www.forward.com.au
   This code may be freely used for both private and commerical use.
   Provide this copyright is maintained.

*/
#include "webPages.h"
#include "LittleFSsupport.h"
#include "ntpSupport.h"
#include "DebugOut.h"
#include "tzPosix.h"
#include <ESP8266WiFi.h>
#include <ESPAsyncTCP.h>
#include <ESPAsyncWebServer.h>

// normally DEBUG is commented out
//#define DEBUG
static Stream* debugPtr = NULL;  // local to this file

static AsyncWebServer server(80);
static void handleSetTime(AsyncWebServerRequest * request);
static void handleSetTimeOnOff(AsyncWebServerRequest * request);
static void handleSetTZstr(AsyncWebServerRequest * request);
static void handleResetDefaultTZstr(AsyncWebServerRequest * request);

static String correctedTZstr;  // empty if no problems
static String correctedTZstrDsc;
static String userInputTZstr;
static String setMsg;

// only handles +v numbers
static void print2digits(String &result, uint num) {
  if (num < 10) {
    result += '0';
  }
  result += num;
}

String minToHH_mm(int mins_in) {
  String rtn;
  int hrs = mins_in / 60;
  int mins = mins_in - (hrs * 60);
  print2digits(rtn, hrs);
  rtn += ':';
  print2digits(rtn, mins);
  return rtn;
}

static String processor(const String& var) {
  String rtnString = "";
  if (debugPtr) {
    debugPtr->print("processing %"); debugPtr->print(var); debugPtr->print("% = '");
  }
  if (var == "TZ_DESC") {
    String TZstr = getTZstr();
    struct posix_tz_data_struct tzdata;
    posixTZDataFromStr(TZstr, tzdata);
    buildPOSIXdescription(tzdata, rtnString);
    rtnString.replace("\n", "<br>");
  } else if (var == "TZ_STR") {
    if (setMsg.length()) {
      rtnString = correctedTZstr;
      correctedTZstr = ""; // finished  with this
    } else {
      rtnString = getTZstr();
    }
  } else if (var == "TZ_DESC_STR") {
    if (correctedTZstrDsc.length()) {
      rtnString = correctedTZstrDsc;
      correctedTZstrDsc = ""; // finished  with this
    } else {
      rtnString = getTZstr();
    }
    String TZstr = rtnString;
    struct posix_tz_data_struct tzdata;
    posixTZDataFromStr(TZstr, tzdata);
    buildPOSIXdescription(tzdata, rtnString);
    rtnString.replace("\n", "<br>");
  } else if (var == "TZ_CORRECTED") {
    if (userInputTZstr.length()) {
      rtnString = "Time Zone string has been cleaned up from<br>";
      rtnString += userInputTZstr;
      //   AEST-10AEDT,M10.1.0,M4.1.0/3
      rtnString += "<br>to";
      userInputTZstr = ""; // finished  with this
    }
  } else if (var == "TZ_STR_SET_CORRECTED") {
    rtnString = setMsg;
    setMsg = "";
  } else if (var == "HAVE_SNTP") {
    rtnString = String(haveSNTP());
  } else if (var == "OFF_SELECTED") {
    if (isOffSelected()) {
      rtnString = "buttonSelected";
    } // else blank
  } else if (var == "ON_SELECTED") {
    if (isOnSelected()) {
      rtnString = "buttonSelected";
    } // else blank
  } else if (var == "AUTO_SELECTED") {
    if (isAutoSelected()) {
      rtnString = "buttonSelected";
    } // else blank
  } else if (var == "TIMER_AUTO_SETTING") {
    if (isAutoSelected()) {
      rtnString = "1";
    } else {
      rtnString = "0";
    }
  } else if (var == "IS_ON") {
    if (isOn()) {
      rtnString = "is ON";
    } else {
      rtnString = "is OFF";
    }
  } else if (var == "TZ_VALUE") {
    rtnString = getTZvalue();
  } else if (var == "TIME") {
    rtnString = getCurrentTime_hhmm();
  } else
    // local time in unix sec
    if (var == "TIME_CURRENT_S") {
      rtnString =  String(getLocalTime_s());
    } else if (var == "TIME_CURRENT_HHMM") {
      rtnString =  String(getCurrentTime_hhmm());
    } else if (var == "TIME_ON") {
      int onTime_mins = getOnTime_mins();
      rtnString =  minToHH_mm(onTime_mins);
    } else if (var == "TIME_OFF") {
      int offTime_mins = getOffTime_mins();
      rtnString =  minToHH_mm(offTime_mins);
    } else if (var == "TIME_ON_SEC") {
      int onTime_mins = getOnTime_mins();
      rtnString =  String(onTime_mins * 60);
    } else if (var == "TIME_OFF_SEC") {
      int offTime_mins = getOffTime_mins();
      rtnString =  String(offTime_mins * 60);
    }
  if (debugPtr) {
    debugPtr->print(rtnString); debugPtr->println("'");
  }
  return rtnString;
}

const char* PARAM_MESSAGE = "message";
void notFound(AsyncWebServerRequest *request) {
  request->send(404, "text/plain", "Not found");
}

void startWebServer() {
#ifdef DEBUG
  debugPtr = getDebugOut();
#endif
  if (!initializeFS()) {
    if (debugPtr) {
      debugPtr->println("LittleFS failed to start");
    }
    return;
  }

  server.on("/", HTTP_GET, [](AsyncWebServerRequest * request) {
    request->send(LittleFS, "/index.html", String(), false, processor);
  });
  server.on("/index.html", HTTP_GET, [](AsyncWebServerRequest * request) {
    request->send(LittleFS, "/index.html", String(), false, processor);
  });
  server.on("/settz.html", HTTP_GET, [](AsyncWebServerRequest * request) {
    request->send(LittleFS, "/settz.html", String(), false, processor);
  });
  server.on("/setOnOffTimes.html", HTTP_GET, [](AsyncWebServerRequest * request) {
    request->send(LittleFS, "/setOnOffTimes.html", String(), false, processor);
  });
  server.on("/setTimeOnOff", HTTP_GET, [](AsyncWebServerRequest * request) {
    if (debugPtr) {
      debugPtr->println("/setTime");
    }
    handleSetTimeOnOff(request);
  });
  // Route to load style.css file
  server.on("/style.css", HTTP_GET, [](AsyncWebServerRequest * request) {
    request->send(LittleFS, "/style.css", "text/css");
  });
  server.on("/setTime", HTTP_GET, [](AsyncWebServerRequest * request) {
    if (debugPtr) {
      debugPtr->println("/setTime");
    }
    handleSetTime(request);
  });
  server.on("/setOff", HTTP_GET, [](AsyncWebServerRequest * request) {
    if (debugPtr) {
      debugPtr->println("/setOff");
    }
    setOff();
    request->redirect("/index.html");
  });
  server.on("/setOn", HTTP_GET, [](AsyncWebServerRequest * request) {
    if (debugPtr) {
      debugPtr->println("/setOn");
    }
    setOn();
    request->redirect("/index.html");
  });
  server.on("/setAuto", HTTP_GET, [](AsyncWebServerRequest * request) {
    if (debugPtr) {
      debugPtr->println("/setAuto");
    }
    setAuto();
    request->redirect("/index.html");
  });
  server.on("/setTZstr", HTTP_GET, [](AsyncWebServerRequest * request) {
    if (debugPtr) {
      debugPtr->println("/setTZstr");
    }
    handleSetTZstr(request);
  });

  server.on("/resetTZ", HTTP_GET, [](AsyncWebServerRequest * request) {
    if (debugPtr) {
      debugPtr->println("/resetTZ");
    }
    handleResetDefaultTZstr(request);
  });

  server.onNotFound(notFound);
  if (debugPtr) {
    debugPtr->println("Starting webserver");
  }
  server.begin();
}

// return true if valid input, result returned in mins_out var
// convert to mins
static bool convertHH_MMtoMins(SafeString &hh_mm, int& mins_out) {
  cSF(token, 20);
  int idx = 0;
  idx = hh_mm.stoken(token, idx, ':');
  int hr = 0; int mins = 0;
  if (token.toInt(hr) && (hr >= 0) && (hr <= 23)) {
    idx = hh_mm.stoken(token, idx, ':');
    if (token.toInt(mins) && (mins >= 0) && (mins <= 59)) {
      mins_out = hr * 60 + mins;
      if (debugPtr) {
        debugPtr->print("dayMins:"); debugPtr->print(mins_out); debugPtr->println();
      }
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

static void handleSetTZstr(AsyncWebServerRequest * request) {
  int headers = request->headers();
  if (debugPtr) {
    debugPtr->print(" Header Count: " + String(headers) + "\n");
  }
  if (debugPtr) {
    debugPtr->print("SetTZstr Data: ");
  }
  int params = request->params();
  if (debugPtr) {
    debugPtr->printf("params count: %d\n", params);
  }
  String newTZ;
  for (int i = 0; i < params; i++) {
    const AsyncWebParameter *p = request->getParam(i);
    if (strcmp(p->name().c_str(), "TZ_INPUT_STR") == 0) {
      userInputTZstr = "";
      correctedTZstr = "";
      correctedTZstrDsc = "";
      setMsg = "";
      if (debugPtr) {
        debugPtr->printf("Tz input string Value: %s\n", p->value().c_str());
      }
      String inputStr = p->value();
      inputStr.trim();
      String cleanStr = p->value();
      cleanUpPosixTZStr(cleanStr);
      if (inputStr != cleanStr) {
        userInputTZstr = inputStr;
        correctedTZstr = cleanStr;
        correctedTZstrDsc = cleanStr;
        setMsg = "Select the Set TZ String button again to set<br>this cleaned up time zone string";
      } else {
        newTZ = cleanStr;
        correctedTZstrDsc = cleanStr;
      }
    }
  }
  if (setMsg.length()) {
    request->redirect("/settz.html");
  } else {
    // set new tz
    setTZfromPOSIXstr(newTZ.c_str()); // cleans up and set save flag as well
    request->redirect("/index.html");
  }
}

static void handleResetDefaultTZstr(AsyncWebServerRequest * request) {
  resetDefaultTZstr();
  request->redirect("/index.html");
}

static void handleSetTime(AsyncWebServerRequest * request) {
  int headers = request->headers();
  if (debugPtr) {
    debugPtr->print(" Header Count: " + String(headers) + "\n");
  }
  cSF(sfTimeSetting, 20);
  if (debugPtr) {
    debugPtr->print("SetDatetime Data: ");
  }
  int params = request->params();
  if (debugPtr) {
    debugPtr->printf("params count: %d\n", params);
  }
  for (int i = 0; i < params; i++) {
    const AsyncWebParameter *p = request->getParam(i);
    if (strcmp(p->name().c_str(), "TIME") == 0) {
      if (debugPtr) {
        debugPtr->printf("Time Value: %s\n", p->value().c_str());
      }
      sfTimeSetting = p->value().c_str();
      int dayMins = 0;
      if (convertHH_MMtoMins(sfTimeSetting, dayMins)) {
        // get utc time
        time_t now = time(nullptr);
        struct tm* tmPtr = gmtime(&now);
        int utcDayMins = tmPtr->tm_hour * 60 + tmPtr->tm_min;
        int tzDiffMins = (utcDayMins - dayMins);
        if (debugPtr) {
          debugPtr->print("tzDiff :"); debugPtr->print(tzDiffMins); debugPtr->println();
        }
        // round to 5min
        int sign = 1;
        if (tzDiffMins < 0) {
          sign = -1;
        }
        int tzDiffMinRoundedUnsigned = (( tzDiffMins * sign * 60 + 150) / 300 * 300) / 60;
        if (debugPtr) {
          debugPtr->print("tzDiffRounded :"); debugPtr->print(tzDiffMinRoundedUnsigned); debugPtr->println();
        }
        int hr_offset = tzDiffMinRoundedUnsigned / 60;
        int min_offset = tzDiffMinRoundedUnsigned - hr_offset * 60;
        tzDiffMins = tzDiffMinRoundedUnsigned * sign;
        hr_offset *= sign;
        if (debugPtr) {
          debugPtr->print("offset "); debugPtr->print(hr_offset); debugPtr->print(':'); debugPtr->print(min_offset); debugPtr->println();
        }
        // offsets in range -12 < offset <= +12  i.e. -11:45 is the smallest offset and +12:00 is the largest
        //         mins in range -720 < offsetMin <= +720
        // e.g. LT (localTime) = 14:00,  UTC=04:00  tzoffset = +10:00
        //      LT = 08:00  UTC = 22:00  tzoffset =  -14 => <=-12 so add 24,  -14+24 = +10
        //      LT = 14:00  UTC = 22:00  tzoffset = -8:00
        //      LT = 20:00  UTC = 4:00   tzoffset = 16:00 => >12 so subtract 24,  16-24 = -8:00
        if (tzDiffMins <= -720) {
          tzDiffMins += (24 * 60);
        } else if (tzDiffMins > 720) {
          tzDiffMins -= (24 * 60);
        }
        sign = 1;
        if (tzDiffMins < 0) {
          sign = -1;
        }
        tzDiffMinRoundedUnsigned = tzDiffMins * sign;
        hr_offset = tzDiffMinRoundedUnsigned / 60;
        min_offset = tzDiffMinRoundedUnsigned - hr_offset * 60;
        hr_offset *= sign;
        if (debugPtr) {
          debugPtr->print("offset (+/-12)"); debugPtr->print(hr_offset); debugPtr->print(':'); debugPtr->print(min_offset); debugPtr->println();
        }
        setTZoffsetInMins(tzDiffMins); // update in min
      } // else error ignore
    }
  }
  request->redirect("/index.html");
}

static void handleSetTimeOnOff(AsyncWebServerRequest * request) {
  int headers = request->headers();
  if (debugPtr) {
    debugPtr->print(" Header Count: " + String(headers) + "\n");
  }
  cSF(sfTimeSetting, 20);
  if (debugPtr) {
    debugPtr->print("SetOnOFF Time: ");
  }
  int params = request->params();
  if (debugPtr) {
    debugPtr->printf("params count: %d\n", params);
  }
  int onMins = getOnTime_mins();
  int offMins = getOffTime_mins();
  for (int i = 0; i < params; i++) {
    const AsyncWebParameter *p = request->getParam(i);
    if (strcmp(p->name().c_str(), "TIME_ON") == 0) {
      if (debugPtr) {
        debugPtr->printf("Time ON Value: %s\n", p->value().c_str());
      }
      sfTimeSetting = p->value().c_str();
      if (convertHH_MMtoMins(sfTimeSetting, onMins)) {
      } // else error leave unchanged
    }
    if (strcmp(p->name().c_str(), "TIME_OFF") == 0) {
      if (debugPtr) {
        debugPtr->printf("Time OFF Value: %s\n", p->value().c_str());
      }
      sfTimeSetting = p->value().c_str();
      if (convertHH_MMtoMins(sfTimeSetting, offMins)) {
      } // else error leave unchanged
    }
  }
  saveOnOffTimes(onMins, offMins); // may be unchanged
  request->redirect("/index.html");
}
