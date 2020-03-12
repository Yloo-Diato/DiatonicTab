# DiatonicTab
Plugin MuseScore, Diatonic Tablature for diatonic accordion
Actual version : v1.05.03
Devlopment version : v1.05.04
//--------------------------------------------------------------------------
//  Copyright (C) 2016 Jean-Michel Bencetti - https://github.com/JMiB-Fr-2020/DiatonicTab
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENSE
//
//--------------------------------------------------------------------------

  Ce plugin ajoute le numéro des touches pour accordéon diatonique 
    afin de créer une forme très simplifiée de tablature
    Ce plugin utlise le textes de paroles pour mettre les numéros de touches
    afin de pouvoir aligner verticalement différement les tirés et les poussés
    
  Auteur : Jean-Michel Bencetti
  Version courrante : 1.04
  Date : v1.00 : 2019-06-13 : développement initial
         v1.02 : 2019-09-02 : tient compte des accords main gauche pour proposer les notes en tiré ou en poussé
         v1.03 : 2019-10-11 : ajoute la possibilité de ne traiter que des mesures sélectionnées
	 v1.04 : 2020-02-24 : propose une fenêtre de dialogue pour utiliser différents critères
	 v1.05 : 2020-03-02 : gestion de plans de claviers différents
	                      mémorisation des parametres dans un fichier format json
	                      préparation à la traduction du plugin
	    
  Description version v1.02 :
    Pour les accords main gauche A, Am, D, Dm, seules les touches en tirées sont proposées
    Pour les accords main gauche E, Em, E7, C, seules les touches en poussé sont proposées
    Pour les accords main gauche G et F, les deux numéros de touches sont proposées lorsqu'elles existes
    Les notes altérées (sauf F#) ne sont pas proposées car trop de plan de claviers différents existent
    Pour la note G, les deux propositions sont faites sur le premier et deuxième rang

  
  Après le passage du plugin, il reste donc à faire le ménage pour supprimer les numéros de touches en trop
  pour les accords F et G et sur les notes G main droite
  
  Description version v1.03 : 
  - pour limiter le travail du plugin, il est possible de sélectionner les mesures à traiter.
  - sans sélection, le plugin travaille sur touite la partition sanf la dernière portée.
  - la dernière portée n'est pas traitée car elle est sencée être en clé de Fa avec des Basses et des Accords.
  - pour traiter quand même la dernière portée, il suffit de la sélectionner.

  Description version v1.04 :
  - propose une tablature sur une ou deux lignes
  - propose de n'afficher qu'une seule alternative lorsque des notes existent sous plusieurs touches
  - propose de tirer ou de pousser les G et les F ou d'indiquer les deux possibilités
  - propose de privilégier le rang de G ou celui de C ou de favoriser le jeu en croisé
  - propose un clavier 2 rangs ou 3 rangs (plan castagnari)
  - utiliser les accords A B Bb C D E f G G# pour déterminer le sens 
  
  Description version v1.05
  - Modification de la structure des plans de clavier main droite et main gauche pour admettre plusieurs type d'accordéons
  - Adaptation du formulaire de choix en conséquence
  - Adaptation du code pour prendre en compte les nouvelles structures
  - Mémorisation des parametres dans un fichier DiatonicTab.json
  - Ajouts plans de claviers



