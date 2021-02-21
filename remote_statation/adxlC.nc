#include<stdio.h>
#include "adxl.h"


module adxlC @safe()
{
 uses interface Timer<TMilli> as Timer0;
  
  uses interface Leds;
  uses interface Boot;
  uses interface AMSend;
  uses interface Packet;
  uses interface SplitControl as RadioControl;
  uses interface I2CPacket<TI2CBasicAddr> as I2CPacket1;
  uses interface I2CPacket<TI2CBasicAddr> as I2CPacket2;
  uses interface Resource;
}
implementation{
	  uint8_t buff[2];
  	  uint8_t Reg_add=0x32;
  	  uint8_t readData[6];
  	  uint8_t readData1[6];
  	  uint8_t cmd=0;  	
  	  int16_t zAccl, zAccl1;
  	  message_t packet;
  	  bool lock = FALSE;
  	  uint8_t sens_no;
  	   radio_sense_msg_t* rsm;
	
	event void Boot.booted()
  {
    call RadioControl.start();
    
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
       call Timer0.startPeriodic(500);
      
    }
  }
  event void RadioControl.stopDone(error_t err) {
  }
  event void Timer0.fired()
  {
  	 	cmd++;
      	if(cmd>8)
      	cmd=5;
      	call Resource.request();
  }
  
    event void Resource.granted() {

             if(cmd==1){
		// Select Power control register(0x2D)
		// Auto-sleep disable(0x08)
		  buff[0] = 0x2D; 
		  buff[1] = 0x08;
		  call I2CPacket1.write(I2C_START|I2C_STOP, 0x53, 2, buff);
		  
		  
		  return;
		   
          }
          
          else if(cmd==2){
		// Select Data format register(0x31)
		// Self test disabled, 4-wire interface, Full resolution, range = +/-16g(0x08)
           buff[0] = 0x31; 
		   buff[1] = 0x0B; 
		   call I2CPacket1.write(I2C_START|I2C_STOP, 0x53, 2, buff);
		   return;
          }
          
          else if(cmd==3 ){
          	 buff[0] = 0x2D; 
		  buff[1] = 0x08;
          	call I2CPacket2.write(I2C_START|I2C_STOP, 0x1D, 2, buff);
          	return;
          	
          }
          else if(cmd==4){
          	buff[0] = 0x31; 
		   buff[1] = 0x0B; 
          	call I2CPacket2.write(I2C_START|I2C_STOP, 0x1D, 2, buff);
          	return;
          }
          	else if(cmd==5){
          	call I2CPacket1.write(I2C_START|I2C_STOP, 0x53, 1, (uint8_t*)(&Reg_add));
          	return;
          	
          	}
          
          else if(cmd==6){
          	
          	call I2CPacket1.read(I2C_START |I2C_STOP, 0x53,6, (uint8_t*)(&readData));
          return;
          }
          
          else if(cmd==7){
          	call I2CPacket2.write(I2C_START|I2C_STOP, 0x1D, 1, (uint8_t*)(&Reg_add));
          	return;}
          
          else if(cmd==8){
          	
          	call I2CPacket2.read(I2C_START |I2C_STOP, 0x1D,6, (uint8_t*)(&readData1));
          return;}
          
      }
      
         async event void I2CPacket1.writeDone(error_t error, uint16_t addr,uint8_t length, uint8_t* data) 
         {
          call Resource.release();
          }
          
                   async event void I2CPacket2.writeDone(error_t error, uint16_t addr,uint8_t length, uint8_t* data) 
         {
          call Resource.release();
          } 
          
            async event void I2CPacket1.readDone(error_t error, uint16_t addr,uint8_t length, uint8_t* data) {
          if (error == SUCCESS){
              call Leds.led1Toggle();
             // Convert the data to 10-bits


		 zAccl = ((readData[5] & 0x03) * 256 + (readData[4] & 0xFF));
		if(zAccl > 511)
		{
			zAccl -= 1024;
		}
		
		}
		
		
         
          
     
      
          rsm = (radio_sense_msg_t*)call Packet.getPayload(&packet, sizeof(radio_sense_msg_t));
          if (rsm == NULL) {
            return;
          }
          rsm-> Node_Id = TOS_NODE_ID;
          rsm-> Sensor_No = 1;
          rsm-> Sensor_Value= zAccl;
          printf("\nSending: %d %d %d\r", rsm-> Node_Id, rsm-> Sensor_No, rsm-> Sensor_Value);
          if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_sense_msg_t)) == SUCCESS) 
          {
            lock = TRUE;
          }
           call Resource.release();    
          return;
      }
      
      
   
   async event void I2CPacket2.readDone(error_t error, uint16_t addr,uint8_t length, uint8_t* data) {
          if (error == SUCCESS){
              call Leds.led1Toggle();
             // Convert the data to 10-bits


		 zAccl = ((readData1[5] & 0x03) * 256 + (readData1[4] & 0xFF));
		if(zAccl > 511)
		{
			zAccl -= 1024;
		}
		
		}
		
		
         
          
     
      
          rsm = (radio_sense_msg_t*)call Packet.getPayload(&packet, sizeof(radio_sense_msg_t));
          if (rsm == NULL) {
            return;
          }
          rsm-> Node_Id = TOS_NODE_ID;
          rsm-> Sensor_No = 2;
          rsm-> Sensor_Value= zAccl;
          printf("\nSending: %d %d %d\r", rsm-> Node_Id, rsm-> Sensor_No, rsm-> Sensor_Value);
          if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_sense_msg_t)) == SUCCESS) 
          {
            lock = TRUE;
          }
           call Resource.release();    
          return;
      }
      
 
	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      lock = FALSE;
    }
  }
	
}
