// motor.h
#ifndef MOTOR_h
#define MOTOR_h

#include <ODriveUART.h>
#include <SoftwareSerial.h>
#include <Arduino.h>

void setupMotor();
void setMotorSpeed(double speed);

#endif