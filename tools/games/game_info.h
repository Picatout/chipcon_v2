/* 
 * File:   game_info.h
 * Author: Jacques
 *
 * Created on 6 février 2015, 07:36
 */

#ifndef GAME_INFO_H
#define	GAME_INFO_H

#ifdef	__cplusplus
extern "C" {
#endif

#define KEYMAP_SIZE (16)

typedef struct{
    char name[32];
    uint16_t size;
    const uint8_t *binary;
    const char *description;
}game_info_t;



#ifdef	__cplusplus
}
#endif

#endif	/* GAME_INFO_H */

