#include <Arduino.h>
#include "encoder.h"
#include "motor.h"
#include "test.h"
#include "accel.h"



void setup() {
  Serial.begin(115200);
  Serial.println("---- Starting Setup ---- ");

  setupEncoders();
  resetEncoders();

  setupAccel();

  Serial.println("---- Finished Setup ---- ");
}

void loop() {
  Serial.print("Z: ");
  Serial.println(getAccel(0));

  // runTest(1, 0);

  delay(100);
}


