// test.h
#ifndef ACCEL_h
#define ACCEL_h

#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>

void setupAccel();

double getAccel(int num);

#endif