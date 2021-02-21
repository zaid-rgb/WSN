#include<stdio.h>
#include "adxl.h"



module From_NodeC @safe()
{
  uses interface Leds;
  uses interface Boot;
  uses interface Receive;
  uses interface Packet;
  uses interface SplitControl as RadioControl;
    
}

implementation
{
  event void Boot.booted()
  {
    call RadioControl.start();
    
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
    	printf("Checking");
  }
  }
event void RadioControl.stopDone(error_t err) {
  }
  
  
  event message_t* Receive.receive(message_t* bufPtr, 
           void* payload, uint8_t len) 
  {
    uint16_t node-id, node-value;
    uint8_t sensor_number;
    if (len != sizeof(radio_sense_msg_t)) {
      return bufPtr;
    }
    else 
    {
      radio_sense_msg_t* rsm = (radio_sense_msg_t*)payload;
      node-id = rsm -> Node_Id
      sensor_number = Sensor_No;
      node-value = rsm-> Sensor_Value;
      
      printf("%d %d %d\r", node-id, sensor-number, node-value);
      

    }
    return bufPtr;
    
  }  
} 

  nx_uint16_t Node_Id;
  nx_uint8_t Sensor_No;
  nx_uint16_t Sensor_Value;
