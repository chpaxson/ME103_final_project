#include "test.h"
#include "encoder.h"
#include "accel.h"
#include "motor.h"

const double pi = 3.141592;
long printDelay = 200;

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

    while (curr_time < end_time) {
        curr_time = micros() - start_time;

        double speed = 100 * sin((double)(fConst * curr_time) / 1000000);

        setMotorSpeed(speed);

        if (printCounter >= printDelay) {
            // printVals(run_num, curr_time, get_encoder(0), get_encoder(1), getAccel(0), getAccel(1));
            printVals(run_num, curr_time / 1000, 0, 0, 0, 0, speed);
            printCounter = 0;
        }
        printCounter++;
    }
}

// return test time, seconds
uint64_t determineSimTime(double freq) {
    // if (freq < 0.02) {
    //     return 270;
    // } else if (freq < 0.05) {
    //     return 150;
    // } else if (freq < 0.1) {
    //     return 90;
    // } else {
        return 60;
    // }
}

void printVals(int num, uint64_t time, long enc1, long enc2, double angle1, double angle2, double speed)
{

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
    Serial.print(speed);
    Serial.println("");
}