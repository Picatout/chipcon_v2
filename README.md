chipcon_v2
=======

console de jeux rétro conçue avec un Atmega328P

caractéristiques:
=================
* Version modifiée de la console CHIPCON (https://github.com/picatout/chipcon)
* sortie vidéo monochrome NTSC
* résolution vidéo: 128x88
* sortie son tonalité.
* contrôle de jeux: joystick Atari 2600
* jeux sur carte SD.
* quelques jeux en mémoire flash
* possède un émulateur/débogueur sur plateforme windows 

modifications matérielle:
=========================
 * Le clavier hexadécimal a été remplacé par un joystick Atari 2600.
 * Le bouton contrôle de vitesse a été suprimé.

Modifications logicielles:
==========================
* La résolution verticale est passé de 64 à 88 pixels.
* la machine virtuelle n'est plus compatible avec SCHIP. De toute façon puisque le clavier a été remplacé par un joystick,
  il n'est n'étais plus possible d'assuré cette compatibilité. 
* L'espace adressable passe de 4096 à 8192. 
* certaines instructions de la VM ont étées suprimées et d'autres ajoutées.
* ajout cache instructions pour accélérer la VM.

licences:
=========
licence logicielle GPLv3,  Voir le fichier copying.txt
licence hardware  Creative Commons CC-SA-BY, voir cc-license 

