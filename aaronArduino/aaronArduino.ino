/*#include <TVout.h>
 #include <fontALL.h>*/

#include <Servo.h>


//__DEF

#define SERVO_1_PIN 3
#define PWM_MIN 800//TODO: 800 +- 200
#define PWM_MAX 2400//TODO: 2400 +- 200
#define SERVO_2_PIN 5
#define SERVO_1_TARGET_ANGLE 30
#define SERVO_2_TARGET_ANGLE 132
#define SERVO_1_REST_ANGLE 140
#define SERVO_2_REST_ANGLE 40
#define SERVO_WAIT_TIME 3000
#define LAMP_PIN 8

#define LED_PIN_1 4

#define BAUDRATE 9600

#define HRES 125
#define VRES 115

//__VARS

/*TVout TV;*/

Servo servo2,servo1;
int servoAngle1,servoAngle2 = 0;
enum ServoState { 
  TOTARGET, WAIT, TOREST, DONE } 
servo_state;
boolean servoFinished1,servoFinished2 = false;
long previousMillisSrv1 = 0;
long previousMillisSrv2 = 0;
long intervalSrv1 = 100;
long intervalSrv2 = 200;
long servoWaitingElapsed = 0;

int ledState = LOW;
long previousMillisLED = 0;

long intervalLED = 500;

unsigned long currentMillis;
boolean doit = false;


void setup(){
  Serial.begin(BAUDRATE);
  servo1.attach(SERVO_1_PIN);//Mano: attach(SERVO_1_PIN,PWM_MIN,PWM_MAX);
  servo2.attach(SERVO_2_PIN);
  servo1.write(100);
  delay(200);
  servo2.write(0);
  delay(200);
  pinMode(LED_PIN_1,OUTPUT);
  pinMode(LAMP_PIN,OUTPUT);
  ledState = HIGH;
  digitalWrite(LED_PIN_1, ledState);
  digitalWrite(LAMP_PIN, LOW);
  /*TV.begin(_PAL); // for PAL system
   TV.clear_screen();
   TV.select_font(font6x8);
   TV.print(0,0,"olakease");*/
  randomSeed(analogRead(0)); // seed the random number generator
  //Move servos to target position slowly
  while(!servoFinished1||!servoFinished2){
    if(!servoFinished1){
      if(servoAngle1 < SERVO_1_REST_ANGLE){
        servoAngle1++;
        servo1.write(servoAngle1);
      }
      else{
        servoFinished1 = true;
      }
    }
    if(!servoFinished2){
      if(servoAngle2 < SERVO_2_REST_ANGLE){
        servoAngle2++;
        servo2.write(servoAngle2);
      }
      else{
        servoFinished2 = true;
      }
    }
    delay(intervalSrv2);
  }
  ledState = LOW;
  digitalWrite(LED_PIN_1, ledState);
  digitalWrite(LAMP_PIN, HIGH);
  Serial.println("Go!");
}

void loop(){
  currentMillis = millis();
  if(doit){
    if(servo_state == DONE ){
      servo_state = TOTARGET;
      servoFinished1 = false;
      servoFinished2 = false;
    }
    //Do things
    blinkLEDs();
    //tvAnim();
    moveServos();
  }
  else{
  }  
}

void moveServos(){

  switch(servo_state){

    //Move arm to down position
  case TOTARGET:
    if(!servoFinished1||!servoFinished2){
      if(!servoFinished1){
        if(currentMillis - previousMillisSrv1 > intervalSrv1) { //This controls general servo speed
          previousMillisSrv1 = currentMillis;   

          if(servoAngle1 > SERVO_1_TARGET_ANGLE){
            servoAngle1--;
            servo1.write(servoAngle1);
            Serial.println(servoAngle1);
          }
          else{
            servoFinished1 = true;
          }
        }
      }
      if(!servoFinished2){
        if(currentMillis - previousMillisSrv2 > intervalSrv2) { //This controls general servo speed
          previousMillisSrv2 = currentMillis;   

          if(servoAngle2 < SERVO_2_TARGET_ANGLE){
            servoAngle2++;
            servo2.write(servoAngle2);
          }
          else{
            servoFinished2 = true;
          }
        }
      }
    }
    else{
      Serial.println("Waiting!");
      servo_state = WAIT;
      digitalWrite(LAMP_PIN, LOW);
      servoWaitingElapsed = currentMillis;
    }
    break;

    //Wait
  case WAIT:
    if(currentMillis - servoWaitingElapsed < SERVO_WAIT_TIME){
      //servoWaitingElapsed += intervalSrv;
    }
    else{
      servoWaitingElapsed = 0;
      servo_state = TOREST;
      servoFinished1 = false;
      servoFinished2 = false;
      digitalWrite(LAMP_PIN, HIGH);
      Serial.println("To rest!");
    }
    break;

    //Move arm up again
  case TOREST:
    if(!servoFinished1||!servoFinished2){
      if(!servoFinished1){
        if(currentMillis - previousMillisSrv1 > intervalSrv1) { //This controls general servo speed
          previousMillisSrv1 = currentMillis;   
          if(servoAngle1 < SERVO_1_REST_ANGLE){
            servoAngle1++;
            servo1.write(servoAngle1);
            Serial.println(servoAngle1);
          }
          else{
            servoFinished1 = true;
          }
        }
      }
      if(!servoFinished2){
        if(currentMillis - previousMillisSrv2 > intervalSrv2) { //This controls general servo speed
          previousMillisSrv2 = currentMillis;   
          if(servoAngle2 > SERVO_2_REST_ANGLE){
            servoAngle2--;
            servo2.write(servoAngle2);
          }
          else{
            servoFinished2 = true;
          }
        }
      }
    }
    else{
      servo_state = DONE;
      stopLEDs();
      doit = false;
      Serial.println("Done!");
    }
    break;
    //Done
  case DONE:
    Serial.println("Finish!");
    delay(100);
    break;
  default:
    break;  
  }
}

void blinkLEDs(){
  if(currentMillis - previousMillisLED > intervalLED) {
    // save the last time you blinked the LED 
    previousMillisLED = currentMillis;   
    // if the LED is off turn it on and vice-versa:
    if (ledState == LOW)
      ledState = HIGH;
    else
      ledState = LOW;
    // set the LED with the ledState of the variable:
    digitalWrite(LED_PIN_1, ledState);
    Serial.println("pica");
  }
}

void stopLEDs(){
  ledState = LOW;
  // set the LED with the ledState of the variable:
  digitalWrite(LED_PIN_1, ledState);
}

void tvAnim(){

}

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read(); 
    if (inChar == 'a') {
      Serial.println("Got serial input!");
      Serial.println("Start!");
      if(!doit){
        doit = true;
      }
    }
    if (inChar == '+') {
      servoAngle1+=1;
      servo1.write(servoAngle1);
      Serial.println(servoAngle1);
    }
    if (inChar == '-') {
      servoAngle1-=1;
      servo1.write(servoAngle1);
      Serial.println(servoAngle1);
    }
    if (inChar == ',') {
      servoAngle1+=10;
      servo1.write(servoAngle1);
      Serial.println(servoAngle1);
    }
    if (inChar == '.') {
      servoAngle1-=10;
      servo1.write(servoAngle1);
      Serial.println(servoAngle1);
    } 
    if (inChar == 'z') {
      servoAngle1+=100;
      servo1.write(servoAngle1);
      Serial.println(servoAngle1);
    }
    if (inChar == 'x') {
      servoAngle1-=100;
      servo1.write(servoAngle1);
      Serial.println(servoAngle1);
    }
  }
}















