/*
* Copyright 2014,2015 Jacques Deschênes
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
 * chipcon_config.h
 *
 * Created: 2014-10-14 13:17:40
 *  Author: Jacques Deschênes
 *  
 * Ce fichier doit-être inclus au début de hardware.h
 */ 


#ifndef CHIPCON_CONFIG_H_
#define CHIPCON_CONFIG_H_

//définir SDC_SUPPORT à 1
//pour une console avec
//carte SD
//sinon mettre à 0
#define SDC_SUPPORT 1

// pour déboguage firware seulement
#define FW_DEBUG  0
// pour inclure du code test pendant le développement
// mettre à 0 autrement
#define TEST 1

// en diminiuant la résolution
// verticale on augmente la vitesse
// de la VM.
// définir DEFVRES à 0 pour VRES=88
// définir DEFVRES à 1 pour VRES=64
// si SD_RAW_SDHC==1 DEFRES est mis à 2
// pour une résolution intermédaire
#define DEFVRES 0
#include "sd_raw_config.h"
// lorsque SD_RAW_SDHC est à 1
// il faut plus de mémoire RAM
// il n'en reste plus assé pour 
// augmenter la VRES à 88 lignes
#if SD_RAW_SDHC
#undef DEFVRES
#define DEFVRES 2
#endif
#endif /* CHIPCON_CONFIG_H_ */