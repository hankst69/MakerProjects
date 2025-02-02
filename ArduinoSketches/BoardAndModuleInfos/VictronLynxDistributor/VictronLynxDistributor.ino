
//https://www.instructables.com/How-to-use-the-ESP8266-01-pins/
/*
How to reprogram when using GPIO0 as an output
Note: GPIO0 is needs to be grounded to get into programming mode. If you sketch is driving it high, grounding it can damage you ESP8266 chip. The safe way to reprogram the ESP8266 when your code drives the GPIO0 output is to :-
a) Power down the board
b) short GPIO0 to gnd
c) power up the board which goes into program mode due to the short on GPIO0
d) remove the short from GPIO0 so you don't short out the output when the program runs
e) reprogram the board
f) power cycle the board if necessary.
*/

void setup() 
{
}
 
void loop() 
{
}