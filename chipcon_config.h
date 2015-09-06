/*
* Copyright 2014,2015 Jacques Desch�nes
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
 *  Author: Jacques Desch�nes
 *  
 * Ce fichier doit-�tre inclus au d�but de hardware.h
 */ 


#ifndef CHIPCON_CONFIG_H_
#define CHIPCON_CONFIG_H_

//d�finir SDC_SUPPORT � 1
//pour une console avec
//carte SD
//sinon mettre � 0
#define SDC_SUPPORT 1

// pour d�boguage firware seulement
#define FW_DEBUG  0
// pour inclure du code test pendant le d�veloppement
// mettre � 0 autrement
#define TEST 1

// en diminiuant la r�solution
// verticale on augmente la vitesse
// de la VM.
// d�finir DEFVRES � 0 pour VRES=88
// d�finir DEFVRES � 1 pour VRES=64
// si SD_RAW_SDHC==1 DEFRES est mis � 2
// pour une r�solution interm�daire
#define DEFVRES 0
#include "sd_raw_config.h"
// lorsque SD_RAW_SDHC est � 1
// il faut plus de m�moire RAM
// il n'en reste plus ass� pour 
// augmenter la VRES � 88 lignes
#if SD_RAW_SDHC
#undef DEFVRES
#define DEFVRES 2
#endif
#endif /* CHIPCON_CONFIG_H_ */