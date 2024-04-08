#include "accel.h"

Adafruit_BNO055 bno0;
Adafruit_BNO055 bno1;

double ref_0 = 0;
double ref_1 = 0;

int rot_0 = 0; 
int rot_1 = 0;

double last_0 = 0; 
double last_1 = 0;

void setupAccel() {
    Adafruit_BNO055 bno0 = Adafruit_BNO055(55, 0x28, &Wire);
    Adafruit_BNO055 bno1 = Adafruit_BNO055(55, 0x29, &Wire);

    if (!bno0.begin()){
        /* There was a problem detecting the BNO055 ... check your connections */
        Serial.print("Ooops, no BNO055_0 detected ... Check your wiring or I2C ADDR!");
        while (1);
    }

    // if (!bno1.begin()){
    //     /* There was a problem detecting the BNO055 ... check your connections */
    //     Serial.print("Ooops, no BNO055_1 detected ... Check your wiring or I2C ADDR!");
    //     while (1);
    // }
}

void resetAccel() {
    imu::Vector<3> euler0 = bno0.getVector(Adafruit_BNO055::VECTOR_EULER);
    imu::Vector<3> euler1 = bno1.getVector(Adafruit_BNO055::VECTOR_EULER);
    ref_0 = euler0.z();
    ref_1 = euler1.z();
}

double getAccel(int num) {
    imu::Vector<3> euler0 = bno0.getVector(Adafruit_BNO055::VECTOR_EULER);
    imu::Vector<3> euler1 = bno1.getVector(Adafruit_BNO055::VECTOR_EULER);

    // get the desired values
    double curr_0 = euler0.z() + ref_0;
    double curr_1 = euler1.z() + ref_1;

    // Adjust for ref value
    if (curr_0 > 360) 
        curr_0 -= 360;
    if (curr_1 > 360)
        curr_1 -= 360;

    // check for rotation increase
    if(curr_0 < -120 && last_0 > 120)
        rot_0 ++;
    if (last_0 < -120 && curr_0 > 120)
        rot_0 --;
    if (curr_1 < -120 && last_1 > 120)
        rot_1++;
    if (last_1 < -120 && curr_1 > 120)
        rot_1--;

    // update last_vals
    last_0 = curr_0;
    last_1 = curr_1;

    if( num==0) {
        return curr_0 + (360 * rot_0);
    }else if(num == 1) {
        return curr_1 + (360 * rot_1);
    } else {
        return 0;
    }
}