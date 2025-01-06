/*
   LittleFSsupport.cpp
   by Matthew Ford,  2021/12/06
   (c)2021 Forward Computing and Control Pty. Ltd.
   NSW, Australia  www.forward.com.au
   This code may be freely used for both private and commerical use.
   Provide this copyright is maintained.

*/

#include "DebugOut.h"
#include "LittleFSsupport.h"

#define DEBUG

static Stream* debugPtr = NULL;  // local to this file
static bool FS_initialized = false;

/* ===================
r   Open a file for reading. If a file is in reading mode, then no data is deleted if a file is already present on a system.
r+  open for reading and writing from beginning

w   Open a file for writing. If a file is in writing mode, then a new file is created if a file doesn’t exist at all. 
    If a file is already present on a system, then all the data inside the file is truncated, and it is opened for writing purposes.
w+  open for reading and writing, overwriting a file

a   Open a file in append mode. If a file is in append mode, then the file is opened. The content within the file doesn’t change.
a+  open for reading and writing, appending to file
============== */

bool initializeFS() {
  if (FS_initialized) {
    return FS_initialized;
  }

#ifdef DEBUG
  debugPtr = getDebugOut();
#endif

  if (debugPtr) {
    debugPtr->println("Mount LittleFS");
  }
  if (!LittleFS.begin()) {
    if (debugPtr) {
      debugPtr->println("LittleFS mount failed");
    }
    return FS_initialized;
  }
  // else
  FS_initialized = true;
  listDir("/");
  return FS_initialized;
}

void listDir(const char * dirname) {
  if (!debugPtr) {
    return; // no where to send the output
  }
  listDir(dirname, *debugPtr);
}

void listDir(const char * dirname, Stream& out) {
  if (!FS_initialized) {
    out.println("FS not initialized yet");
    return;
  }

  out.printf("Listing directory: %s\n", dirname);
  Dir root = LittleFS.openDir(dirname);
  while (root.next()) {
    File file = root.openFile("r");
    out.print("  FILE: ");
    out.print(root.fileName());
    out.print("  SIZE: ");
    out.println(file.size());
    file.close();
  }
  out.println();
}

bool renameFile(const char * path1, const char * path2) {
  if (!FS_initialized) {
    if (debugPtr) {
      debugPtr->println("FS not initialized yet");
    }
    return false;
  }

  if (debugPtr) {
    debugPtr->printf("Renaming file %s to %s\n", path1, path2);
  }
  if (LittleFS.rename(path1, path2)) {
    if (debugPtr) {
      debugPtr->println("File renamed");
    }
    return true;
  } //else
  if (debugPtr) {
    debugPtr->println("Rename failed");
  }
  return false;
}

bool deleteFile(const char * path) {
  if (!FS_initialized) {
    if (debugPtr) {
      debugPtr->println("FS not initialized yet");
    }
    return false;
  }
  if (debugPtr) {
    debugPtr->printf("Deleting file: %s\n", path);
  }
  if (LittleFS.remove(path)) {
    if (debugPtr) {
      debugPtr->println("File deleted");
    }
    return true;
  }
  //else
  if (debugPtr) {
    debugPtr->println("Delete failed");
  }
  return false;
}
