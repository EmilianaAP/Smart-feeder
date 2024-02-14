#include <Wire.h>
#include <RTClib.h>
#include <WiFiManager.h>
#include <SPI.h>
#include <PubSubClient.h>
#include <WifiUdp.h>
#include <NTPClient.h>
#include <TimeLib.h>

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

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "asia.pool.ntp.org", 7200, 60000);

char t[32];
byte last_second, second_, minute_, hour_, day_, month_;
int year_;


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

  timeClient.begin();  // Start NTP client
  timeClient.update();  // Retrieve current epoch time from NTP server
  unsigned long unix_epoch = timeClient.getEpochTime();  // Get epoch time
  rtc.adjust(DateTime(unix_epoch));  // Set RTC time using NTP epoch time

  DateTime now = rtc.now();
  last_second = now.second();
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  timeClient.update();  // Update time from NTP server
  unsigned long unix_epoch = timeClient.getEpochTime();  // Get current epoch time


  second_ = second(unix_epoch);  // Extract second from epoch time
  if (last_second != second_)
  {
    minute_ = minute(unix_epoch);  // Extract minute from epoch time
    hour_ = hour(unix_epoch);  // Extract hour from epoch time
    day_ = day(unix_epoch);  // Extract day from epoch time
    month_ = month(unix_epoch);  // Extract month from epoch time
    year_ = year(unix_epoch);  // Extract year from epoch time


    // Format and print NTP time on Serial monitor
    sprintf(t, "NTP Time: %02d:%02d:%02d %02d/%02d/%02d", hour_, minute_, second_, day_, month_, year_);
    Serial.println(t);


    DateTime rtcTime = rtc.now();  // Get current time from RTC


    // Format and print RTC time on Serial monitor
    sprintf(t, "RTC Time: %02d:%02d:%02d %02d/%02d/%02d", rtcTime.hour(), rtcTime.minute(), rtcTime.second(), rtcTime.day(), rtcTime.month(), rtcTime.year());
    Serial.println(t);


    // Compare NTP time with RTC time
    if (rtcTime == DateTime(year_, month_, day_, hour_, minute_, second_))
    {
      Serial.println("Time is synchronized!");  // Print synchronization status
    }
    else
    {
      Serial.println("Time is not synchronized!");  // Print synchronization status
    }


    last_second = second_;  // Update last second
  }


  delay(1000);  // Delay for 1 second before the next iteration
}
