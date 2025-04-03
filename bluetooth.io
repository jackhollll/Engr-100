#include <SoftwareSerial.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#include <MQ135.h>

// Feather HUZZAH ESP8266 note: use pins 3, 4, 5, 12, 13 or 14 --
// Pin 15 can work but DHT must be disconnected during program upload.

// Uncomment the type of sensor in use:
//#define DHTTYPE    DHT11     // DHT 11
#define DHTTYPE    DHT11     // DHT 22 (AM2302)
//#define DHTTYPE    DHT21     // DHT 21 (AM2301)

// See guide for details on sensor wiring and usage:
//   https://learn.adafruit.com/dht/overview



uint32_t delayMS;
SoftwareSerial HM10(2, 3); // RX= 2, TX= 3
char appData;
String inData = "";
const uint8_t outPins[4] = {0, 1, 4, 5};  // Output pins
const uint8_t inPins[4] = {6, 7, 8, 9}; // Input pins
const uint8_t sensorDPins[4] = {10, 11, 12, 13}; // Define input pins
const uint8_t sensorAPins[4] = {A0, A1, A2, A3}; // Define input pins

//DHT_Unified dht2(10, DHTTYPE);
//DHT_Unified dht2(sensorDPins[1], DHTTYPE);
//DHT_Unified dht3(sensorDPins[2], DHTTYPE);
//DHT_Unified dht4(sensorDPins[3], DHTTYPE);

float temperature = 21.0; // Assume current temperature. Recommended to measure with DHT22
float humidity = 25.0; // Assume current humidity. Recommended to measure with DHT22

DHT_Unified dht[4] =
{
  {sensorDPins[0], DHTTYPE},
  {sensorDPins[1], DHTTYPE},
  {sensorDPins[2], DHTTYPE},
  {sensorDPins[3], DHTTYPE}
};

MQ135 mq135[4] =
{
  {A0},
  {A1},
  {A3},
  {A4}
};

void setup() {
  HM10.begin(9600);
  for (int i = 0; i < 4; i++) {
    pinMode(outPins[i], OUTPUT);
    pinMode(inPins[i], INPUT_PULLUP);  // Stabilize input readings
  }
  for (int i = 0; i < 4; i++) {
      pinMode(sensorDPins[i], INPUT); // Use internal pull-up resistors
  }
  // Print temperature sensor details.
  dht[0].begin();
  dht[1].begin();
  dht[2].begin();
  dht[3].begin();
}


#define NO_SENSOR -1
#define SENSOR_OVERLOAD -2

void loop() {
  String output;
  for (int port = 0; port < 4; port++)
  {
    int sensor = NO_SENSOR;

    // Figures out which type sensor is in the port
    for (int i = 0; i < 4; i++) {
      digitalWrite(outPins[i], HIGH);
      delay(20);  // Allow signal to stabilize
  
      String outputLine = "";  // Store detected signals in a string

      bool detected = false;
      if (digitalRead(inPins[port]) == HIGH)
      {
        if (sensor != NO_SENSOR)
        {
          sensor = SENSOR_OVERLOAD;
        }
        else
        {
          sensor = i;
        }
      }
      digitalWrite(outPins[i], LOW);
      delay(20);  // Ensure proper switching
    }

    switch (sensor)
    {
      case 0:
        {
          sensors_event_t event;
          dht[port].temperature().getEvent(&event);
          output += ("Sensor Port " + String(port+1) + ": Humidity sensor: " + String(event.relative_humidity) + "\n");
        }
        break;
      case 1:
        {
          int sensorValue = analogRead(sensorAPins[port]);
          int outputValue = map(sensorValue, 0, 1023, 100, 0);
          output += ("Sensor Port " + String(port+1) + ": Soil Moisture: " + String(outputValue) + "\n");
        }
        break;
      case 2:
        {
          int sensorValue = analogRead(sensorAPins[port]);
          int outputValue = max(map(sensorValue, 0, 1023, 100, 0), 0);
          output += ("Sensor Port " + String(port+1) + ": Light: " + String(sensorValue) + "\n");
        }
        break;
      case 3:
        {
          float PPM = mq135[port].getRZero();
          output += ("Sensor Port " + String(port+1) + ": Air ppm: " + String(PPM) + "\n");
        }
        break;
      case NO_SENSOR:
        {
          output += ("Sensor Port " + String(port+1) + ": No Sensor Selected!\n");
        }
        break;
      case SENSOR_OVERLOAD:
        {
          output += ("Sensor Port " + String(port+1) + ": No Sensor Selected!\n");
        }
        break;
    }
  }
  HM10.println(output);
  delay(1000);
}
