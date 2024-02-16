#include <Wire.h>
#include <RTClib.h>
#include <WiFiManager.h>
#include <PubSubClient.h>
#include <WifiUdp.h>
#include <NTPClient.h>
#include <TimeLib.h>
#include <TMCStepper.h>
#include <SPI.h>

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

// Objects and Variables
RTC_DS3231 rtc;
IPAddress server(34, 122, 107, 45);
WiFiClient espClient;
PubSubClient client(server, 1883, callback, espClient);
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "asia.pool.ntp.org", 7200, 60000);
hw_timer_t *timer1 = NULL;
TMC2209Stepper driver(&SERIAL_PORT, R_SENSE, DRIVER_ADDRESS);

// Movement control variables
unsigned long moveStartTime = 0;
bool startMotor = false; // Flag to start motor based on MQTT command

// Callback function for MQTT messages
void callback(char* topic, byte* payload, unsigned int length) {
  String response;
  for (int i = 0; i < length; i++) {
    response += (char)payload[i];
  }
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  Serial.println(response);

  // Check MQTT topic and payload to determine action
  if (strcmp(topic, "startMotorTopic") == 0) {
    Serial.println("on topic");
    if (response.equals("start")) {
      Serial.println("Start");
      startMotor = true; // Set flag to start motor
      moveStartTime = millis(); // Record the start time
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

  // Debugging: Print the state of the startMotor flag
  Serial.print("startMotor flag: ");
  Serial.println(startMotor);

  if (startMotor) {
    Serial.println("Starting motor movement...");
    controlStepper(); // Debugging: Print when controlStepper() is called
    
    // Check if 10 seconds have elapsed since motor movement started
    if (millis() - moveStartTime >= 10000) {
      Serial.println("Motor movement completed.");
      startMotor = false; // Reset the flag
    }
  } else {
    Serial.println("Motor not moving");
    digitalWrite(EN_PIN, HIGH); 
  }

  timeClient.update();  
  unsigned long unix_epoch = timeClient.getEpochTime();  

  static byte last_second = 0;
  byte second_ = second(unix_epoch);  
  if (last_second != second_) {
    last_second = second_;  

    byte minute_ = minute(unix_epoch);  
    byte hour_ = hour(unix_epoch);  
    byte day_ = day(unix_epoch);  
    byte month_ = month(unix_epoch);  
    int year_ = year(unix_epoch);  

    char t[32];
    

    DateTime rtcTime = rtc.now();  

    if (rtcTime != DateTime(year_, month_, day_, hour_, minute_, second_)) {
      Serial.println("Time is not synchronized!");
    }
  }

  delay(1000);
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
  if (client.connect("arduinoClient", "Erix", "!!SmartPet!!")) {
    client.publish("outTopic", "hello world");
    client.subscribe("inTopic");
    client.subscribe("startMotorTopic");
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

// Function to handle MQTT messages
void handleMQTT() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}