#include <Arduino.h>
#include "encoder.h"
#include "motor.h"
#include "test.h"
#include "accel.h"

void setup() {

  Serial.begin(230400);
  Serial.println("start");
  setupAccel();
  setupMotor();

  setupEncoders();
  resetEncoders();

  
}

void loop() {

  /*
  Test frequencies:
  0.1000    0.1389    0.1931    0.2683    0.3728    0.5179    0.7197
  1.0000    1.3895    1.9307    2.6827    3.7276    5.1795    7.1969
  10.0000

  */

  runTest(0.5179, 0);

  while(1){
    setMotorSpeed(0);
    delay(100);
  }
  

  delay(1000);
}


