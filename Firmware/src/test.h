// test.h
#ifndef TEST_h
#define TEST_h

#include <Arduino.h>

void runTest(double freq, int num);

void printVals(int num, uint64_t time, long enc1, long enc2, double angle1, double angle2, double accel1, double accel2, double speed);
uint64_t determineSimTime(double freq);

#endif