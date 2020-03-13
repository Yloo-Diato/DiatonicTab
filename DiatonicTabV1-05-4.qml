//---------------------------------------------------------------------
//Coucou ! DiatonicTab, MuseScore 3 plugin
// Create diatinic accordion tablature from a MuseScore music score
//---------------------------------------------------------------------

//--------------------------------------------------------------------------
/* Ce plugin ajoute le numéro des touches pour accordéon diatonique 
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

  ----------------------------------------------------------------------------*/
import QtQuick 2.2
import MuseScore 3.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2 // FileDialogs
import FileIO 3.0

MuseScore {
   description: qsTr("Tablatures pour accordéon diatonique, avec choix multi-critères")
   menuPath: "Plugins.DiatonicTab.Multi Critere v1-05-04"
   requiresScore: true
   version: "1.05.04"
   pluginType: "dialog"

   property int margin: 10

   width:  480
   height: 600

   // Fichiers JSON pour la mémorisation des parametres
   FileIO {
        id: myParameterFile
        source: homePath() + "/DiatonicTab.json"
        onError: console.log(msg)
        }   
   FileIO {
        id: myKeyboardsFile
        source: homePath() + "/DiatonicTabKeyboards.json"
        onError: console.log(msg)
        }
  
  //---------------------------------------------------------------
  // Variables de fonctionnement
  //---------------------------------------------------------------
  
  //-----------------------------------------------------------------
  // Tableau des plans de clavier main gauche avec sens tiré ou poussé
  //-----------------------------------------------------------------
  property var tabClavierMainGauche: 
                 
     // Clavier 8 basses Sol/Do
     { "GC8B" : 
       { 
         "Description" : qsTr("G/C 8 Basses"),
         "Pousse": "-C-C7-CM-CM7-C--C-7-C/E-C/G-E-E7-EM-EM7-E--E-7-" ,
	    "Tire"  : "-A-A7-AM-AM7-A--A-7" +
	              "-D-D7-DM-DM7-D--D-7" +
	              "-DM/F-DM7/F-D-7/F-DM/A-DM7/A-D-/A-D-7/A-D/A-" ,
        "2sens"  : "-F-F7-FM-FM7-F--F-7" +
                   "-G-G7-GM-GM7-G--G-7" ,
	  },
	  // Clavier Sol/Do 12 basses
       "GC12B" : 
       { 
         "Description" : qsTr("G/C 12 Basses"),
         "Pousse": "-C-C7-CM-CM7-C--C-7-C/E-C/G" + 
                   "-E-E7-EM-EM7-E--E-7" + 
                   "-G#-G#7-G#M-G#M7-G#--G#-7" +
                   "-AB-AB7-ABM-ABM7-AB--AB-7" +
                   "-EB-EB7-EBM-EBM7-EB--EB-7" + 
                   "-D#-D#7-D#M-D#M7-D#--D#-7-"+
                   "-B#-B#7-B#M-B#M7-B#--B#-7-" ,
	    "Tire"  : "-A-A7-AM-AM7-A--A-7" +
	              "-D-D7-DM-DM7-D--D-7" +
	              "-B-B7-BM-BM7-B--B-7" + 
	              "-CB-CB7-CBM-CBM7-CB--CB-7" +
	              "-BB-BB7-BBM-BBM7-BB--BB-7" +
	              "-A#-A#7-A#M-A#M7-A#--A#-7" + 
	              "-F#-F#7-F#M-F#M7-F#--F#-7" +
	              "-GB-GB7-GBM-GBM7-GB--GB-7" +
	              "-C#-C#7-C#M-C#M7-C#--C#-7" +
                   "-DB-DB7-DBM-DBM7-DB--DB-7" + 
                   "-DM/F-DM7/F-D-7/F-DM/A-DM7/A-D-/A-D-7/A-D/A-",
         "2sens" : "-F-F7-FM-FM7-F--F-7" +
                   "-G-G7-GM-GM7-G--G-7" +
                   "-E#-E#7-E#M-E#M7-E#--E#-7-",
	  },
	  // Clavier Sol/Do 18 basses
	 "GC18B" : 
         { 
	 "Description" : qsTr("Sol/Do 18 basses")
         "Titre" : qsTr("G/C 18 Basses"),
         "Pousse": "-C-C7-CM-CM7-C--C-7-C/E-C/G" + 
                   "-E-E7-EM-EM7-E--E-7" + 
                   "-G#-G#7-G#M-G#M7-G#--G#-7" +
                   "-AB-AB7-ABM-ABM7-AB--AB-7" +
                   "-EB-EB7-EBM-EBM7-EB--EB-7" + 
                   "-D#-D#7-D#M-D#M7-D#--D#-7-"+
                   "-B#-B#7-B#M-B#M7-B#--B#-7-" ,
         "Tire"  : "-A-A7-AM-AM7-A--A-7" +
	              "-D-D7-DM-DM7-D--D-7" +
	              "-BB-BB7-BBM-BBM7-BB--BB-7" +
	              "-A#-A#7-A#M-A#M7-A#--A#-7" + 
	              "-F#-F#7-F#M-F#M7-F#--F#-7" +
	              "-GB-GB7-GBM-GBM7-GB--GB-7" +
	              "-C#-C#7-C#M-C#M7-C#--C#-7" +
	              "-DB-DB7-DBM-DBM7-DB--DB-7" + 
	              "-DM/F-DM7/F-D-7/F-DM/A-DM7/A-D-/A-D-7/A-D/A-",
         "2sens" : "-F-F7-FM-FM7-F--F-7" +
                   "-G-G7-GM-GM7-G--G-7" +
                   "-B-B7-BM-BM7-B--B-7" + 
                   "-CB-CB7-CBM-CBM7-CB--CB-7" +
                   "-E#-E#7-E#M-E#M7-E#--E#-7-",
	  },
	  // Clavier 8 basses La/Ré
	"AD" : 
	{ "description": qsTr("8 basses La/Ré")
	    "Titre" : qsTr("A/D 8 Basses"),
	    "Pousse": "-D-F#-Gb-A#-Bb-" ,
	    "Tire"  : "-B-E-",
         "2sens" : "-G-A-",
	  },
	  // Irish diatonic
       "C#D8B" : 
       { 
         "description" : qsTr("C#/D 8 Basses"),
         "Pousse": "-D-D7-DM-DM7-D--D-7" + 
                   "-F#-F#7-F#M-F#M7-F#--F#-7"  ,
         "Tire"  : "-B-B7-BM-BM7-B--B-7" + 
	              "-G-G7-GM-GM7-G--G-7" , 
         "2sens" : "-A-A7-AM-AM7-A--A-7"  +
                   "-E-E7-EM-EM7-E--E-7" ,
	 },
	 // BC
	     "BC8B" : 
         { 
          "description" : qsTr("B/C 8 Basses"),
          "Pousse": "-E-E7-EM-EM7-E--E-7" + 
                    "-C-C7-CM-CM7-C--C-7",
           "Tire" : "-A-A7-AM-AM7-A--A-7" +
                    "-F-F7-FM-FM7-F--F-7" ,
          "2sens" : "-D-D7-DM-DM7-D--D-7" +
                    "-G-G7-GM-GM7-G--G-7",
	  },

     }
     
  //--------------------------------------------------------------------------------------------    
  // Numéro des touches à appuyer. Si plusieurs boutons possible, il y a un / entre les numéros
  // P pour Poussé, T pour Tiré
  // Nom des notes : "C3" à "B3": du Do 2ème interligne clé de fa au si au dessus dernière ligne cla de fa
  //                 "C4" à "B4": du do en bas de la clé de sol au si 3ième ligne clé de sol
  //                 "C5" à "B5": du do 4ième interligne clé de sol au si 2 interlignes au dessus clé de sol 
  //                 "C6" à "B6": notes du dessus
  //--------------------------------------------------------------------------------------------    
  property var planClavier:  
  {
      // Sol/Do, Standard (sans altération touches 1 et 1'), 2 rangs, 21 boutons
      "GCStd2R21" : { 
               description: "G/C,2 rangs, pas d'altération",
               "C3" : ""       ,"C3#"  : ""        ,"D3"  : "2P"    ,"D3#" : ""       ,"E3"  : "1'P"   ,"F3" : "1'T",
               "F3#": "2T"     ,"G3"   : "3P/2'P"  ,"G3#" : ""      ,"A3"  : "3T"     ,"A3#" : " "     ,"B3" : "4P/2'T",
               "C4"  : "3'P/4T","C4#"  : ""        ,"D4"  : "5P/3'T","D4#" : ""       ,"E4"  : "4'P/5T","F4" : "4'T",
               "F4#" : "6T"    ,"G4"   : "6P/5'P"  ,"G4#" : ""      ,"A4"  : "7T/5'T" ,"A4#" : ""      ,"B4" : "7P/6'T",
               "C5"  : "6'P/8T","C5#"  : " "       ,"D5"  : "8P/7'T","D5#" : ""       ,"E5"  : "7'P/9T","F5" : "8'T",
               "F5#" : "10T"   ,"G5"   : "8'P/9P"  ,"G5#" : ""      ,"A5"  : "9'T/11T","A5#" : " "     ,"B5" : "10P/10'T",
               "C6" : "9'P"    ,"C6#"  : ""        ,"D6"  : "11P"   ,"D6#" : ""       ,"E6"  : "10'P"  ,
            },
      // Sol/Do, Alt (avec altération touches 1 et 1'), 2 rangs 21 boutons
      "GCAlt2R21" : { 
               description: "G/C,2 rangs, avec altérations",
               "C3" : ""      ,"C3#" : ""        ,"D3" : "2P"    ,"D3#" : ""       ,"E3" : ""      ,"F3" : "",
               "F3#": "2T"    ,"G3"  : "3P/2'P"  ,"G3#": "1'P"   ,"A3"  : "3T"     ,"A3#": "1'T"   ,"B3" : "4P/2'T",
               "C4" : "3'P/4T","C4#" : "1P"      ,"D4" : "5P/3'T","D4#" : "1T"     ,"E4" : "4'P/5T","F4" : "4'T",
               "F4#": "6T"    ,"G4"  : "6P/5'P"  ,"G4#": ""      ,"A4"  : "7T/5'T" ,"A4#": ""      ,"B4" : "7P/6'T",
               "C5" : "6'P/8T","C5#" : ""        ,"D5" : "8P/7'T","D5#" : ""       ,"E5" : "7'P/9T","F5" : "8'T",
               "F5#": "10T"   ,"G5"  : "8'P/9P"  ,"G5#": ""      ,"A5"  : "9'T/11T","A5#": ""      ,"B5" : "10P/10'T",
               "C6" : "9'P"   ,"C6#" : ""        ,"D6" : "11P"   ,"D6#" : ""       ,"E6" : "10'P"  ,
            },
      // Clavier Loffet 3 rangs
      "GCLoffet3R" : {
               description: "Sol/Do Bernard Loffet 3 rangs",
               "C3" : ""      ,"C3#": ""           ,"D3" : "2P"        ,"D3#": ""            ,"E3" : "1'P/1T","F3": "1'T",
               "F3#": "2T"    ,"G3" : "3P/2'P"     ,"G3#": "1''P"      ,"A3" : "2''P/3T"     ,"A3#": "1''T"  ,"B3": "4P/2'T",
               "C4" : "3'P/4T","C4#": "2''T "      ,"D4" : "5P/3'T"    ,"D4#": " 3''P"       ,"E4" : "4'P/5T","F4": "4'T",
               "F4#": "6T"    ,"G4" : "6P/5'P"     ,"G4#": "4''P/4''T" ,"A4" : "7T/5'T"      ,"A4#": "5''T"  ,"B4": "7P/6'T",
               "C5" : "6'P/8T","C5#": "6''T"       ,"D5" : "8P/7'T"    ,"D5#": "6''P"        ,"E5" : "7'P/9T","F5": "8'T",
               "F5#": "10T"   ,"G5" : "8'P/9P/7''T","G5#": "7''P/8''T ","A5" : "8''P/9'T/11T","A5#": "9''T " ,"B5": "10P/10'T",
               "C6" : "9'P"   ,"C6#": ""           ,"D6" : "11P"       ,"D6#": "9''P "       ,"E6" : "10'P",
                },      
      // Castagnari G/C FH
      "GCCasta3RFH" : {
               description: "Sol/Do Castagnari 3 rangs FH",
               "C3" : ""      ,"C3#": ""            ,"D3" : "2P"        ,"D3#": ""            ,"E3" : "1'P/1T","F3" : "1'T",
               "F3#": "2T"    ,"G3" : "3P/2'P"      ,"G3#": "1''P"      ,"A3" : "2''P/3T"     ,"A3#": "1''T"  ,"B3" : "4P/2'T",
               "C4" : "3'P/4T","C4#": "2''T "       ,"D4" : "5P/3'T"    ,"D4#": "3''P"        ,"E4" : "4'P/5T","F4" : "4'T",
               "F4#": "6T"    ,"G4" : "6P/5'P/3''T" ,"G4#": "4''P/4''T" ,"A4" : "5''P/7T/5'T","A4#": "5''T"  ,"B4" : "7P/6'T",
               "C5" : "6'P/8T","C5#": "6''T"        ,"D5" : "8P/7'T"    ,"D5#": "6''P"        ,"E5" : "7'P/9T","F5" : "8'T",
               "F5#": "10T"   ,"G5" : "8'P/9P/7''T" ,"G5#": "7''P/8''T ","A5" : "8''P/9'T/11T","A5#": "9''T " ,"B5" : "10P/10'T",
               "C6" : "9'P"   ,"C6#": "10''T"       ,"D6" : "11P"       ,"D6#": "9''P "       ,"E6" : "10'P"  ,"G6#": "10''P"
      },
      // Castagnari G/C JPL
      "GCCasta3RJPL" : {
               description: "Sol/Do Castagnari 3 rangs JPL",
               "A2" : ""        ,"B2": "1P"     ,
               "C3#": ""        ,"D3" : "2P"          ,"D3#": " "         ,"E3" : "1'P/1T"      ,"F3" : "1'T"       ,
               "F3#": "2T"      ,"G3" : "3P/2'P/1''T" ,"G3#": "1''P"      ,"A3" : "2''P/3T"     ,"A3#": "2''T"      ,"B3" : "4P/2'T",
               "C4" : "3'P/4T"  ,"C4#": "3''T "       ,"D4" : "5P/3'T"    ,"D4#": "3''P"        ,"E4" : "4'P/5T"    ,"F4" : "4'T",
               "F4#": "6T"      ,"G4" : "6P/5'P/4''T" ,"G4#": "4''P"      ,"A4" : "5''P/7T/5'T" ,"A4#": "5''T"      ,"B4" : "7P/6'T",
               "C5" : "6'P/8T"  ,"C5#": "6''T"        ,"D5" : "8P/7'T"    ,"D5#": "6''P"        ,"E5" : "7'P/9T"    ,"F5" : "8'T",
               "F5#": "10T"     ,"G5" : "8'P/9P/7''T" ,"G5#": "7''P"      ,"A5" : "8''P/9'T/11T","A5#": "8''T"      ,"B5" : "10P/10'T",
               "C6" : "9''T/9'P","C6#": ""            ,"D6" : "11P"       ,"D6#": "9''P/11'T"   ,"E6" : "10'P/10''T","F6" : "",
               "F6#": ""        ,"G6" : "12'P"        ,"G6#": "11'P",
      },
      // Clavier 5' inversé
      "GC5Inv" : {
               description: "Sol/Do 5' Inversé",
               "C3" : ""      ,"C3#": ""      ,"D3" : "2P"    ,"D3#": ""       ,"E3" : "1'P"   ,"F3" : "1'T",
               "F3#": "2T"    ,"G3" : "3P/2'P","G3#": ""      ,"A3" : "3T"     ,"A3#": ""      ,"B3" : "4P/2'T",
               "C4" : "3'P/4T","C4#": ""      ,"D4" : "5P/3'T","D4#": ""       ,"E4" : "4'P/5T","F4" : "4'T",
               "F4#": "6T"    ,"G4" : "6P/5'T","G4#": ""      ,"A4" : "7T/5'P" ,"A4#": ""      ,"B4" : "7P/6'T",
               "C5" : "6'P/8T","C5#": ""      ,"D5" : "8P/7'T","D5#": ""       ,"E5" : "7'P/9T","F5" : "8'T",
               "F5#": "10T"   ,"G5" : "8'P/9P","G5#": ""      ,"A5" : "9'T/11T","A5#": ""      ,"B5" : "10P/10'T",
               "C6" : "9'P"   ,"C6#": ""      ,"D6" : "11P"   ,"D6#": ""       ,"E6" : "10'P"  ,
      },
      // Clavier François Heim
      "GCHeim2" : { 
               description: "Sol/Do, Heim 2",
               "B2" : "1P"    ,  
               "C3" : "0'P "  ,"C3#": ""      ,"D3" : "2P"        ,"D3#": "0''P"      ,"E3" : "1'P/1T","F3" : "1''P/0'T",
               "F3#": "2T"    ,"G3" : "3P/1'T","G3#": " 2''P/0''T","A3" : "3T/2'P"    ,"A3#": "1''T " ,"B3" : "4P/2'T",
               "C4" : "3'P/4T","C4#": "2''T " ,"D4" : "5P/3'T"    ,"D4#": "3''P/3''T" ,"E4" : "4'P/5T","F4" : "4''P/4'T",
               "F4#": "6T"    ,"G4" : "6P/5'T","G4#": "5''P/4''T" ,"A4" : "5'P/7T"    ,"A4#": "5''T"  ,"B4" : "7P/6'T",
               "C5" : "6'P/8T","C5#": "6''T " ,"D5" : "8P/7'T"    ,"D5#": "6''P/7''T ","E5" : "7'P/9T","F5" : "7''P/8'T",
               "F5#": "10T"   ,"G5" : "9P/9'T","G5#": "8''P/8''T" ,"A5" : "8'P/11T"   ,"A5#": "9''T"  ,"B5" : "10P/10'T",
               "C6" : "9'P"   ,"C6#": "10''T ","D6" : "11P/11'T"  ,"D6#": "8''P"      ,"E6" : "10'P"  ,"F6" : "9''P", 
               "F6" : ""      ,"G6" : ""      ,"G6#": ""          ,"A6" : "11'P"      , 
      },
      // Clavier Milleret Pignol
      "GCMillPign" : {
               description: "Milleret/Pignol",
               "B3" : "",  
               "C3" : "","C3#": "0P","D3" : "1P","D3#": " 0''P","E3" : "0'P/1T","F3" : "0''P",
               "F3#": "1''P/2T","G3" : "3P/0'T","G3#": "1'T","A3" : "3T/2'P","A3#": "1'P/0''T ","B3" : "4P/2'T",
               "C4" : "3'P/4T","C4#" : "1''T ","D4"  : "5P/3'T","D4#" : "2''P/2''T","E4"  : "4'P/5T","F4"  : "3''P/4'T",
               "F4#": "4''P/6T","G4"  : "6P/3''T","G4#" : "5'T ","A4"  : "5'P/7T","A4#" : "4''T ","B4"  : "7P/6'T",
               "C5" : "6'P/8T","C5#" : "5''T","D5"  : "8P/7'T","D5#" : "5''P/6''T","E5"  : "7'P/9T","F5"  : "6''P/8'T",
               "F5#": "7''P/10T","G5"  : "9P/7''T","G5#" : "9'T","A5"  : "8'P/11T","A5#" : "8''T","B5"  : "10P/10'T",
               "C6" : "9'P","C6#": "9''T ","D6" : "11P/11'T","D6#": "8''P ","E6" : "10'P", "F6" : "9''P", 
               "F6#" : "10''P","G6"  : "11'P","G6#" : "","A6"  : "",
               },
      "C#DIrish" : {
               description: "C#/D Irish machine",
               "C3#": "0P "    ,"D3" : "0'P","D3#": " "  ,"E3" : ""   ,"F3" : "1P",
               "F3#": "1'/0T"  ,"G3" : "0'T","G3#": "2P ","A3" : "2'P","A3#": "1T","B3" : "1'T",
               "C4" : "2T"     ,"C4#": "3P/2'T ","D4"  : "3'P","D4#" : "3T ","E4"  : "3'T","F4"  : "4P",
               "F4#": "4'P/4T" ,"G4" : "4'T","G4#" : "5P","A4"  : "5'P","A4#" : "5T","B4"  : "5'T",
               "C5" : "6T"     ,"C5#": "6P/6'T ","D5"  : "6'P","D5#" : "7T ","E5"  : "7'T","F5"  : "7P",
               "F5#": "7'P/8T" ,"G5" : "8'T","G5#" : "8P","A5"  : "8'P","A5#" : "9T","B5"  : "9'T",
               "C6" : "10T"    ,"C6#": "9P/10'T ","D6" : "9'P","D6#": "11T","E6" : "","F6" : "10T",
               "f#'" : "10'P"  ,"G6" : "10'P","g#'" : "11P",
            },
       "BCIrish": { 
               description: "BC Irish machine",
               "B3": "0P",
               "C3#": "0'P","D3" : ""   ,"D3#": "1P" ,"E3" : "1'P/0'T","F3" : "",
               "F3#": "2P","G3"  : "2'P","G3#": "1T" ,"A3" : ""       ,"A3#": "2T"    ,"B3" : "3P",
               "C4" : "3'P","C4#" : "3T" ,"D4"  : "3'T","D4#" : "4P"     ,"E4"  : "4'P/4T","F4"  : "4'T",
               "F4#": "5P","G4"   : "5'P","G4#" : "5T" ,"A4"  : "5'T"    ,"A4#" : "6T"    ,"B4"  : "6P/6'T",
               "C5" : "6'P","C5#" : "7T" ,"D5"  : "7'T","D5#" : "7P"     ,"E5"  : "7'P/8T","F5"  : "8'T",
               "F5#": "8P","G5"   : "8'P","G5#" : "9T" ,"A5"  : "9'T"    ,"A5#" : "10T"   ,"B5"  : "9P/10'T",
               "C6" : "9'P","C6#": "11T","D6" : ""   ,"D6#": "10P"    ,"E6" : "10'P"  ,"F6" : "",
               "f#'": "11P","G6" : ""   ,"g#'": ""
            }
      } 

  // Critères à choisir dans la boîte de dialogue
  property var parametres: {
        "sensFa" : 3,         // 1 Fa Tirés  / 2 Fa Poussés / 3 Fa dans les deux sens
        "sensSol" : 3,        // 1 Sol Tirés  / 2 Sol Poussés / 3 Sol dans les deux sens
        "typeJeu" : 3,        // 1 C privilégié  / 2 G privilégié / 3 Jeu croisé
        "typePossibilite": 2, // 2 Afficher toutes les possibilités  / 1 n'afficher qu'une seule possibilité
        "nbLignes":  2,       // 1 tablature sur une seule ligne / 2 tablature sur plusieurs lignes
        "modeleClavierMD": "GCStd2R21", // Par défaut, modèle Sol/Do 2 rangs sans altération touches 1 et 1'
        "modeleClavierMG": "GC8B"    // Par défaut, G/C 8 basses
  }
  
  // Tableau des modèles de clavier : doit être dans le même ordre que le contenu de la comboBox de choix
  property var tabmodeleClavier: [
     "GCStd2R21", // G/C 2 rangs 21 bouton sans altérations touches 1 et 1'
     "GCAlt2R21", // G/C 2 rangs 21 boutons avec altérations touches 1 et 1'
     "GCLoffet3R",    // G/C Bernard Loffet 3 rangs
     "GCCasta3RFH", // G/C Castagnari 3 rangs modele FH (Maryse)
     "GCCasta3RJPL",// G/C Castagnari 3 rangs JPL
     "GC5Inv",    // G/C/5' inversé
     "GCHeim2",     // Heim 2 
     "GCMillPign",  // Milleret pignol
     "C#DIrish",  // C#/D
     "BCIrish" ,  // BC
     ] 
  property var tabModeleClavierMG: [
     "GC8B" , // Sol/Do 8 Basses
     "GC12B", // Sol/Do 12 Basses
     "GC18B", // Sol/Do 18 basses
     "C#D8B", // C#D 8 basses
     "AD8B" , // La/Ré 8 basses
     "BC8B" , // BC 8 basses
     ]


// -------------------------------------------------------------------
// Description de la fenêtre de dialogue
//--------------------------------------------------------------------
 GridLayout {
      id: 'mainLayout'
      anchors.fill: parent
      anchors.margins: 10
      columns: 1

Label {
            width: parent.width
            wrapMode: Label.Wrap
            horizontalAlignment: Qt.AlignHCenter
		    font.bold: true
            text:  qsTr("Tablatures pour accordéons diatoniques")
      }
      
//------------------------------------------------
// Type d'accordéon et plan de clavier Main DROITE
//------------------------------------------------

ComboBox {
         id: comboModeleClavierMD
         //editable: true
         model:  [
               // La liste de choix doit être dans le même ordre que le tableau tabmodeleClavier
                { text:  qsTr("G/C,2 rangs, pas d'altération"), value: "GCStd2R21"  },
                { text:  qsTr("G/C,2 rangs, avec altérations"), value: "GCAlt2R21"  },
                { text:  qsTr("Sol/Do Bernard Loffet 3 rangs"), value: "GCLoffet3R"  },
                { text:  qsTr("Sol/Do Castagnari 3 rangs FH") , value: "GCCasta3RFH"  },
                { text:  qsTr("Sol/Do Castagnari 3 rangs JPL"), value: "GCCasta3RJPL"  },
                { text:  qsTr("Sol/Do 5' Inversé")            , value: "GC5Inv"      },
                { text:  qsTr("Sol/Do, Heim 2")               , value: "GCHeim2" },
                { text:  qsTr("Milleret/Pignol")              , value: "GCMillPign" },
                { text:  qsTr("C#/D Irish machine")           , value: "C#DIrish" },
                { text:  qsTr("BC Irish machine")             , value: "BCIrish" } 
               ]
        // Récupère le code du modèle de clavier
        onActivated: { parametres["modeleClavierMD"] = tabmodeleClavier[index]
                       //console.log("Modele de clavier : " + parametres.modeleClavierMD)
                     }
        }
//------------------------------------------------
// Type d'accordéon et plan de clavier Main GAUCHE
//------------------------------------------------
ComboBox {
         id: comboModeleClavierMG
         model: ListModel {
               id: modelAccMG
               // La liste de choix doit être dans le même ordre que le tableau tabmodeleClavier
               ListElement { text:  qsTr("G/C 8 Basses")   }
               ListElement { text:  qsTr("G/C 12 Basses")  }
               ListElement { text:  qsTr("G/C 18 Basses")  }
               ListElement { text:  qsTr("C#D 8 Basses")   }
               ListElement { text:  qsTr("A/D 8 Basses")   } 
               ListElement { text:  qsTr("B/C 8 Basses")   } 
               }
               
        // Récupère le code du modèle de clavier
        onActivated: { parametres["modeleClavierMG"] = tabModeleClavierMG[index]
//                     console.log("Modele de clavierMG : " + parametres.modeleClavierMG) }
        }
}

//------------------------------------------------
// Sens des mesures de Sol   1 = tiré / 2 = poussé / 3 = dans les deux sens
//------------------------------------------------
GroupBox {
    title:  qsTr("Sens pour les mesures de G (Sol/Do) ou A (La/Ré)")
    RowLayout {
        ExclusiveGroup { id: tabPositionGroupSOL }
        RadioButton {
            text: qsTr("Dans les 2 sens")
            checked: (parametres.sensSol==3)
            exclusiveGroup: tabPositionGroupSOL
            onClicked : {
              parametres.sensSol = 3
              //console.log("Sens Sol " + parametres.sensSol);
            }
        }
        RadioButton {
            text: qsTr("Privilégier le tiré")
            checked: (parametres.sensSol==1)
            exclusiveGroup: tabPositionGroupSOL
            onClicked : {
              parametres.sensSol = 1
              //console.log("Sens Sol " + parametres.sensSol);
            }
          }
        RadioButton {
            text: qsTr("Privilégier le poussé")
            exclusiveGroup: tabPositionGroupSOL
            checked: (parametres.sensSol==2)
            onClicked : {
              parametres.sensSol = 2
              //console.log("Sens Sol " + parametres.sensSol);
            }
          }
    }
}
//------------------------------------------------
// Sens des mesures de Fa   1 = tiré / 2 = poussé / 3 = dans les deux sens
//------------------------------------------------
GroupBox {
    title:qsTr( "Sens pour les mesures de F (Sol/Do) ou de G (La/Ré)")
    RowLayout {
        ExclusiveGroup { id: tabPositionGroupFA }
        RadioButton {
            text:qsTr("Dans les 2 sens")
            checked: (parametres.sensFa==3)
            exclusiveGroup: tabPositionGroupFA
            onClicked : {
              parametres.sensFa = 3
              //console.log("Sens Fa " + parametres.sensFa);
            }
        }
        RadioButton {
            text:qsTr("Privilégier le tiré")
            checked: (parametres.sensFa==1)
            exclusiveGroup: tabPositionGroupFA
            onClicked : {
              parametres.sensFa = 1
              //console.log("Sens Fa " + parametres.sensFa);
            }
  
        }
        RadioButton {
            text:qsTr("Privilégier le poussé")
            checked: (parametres.sensFa==2)
            exclusiveGroup: tabPositionGroupFA
            onClicked : {
              parametres.sensFa = 2
              //console.log("Sens Fa " + parametres.sensFa);
            }
        }
    }
}
//------------------------------------------------
// Sens des mesures de Sol   1 = C / 2 = G / 3 = Croisé
//------------------------------------------------
GroupBox {
    title:qsTr("Jeu Tiré/Poussé ou Croisé")
    RowLayout {
        ExclusiveGroup { id: tabPositionGroupCroise }
        RadioButton {
            text: qsTr("Jeu en croisé")
            exclusiveGroup: tabPositionGroupCroise
             checked: (parametres.typeJeu==3)
            onClicked : {
              parametres.typeJeu = 3
              //console.log("Type de jeu " + parametres.typeJeu);
            }
          }
        RadioButton {
            text:qsTr("Privilégier rang 1")
            checked: (parametres.typeJeu==1)
            exclusiveGroup: tabPositionGroupCroise
            onClicked : {
              parametres.typeJeu = 1
              //console.log("Type de jeu " + parametres.typeJeu);
            }
        }
          RadioButton {
            text:qsTr("Privilégier rang 2")
            checked: (parametres.typeJeu==2)
            exclusiveGroup: tabPositionGroupCroise
            onClicked : {
              parametres.typeJeu = 2
              //console.log("Type de jeu " + parametres.typeJeu);
            }
        }


    }
}
//------------------------------------------------
// Simple ou double possibilité
//------------------------------------------------
GroupBox {
    title: qsTr("Lorsque plusieurs touches correspondent à une même note")
    RowLayout {
        ExclusiveGroup { id: tabPositionGroupPossibilite }
        RadioButton {
            text:qsTr("Afficher toutes les possibilités")
            checked : (parametres.typePossibilite==2)
            exclusiveGroup: tabPositionGroupPossibilite
            onClicked : {
              parametres.typePossibilite = 2
              //console.log("Possibilités " + parametres.typePossibilite);
            }
        }
        RadioButton {
            text:qsTr("N'afficher qu'une seule possibilité")
            checked : (parametres.typePossibilite==1)
            exclusiveGroup: tabPositionGroupPossibilite
            onClicked : {
              parametres.typePossibilite = 1
              //console.log("Possibilités " + parametres.typePossibilite);
            }
        }

    }
}
//------------------------------------------------
// Tablature sur une seule ligne ou sur deux
//------------------------------------------------
GroupBox {
    title: qsTr("Ecrire la tablature sur une seule ligne ou sur 2 lignes")
    RowLayout {
        ExclusiveGroup { id: tabPositionGroupNbLigne }
     RadioButton {
            text:qsTr("Tablature sur plusieurs lignes")
            exclusiveGroup: tabPositionGroupNbLigne
            checked : (parametres.nbLignes==2)
            onClicked : {
              parametres.nbLignes = 2
              //console.log("Nombre de lignes " + parametres.nbLignes);
            }
        }
       
    RadioButton {
            text:qsTr("Tablature sur une seule ligne")
            checked : (parametres.nbLignes==1)
            exclusiveGroup: tabPositionGroupNbLigne
            onClicked : {
              parametres.nbLignes = 1
              //console.log("Nombre de lignes " + parametres.nbLignes);
            }
        }
    }
}
//-----------------------------------------------
   Button {
         id: okButton
         isDefault: true
         Layout.columnSpan: 1
         text: qsTr( "OK")
         onClicked: {
            // Mémorise les parametres pour la prochaine fois
            myParameterFile.write(JSON.stringify(parametres).replace(/,/gi ,",\n"))
            curScore.startCmd();
            // Here start the job --------------
            doTablature();
            // ---------------------------------
            curScore.endCmd();
            Qt.quit();
         }
      } 
   Button {
         id: cancelButton
         Layout.columnSpan: 1
         text: qsTr( "Annuler")
         onClicked: {
            Qt.quit();
         }
      }

  } // GridLayout 

//-------------------------------------------------------
// Début du code
//-------------------------------------------------------
   onRun: {
         
        if (!curScore) Qt.quit();   // Si pas de partition courrante, sortie du plugin
        if (typeof curScore === 'undefined')  Qt.quit();
        
        // Lecture du fichier de parametres
//        console.log("Lecture du fichier " + myParameterFile.source)
        // Lecture du fichier de parametres
//        var document = myParameterFile.read()
//        console.log(document)
        
        parametres = JSON.parse(myParameterFile.read())
        
// Lecture du fichier des claviers -----------------------------------------------------
//        console.log("Lecture du fichier des claviers : " + myKeyboardsFile.source)
//        planClavier = JSON.parse(myKeyboardsFile.read())
//        console.log("Claviers : " + JSON.stringify(planClavier))
// Lecture du fichier des claviers -----------------------------------------------------

        //------------------------------------------------------------------------------
        // initialisation des comboBox selon les parametres mémorisés dans le fichiers de parametres
        //------------------------------------------------------------------------------
        var numClavier 
 
        // Rigth Hand
        
        // Construction automatique du contenu de la comboBox selon le fichier des claviers 
        /* ATTENTION WARNING : THIS FEATURE IS  UNACTIVATED BECAUSE 
           model.append does'nt work in MuseScore plugins
           
        for (numClavier = 0; numClavier < tabmodeleClavier.length; numClavier++) {
             comboModeleClavierMD.model.append({text: planClavier[tabmodeleClavier[numClavier]].description, value: tabmodeleClavier[numClavier]})
        } 
        */
        

        comboModeleClavierMD.currentIndex = 0
        for (numClavier = 0; numClavier < tabmodeleClavier.length; numClavier ++) {
          
          if (tabmodeleClavier[numClavier] == parametres["modeleClavierMD"]) 
               comboModeleClavierMD.currentIndex = numClavier
        }
        // Left Hand 
        comboModeleClavierMG.currentIndex = 0
        for (numClavier = 0; numClavier < tabModeleClavierMG.length; numClavier ++) {
        if (tabModeleClavierMG[numClavier] == parametres["modeleClavierMG"]) 
               comboModeleClavierMG.currentIndex = numClavier
        }
        //------------------------------------------------------------------------------

    }

// ------------------------------------------------------------------------------
// fonction addTouche(cursor, note, accord)
// Cette fonction ajoute le numéro de la touche à actionner en fonction de l'accord main gauche
// Entrée : curseur positionné à l'endroit où il faut insérer le numéro de la touche
//              note à traiter, cette fonction ne traite qu'une seile note à la fois
//              le dernier accord main gauche rencontré pour choisir entre tiré et poussé lorsque c'est possible
// Si la note n'existe pas en poussé mais qu'elle existe en tiré, celle-ci est proposée quelque soit l'accord (A, F, F#))
// et réciproquement
// Les critères définis par l'utilisateur dans la boite de dialogue sont utilisés ici
//------------------------------------------------------------------------------
 function addTouche(cursor, note, accord) {

        // Choix entre STAFF_TEXT et LYRICS : Si tablature sur 2 lignes, LYRICS, sinon STAFF
        var textPousse = (parametres.nbLignes==1) ? newElement(Element.STAFF_TEXT) : newElement(Element.LYRICS)
        var textTire   = (parametres.nbLignes==1) ? newElement(Element.STAFF_TEXT) : newElement(Element.LYRICS)
   
         textPousse.text = textTire.text = ""
         if (parametres.nbLignes!=1) {
               textPousse.no=1
               textTire.no=2
         }

        // note.pitch contient le numéro de la note dans l'univers MuseScore. dans les octaves qui nous concernent
        // pitch - 45 = note numéro A3 (48 = C4,)
         const noNote0 = 45
         var noteNames = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
         var octave = "" + ((note.pitch / 12)-1) + ""
         octave = octave.split("\.")[0]
         var noteName = noteNames[note.pitch % 12] 
         if (noteName.match("#")) 
               noteName = noteName[0] + octave.split("\.")[0] + noteName[1]
          else         
               noteName += octave.split("\.")[0]
                   
        var noBouton = planClavier[parametres.modeleClavierMD][noteName]
        if (!noBouton) noBouton = ""
        
//        console.log("Note : " + noteName +
//                    " noBouton : " + noBouton)
        
        var indexDoubleSens = 0
           
        // Recherche des boutons Tirés et Poussés
        // la variable noBouton peut contenir :
        // xP ou xT pour une seule touche X en Tiré ou en Poussé
        // xP/xT ou xT/xP pour deux touches en Tiré Poussé
        // xP/yP ou xT/yT pour deux touches en Poussé Tiré
        // xP/yP/zT pour trous touches , etc...
        var tabBouton = noBouton.split("/")             // Découpage selon les slash
//        console.log("tabBouton.length : " + tabBouton.length)
        var i = 0
        for (i = 0 ; i < tabBouton.length ; i++) {
//               console.log("tabBouton["+i+"] : " + tabBouton[i])
               if (tabBouton[i].match("P")) textPousse.text += tabBouton[i].replace("P","") + "/"
               if (tabBouton[i].match("T")) textTire.text   += tabBouton[i].replace("T","") + "/"
        }
        if (textPousse.text.match("/$"))  textPousse.text = textPousse.text.substr(0,textPousse.text.length -1)
        if (textTire.text.match("/$"))  textTire.text = textTire.text.substr(0,textTire.text.length -1)
//        console.log("Text Tire : " + textTire.text + " TextPousse : " + textPousse.text)
  
           // Type de Jeu ------------------------------------------------------------
           // Si le jeu est en croisé, on tient compte des accords pour choisir le sens
           // Si le jeu est en tiré poussé, on ne tient pas compte des accords
           
           switch (parametres.typeJeu) {
               
           case 3 : // Jeu en croisé, on tient compte des accords
 
                if (tabClavierMainGauche[parametres.modeleClavierMG]["Tire"].match("-"+accord+"-"))
					if (textTire.text != "")
						textPousse.text    = "";

                if (tabClavierMainGauche[parametres.modeleClavierMG]["Pousse"].match("-"+accord+"-")) 
					if (textPousse.text != "") 
						textTire.text      = "";

                 if (tabClavierMainGauche[parametres.modeleClavierMG]["2sens"].match("-"+accord+"-"))
                 {
                    if ((parametres.modeleClavierMG.match("^GC") && accord.match("F")) ||
                        (parametres.modeleClavierMG.match("^AD") && accord.match("G")) ) {
                      switch (parametres.sensFa) {
                        case 1 :          // Fa (Sol/Do) ou G (La/Ré) en tiré uniquement 
                               if (textTire.text != "") textPousse.text      = ""; // supression du texte poussé
                        break;
                        case 2 :          // Fa (Sol/Do) ou G (La/Ré) en poussé uniquement
                               if (textPousse.text != "") textTire.text      = "";  // supression du texte tiré
                        break;
                      }
                    }
          
                    if ( (parametres.modeleClavierMG.match("^GC") && accord.match("G"))  ||
                         (parametres.modeleClavierMG.match("^AD") && accord.match("A")) ) 
                    { 
                      switch (parametres.sensSol) {
                        case 1 :          // Sol (Sol/Do) ou La (La/Ré) en tiré uniquement
                               if (textTire.text != "") textPousse.text      = ""; // supression du texte poussé
                        break;
                        case 2 :          // Sol (Sol/Do) ou La (La/Ré)  en poussé uniquement
                                if (textPousse.text != "") textTire.text      = "";  // supression du texte tiré
                        break;

                      }
                    }  
                 }
                
           break;
           // jeu en tiré poussé sur le rang 2 (de C sur un GC, de D sur une AD)
           case 2 : 
                 //Si double possibilité , on ne garde que le rang 2
                 if (textTire.text.match("/")) 
                    textTire.text = textTire.text.split("/")[(textTire.text.match(/'$/))?1:0]
	            if (textPousse.text.match("/")) 
	                textPousse.text = textPousse.text.split("/")[(textPousse.text.match(/'$/))?1:0]
	            if (textTire.text.match("'")  && (!textPousse.text.match("'"))) textPousse.text = " "
	            if (textPousse.text.match("'")  && (!textTire.text.match("'"))) textTire.text = " "
	            indexDoubleSens = (textTire.text.match(/\/.*'$/) || textPousse.text.match(/\/.*'$/)) ? 1 : 0
           break;
           // jeu en tiré poussé sur le rang 1 (de G sur un GC, de A sur un AD)
           case 1 : 
                 //Si double possibilité, on ne garde que le rang de 1
                 if (textTire.text.match("/")) 
                        textTire.text = textTire.text.split("/")[(textTire.text.match(/'$/))?0:1]
	            if (textPousse.text.match("/")) 
	                textPousse.text = textPousse.text.split("/")[(textPousse.text.match(/'$/))?0:1] 
	            if (!(textTire.text.match("'"))  && (textPousse.text.match("'"))) textPousse.text = " "
	            if (!(textPousse.text.match("'"))  && (textTire.text.match("'"))) textTire.text = " "
	            indexDoubleSens = (textTire.text.match(/\/.*'$/) || textPousse.text.match(/\/.*'$/)) ? 1 : 0
           break;
           }            // Fin du swith "type de jeu"
           
	   // Gestion des doubles possibilités pour les notes en double sur le clavier
	   // Si on ne veut qu'une seule possibilité, on ne garde que la première définie dans le tableau des touches
	   if (parametres.typePossibilite == 1) {  
	        if (textTire.text.match("/"))   textTire.text   = textTire.text.split("/")[indexDoubleSens]
	        if (textPousse.text.match("/")) textPousse.text = textPousse.text.split("/")[indexDoubleSens]   
	   }
             
           // Définition de l'offset Y selon que la tablature soit sur une ou deux lignes
           var grand = 0//5.5
           if (parametres.nbLignes == 1 ) {
		textPousse.offsetY = 0//0.75     
           	textTire.offsetY = 0//2.25
	   } else {
                textPousse.offsetY = 3//4.5  + grand     
                textTire.offsetY = 6//8  + grand
           }
 
       // Soulignement des touches à tirer
	  if (textTire.text !== "")  
	      textTire.text = "<u>" + textTire.text + "</u>"  // Les numéros de touche en tiré sont soulignés

	// Gestion du nombre de lignes de la tablature
	  if (parametres.nbLignes == 1) {
		textTire.offsetY = textPousse.offsetY  = 0
	  } else {
 
                textTire.autoplace = textPousse.autoplace = false 
          }

        // Pour finir,on ajoute le numéro dans la partition
          //if (!(textPousse == "")) 
               cursor.add(textPousse)
          //if (!(textTire ==  ""))  
               cursor.add(textTire)


//        } if index correct

    }

 
// ---------------------------------------------------------------------
// Fonction doTablature
//
// Fonction principale appelée par le click que le bouton OK
//----------------------------------------------------------------------
function doTablature() {

      var myScore = curScore,                  // Partition en cours
          cursor = myScore.newCursor(),        // Fabrique un curseur pour se déplacer dans les mesures
          startStaff,                          // Début de partition ou début de sélection
          endStaff,                            // Fin de partition ou fin de sélection
          endTick,                             // Numéro du dernier élément de la partition ou de la sélection
          staff = 0,                           // Compteur sur le nombre de portée de la partition
          accordMg,                            // Détermine si on est en Poussé ou en Tiré lorsque c'est possible
          fullScore = false;                   // Partition entière ou sélection

//      console.log("Entrée dans la fonction doTablature")

      // Cherche les portées, on ne travaillera pas sur la dernière portée (en général clé de Fa, Basses et Accords)
      var nbPortees = myScore.nstaves
      //console.log("Nombre de portées =",nbPortees)  

      // pas d'accord main gauche à priori
      accordMg = "zzz"   
      
      // ---------------------------------------------------------
      // Boucle sur chacune des portées sauf la dernière s'il y en a plusieurs
      // ---------------------------------------------------------
      do {
            cursor.voice    = 0;                           // on ne traite que la première voix
            cursor.staffIdx = staff;                       // on traite portée par portée 

	  // Gestion d'une sélection ou du traitement de toute la partition
          //  cursor.rewind(Cursor.SCORE_START); // rembobine au début de la partition

            cursor.rewind(1)       // rembobine au début de la sélection
            if (!cursor.segment) { // pas de sélection
                  fullScore = true;
                  startStaff = 0;       // commence à la première mesure
                  endStaff = curScore.nstaves - 1; // et termine à la dernière
            } else {
                  startStaff = cursor.staffIdx;        // commence au début de la sélection
                  cursor.rewind(2);                       // passe derrière le dernier segment et fixe tick = 0
                  if (cursor.tick === 0) {              // ceci survient lorsque la sélection contient la dernière mesure
                       endTick = curScore.lastSegment.tick + 1;
                  } else {
                      endTick = cursor.tick;
                  }
                 endStaff = cursor.staffIdx;
            }

            if (fullScore) {                          // si pas de sélection
                  cursor.rewind(0);                   // rembobine au début de la partition
             } else {                                 // si sélection
                 cursor.rewind(1);                    // rembobine au début de la sélection
             }

             //console.log("Debut de boucle pour chaque mesure de la portee " + staff)

             // ------------------------------------------
             // Boucle pour chaque mesure de la portée ou de la sélection en cours
             // ------------------------------------------
             while (cursor.segment && (fullScore || cursor.tick < endTick))  {
                    var aCount = 0;
                   
                    // Recherche des accords main gauche (genre Am ou Em ou E7 ...)
                    var annotation = cursor.segment.annotations[aCount];
                    while (annotation) {
                           if (annotation.type == Element.HARMONY){                               
                                //console.log("Annotation : " + annotation.text);
                                accordMg = annotation.text.toUpperCase()
                           }
                           annotation = cursor.segment.annotations[++aCount];     
                    }

                  // Si le curseur pointe sur une à plusieurs notes jouées simultanément
                  if (cursor.element && cursor.element.type == Element.CHORD) {
                        var notes = cursor.element.notes                           
                        // Boucle pour chaque note joué en même temps
                        for (var i = 0; i < notes.length; i++) {
                            addTouche(cursor, notes[i], accordMg)
                        } // end for chaque note de l'accord

                  } // end if CHORD

                  cursor.next() //Element suivant
               
             } // fin du while cursor.segment et (fullScore || cursor.tick < endTick)

             staff+=1 // Portée suivante          

      } while ((staff < curScore.nstaves-1) && fullScore)  // fin du for chaque portée sauf si sélection

       // Rappel : on ne traite pas la dernière portée qui est probablement en clé de fa, 
       // avec basses et accords. Pour la traiter quand même, il suffit de la sélectionner
        
  }   // Fin de la fonction doTablature
  
   
}  // MuseScore
