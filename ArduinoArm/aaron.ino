/* LedStripGradient: Example Arduino sketch that shows
 * how to control an Addressable RGB LED Strip from Pololu.
 *
 * To use this, you will need to plug an Addressable RGB LED
 * strip from Pololu into pin 12.  After uploading the sketch,
 * you should see a pattern on the LED strip that fades from
 * green to pink and also moves along the strip.
 */
 
#include <PololuLedStrip.h>
#include <Servo.h> 
 
Servo myservo, myservo1;  // create servo object to control a servo 
                // a maximum of eight servo objects can be created 

#define ledPin 5
// Create an ledStrip object on pin 12.
PololuLedStrip<12> ledStrip;
 
// Variables will change:
int ledState = LOW;             // ledState used to set the LED
long previousMillis = 0;        // will store last time LED was updated

// the follow variables is a long because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long interval = 1000;           // interval at which to blink (milliseconds)

int pos = 0;    // variable to store the servo position 

// Create a buffer for holding 60 colors.  Takes 180 bytes.
#define LED_COUNT 60
rgb_color colors[LED_COUNT];

void setup()
{
  pinMode(ledPin, OUTPUT);  
  Serial.begin(9600);
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  myservo.attach(7);  // attaches the servo on pin 9 to the servo object
}

void ledBlinking()
{
  // here is where you'd put code that needs to be running all the time.

  // check to see if it's time to blink the LED; that is, if the 
  // difference between the current time and last time you blinked 
  // the LED is bigger than the interval at which you want to 
  // blink the LED.
  unsigned long currentMillis = millis();
 
  if(currentMillis - previousMillis > interval) {
    // save the last time you blinked the LED 
    previousMillis = currentMillis;   

    // if the LED is off turn it on and vice-versa:
    if (ledState == LOW)
      ledState = HIGH;
    else
      ledState = LOW;

    // set the LED with the ledState of the variable:
    digitalWrite(ledPin, ledState);
  }
}

void moveServos() 
{ 
  for(pos = 45; pos < 120; pos += 1)  // goes from 0 degrees to 180 degrees 
  {                                  // in steps of 1 degree 
    ledBlinking();
     ledstring();
    myservo.write(pos);              // tell servo to go to position in variable 'pos' 
    myservo1.write(pos); 
    delay(40);                       // waits 15ms for the servo to reach the position 
  } 
  for(pos = 120; pos>=45; pos-=1)     // goes from 180 degrees to 0 degrees 
  {                                
    ledBlinking();
    ledstring();
    myservo.write(pos);              // tell servo to go to position in variable 'pos' 
    myservo1.write(pos); 
    delay(40);                       // waits 15ms for the servo to reach the position 
  } 
} 

void loop()
{
 
}

void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read(); 
    // add it to the inputString:
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == 'a') {
      moveServos();
    } 
  }
}
void ledstring(){
 // Update the colors.
  byte time = millis() >> 2;
  for(byte i = 0; i < LED_COUNT; i++)
  {
    byte x = time - 8*i;
    colors[i] = (rgb_color){ x, 255 - x, x };
  }
  
  // Write the colors to the LED strip.
  ledStrip.write(colors, LED_COUNT);  
  
  delay(10);

}