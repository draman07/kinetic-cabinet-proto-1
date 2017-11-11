import processing.serial.*;


// constants
int SENSOR_PORT_INDEX = 5; // /dev/tty.usbmodem1451, change to match port
int SENSOR_PORT_NUMBER = 9600;


// variables
Serial sensorPort;
String sensorPortName;
String sensorPortData;

String lastGestureId;
String receivedGestureId;
String gestureDirection;
int gestureSpeed;


// 
void setup() {
  initSensorPort();
}

void draw() {
  parseGestureData();
}

// methods definitions
void initSensorPort() {
  printArray(Serial.list());
  
  sensorPortName = Serial.list()[SENSOR_PORT_INDEX];
  println("port name: " + sensorPortName + ", index: " + SENSOR_PORT_INDEX);

  sensorPort = new Serial(this, sensorPortName, SENSOR_PORT_NUMBER);
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