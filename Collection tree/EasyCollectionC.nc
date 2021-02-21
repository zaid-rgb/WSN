#include <Timer.h>

#include <stdio.h>

module EasyCollectionC {
  uses interface Boot;
  uses interface SplitControl as RadioControl;
  uses interface StdControl as RoutingControl;
  uses interface Send;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface RootControl;
  uses interface Receive;
  uses interface I2CPacket<TI2CBasicAddr>;
  uses interface Resource;
}
implementation {
    uint8_t counter;
	  uint8_t buff[2];
  	  uint8_t Reg_add=0x32;
  	  uint8_t readData[6];
  	  uint8_t cmd=0;  	
  	  uint16_t z;
	  uint16_t temp;
	  uint16_t temp2;
	  uint16_t temp3;	
	  uint8_t e=0;	
	   uint16_t luxv;
    uint16_t node1;
    uint8_t a;
  message_t packet;
  bool sendBusy = FALSE;

  typedef nx_struct EasyCollectionMsg {
    nx_uint16_t data;
    nx_uint8_t adxl_no;
    nx_uint16_t NodeId;
  } EasyCollectionMsg;

  event void Boot.booted() {
    call RadioControl.start();
  }
  
  event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS)
      call RadioControl.start();
    else {
      call RoutingControl.start();
      if (TOS_NODE_ID == 1) 
	call RootControl.setRoot();
      else
	call Timer1.startPeriodic(100);
	
    }
  }
  event void Timer2.fired(){
  	
  	call Timer2.stop();
  	printf("%d,%d,%d\n",node1,luxv,a);
  }
  event void RadioControl.stopDone(error_t err) {}

  void sendMessage() {
    EasyCollectionMsg* msg =
      (EasyCollectionMsg*)call Send.getPayload(&packet, sizeof(EasyCollectionMsg));
    msg->data = z;
    msg->NodeId = TOS_NODE_ID;
    msg->adxl_no = counter;
   
    if (call Send.send(&packet, sizeof(EasyCollectionMsg)) != SUCCESS) 
      call Leds.led2On();
    else 
       printf("Sending data: %d,%d,%d\n",msg->NodeId,msg->data,msg->adxl_no);
      sendBusy = TRUE;
  }
  event void Timer1.fired() {
    if (counter>4)
      		{counter=0;
      		e++;
      		}
      	cmd++;
      	if(cmd>4 )
      	{cmd=1;
      	 counter++;
      	 }
  
      	call Resource.request();

  }
  
  event void Resource.granted() {

	if (counter & 0x1) {
      call Leds.led0On();
    }
    else {
      call Leds.led0Off();
    }
    if (counter & 0x2) {
      call Leds.led1On();
    }
    else {
      call Leds.led1Off();
          }

         if(cmd==1){
		// Select Power control register(0x2D)
		// Auto-sleep disable(0x08)
		  buff[0] = 0x2D; 
		  buff[1] = 0x08;
		  call I2CPacket.write(I2C_START|I2C_STOP, 0x53, 2, buff);
		  return;
		   
          }
             else if(cmd==2){
		// Select Data format register(0x31)
		// Self test disabled, 4-wire interface, Full resolution, range = +/-2g(0x08)
           buff[0] = 0x31; 
		   buff[1] = 0x0B; 
		   call I2CPacket.write(I2C_START|I2C_STOP, 0x53, 2, buff);
		   return;
          }
          
          else if(cmd==3 ){
          	call I2CPacket.write(I2C_START|I2C_STOP, 0x53, 1, (uint8_t*)(&Reg_add));
          	return;
          	
          }
          else if(cmd==4){
          call I2CPacket.read(I2C_START |I2C_STOP, 0x53,6, (uint8_t*)(&readData));
          return;}
          
      }
  
  async event void I2CPacket.writeDone(error_t error, uint16_t addr,uint8_t length, uint8_t* data) 
         {
          call Resource.release();
          }
  
     async event void I2CPacket.readDone(error_t error, uint16_t addr,uint8_t length, uint8_t* data) {
          if (error == SUCCESS){
		 				
       	//	  printf("Reading from ADXL %d\r", counter);
       	z = ((readData[5]) * 256 + (readData[4]));
		if(counter==1){
			if(e==0)
				{  
				temp=z;	
				}
		else 
			{
			z=(z-temp)+10;	
				
			}
			}
		else if(counter==2){
				if(e==0)
				{  
					temp2=z;		
				}
				else 
				{
					z=(z-temp2)+10;	
				}

		}
		else if(counter==3){
					if(e==0)
				{   
					temp3=z;	
				}
				else 
				{
					z=(z-temp3)+10;	
				}

		}
	
   		//	printf("\nData are from z :%d\n\r", z );
   			if (!sendBusy)
      sendMessage();         
			}
           call Resource.release(); 

          return;
               
      }
  
  event void Send.sendDone(message_t* m, error_t err) {
    if (err != SUCCESS)
      call Leds.led0On();
    sendBusy = FALSE;
  }
  
  event message_t* 
  Receive.receive(message_t* msg, void* payload, uint8_t len) 
    {
   
    if (len != sizeof(EasyCollectionMsg)) {
      return msg;
    }
    else 
    { 	
      EasyCollectionMsg* rsm = (EasyCollectionMsg*)payload;
      a =rsm->adxl_no;
      luxv = rsm->data;
      node1 = rsm-> NodeId;
      call Timer2.startPeriodic(100);
}
	
    return msg;
  
  } 
  	 
}
