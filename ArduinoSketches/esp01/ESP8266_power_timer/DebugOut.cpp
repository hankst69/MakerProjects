/*
   DebugOut.cpp
   by Matthew Ford,  2021/12/06
   (c)2021 Forward Computing and Control Pty. Ltd.
   NSW, Australia  www.forward.com.au
   This code may be freely used for both private and commerical use.
   Provide this copyright is maintained.

*/
#include "DebugOut.h"

static HardwareSerial* DebugPtr = NULL;
static const size_t DEBUG_BUFFER_SIZE = 2048;
static uint8_t debugBuffer[DEBUG_BUFFER_SIZE];
static BufferedOutput outputBuffer = BufferedOutput(DEBUG_BUFFER_SIZE, debugBuffer, DROP_IF_FULL, true); // all or nothing

// ---------------- Serial Debugging
static bool SerialStarted = false;

/**
 force any buffered output to completely written now.
 This blocks until all output written
 */
void flushDebugOut() {
  if (DebugPtr) {
    outputBuffer.flush();
  }
}

/**
  tickles the buffered output to write some more data
*/
void pushDebugOut() {
  if (DebugPtr) {
    outputBuffer.nextByteOut();
  }
}

BufferedOutput* getDebugOut() {
  return &outputBuffer;
}

/**
  initializes debug Stream if not already done
  Safe to call more the once.
  Connect Serial via a buffered outputStream
  */
BufferedOutput* initializeDebugOut(HardwareSerial &out) {
  if (!SerialStarted) {
  	DebugPtr = &out;
    outputBuffer.connect(out);
    SerialStarted = true;
  }
  return &outputBuffer;
}
