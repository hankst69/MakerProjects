#ifndef _DEBUG_OUT_H
#define _DEBUG_OUT_H

/**
   DebugOut.h
   by Matthew Ford,  2021/12/06
   (c)2021 Forward Computing and Control Pty. Ltd.
   NSW, Australia  www.forward.com.au
   This code may be freely used for both private and commerical use.
   Provide this copyright is maintained.
*/
#include <Arduino.h>
#include "BufferedOutput.h" 

#define pfod_MAYBE_UNUSED(x) (void)(x)

BufferedOutput* initializeDebugOut(HardwareSerial &out); // note hardware serial NOT Stream
BufferedOutput* getDebugOut();
void flushDebugOut();
void pushDebugOut(); // call this often to output buffered debug data

#endif
