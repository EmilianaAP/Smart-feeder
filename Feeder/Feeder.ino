#ifdef ESP32
  #include <WiFi.h>
#else
  #include <ESP8266WiFi.h>
#endif

#include <Wire.h>
#include <RTClib.h>
#include <WiFiManager.h>
#include <PubSubClient.h>
#include <WifiUdp.h>
#include <NTPClient.h>
#include <TimeLib.h>
#include <TMCStepper.h>
#include <SPI.h>
#include <SharpIR.h>


// Pin Definitions
#define SW_RX       17 // TMC2208/TMC2224 SoftwareSerial receive pin
#define SW_TX       16 // TMC2208/TMC2224 SoftwareSerial transmit pin
#define EN_PIN      18 // LOW: Driver enabled. HIGH: Driver disabled
#define STEP_PIN    5  // Step on rising edge
#define DIR_PIN     4  // Step on rising edge

// Constants
#define R_SENSE           0.11f // R_SENSE for current calc.
#define STALL_VALUE       2     // [0..255]
#define DRIVER_ADDRESS    0b00  // TMC2209 Driver address according to MS1 and MS2
#define SERIAL_PORT       Serial2 // TMC2208/TMC2224 HardwareSerial port
#define ir                34 // ir: the pin where your sensor is attached
#define model             430 // model: an int that determines your sensor:  1080 for GP2Y0A21Y
#define ClientID          WiFi.macAddress()
//                                            20150 for GP2Y0A02Y
//                                            (working distance range according to the datasheets)

// Function prototypes
void callback(char* topic, byte* payload, unsigned int length);
void setupPins();
void setupSerial();
void setupRTC();
void setupWiFi();
void setupMQTT();
void setupStepper();
void onTimer();
void reconnect();
void controlStepper();
void handleMQTT();
void setupInterrupt();
int getDistance();

// Objects and Variables
RTC_DS3231 rtc;
IPAddress server(34, 122, 107, 45);
WiFiClient espClient;
PubSubClient client(server, 1883, callback, espClient);
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "europe.pool.ntp.org", 0, 60000);
hw_timer_t *timer1 = NULL;
TMC2209Stepper driver(&SERIAL_PORT, R_SENSE, DRIVER_ADDRESS);
SharpIR SharpIR(ir, model);

// Movement control variables
unsigned long moveStartTime = 0;
unsigned long lastMealTime = millis();
bool startMotor = false; // Flag to start motor based on MQTT command
bool startedMotor = false;
byte storedHour = 0;
byte storedMinute = 0;

// Callback function for MQTT messages
void callback(char* topic, byte* payload, unsigned int length) {
  String response;
  for (int i = 0; i < length; i++) {
    response += (char)payload[i];
  }

  //Used for debugging to see if the right messages arrive through the mqtt
  /*Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  Serial.println(response);*/

  if (strcmp(topic, "time-to-feed") == 0) {
    if (response.equals("start")) {
      unsigned long currentTime = millis();
      if (currentTime - lastMealTime >= 60000) {
        //Serial.println("Start");
        startMotor = true; // Set flag to start motor
        moveStartTime = currentTime; // Record the start time
        lastMealTime = currentTime; // Update the last meal time
      } else {
        //Serial.println("Meal skipped: Less than 1 minute since last meal.");
      }
    } else {
      // Parse the time in HH:MM format
      int pos = response.indexOf(':');
      if (pos > 0 && pos < response.length() - 1) {
        storedHour = response.substring(0, pos).toInt();
        storedMinute = response.substring(pos + 1).toInt();
      }
    }
  }
}

void setup() {
  setupPins();
  setupSerial();
  setupRTC();
  setupWiFi();
  setupMQTT();

  timeClient.begin();  
  timeClient.update();  
  unsigned long unix_epoch = timeClient.getEpochTime();  
  rtc.adjust(DateTime(unix_epoch));  

  DateTime now = rtc.now();
  setupStepper();
  setupInterrupt();
}

void loop() {
  handleMQTT();

  // Get current time
  timeClient.update();  
  unsigned long unix_epoch = timeClient.getEpochTime();  
  byte minute_ = minute(unix_epoch);  
  byte hour_ = hour(unix_epoch);  

  //Used for checking the time
  /*Serial.print(hour_);
  Serial.print(minute_);*/

  // Check if the current time matches the stored time
  if (storedHour == hour_ && storedMinute == minute_) {
    unsigned long currentTime = millis();
    if (currentTime - lastMealTime >= 60000) {
      startMotor = true; // Set flag to start motor
      moveStartTime = currentTime; // Record the start time
      lastMealTime = currentTime; // Update the last meal time
    }
  }

  if (startMotor) {
    if (getDistance() > 10 || startedMotor == true){
      startedMotor = true;
      Serial.println("Starting motor movement...");
      controlStepper(); // Debugging: Print when controlStepper() is called
      
      // Check if 10 seconds have elapsed since motor movement started
      if (millis() - moveStartTime >= 10000) {
        Serial.println("Motor movement completed.");
        startMotor = false; // Reset the flag
        startedMotor = false;

        Serial.print(storedHour);
        Serial.print(":");
        Serial.println(storedMinute);
      }
    }
  } else {
    digitalWrite(EN_PIN, HIGH); 
  }

  static byte last_minute = 0;
  if (last_minute != minute_) {
    last_minute = minute_;  

    // Check if RTC time is synchronized
    /*DateTime rtcTime = rtc.now();  
    if (rtcTime != DateTime(year(unix_epoch), month(unix_epoch), day(unix_epoch), hour_, minute_, 0)) {
      Serial.println("Time is not synchronized!");
    }*/
  }

  delay(2000);
}

// Function to set up pins
void setupPins() {
  Wire.begin(26, 27);
  pinMode(EN_PIN, OUTPUT);
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  digitalWrite(EN_PIN, LOW);
  digitalWrite(DIR_PIN, LOW);
}

// Function to set up serial communication
void setupSerial() {
  Serial.begin(115200);
  while (!Serial);
  SERIAL_PORT.begin(115200, SERIAL_8N1);
}

// Function to set up real-time clock
void setupRTC() {
  if (!rtc.begin()) {
    Serial.println("RTC module is NOT found");
    Serial.flush();
    while (1);
  }
}

// Function to set up WiFi connection
void setupWiFi() {
  WiFiManager wm;
  bool res = wm.autoConnect("AutoConnectAP", "password");
  if (!res) {
    Serial.println("Failed to connect");
  } else {
    Serial.println("connected...yeey :)");
  }
}

// Function to set up MQTT connection
void setupMQTT() {
  if (client.connect(ClientID.c_str(), "Erix", "!!SmartPet!!")) {
    client.publish(ClientID.c_str(), "hello world");
    client.subscribe("inTopic");
    client.subscribe("time-to-feed");
  }
}

// Function to set up stepper motor
void setupStepper() {
  driver.begin();
  driver.toff(4);
  driver.blank_time(24);
  driver.rms_current(500);
  driver.microsteps(16);
  driver.TCOOLTHRS(0xFFFFF); 
  driver.semin(0);
  driver.semax(2);
  driver.shaft(false);
  driver.sedn(0b01);
  driver.SGTHRS(STALL_VALUE);
}

// Function for interrupt setup
void setupInterrupt() {
  cli();
  timer1 = timerBegin(3, 8, true);
  timerAttachInterrupt(timer1, &onTimer, true);
  timerAlarmWrite(timer1, 8000, true);
  timerAlarmEnable(timer1);
  sei();
}

// Timer interrupt function
void IRAM_ATTR onTimer() {
  digitalWrite(STEP_PIN, !digitalRead(STEP_PIN));
} 

// Function to reconnect MQTT client
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

// Function to control stepper motor
void controlStepper() {
  digitalWrite(EN_PIN, LOW); // Enable motor
  digitalWrite(DIR_PIN, LOW); // Set direction
  digitalWrite(STEP_PIN, HIGH); // Step
}

int getDistance() {
  unsigned long pepe1=millis();  // takes the time before the loop on the library begins

  int dis=SharpIR.distance();  // this returns the distance to the object you're measuring


  Serial.print("Mean distance: ");  // returns it to the serial monitor
  Serial.println(dis);
  
  return dis;
}

// Function to handle MQTT messages
void handleMQTT() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}