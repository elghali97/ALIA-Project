:-dynamic column/2.
:-dynamic piece/3.
/*init du jeu*/
init:-init_c(7),init_p(7,6),play('r'). 
/*init des colonnes à 0*/
init_c(0):-!.
init_c(N):-assert(column(N,0)),N1 is N-1,init_c(N1),!.

/* init des pieces à ?*/
init_p(0,6):-!.
init_p(I,1):-assert(piece(I,1,'?')),I1 is I-1,init_p(I1,6),!.
init_p(I,J):-assert(piece(I,J,'?')),J1 is J-1,init_p(I,J1),!.

play(Player) :-
        move(Player),
    	not(endGame(Player)),
    	changePlayer(Player,Player1),
        play(Player1).

changePlayer('r','y').
changePlayer('y','r').

/* Prédicat displayBoard (1,6) pour afficher */
displayBoard(7,1):-piece(7,1,X),write(' | '),write(X),writeln(' | '),writeln('_______________________').
displayBoard(7,J):-piece(7,J,X),write(' | '),write(X),writeln(' | '),writeln('_______________________'),J1 is J-1,displayBoard(1,J1),!.
displayBoard(I,J):-piece(I,J,X),write(' | '),write(X),write(' | '),I1 is I+1,displayBoard(I1,J),!.


/*ajout d'un jeton dans une position valide*/
add(NC,Player):-
    column(NC,N),
    N<7,
    N1 is N+1,
    retract(piece(NC,N1,'?')),
    asserta(piece(NC,N1,Player)),
    retract(column(NC,N)),
assert(column(NC,N1)).


/* Prédicat isBoardFull (1) pour vérifier si la grille est pleine */
isBoardFull(7):-column(7,C), C==7,writeln('Egalite').
isBoardFull(X):-column(X,C), C==7, X1 is X+1, isBoardFull(X1).

endGame(Player):-checkStatus(Player),displayBoard(1,6),!,abort.
endGame(_):-isBoardFull(1),displayBoard(1,6),!,abort.

/* predicat permettant a un utilisateur de jouer*/
move(Player):-repeat,random(1,7,X),X>0,X<8,column(X,N),N<6,add(X,Player).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CONDITIONS DE FIN DU JEU POUR SAVOIR SI UN JOUEUR A GAGNE/PERDU
   
   Les conditions de fin de jeu sont les suivantes :
   - Alignement de quatre pièces de même couleur horizontalement
   - Alignement de quatre pièces de même couleur verticalement
   - Alignement de quatre pièces de même couleur dans la direction de la diagonale principale
   - Alignement de quatre pièces de même couleur dans la direction de la diagonale secondaire
   
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*Verification d'un alignement gagnant à partir d'une pièce (X,Y) avec sa couleur*/

checkStatus(Player):-piece(X,Y,Player),!,checkStatus(X,Y,Player).
checkStatus(X,Y,Player):-
	fourCheck(X,Y,Player),
	(   Player == r -> writeln('Le joueur rouge a gagné !');
	    Player == y -> writeln('Le joueur jaune a gagné !')
	).

/* Comptage du nombre de pièce de même couleur à la suite dans une direction donnée
 - (X,Y) la position de la pièce dans le jeu
 - (DirectX, DirectY) le vecteur directeur de la direction dans laquelle on vérifie l'alignement
 - sumInARow le nombre de pièces de même couleur à la suite trouvées dans cette direction
*/
fourCheck(X,Y,Player):-fourInARowCheckR(X,Y,Player,1),!.
fourCheck(X,Y,Player):-fourInARowCheckL(X,Y,Player,1),!.
fourCheck(X,Y,Player):-fourInAColumnCheckU(X,Y,Player,1),!.
fourCheck(X,Y,Player):-fourInAColumnCheckD(X,Y,Player,1),!.
fourCheck(X,Y,Player):-fourInADiagCheckNE(X,Y,Player,1),!.
fourCheck(X,Y,Player):-fourInADiagCheckNW(X,Y,Player,1),!.
fourCheck(X,Y,Player):-fourInADiagCheckSE(X,Y,Player,1),!.
fourCheck(X,Y,Player):-fourInADiagCheckSW(X,Y,Player,1),!.

/*Verification d'un alignement horizontal droite*/
fourInARowCheckR(_,_,_,4).
fourInARowCheckR(X,Y,Player,Sum):-
    X1 is X+1,
    piece(X1,Y,Player),
    Sum1 is Sum+1,
    fourInARowCheckR(X1,Y,Player,Sum1).
/*test: init,add(1,'r'),add(2,'y'),add(3,'y'),add(4,'y'),add(5,'y'),checkStatus(5,1,'y').*/    

 /*Verification d'un alignement horizontal gauche*/
fourInARowCheckL(_,_,_,4).
fourInARowCheckL(X,Y,Player,Sum):-
    X1 is X-1,
    piece(X1,Y,Player),
    Sum1 is Sum+1,
    fourInARowCheckL(X1,Y,Player,Sum1).
/*test: init,add(1,'r'),add(2,'y'),add(3,'y'),add(4,'y'),add(5,'y'),checkStatus(2,1,'y').*/

/*Verification d'un alignement vertical haut*/
fourInAColumnCheckU(_,_,_,4).
fourInAColumnCheckU(X,Y,Player,Sum):-
    Y1 is Y+1,
    piece(X,Y1,Player),
    Sum1 is Sum+1,
    fourInAColumnCheckU(X,Y1,Player,Sum1).
/*test: init,add(1,'r'),add(1,'y'),add(1,'y'),add(1,'y'),add(1,'y'),checkStatus(1,2,'y').*/

/*Verification d'un alignement vertical bas*/
fourInAColumnCheckD(_,_,_,4).
fourInAColumnCheckD(X,Y,Player,Sum):-
    Y1 is Y-1,
    piece(X,Y1,Player),
    Sum1 is Sum+1,
    fourInAColumnCheckD(X,Y1,Player,Sum1).
/*test: init,add(1,'r'),add(1,'y'),add(1,'y'),add(1,'y'),add(1,'y'),checkStatus(1,5,'y').*/

/*Verification d'un alignement dans la direction de la diagonale nord est*/
fourInADiagCheckNE(_,_,_,4).
fourInADiagCheckNE(X,Y,Player,Sum):-
    Y1 is Y+1,
    X1 is X+1,
    piece(X1,Y1,Player),
    Sum1 is Sum+1,
    fourInADiagCheckNE(X1,Y1,Player,Sum1).
/*test: init,add(1,'r'),add(2,'y'),add(2,'r'),add(3,'y'),add(3,'y'),add(3,'r'),add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),checkStatus(1,1,'y').*/

/*Verification d'un alignement dans la direction de la diagonale sud est*/

fourInADiagCheckSE(_,_,_,4).
fourInADiagCheckSE(X,Y,Player,Sum):-
    Y1 is Y-1,
    X1 is X+1,
    piece(X1,Y1,Player),
    Sum1 is Sum+1,
    fourInADiagCheckSE(X1,Y1,Player,Sum1).
/*test: init,add(7,'r'),add(6,'y'),add(6,'r'),add(5,'y'),add(5,'y'),add(5,'r'),add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),checkStatus(4,4,'y').*/

/*Verification d'un alignement dans la direction de la diagonale nord west*/

fourInADiagCheckNW(_,_,_,4).
fourInADiagCheckNW(X,Y,Player,Sum):-
    Y1 is Y+1,
    X1 is X-1,
    piece(X1,Y1,Player),
    Sum1 is Sum+1,
    fourInADiagCheckNW(X1,Y1,Player,Sum1).
/*test: init,add(7,'r'),add(6,'y'),add(6,'r'),add(5,'y'),add(5,'y'),add(5,'r'),add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),checkStatus(7,1,'y').*/

/*Verification d'un alignement dans la direction de la diagonale sud west*/

fourInADiagCheckSW(_,_,_,4).
fourInADiagCheckSW(X,Y,Player,Sum):-
    Y1 is Y-1,
    X1 is X-1,
    piece(X1,Y1,Player),
    Sum1 is Sum+1,
    fourInADiagCheckSW(X1,Y1,Player,Sum1).
/*test: init,add(1,'r'),add(2,'y'),add(2,'r'),add(3,'y'),add(3,'y'),add(3,'r'),add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),checkStatus(4,4,'y').*/
