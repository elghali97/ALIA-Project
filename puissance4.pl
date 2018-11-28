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

play(Player) :- write('New turn for:'), writeln(Player),
		displayBoard(1,6), /*in order to print it*/
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

/*endGame(Player):-checkStatus(Player),!,abort.*/
endGame(_):-isBoardFull(1),!,abort.

/* predicat permettant a un utilisateur de jouer*/
move(Player):-repeat,read(X),X>0,X<8,column(X,N),N<6,add(X,Player).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CONDITIONS DE FIN DU JEU POUR SAVOIR SI UN JOUEUR A GAGNE/PERDU
   
   Les conditions de fin de jeu sont les suivantes :
   - Alignement de quatre pièces de même couleur horizontalement
   - Alignement de quatre pièces de même couleur verticalement
   - Alignement de quatre pièces de même couleur dans la direction de la diagonale principale
   - Alignement de quatre pièces de même couleur dans la direction de la diagonale secondaire
   
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*Verification d'un alignement gagnant à partir d'une pièce (X,Y) avec sa couleur*/
/*
checkStatus(Player):-piece(X,Y,Player),!,checkStatus(X,Y,Player).
checkStatus(_,_,_).
checkStatus(X,Y,Color):-
	fourInARowCheck(X,Y),
	(   Color == r -> write('Le joueur rouge a gagné !');
	    Color == y -> write('Le joueur jaune a gagné !')
	).
*/
/* Comptage du nombre de pièce de même couleur à la suite dans une direction donnée
 - (X,Y) la position de la pièce dans le jeu
 - (DirectX, DirectY) le vecteur directeur de la direction dans laquelle on vérifie l'alignement
 - sumInARow le nombre de pièces de même couleur à la suite trouvées dans cette direction
*/
numberInARow(_,_,_,_,1).
numberInARow(X,Y,DirectX,DirectY,SumInARow):-
    NewX is X+DirectX,
    NewY is Y+DirectY,
    piece(X,Y,C1),
    piece(NewX,NewY,C2),
    C1==C2,
    numberInARow(NewX,NewY,DirectX,DirectY,NewSum),
    SumInARow is NewSum +1,!.

/*Verification d'un alignement horizontal*/
fourInARowCheck(X,Y):-
    numberInARow(X,Y,1,0,Sum1),
    numberInARow(X,Y,-1,0,Sum2),
    Sum is Sum1+Sum2-1,
    Sum>=4,!.

/*Verification d'un alignement vertical*/
fourInARowCheck(X,Y):-
    numberInARow(X,Y,0,1,Sum1),
    numberInARow(X,Y,0,-1,Sum2),
    Sum is Sum1+Sum2-1,
    Sum>=4,!.

/*Verification d'un alignement dans la direction de la diagonale principale*/
fourInARowCheck(X,Y):-
    numberInARow(X,Y,-1,1,Sum1),
    numberInARow(X,Y,1,-1,Sum2),
    Sum is Sum1+Sum2-1,
    Sum>=4,!.

/*Verification d'un alignement dans la direction de la diagonale secondaire*/
fourInARowCheck(X,Y):-
    numberInARow(X,Y,1,1,Sum1),
    numberInARow(X,Y,-1,-1,Sum2),
    Sum is Sum1+Sum2-1,
    Sum>=4,!.
