

configuration From_NodeAppC
{
}
implementation
{
  components From_NodeC as App, MainC, LedsC;
  components SerialPrintfC;
  components ActiveMessageC;
  components new AMReceiverC(AM_RADIO_SENSE_MSG);
  
  App.Boot -> MainC;
  
  App.Leds -> LedsC;
  App.Receive -> AMReceiverC;
  App.RadioControl -> ActiveMessageC;
  
}
