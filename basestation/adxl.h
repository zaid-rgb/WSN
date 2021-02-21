#ifndef ADXL_H
#define ADXL_H

typedef nx_struct radio_sense_msg {
  nx_uint16_t Node_Id;
  nx_uint8_t Sensor_No;
  nx_uint16_t Sensor_Value;
  
} radio_sense_msg_t;

enum {
  AM_RADIO_SENSE_MSG = 7,
};
#endif /* ADXL_H */
