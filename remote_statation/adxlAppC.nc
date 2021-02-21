#include<stdio.h>
#include "adxl.h"


configuration adxlAppC{
}
implementation{

  components  MainC, LedsC, adxlC as App;
  
  
  components new TimerMilliC() as Timer0; 

  components SerialPrintfC;
  components ActiveMessageC;
  components new AMSenderC(AM_RADIO_SENSE_MSG);
  components new AMReceiverC(AM_RADIO_SENSE_MSG);
  components new Atm128I2CMasterC() as Atm128I2CMasterC;
  
  App.Boot -> MainC;
  App.Timer0 -> Timer0;
  
  
  
  App.Leds -> LedsC;
  App.AMSend -> AMSenderC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> AMSenderC;  
  
  
  App.Resource -> Atm128I2CMasterC;
  App.I2CPacket1 -> Atm128I2CMasterC;
  App.I2CPacket2 -> Atm128I2CMasterC;
}