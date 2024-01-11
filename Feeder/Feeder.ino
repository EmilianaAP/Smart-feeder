#include <Wire.h>
#include <RTClib.h>
#include <WiFiManager.h>
#include <SPI.h>
#include <PubSubClient.h>

RTC_DS3231 rtc;
IPAddress server(34, 122, 107, 45);

void callback(char* topic, byte* payload, unsigned int length) {
  String response;

  for (int i = 0; i < length; i++)
  {
    response += (char)payload[i];
  }
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  Serial.println(response);
}

WiFiClient espClient;
PubSubClient client(server, 1883, callback, espClient);

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("arduinoClient")) {
      Serial.println("connected");
      client.publish("Feeder","hello world");
      client.subscribe("Topic_2");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  Wire.begin(5,4);
  Serial.begin(115200);

  if (! rtc.begin()) {
    Serial.println("RTC module is NOT found");
    Serial.flush();
    while (1);
  }

  WiFiManager wm;
  bool res;
  res = wm.autoConnect("AutoConnectAP","password");

  if(!res) {
      Serial.println("Failed to connect");
  } 
  else {  
      Serial.println("connected...yeey :)");
  }


  if (client.connect("arduinoClient", "Erix", "!!SmartPet!!")) {
    client.publish("outTopic","hello world");
    client.subscribe("inTopic");
  }

  rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));

  delay(1500);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  DateTime now = rtc.now();
  Serial.print("ESP32 RTC Date Time: ");
  Serial.print(now.year(), DEC);
  Serial.print('/');
  Serial.print(now.month(), DEC);
  Serial.print('/');
  Serial.print(now.day(), DEC);
  Serial.print(' ');
  Serial.print(now.hour(), DEC);
  Serial.print(':');
  Serial.print(now.minute(), DEC);
  Serial.print(':');
  Serial.println(now.second(), DEC);

  delay(10000);
}
