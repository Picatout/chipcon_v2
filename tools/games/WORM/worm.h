#ifndef WORM_
#define WORM_

#include <avr/pgmspace.h>
#include <stdint.h>

#define WORM_SIZE (658)

extern const uint8_t worm[WORM_SIZE];

extern const uint8_t worm_info[];

#endif