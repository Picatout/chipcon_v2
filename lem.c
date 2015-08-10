#include "lem.h"

PROGMEM const uint8_t lem_info[]="";

PROGMEM const uint8_t lem[LEM_SIZE]={
	0x00,0xe0,0x20,0xc9,0x69,0x00,0x68,0x00,0x78,0x01,0x9e,0x08,0x60,0x10,0x8e,0x05,
	0x8e,0x06,0x6d,0x00,0x6c,0x00,0x6b,0x00,0x6a,0x64,0x20,0x8e,0x20,0x74,0x20,0xba,
	0x4a,0x00,0x10,0x2b,0x60,0x08,0xe0,0xa1,0x10,0x1c,0x60,0x10,0xe0,0xa1,0x10,0x20,
	0x60,0x20,0xe0,0xa1,0x10,0x24,0x10,0x2b,0x20,0xba,0x7c,0xff,0x7a,0xff,0x10,0x29,
	0x20,0xba,0x7c,0x01,0x7a,0xff,0x10,0x29,0x20,0xba,0x7b,0xfe,0x3a,0x01,0x7a,0xff,
	0x7a,0xff,0x90,0x44,0x20,0xba,0x20,0xba,0x20,0x74,0x8e,0xc4,0x60,0x7f,0x8e,0x02,
	0x8d,0xb4,0x7b,0x01,0x20,0x74,0x4f,0x01,0x10,0x4b,0x20,0xba,0x4a,0x00,0x10,0x3b,
	0x60,0x14,0x20,0x46,0x10,0x10,0x20,0xba,0x60,0x0a,0x61,0x04,0x90,0x11,0x60,0x04,
	0x20,0x46,0x20,0xba,0x60,0x04,0x90,0x11,0x20,0x46,0x10,0x10,0xf0,0x15,0xf0,0x07,
	0x30,0x00,0x10,0x47,0x00,0xee,0x20,0xba,0x60,0x02,0x80,0xb5,0x3f,0x01,0x10,0x63,
	0x60,0x02,0x80,0xc5,0x3f,0x01,0x10,0x63,0x80,0xe0,0x80,0x75,0x3f,0x01,0x10,0x63,
	0x80,0x70,0x70,0x10,0x80,0xe7,0x3f,0x00,0x10,0x63,0x79,0x01,0xa0,0xf1,0x61,0x00,
	0x62,0x10,0x91,0x22,0x10,0x67,0xa0,0xeb,0x61,0x00,0x62,0x10,0x91,0x22,0x20,0x77,
	0x60,0x3c,0x20,0x46,0x60,0x20,0xe0,0x9e,0x10,0x6b,0x61,0x01,0x62,0x0a,0x91,0x21,
	0xe0,0xa1,0x10,0x70,0x00,0xe0,0x10,0x04,0xa0,0xd6,0xde,0xd0,0x00,0xee,0x61,0x00,
	0x62,0x0a,0xa1,0x15,0xf9,0x33,0x20,0x83,0xa0,0xe6,0xd1,0x25,0x71,0x04,0xa1,0x15,
	0xf8,0x33,0x20,0x83,0x00,0xee,0x63,0x00,0xa1,0x15,0xf3,0x1e,0xf0,0x65,0xf0,0x29,
	0xd1,0x25,0x71,0x04,0x73,0x01,0x33,0x03,0x10,0x84,0x00,0xee,0x65,0x00,0xc7,0xff,
	0x90,0x08,0x63,0x10,0x80,0x35,0x90,0x06,0x80,0x75,0x90,0x07,0x3f,0x01,0x87,0x00,
	0x84,0x70,0x74,0x10,0xc1,0x0f,0x90,0x09,0x81,0x07,0x83,0x50,0x83,0x75,0x3f,0x01,
	0x10,0xa5,0x83,0x50,0x83,0x45,0x3f,0x01,0x10,0xb4,0x90,0x09,0x80,0x06,0x80,0x15,
	0x3f,0x00,0x71,0x01,0x90,0x09,0x70,0xff,0x80,0x17,0x3f,0x00,0x71,0xff,0xc3,0x03,
	0x83,0x06,0x33,0x00,0x71,0xfe,0x71,0x01,0x95,0x13,0x75,0x01,0x90,0x08,0x55,0x00,
	0x10,0x9d,0x00,0xee,0x61,0x00,0x62,0x00,0x63,0x00,0xa1,0x15,0xfa,0x33,0xa1,0x15,
	0xf3,0x1e,0xf0,0x65,0xf0,0x30,0xd1,0x2a,0x71,0x08,0x73,0x01,0x33,0x03,0x10,0xbf,
	0x00,0xee,0xa0,0xf9,0x61,0x00,0x92,0x09,0x82,0x06,0x91,0x22,0x91,0x09,0x00,0xd1,
	0x60,0x03,0x20,0x46,0x71,0xff,0x31,0x00,0x10,0xcf,0x00,0xee,0x03,0xc0,0x06,0x60,
	0x1f,0xf8,0x3f,0xfc,0x20,0x04,0xaf,0xf5,0x6c,0x36,0x2c,0x34,0x6f,0xf6,0xa0,0x05,
	0x3f,0xfc,0x3f,0xfc,0x12,0x90,0x24,0x48,0x60,0x0c,0xc0,0x06,0x20,0x00,0x40,0x00,
	0x40,0x00,0x80,0x00,0x80,0x00,0x79,0x6f,0x75,0x20,0x63,0x72,0x61,0x73,0x68,0x65,
	0x64,0x00,0x63,0x6f,0x6e,0x67,0x72,0x61,0x74,0x75,0x6c,0x61,0x74,0x69,0x6f,0x6e,
	0x21,0x00,0x4c,0x45,0x4d,0x0a,0x4a,0x61,0x63,0x71,0x75,0x65,0x73,0x20,0x44,0x65,
	0x73,0x63,0x68,0x65,0x6e,0x65,0x73,0x0a,0x43,0x6f,0x70,0x79,0x72,0x69,0x67,0x68,
	0x74,0x20,0x32,0x30,0x31,0x34,0x2c,0x32,0x30,0x31,0x35,0x0a,0x6c,0x69,0x63,0x65,
	0x6e,0x63,0x65,0x20,0x47,0x50,0x4c,0x76,0x33,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
};