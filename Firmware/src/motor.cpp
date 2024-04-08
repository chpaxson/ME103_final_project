#include "motor.h"

void setMotorSpeed(double speed)
{
    int ana_val = 127 + (127 * speed) / 100;
    analogWrite(PA4, ana_val);
}