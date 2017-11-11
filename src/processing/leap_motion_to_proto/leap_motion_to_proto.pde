import de.voidplus.leapmotion.*;
import processing.serial.*;


// constants
int PROTO_PORT_INDEX = 5;
int PORT = 9696;

int MAX_SPEED = 20;
int SWIPE_DURATION = 250;


// vars
LeapMotion leap;
Serial protoPort;

int currentMotorSpeed = 0;
int motorDirection = 0;
int speedIncrement = 1;
int endMillis = -1;

boolean isKeyPressed = false;
boolean isSwiped = false;


void setup(){
  size(128, 128);
  background(200);

  initProtoSerial();
  initLeapMotion();
}

void draw() {
  if (isKeyPressed) {
    increaseMotorSpeed();

  } else {
    if (isSwiped) {
      // check if delay passed
      if (millis() >= endMillis) {
        isSwiped = false;
      }

    } else {
      applyFriction();
    }
  }

  sendMotorSpeed();
}


// methods
void initProtoSerial() {
  String portName = Serial.list()[PROTO_PORT_INDEX];
  println("proto port name: " + portName);
  protoPort = new Serial(this, portName, PORT);
}

void initLeapMotion() {
  leap = new LeapMotion(this).allowGestures();
}

void applyFriction() {
  if (currentMotorSpeed > 0) {
    currentMotorSpeed -= 1;
    if (currentMotorSpeed <= 0) {
      currentMotorSpeed = 0;
    }

  } else if (currentMotorSpeed < 0) {
    currentMotorSpeed += 1;
    if (currentMotorSpeed >= 0) {
      currentMotorSpeed = 0;
    }
  }
}

void increaseMotorSpeed() {
  currentMotorSpeed += speedIncrement * motorDirection;

  if (currentMotorSpeed >= MAX_SPEED) {
    currentMotorSpeed = MAX_SPEED;

  } else if (currentMotorSpeed <= -MAX_SPEED) {
    currentMotorSpeed = -MAX_SPEED;
  }

  if (currentMotorSpeed != 0) {
    println("currentMotorSpeed: " + currentMotorSpeed);
  }
}

void sendMotorSpeed() {
  if (protoPort == null) {
    return;
  }
  
  protoPort.write(currentMotorSpeed);
}

void setImpulse() {
  currentMotorSpeed = MAX_SPEED * motorDirection;
  
  isSwiped = true;
  endMillis = millis() + SWIPE_DURATION;
}


// event handlers
void keyPressed() {
  if (keyCode == UP || keyCode == DOWN) {
    isKeyPressed = true;
    speedIncrement = 1;

    if (keyCode == UP) {
      motorDirection = 1;

    } else if (keyCode == DOWN) {
      motorDirection = -1;
    }
  }
}

void keyReleased() {
  isKeyPressed = false;
}



// leap motion handlers
void leapOnSwipeGesture(SwipeGesture g, int state){
  PVector leapDirection = g.getDirection();

  switch(state){
    // start
    case 1:
      break;
    
    // update
    case 2:
      break;

    // stop
    case 3:
      if (leapDirection.x > 0) {
        // going right
        motorDirection = 1;
        setImpulse();
        
      } else {
        // going left
        motorDirection = -1;
        setImpulse();
      }

      break;
  }
}