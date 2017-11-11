import processing.serial.*;


// constants
int PROTO_PORT_INDEX = 6; // /dev/tty.usbmodem1411, change to match port
int PROTO_PORT_NUMBER = 9696;

int SENSOR_PORT_INDEX = 7; // /dev/tty.usbmodem1451, change to match port
int SENSOR_PORT_NUMBER = 9600;

int MAX_SPEED = 20;
int MIN_SWIPE_DURATION = 6;
int MAX_SWIPE_DURATION = 666;


// vars
Serial protoPort;
String protoPortName;

Serial sensorPort;
String sensorPortName;
String sensorPortData;

int currentMotorSpeed = 0;
int motorDirection = 0;
int speedIncrement = 1;

String lastGestureId;
String receivedGestureId;
int gestureDirection;
int gestureSpeed;
int lowestSpeed = 1000;
int highestSpeed = 0;
int endMillis = -1;

boolean isKeyPressed = false;
boolean isSwiped = false;


// processing methods
void setup() {
  size(128, 128);
  background(222, 211, 199);

  printArray(Serial.list());
  initProtoPort();
  initSensorPort();
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

void serialEvent(Serial port) {
  if (port == sensorPort) {
    parseGestureData();
  }
}


// methods definitions
void initProtoPort() {
  protoPortName = Serial.list()[PROTO_PORT_INDEX];
  println("proto port name: " + protoPortName + ", index: " + PROTO_PORT_INDEX);

  protoPort = new Serial(this, protoPortName, PROTO_PORT_NUMBER);
}

void initSensorPort() {
  sensorPortName = Serial.list()[SENSOR_PORT_INDEX];
  println("sensor port name: " + sensorPortName + ", index: " + SENSOR_PORT_INDEX);

  sensorPort = new Serial(this, sensorPortName, SENSOR_PORT_NUMBER);
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

int mapGestureDirection(String rawDirection) {
  int direction;
  switch (rawDirection) {
    case "LEFT":
      direction = -1;
      break;
    case "RIGHT":
      direction = 1;
      break;
    default:
     direction = 0;
  }
  return direction;
}

void increaseMotorSpeed() {
  currentMotorSpeed += speedIncrement * motorDirection;

  if (currentMotorSpeed >= MAX_SPEED) {
    currentMotorSpeed = MAX_SPEED;

  } else if (currentMotorSpeed <= -MAX_SPEED) {
    currentMotorSpeed = -MAX_SPEED;
  }
}

void parseGestureData() {
  if (sensorPort == null) {
    return;
  }

  if (sensorPort.available() > 0) {
    sensorPortData = sensorPort.readStringUntil(';');
  }
  if (sensorPortData != null) {
    sensorPortData = sensorPortData.replaceFirst(";", "");
    //println("port data: " + sensorPortData);

    String data[] = split(sensorPortData, ",");
    receivedGestureId = data[0];

    if (receivedGestureId.equals(lastGestureId) == false) {
      lastGestureId = receivedGestureId;
      gestureDirection = mapGestureDirection(data[1]);
      gestureSpeed = int(data[2]);

      //printNewGesture();
      
      motorDirection = gestureDirection;
      lowestSpeed = max(lowestSpeed, gestureSpeed);
      highestSpeed = max(highestSpeed, gestureSpeed);
      setImpulse();

      sensorPortData = null;
    }
  }
}

void printNewGesture() {
  println(
    "New gesture! (id: " + lastGestureId +
    ", direction: " + gestureDirection +
    ", speed: " + gestureSpeed +
    ")"
  );
}

void sendMotorSpeed() {
  if (protoPort == null) {
    return;
  }

  //println("sending speed: " + currentMotorSpeed);
  protoPort.write(currentMotorSpeed);
}

void setImpulse() {
  currentMotorSpeed = MAX_SPEED * motorDirection;

  // TODO: make swipe duration dynamic
  //int swipeDuration = int(map(
  //  gestureSpeed,
  //  highestSpeed, lowestSpeed,
  //  MIN_SWIPE_DURATION, MAX_SWIPE_DURATION
  //));  
  //println("swipeDuration: " + swipeDuration);
  
  isSwiped = true;
  endMillis = millis() + MAX_SWIPE_DURATION;
}


// event handlers
void keyPressed() {
  if (keyCode == UP || keyCode == DOWN) {
    isKeyPressed = true;

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