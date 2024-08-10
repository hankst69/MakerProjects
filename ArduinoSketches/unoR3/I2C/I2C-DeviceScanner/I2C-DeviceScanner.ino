# include "Wire.h"

void setup()
{
  Wire.begin(1000);
  Wire.setTimeout(500);
  //Wire.setClock(10000L);  

  Serial.begin(115200);
  delay(1000);
  Serial.println();
  Serial.println("I2C Scanner");

  //Serial.println();
  //Serial.println("Test Global Broadcast (address 0x00)");
  //Wire.beginTransmission(0);
  //byte i2cError = Wire.endTransmission();
  //if (i2cError == 0)
  //{
  //  Serial.println("I2C Gerät gefunden - Adresse: 0x00");
  //}
  //delay(2000);
}

void loop()
{
  uint8_t Fehler, Adresse;
  int Geraete = 0;
  Serial.println("Starte Scanvorgang");

  for (Adresse = 1; Adresse < 127; Adresse++)
  {
    // Übertragung starten
    Wire.beginTransmission(Adresse);

    // wenn die Übertragung beendet wird
    Fehler = Wire.endTransmission();

    if (Fehler == 0)
    {
      Serial.print("I2C Gerät gefunden - Adresse: 0x");
      if (Adresse < 16) Serial.print("0");
      Serial.print(Adresse, HEX);
      Serial.println();
      Geraete++;

      //https://ww1.microchip.com/downloads/en/DeviceDoc/41291D.pdf
      //https://forum.arduino.cc/t/does-i2c-need-pull-up-resistors-on-scl-and-sda/184138
      //https://docs.arduino.cc/learn/communication/wire/
      //https://hartmut-waller.info/arduinoblog/i2c/
      //https://wolles-elektronikkiste.de/i2c-schnittstellen-des-esp32-nutzen
      //https://www.arduino.cc/reference/en/libraries/adafruit-busio/
      uint8_t numBytes = 4;
      Wire.requestFrom(Adresse, numBytes); // request 6 bytes from peripheral device #8
      while (Wire.available()) {    // peripheral may send less than requested
        //char c = Wire.read();       // receive a byte as character
        //Serial.print(c);            // print the character
        int data = Wire.read();
        if (data < 16) Serial.print("0");
        Serial.print(data, HEX);
        Serial.println();        
      }
    }
  }
  
  if (Geraete == 0) {
    Serial.println("Keine I2C Geräte gefunden\n");
  } else {
    Serial.println("Scanvorgang abgeschlossen");
  }

  delay(10000);
}