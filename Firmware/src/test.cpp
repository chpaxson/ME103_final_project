#include "test.h"
#include "encoder.h"
#include "accel.h"
#include "motor.h"

const double pi = 3.141592;
long printDelay = 10;

void runTest(double freq, int run_num) {

    const double fConst = pi * freq * 2;    
    long printCounter = 0;

    uint64_t test_time = (uint64_t) determineSimTime(freq);

    uint64_t start_time = micros();
    uint64_t end_time = test_time * 1000000;
    
    uint64_t curr_time = micros() - start_time;
    resetEncoders();

    Serial.print("end time:");
    Serial.println(end_time);

    // while (curr_time < end_time) {
      while (true) {
        curr_time = micros() - start_time;

        double speed = 100 * cos((double)(fConst * curr_time) / 1000000);

        setMotorSpeed(speed);

        if (printCounter >= printDelay) {
            // printVals(run_num, curr_time, get_encoder(0), get_encoder(1), get_gyro(0), get_gyro(1), get_accel(0), get_accel(1), speed);
            printVals(run_num, curr_time, get_encoder(0), get_encoder(1), 1, 1, 1, 1, speed);
            // printVals(run_num, curr_time / 1000, 0, 0, 0, 0, 0, 0, speed);
            printCounter = 0;
        }
        printCounter++;
    }
}

// return test time, seconds
uint64_t determineSimTime(double freq) {
    if (freq < 0.3) {
        return 60;
    } else if (freq < 1) {
        return 10;
    } else {
        return 5;
    }
}

void printVals(int num, uint64_t time, long enc1, long enc2, double angle1, double angle2, double accel1, double accel2, double speed)
{

    if (accel1 == 0 || accel2 == 0) {
        // setMotorSpeed(0);
        Serial.println("I2C failed");
        while(1);
    }

    Serial.print(num);
    Serial.print(", ");
    Serial.print(time);
    Serial.print(", ");
    Serial.print(enc1);
    Serial.print(", ");
    Serial.print(enc2);
    Serial.print(", ");
    Serial.print(angle1);
    Serial.print(", ");
    Serial.print(angle2);
    Serial.print(", ");
    Serial.print(accel1);
    Serial.print(", ");
    Serial.print(accel2);
    Serial.print(", ");
    Serial.print(speed);
    Serial.println("");
}