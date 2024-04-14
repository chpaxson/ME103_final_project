// test.h
#ifndef ACCEL_h
#define ACCEL_h

#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>

void setupAccel();
void reset_gyro();


double get_accel(int num);
double get_gyro(int num);

#endif