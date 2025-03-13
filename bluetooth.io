#include <SoftwareSerial.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

#define SENSORD1 13
// Feather HUZZAH ESP8266 note: use pins 3, 4, 5, 12, 13 or 14 --
// Pin 15 can work but DHT must be disconnected during program upload.

// Uncomment the type of sensor in use:
//#define DHTTYPE    DHT11     // DHT 11
#define DHTTYPE    DHT22     // DHT 22 (AM2302)
//#define DHTTYPE    DHT21     // DHT 21 (AM2301)

// See guide for details on sensor wiring and usage:
//   https://learn.adafruit.com/dht/overview

DHT_Unified dht2(SENSORD1, DHTTYPE);

uint32_t delayMS;
SoftwareSerial HM10(2, 3); // RX= 2, TX= 3
char appData;
String inData = "";
const int outPins[4] = {4, 5, 6, 7};  // Output pins
const int inPins[4] = {8, 9, 10, 11}; // Input pins
const int sensorPins[4] = {10, 11, 12, 13}; // Define input pins
void setup() {
  Serial.begin(9600);
  Serial. println("HM10 serial started at 9600");
  HM10.begin(9600);
  for (int i = 0; i < 4; i++) {
    pinMode(outPins[i], OUTPUT);
    pinMode(inPins[i], INPUT_PULLUP);  // Stabilize input readings
  }
  for (int i = 0; i < 4; i++) {
      pinMode(sensorPins[i], INPUT_PULLUP); // Use internal pull-up resistors
  }
  Serial.println(F("DHTxx Unified Sensor Example"));
  // Print temperature sensor details.
  dht2.begin();
  sensor_t sensor;
  dht2.temperature().getSensor(&sensor);
  dht2.humidity().getSensor(&sensor);
}
void loop() {
  HM10.listen();
  while (HM10.available() > 0) {
    appData = HM10.read();
    inData = String(appData);
    Serial.write(appData);
  }
  if (Serial.available()) {
    delay(10);
    HM10.write(Serial.read());
  }
  for (int i = 0; i < 4; i++) {
        digitalWrite(outPins[i], HIGH);
        delay(20);  // Allow signal to stabilize

        String outputLine = "";  // Store detected signals in a string

       // for (int j = 0; j < 4; j++) {  // Check all input pins
            bool detected = false;
            for (int k = 0; k < 5; k++) {  // Read multiple times for stability
                if (digitalRead(inPins[0]) == HIGH) {
                    detected = true;
                }
                delay(5);
            }

            if (detected) {
                outputLine += "Out " + String(outPins[i]) + " -> In " + String(inPins[0]) + " | ";
                switch (i)
                {
                  case 0:
                    sensors_event_t event;
                    dht2.temperature().getEvent(&event);
                    Serial.println("Humidity sensor: " + String(event.relative_humidity));
                    break;
                  case 1:
                    break;
                  case 2:
                    break;
                  case 3:
                    break;
                }
            }
       //}

        digitalWrite(outPins[i], LOW);
        delay(20);  // Ensure proper switching

        if (outputLine.length() > 0) {
            Serial.println(outputLine);  // Print only if something was detected
        }
    }
  // String sensorOutputLine = "";
  //   for (int i = 0; i < 4; i++) {
  //       int sensorValue = digitalRead(sensorPins[i]); // Read sensor value
  //       sensorOutputLine += "Pin " + String(sensorPins[i]) + ": " + String(sensorValue) + " | ";
  //   }

  //   Serial.println(sensorOutputLine); // Print sensor values in one line
}
