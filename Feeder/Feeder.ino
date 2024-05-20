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
#define DRIVER_ADDRESS    0b00  // TMC2208 Driver address according to MS1 and MS2
#define SERIAL_PORT       Serial2 // TMC2208/TMC2224 HardwareSerial port
#define ir                34 // The pin where the ir sensor is attached
#define model             430 // model: an int that determines the sensor (working distance range according to the datasheets)
#define ClientID          WiFi.macAddress()                                         

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

bool startMotor = false;
bool startedMotor = false;

//Next meal
byte storedHour = 0;
byte storedMinute = 0;

// Callback function for MQTT messages
void callback(char* topic, byte* payload, unsigned int length) {
  String response;
  for (int i = 0; i < length; i++) {
    response += (char)payload[i];
  }

  if (strcmp(topic, "time-to-feed") == 0) {
    if (response.equals("start")) {
      unsigned long currentTime = millis();
      if (currentTime - lastMealTime >= 60000) {
        startMotor = true;
        moveStartTime = currentTime; 
        lastMealTime = currentTime;
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

  //Setting up the NTP and adjusting the RTC to the current time
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

  // Check if the current time matches the stored time
  if (storedHour == hour_ && storedMinute == minute_) {
    unsigned long currentTime = millis();
    if (currentTime - lastMealTime >= 60000) {
      startMotor = true; 
      moveStartTime = currentTime; 
      lastMealTime = currentTime;
    }
  }

  //Starting the stepper if the flag is up
  if (startMotor) {
    if (getDistance() > 10 || startedMotor == true){
      startedMotor = true;
      controlStepper();
      
      // Checking if it's time to stop the feeding
      if (millis() - moveStartTime >= 10000) {
        startMotor = false;
        startedMotor = false;
        client.publish("notifications", "Feeding completed");
      }
    }else{
      client.publish("notifications", "ERROR (bowl is already full)");
    }
  } else {
    digitalWrite(EN_PIN, HIGH); 
  }

  static byte last_minute = 0;
  if (last_minute != minute_) {
    last_minute = minute_;
  }

  delay(2000);
}

// Function to set up pins
void setupPins() {
  Wire.begin(26, 27); //sets up a I2C communication protocol
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
  SERIAL_PORT.begin(115200, SERIAL_8N1); // Setting up the communication with the driver 
                                         //SERIAL_8N1 -> 8 data bits, no parity bit, and 1 stop bit
}

// Function to set up real-time clock
void setupRTC() {
  if (!rtc.begin()) {
    Serial.flush();
    while (1);
  }
}

// Function to set up WiFi connection
void setupWiFi() {
  WiFiManager wm; // Provides user interface to configure WiFi-credentials 
  bool res = wm.autoConnect("AutoConnectAP", "password");
}

// Function to set up MQTT connection
void setupMQTT() {
  //Setting up the MAC address as a ClientID
  if (client.connect(ClientID.c_str(), "Erix", "!!SmartPet!!")) {
    client.subscribe("time-to-feed");
  }
}

// Function to set up stepper motor
void setupStepper() {
  driver.begin(); //Initializes the stepper motor driver
  driver.toff(4); //This sets the value of the "toff" parameter, the duration the current is off between motor movements
  driver.blank_time(24); //The duration the stepper driver will wait after the last step before turning off the outputs
  driver.rms_current(500); //Determines the maximum current that the stepper motor driver will deliver to the stepper motor, to 500 mA
  driver.microsteps(16); //Sets the number of microsteps per full step
  driver.TCOOLTHRS(0xFFFFF); //Disables coolStep
  driver.semin(0); //Sets the min stall detection sensitivity
  driver.semax(2); //Sets the max stall detection sensitivity
  driver.shaft(false);
  driver.sedn(0b01); //Sets the stall detection filter to filter out short stall events.
  driver.SGTHRS(STALL_VALUE); //Specifies the threshold for stall detection.
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
    client.connect(ClientID.c_str());
  }
}

// Function to control stepper motor
void controlStepper() {
  digitalWrite(EN_PIN, LOW); // Enable motor
  digitalWrite(DIR_PIN, LOW); // Set direction
  digitalWrite(STEP_PIN, HIGH); // Step
}

// Function to measure the distance to the bowl
int getDistance() {
  int dis=SharpIR.distance();
  return dis;
}

// Function to handle MQTT messages
void handleMQTT() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}