import processing.serial.*;


// constants
int PROTO_PORT_INDEX = 6; // /dev/tty.usbmodem1411, change to match port
int PROTO_PORT_NUMBER = 9696;

int SENSOR_PORT_INDEX = 7; // /dev/tty.usbmodem1451, change to match port
int SENSOR_PORT_NUMBER = 9600;

int MAX_SPEED = 20;


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
String gestureDirection;
int gestureSpeed;

boolean isKeyPressed = false;


// processing setup
void setup() {
  size(128, 128);
  background(222, 211, 199);

  printArray(Serial.list());
  initProtoPort();
  initSensorPort();
}

void draw() {
  parseGestureData();

  if (isKeyPressed) {
    increaseMotorSpeed();
  } else {
    applyFriction();
  }

  sendMotorSpeed();
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

  protoPort = new Serial(this, sensorPortName, SENSOR_PORT_NUMBER);
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
      gestureDirection = data[1];
      gestureSpeed = int(data[2]);
      
      println(
        "New gesture! (id: " + lastGestureId +
        ", direction: " + gestureDirection +
        ", speed: " + gestureSpeed +
      ")");
      
      sensorPortData = null;
    }
  }
}

void sendMotorSpeed() {
  if (protoPort == null) {
    return;
  }

  println("sending speed: " + currentMotorSpeed);
  protoPort.write(currentMotorSpeed);
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