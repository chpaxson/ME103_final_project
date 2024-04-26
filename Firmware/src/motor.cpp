#include "motor.h"

HardwareSerial Serial5(PD2, PC12);
int baudrate = 921600;

ODriveUART odrive(Serial5);

void setupMotor() {
    Serial5.begin(baudrate);

    Serial.println("Waiting for ODrive...");
    Serial.println("pin");
    while (odrive.getState() == AXIS_STATE_UNDEFINED)
    {
        Serial.println(odrive.getState());
        delay(100);
    }

    Serial.println("found ODrive");

    Serial.print("DC voltage: ");
    Serial.println(odrive.getParameterAsFloat("vbus_voltage"));

    Serial.println("Enabling closed loop control...");
    while (odrive.getState() != AXIS_STATE_CLOSED_LOOP_CONTROL)
    {
    odrive.clearErrors();
    odrive.setState(AXIS_STATE_CLOSED_LOOP_CONTROL);
    delay(10);
    }

    Serial.println("ODrive running!");
    delay(100);
    odrive.setPosition(0);
    delay(500);
    odrive.setTorque(0);
}

void setMotorSpeed(double speed) {
    // float accspeed = 6 * (speed / 100);
    // Serial.println(speed);
    // odrive.setVelocity(accspeed);

    float acct = 0.15 * (speed / 100);
    odrive.setTorque(acct);

    // float accpos = 3 * (speed / 100);
    // odrive.setPosition(accpos);
   
    
}