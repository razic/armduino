#include <Servo.h>

Servo shoulder, forearm, elbow, claw;
Servo arm[4] = { shoulder, forearm, elbow, claw };

byte i = 0;
byte buff[2];

int claw_pin = 9;
int elbow_pin = 6;
int forearm_pin = 5;
int shoulder_pin = 3;

long int baud = 115200;

boolean ended = false;
boolean started = false;

void setup(){
  Serial.begin(baud);

  shoulder.attach(shoulder_pin);
  forearm.attach(forearm_pin);
  elbow.attach(elbow_pin);
  claw.attach(claw_pin);
}

void loop(){
  while(Serial.available()){
    byte aByte = Serial.read();
    
    switch(aByte){
    case 60: // <
      started = true; 
      ended = false;
      break;
    case 62: // >
      ended = true;
      break;
    default:
      buff[i] = aByte;
      i++;
      buff[i] = '\0';
    }
  }

  if(started && ended){
    arm[buff[0]].write(buff[1]);
    
    i = 0;
    buff[i] = '\0';
    started = false;
    ended = false;
  }
}

