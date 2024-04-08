// encoder.h
#ifndef ENCODER_h
#define ENCODER_h

#include <Arduino.h>

void setupEncoders();
void resetEncoders();

long get_encoder(int n);


#endif