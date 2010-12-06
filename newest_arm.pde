#include <Servo.h>

Servo shoulder, forearm, elbow, claw;

int shoulder_pin = 3;
int forearm_pin = 5;
int elbow_pin = 6;
int claw_pin = 9;
long int baud = 115200;
char buff[4];
byte i = 0;
boolean started = false;
boolean ended = false;

void setup(){
  Serial.begin(baud);
  
  shoulder.attach(shoulder_pin);
  forearm.attach(forearm_pin);
  elbow.attach(elbow_pin);
  claw.attach(claw_pin);
}

void loop(){
  while(Serial.available() > 0){
    char aChar = Serial.read();

    if(aChar == '<'){ 
      started = true; 
      ended = false; 
    } 
    else if(aChar == '>'){
      ended = true;
      break; // break the while loop
    } 
    else {
      buff[i] = aChar;
      i++;
      buff[i] = '\0'; // this terminates the array
    }
  }

  if(started && ended){
    int intpos;
    char pos[3] = { buff[1], buff[2], buff[3] };
    intpos = atoi(pos);
    
    Serial.print("Writing motor ");
    Serial.print(buff[0]);
    Serial.print(" to ");
    Serial.println(intpos);
    Serial.println();
    
    if(buff[0] == 's') shoulder.write(intpos);
    if(buff[0] == 'f') forearm.write(intpos);
    if(buff[0] == 'e') elbow.write(intpos);
    if(buff[0] == 'c') claw.write(intpos);
    
    i = 0;
    buff[i] = '\0'; // this terminates the array
    started = false;
    ended = false;
  }
}




