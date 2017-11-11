

//#include <Stepper.h>
#include <AccelStepper.h>


// constants
const int STEPPER_PINS[] = {2, 3, 4, 5};
const int STEPPER_SPEED = 1000;

const int SERIAL_MAX_VAL = 20;
const int MAX_SPEED = 40;
const int SPEED_INCREMENT = MAX_SPEED / SERIAL_MAX_VAL;


// vars
char serialData;
int currentSpeed = 0;
AccelStepper stepper; // Defaults to AccelStepper::FULL4WIRE (4 pins) on 2, 3, 4, 5


// arduino setup
void setup()  {
  // init serial communications
  Serial.begin(9600);

  stepper.setMaxSpeed(MAX_SPEED);
}

void loop() {
  if (Serial.available()) {
    // if data is available to read, store it
    serialData = Serial.read();
  }

  int newSpeed;
  if (serialData > 0) {
    newSpeed = serialData * SPEED_INCREMENT;
    stepper.setSpeed(newSpeed);
    stepper.runSpeed();

  } else if (serialData < 0) {
    newSpeed = serialData * SPEED_INCREMENT;
    stepper.setSpeed(newSpeed);
    stepper.runSpeed();
  }

  delay(10);
}

void setNewSpeed(int serialValue) {
  int newSpeed = serialValue * SPEED_INCREMENT;
  if (newSpeed != currentSpeed) {
    currentSpeed = newSpeed;
    stepper.setSpeed(currentSpeed);
  }
}

void runStepper() {
  if (!stepper.isRunning()) {
    stepper.runSpeed();
  }
}

