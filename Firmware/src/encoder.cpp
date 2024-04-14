#include "encoder.h"

uint8_t data[8];
HardwareSerial Serial3(PC11, PC10);

void setupEncoders() {
    Serial3.begin(921600);
}

void resetEncoders() {
    Serial3.write('A');
}


long get_encoder(int n) {

  while(Serial3.available()){
    Serial3.read();
  }

  if(n == 0) {
    Serial3.write('b');
  } else if(n == 1) {
    Serial3.write('a');
  } else {
    Serial3.write('c');
  }

  int i = 0;
  while(1) {
    if (Serial3.available()) {
      data[i] = Serial3.read();
      i++;
    }
    if(i == 7) {
      break;
    }
  }

  return (data[0] + (data[1] << 8) + (data[2] << 16) + (data[3] << 24) + (data[4] << 32) + (data[5] << 40) + (data[6] << 48));
}