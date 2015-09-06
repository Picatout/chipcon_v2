/*
* Copyright 2014, 2015, Jacques Deschênes
* This file is part of CHIPcon v2.
*
*     CHIPcon is free software: you can redistribute it and/or modify
*     it under the terms of the GNU General Public License as published by
*     the Free Software Foundation, either version 3 of the License, or
*     (at your option) any later version.
*
*     CHIPcon is distributed in the hope that it will be useful,
*     but WITHOUT ANY WARRANTY; without even the implied warranty of
*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*     GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with CHIPcon v2.  If not, see <http://www.gnu.org/licenses/>.
*/
/*
 * filesys.h
 *
 * Created: 2014-10-11 21:09:04
 *  Author: Jacques
 */ 


#ifndef FILESYS_H_
#define FILESYS_H_

#include "hardware.h"

// sdcard and FAT library
#include "fat/fat.h"
#include "fat/partition.h"
#include "fat/sd_raw.h"



uint8_t fs_mount();
void fs_umount();

uint8_t  fs_open_dir(char *dir_name);
void fs_close_dir();

uint8_t fs_open_file(char *file_name);
void fs_close_file();
uint8_t fs_load_file(uint16_t file_no);
uint8_t fs_read_dir(struct fat_dir_entry_struct *dir_entry);


#endif /* FILESYS_H_ */