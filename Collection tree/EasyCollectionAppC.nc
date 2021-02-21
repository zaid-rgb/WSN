configuration EasyCollectionAppC {}
implementation {
  components EasyCollectionC, MainC, LedsC, ActiveMessageC;
  components CollectionC as Collector;
  components new CollectionSenderC(0xee);
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  components SerialPrintfC;
  components new Msp430I2CC() as Atm128I2CMasterC;
  
  EasyCollectionC.Boot -> MainC;
  EasyCollectionC.RadioControl -> ActiveMessageC;
  EasyCollectionC.RoutingControl -> Collector;
  EasyCollectionC.Leds -> LedsC;
  EasyCollectionC.Timer1 -> Timer1;
  EasyCollectionC.Send -> CollectionSenderC;
  EasyCollectionC.RootControl -> Collector;
  EasyCollectionC.Receive -> Collector.Receive[0xee];
  EasyCollectionC.Timer2 -> Timer2;
  
  EasyCollectionC.Resource -> Atm128I2CMasterC;
  EasyCollectionC.I2CPacket -> Atm128I2CMasterC;
}
