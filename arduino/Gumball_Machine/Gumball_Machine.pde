 /*
 
 Code to read an oyster card and send the ID to python -
 Python then connects to facebook to check the person in
 
 Python code is in /python/main.py
 check usb serial port is correct
 also check baud rate matches

- Elly ;-)


Arduino Code Based on :

 *  @title:  StrongLink SL018/SL030 RFID reader demo
 *  @author: marc@marcboon.com
 *  @see:    http://www.stronglink.cn/english/sl018.htm
 *  @see:    http://www.stronglink.cn/english/sl030.htm
 *
 *  Arduino to SL018/SL030 wiring:
 *  A3/TAG     1      5
 *  A4/SDA     2      3
 *  A5/SCL     3      4
 *  5V         4      -
 *  GND        5      6
 *  3V3        -      1
 */
 


#include <Wire.h>
#include <Servo.h>

#define TAG 17 // A3

#define successLed 13 //led to show successfull checkin
#define errorLed 12 //led to show when there is an error with checkin
#define readyLed 11 //led to show when program ready for card to be read
#define receivedLed 10 //led to show when card has been read


char* mifare[] = { 
  "1K", "Pro", "UltraLight", "4K", "ProX", "DesFire" };

int incomingSerial = 0;

//servo stuff
Servo myservo; 

boolean readTag = false;
String mode = "readRFID";


//timeout stuff
boolean firstNoSerial = false;
long setTime = 0;
unsigned long currentMillis;

boolean timeout = false;


void setup()
{
  // Init serial port to host and I2C interface to SL018/SL030
  Serial.begin(57600);

  pinMode(successLed, OUTPUT);
  pinMode(errorLed, OUTPUT);
  pinMode(readyLed, OUTPUT);
  pinMode(receivedLed, OUTPUT);


  Wire.begin();

  // Flash red led (only on SL018)
  ledOn(true);
  delay(500);
  ledOn(false);

  testEverything();
}

//---------------------------------------------------------------------------

void loop()
{
    
    
  if(mode == "readRFID"){
   
    //reset everything   
    timeout = false;
    firstNoSerial = false;
             
    delay(50);
    digitalWrite(readyLed, HIGH);
    
    // Wait for tag    
    while(digitalRead(TAG));
   
    // Read tag ID
    readID();
    
    delay(1000);   
    
  }
  
  if(mode == "readSerial"){
  
  isSuccess();

  }
  



}


void isSuccess(){
  
  if (Serial.available() > 0) {
    
      incomingSerial = Serial.read();
      
      if(incomingSerial== 49){
  
         //turn off received Led
        digitalWrite(receivedLed, LOW);
        
        //flash success led
        digitalWrite(successLed, HIGH);
        delay(1000);
        digitalWrite(successLed, LOW);
        
        //turn on motor
        myservo.attach(9);
        myservo.write(150); 
        delay(2000);
        myservo.detach();
        
        //set mode to read in rfid
        mode = "readRFID";
      }
      if(incomingSerial== 50){
        
        //turn off received Led
        digitalWrite(receivedLed, LOW);
  
        //flash error led
        digitalWrite(errorLed, HIGH);
        delay(1000);
        digitalWrite(errorLed, LOW);
        
         //set mode to read in rfid
        mode = "readRFID";
      }
    

  }
  
  else{   
   
     if(!firstNoSerial){
             
            //if no serial input then initiate timer       
            setTime = millis();
            firstNoSerial = true;
            timeout = true;           
            
             }
    
     if(timeout){
               
              //timer will count to 3 secs before reseting      
              currentMillis = millis();
              
              if(currentMillis - setTime > 3000) {              
              
                //times up
              digitalWrite(receivedLed, LOW);
              mode = "readRFID";
             
              } 
              
    }//end of else
    
  }//end of if serial available
  
}



void ledOn(boolean on)
{
  
  
  // Send LED command
  Wire.beginTransmission(0x50);
  Wire.send(2);
  Wire.send(0x40);
  Wire.send(on);
  Wire.endTransmission();
}

int readID()
{
  //flush out any incoming serial data so that serial is clear.
  Serial.flush();
  
  // Send SELECT command
  Wire.beginTransmission(0x50);
  Wire.send(1);
  Wire.send(1);
  Wire.endTransmission();

  // Wait for response
  while(!digitalRead(TAG))
  {
      
    // Allow some time to respond
    delay(5);

    // Anticipate maximum packet size
    Wire.requestFrom(0x50, 11);
    if(Wire.available())
    {
          
      // Get length of packet
      byte len = Wire.receive();

      // Wait until whole packet is received
      while(Wire.available() < len)
      {      
        
        // Quit if no response before tag left
        if(digitalRead(TAG)) return 0;
      }

      // Read command code, should be same as request (1)
      byte command = Wire.receive();
      if(command != 1) return -1;

      // Read status
      byte status = Wire.receive();


      switch(status)
      {
      case 0: // Succes, read ID and tag type
        {
          digitalWrite(readyLed, LOW);
          digitalWrite(receivedLed, HIGH);          
          
          len -= 2;

          int i = 0;

          // Get tag ID
          for(i=0;i<(len-1);i++){
            {

              byte data = Wire.receive();
              //if(data < 0x10) Serial.print(0);
              
              //send data to python script
              Serial.print(data, HEX);
              
            }
            // Get tag type
            byte type = Wire.receive();
 
          }
        
          Serial.print("\n");
         
         //tag id received and sent to python - now set mode to read in serial
          mode = "readSerial";
                   
          return 1;
        }

      case 0x0A: // Collision
        //Serial.println("Collision detected");
        break;

      case 1: // No tag
        //Serial.println("No tag found");
        break;

      default: // Unexpected
        //Serial.println("Unexpected result");
        ;
      }
      return -1;
    }
  }

  return 0;
}




void testEverything(){
   
  digitalWrite(successLed, HIGH);
  delay(500);
  digitalWrite(successLed, LOW);
  delay(500);
  digitalWrite(errorLed, HIGH);
  delay(500);
  digitalWrite(errorLed, LOW);
  delay(500);
  digitalWrite(receivedLed, HIGH);
  delay(500);
  digitalWrite(receivedLed, LOW);
  delay(500);
  digitalWrite(readyLed, HIGH);
  delay(500);
  digitalWrite(readyLed, LOW);
  
   myservo.attach(9);
   myservo.write(150);
   delay(2000);
   myservo.detach(); 
  
  
}
