//code to react to facebook checkin - will be linked to python code.



#include <Servo.h>

#define successLed 13 //led to show successfull checkin
#define errorLed 12 //led to show when there is an error with checkin



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
 



  testEverything();
}

//---------------------------------------------------------------------------

void loop()
{
   //Serial.flush(); 
  
  //if(mode == "readSerial"){
  
  isSuccess();

 // }
  



}


void isSuccess(){
  
  if (Serial.available() > 0) {
    
      incomingSerial = Serial.read();
      
      if(incomingSerial== 49){
  
         //turn off received Led
       
        
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
        //mode = "readRFID";
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
             
              //mode = "readRFID";
             
              } 
              
    }//end of else
    
  }//end of if serial available
  
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
 
  
   /*myservo.attach(9);
   myservo.write(150);
   delay(2000);
   myservo.detach(); */
  
  
}
