#include <Stepper.h>


// constants
const int PORT_NUMBER = 9696;
const int MAX_STEPS = 200;
const int STEPPER_PINS[] = {2, 3, 4, 5};


// vars
char serialData;


Stepper motor(
  MAX_STEPS,
  STEPPER_PINS[0],
  STEPPER_PINS[1],
  STEPPER_PINS[2],
  STEPPER_PINS[3]
);


// arduino setup
void setup()  {
  // init serial communications
  Serial.begin(PORT_NUMBER);
}

void loop() {
  if (Serial.available()) {
    // if data is available to read, store it
    serialData = Serial.read();
  }

  if (serialData > 0) {
    motor.step(1);
  } else if (serialData < 0) {
    motor.step(-1);
  }

  delay(10);
}
