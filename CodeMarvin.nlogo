globals [
  opinion-somme ;; somme de l'opinion de toute la population
  opinion-globale ;; l'opinion de la population entre 0 (bleu) et la population (rouge) (opinion-somme/population)
  opinion-autre ;; opinion de la tortue discutant avec la tortue sujet
  alea ;; variable permettant de définir un nombre entre 0 et 100
  voteBleu ;; variable retennant le nombre de votes bleus au moment de l'élection
  voteRouge ;; variable retennant le nombre de votes rouges au moment de l'élection
  i ;; compteur
  selected ;; l'agent selectionné

  dark-blue
  light-blue
  neutral-color
  light-red
  dark-red
]

turtles-own [
  rural? ;; est-il de la ville ou de la campagne, si c'est vrai, il est de la campagne
  vieux? ;; est-il vieux ou jeune, si c'est vrai, il est vieux
  cadre? ;; est-il cadre ou non, si c'est vrai, il est cadre
  opinion ;; quel est son opinion politique de 0 (bleu) à 100 (rouge)
  influence ;; c'est le nombre de personnes autour de lui qu'il peut influencer à chaque tick de 1 à 50
  malleabilite ;; taux de 0 à 100 qui détermine à quel point quelqu'un peut changer d'avis
]

to setup
  clear-all
  set selected nobody
  set dark-blue 105
  set light-blue 97
  set neutral-color 9
  set light-red 17
  set dark-red 14
  stop-inspecting-dead-agents
  set-default-shape turtles "person"
  set i 0 ;; initialisation du compteur
  create-turtles population
  [ setxy random-xcor random-ycor ;; place les agents de manière aléatoire dans l'environnement
    set opinion random 101 ;; donne une opinion aléatoire entre 0 et 100
    set opinion-somme opinion-somme + opinion ;; fait la somme de tous les opinions pour vérifier les conditions initiales
    set influence random 51 ;; donne la force d'influence de 0 à 10
    set size 1
    ;; donne la couleur en fonction de l'opinion
    ifelse opinion < 20 [set color dark-blue]
    [ifelse opinion < 40  [set color light-blue]
      [ifelse opinion < 60  [set color neutral-color]
        [ifelse opinion < 80  [set color light-red] [set color dark-red]]]]
    if influence = 50 [set size 2] ;; représente les plus gros influenceurs
    ifelse i < vieux/jeunes [set vieux? true set shape "star"] [set vieux? false set shape "triangle"] ;; divise la population en vieux et jeunes
    ifelse i < noncadres/cadres [set cadre? true] [set cadre? false] ;; divise la population en cadres et non cadres
    ifelse i < ruraux/urbains [set rural? true] [set rural? false] ;; divise la population en ruraux et urbains
    set i i + 1 ;; tour de compteur
    ifelse vieux? [set maleabilite random 31] [set maleabilite random 71] ;;définie la maléabilité de chaque tortue entre 0 et 30 pour les vieux ou entre 0 et 70 pour les jeunes
    ifelse cadre? [ifelse maleabilite > 10 [set maleabilite maleabilite - 10] [set maleabilite 0]] [set maleabilite maleabilite + 10] ;; coeff de maleabilite en fct de si une personne est cadre ou non
  ]
  ;;setup-patches
  set opinion-globale opinion-somme / population ;; calcul de l'opinion global
  set i 0 ;; reset du compteur pour d'autres utilisation dans le reste du code
  watch one-of turtles ;; permet d'observer un agent aléatoire au début de la simulation
  inspect subject
  set selected subject
  ask selected [pen-down] ;; on demande a l'agent selectionné de dessiner sa trace de déplacement
  reset-ticks
end

to go
  if mouse-down? [changer-inspect] ;; si le bouton de la souris est pressé alors faire changer-inspect
  ask turtles
  [
    ifelse rural? [chercher-ami-campagne] [chercher-ami-ville] ;; recherche d'un ami avec qui discuter
    convaincre-moi ;; modification de l'opinion et actualisation de la couleur de la tortue en fonction
    ifelse opinion < 20 [set color dark-blue]
    [ifelse opinion < 40 [set color light-blue]
      [ifelse opinion < 60 [set color neutral-color]
        [ifelse opinion < 80 [set color light-red] [set color dark-red]]]]
    set i i + 1 ;; tour de compteur
    if i = 1000 ;; si on a fait toutes les tortues, on actualise l'opinion globale sinon rien
    [
    set opinion-globale opinion-somme / population
    set opinion-somme 0 ;; remise a 0 de la variable intermédiaire
    set i 0 ;; remise à 0 du compteur
    ]
  ]
  if ( ticks >= 3000 ) [
    voter
    stop
  ]
  tick
end

to changer-inspect ;; permet de changer d'agent à observer
  ask selected [pen-up]
  ask selected [ stop-inspecting self ]
  clear-drawing
  set selected min-one-of turtles [distancexy mouse-xcor mouse-ycor] ;; selectionne l'agent le plus proche du curseur de la souris
  watch selected
  inspect selected
  ask selected [pen-down]
end

to chercher-ami-campagne
  set alea random 101
  ifelse alea < 90 ;; 90% de chance d'aller voir quelqu'un qui nous ressemble sinon voir un différent
  [
    if vieux? and one-of (turtles in-radius 3) with [vieux? = true] != nobody ;; si il existe quelqu'un dans les 3 patch et que c'est un vieux faire
    [
      face one-of (turtles in-radius 3) with [vieux? = true] ;; se tourner vers un des vieux
      fd random 2 ;; avancer de 0 ou 1 patch
    ]
    if not vieux? and one-of (turtles in-radius 3) with [vieux? = false] != nobody
    [
      face one-of (turtles in-radius 3) with [vieux? = false] ;; se tourner vers un jeune
      fd random 3 ;; avancer de 0, 1 ou 2 patch
    ]
  ]
  [
    if vieux? and one-of (turtles in-radius 3) with [vieux? = false] != nobody ;; si il existe quelqu'un dans les 3 patch et que c'est un jeune faire
    [
      face one-of (turtles in-radius 3) with [vieux? = false] ;; se tourner vers un des jeunes
      fd random 2 ;; avancer de 0 ou 1 patch
    ]
    if not vieux? and one-of (turtles in-radius 3) with [vieux? = true] != nobody
    [
      face one-of (turtles in-radius 3) with [vieux? = true] ;; se tourner vers un vieux
      fd random 3 ;; avancer de 0, 1 ou 2 patch
    ]
  ]
end

to chercher-ami-ville ;; pareil que pour chercher-ami-campagne mais avec un plus grand rayon d'action
  if vieux? and one-of (turtles in-radius 5) with [vieux? = true] != nobody
  [
    face one-of (turtles in-radius 5) with [vieux? = true]
    fd random 3
  ]
 if not vieux? and one-of (turtles in-radius 5) with [vieux? = false] != nobody
  [
    face one-of (turtles in-radius 5) with [vieux? = false]
    fd random 4
  ]
end

to convaincre-moi
  set alea random 101 ;; tirer au sort un nombre représentant si la discussion avec un ami a su convaincre ou non
  ifelse one-of (turtles in-radius 1) with [influence = 50] != nobody ;; si un de ses voisins direct est un influenceur et qu'il existe un voisin avec qui discuter alors la tortue deviens plus maléable
    [set maleabilite maleabilite + 10
      if alea < maleabilite ;; si la discussion a été convaincante alors
      [
        set opinion-autre [opinion] of one-of turtles in-radius 1 ;; choisir une opinion parmis ses voisins
        if opinion-autre > opinion [set opinion opinion + 5] ;; si son opinion est supérieure, augmenter la sienne sinon la diminuer
        if opinion-autre < opinion [set opinion opinion - 5]
        set opinion [opinion] of one-of turtles in-radius 1
      ]
      ifelse maleabilite > 10 [set maleabilite maleabilite - 10] [set maleabilite 0]]
    [if alea < maleabilite
      [
        set opinion-autre [opinion] of one-of turtles in-radius 1
        if opinion-autre > opinion [set opinion opinion + 5]
        if opinion-autre < opinion [set opinion opinion - 5]
        ;set opinion [opinion] of one-of turtles in-radius 1
      ]
    ]
  set opinion-somme opinion-somme + opinion
end

to voter
  set voteBleu 0
  set voteRouge 0
  ask turtles[
    ifelse opinion < 40 [set voteBleu  (voteBleu + 1)]
    [ifelse opinion < 50 [
      set alea random 2
      set voteBleu (voteBleu + 1 * alea)
    ]
    [ifelse opinion > 60 [set voteRouge (voteRouge + 1)]
    [ set alea random 2
          set voteRouge (voteRouge + 1 * alea)]]]
  ]
end

to creer_influenceur_souris
  if mouse-down? [
    ask patch mouse-xcor mouse-ycor [
      sprout 1 [
        set opinion random 101 ;; donne une opinion aléatoire entre 0 et 100
        set influence 50
        set size 2
        ;; donne la couleur en fonction de l'opinion
        ifelse opinion < 20 [set color dark-blue]
        [ifelse opinion < 40  [set color light-blue]
          [ifelse opinion < 60  [set color neutral-color]
            [ifelse opinion < 80  [set color light-red] [set color dark-red]]]]
        ifelse random population + 1 < vieux/jeunes [set vieux? true set shape "star"] [set vieux? false set shape "triangle"] ;; divise la population en vieux et jeunes
        ifelse random population + 1 < noncadres/cadres [set cadre? true] [set cadre? false] ;; divise la population en cadres et non cadres
        ifelse random population + 1 < ruraux/urbains [set rural? true] [set rural? false] ;; divise la population en ruraux et urbains
        ifelse vieux? [set malleabilite random 31] [set malleabilite random 71] ;;définie la maléabilité de chaque tortue entre 0 et 30 pour les vieux ou entre 0 et 70 pour les jeunes
        ifelse cadre? [set malleabilite malleabilite - 10] [set malleabilite malleabilite + 10] ;; coeff de malleabilite en fct de si une personne est cadre ou non
      ]
    ]

  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
344
49
795
501
-1
-1
13.42424242424243
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

INPUTBOX
36
53
191
113
population
1000.0
1
0
Number

SLIDER
26
127
198
160
vieux/jeunes
vieux/jeunes
0
population
470.0
10
1
NIL
HORIZONTAL

SLIDER
24
185
196
218
noncadres/cadres
noncadres/cadres
0
population
760.0
10
1
NIL
HORIZONTAL

SLIDER
26
240
198
273
ruraux/urbains
ruraux/urbains
0
population
900.0
10
1
NIL
HORIZONTAL

BUTTON
233
32
296
65
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
31
290
162
335
NIL
opinion-globale
17
1
11

BUTTON
237
149
300
182
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
20
356
342
632
Opinion
Ticks
Opinion
0.0
0.0
0.0
1000.0
true
true
"" ""
PENS
"0-20" 10.0 0 -13345367 true "" "plot count turtles with [opinion < 20]"
"20-40" 10.0 0 -8275240 true "" "plot count turtles with [opinion < 40 and opinion > 19.99]"
"40-60" 10.0 0 -7500403 true "" "plot count turtles with [opinion < 60 and opinion > 39.99]"
"60-80" 10.0 0 -1604481 true "" "plot count turtles with [opinion < 80 and opinion > 59.99]"
"80-100" 10.0 0 -5298144 true "" "plot count turtles with [opinion > 79.99]"

BUTTON
348
506
502
539
Flash news bleu foncé
ask n-of nombre turtles [set opinion random 21]\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
554
559
772
592
nombre
nombre
10
100
100.0
10
1
personnes influencées
HORIZONTAL

BUTTON
346
541
497
574
Flash news bleu claire
ask n-of nombre turtles [set opinion 20 + random 21]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
642
506
775
539
Flash news neutre
ask n-of nombre turtles [set opinion 40 + random 21]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
347
577
501
610
Flash news rouge clair
ask n-of nombre turtles [set opinion 60 + random 21]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
343
616
506
649
Flash news rouge foncé
ask n-of nombre turtles [set opinion 80 + random 21]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
170
290
244
335
NIL
VoteRouge
17
1
11

MONITOR
253
290
325
335
NIL
VoteBleu
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
