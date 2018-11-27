%%%%%%TODO HERE PUT USEFUL GENERAL PREDICATES %%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:-dynamic column/2.
:-dynamic piece/3.
/*init du jeu*/
init:-init_c(7),init_p(7,6). 
/*init des colonnes a 0, init des pieces a ?*/
init_c(0).
init_c(N):-assert(column(N,0)),N1 is N-1,init_c(N1).


play(Player) :- write('New turn for:'), writeln(Player),
		displayBoard %in order to print it
		
% Prédicat piece(num col, num line, color)
piece(1,6,'r').
piece(2,6,'r').
piece(3,6,'r').
piece(4,6,'r').
piece(5,6,'?').
piece(6,6,'r').
piece(7,6,'r').
piece(X,Y,'?'):-X>0, X<8, Y>0, Y<7. 	% empty case
piece(X,Y,'r'):-X>0, X<8, Y>0, Y<7. 	% red
piece(X,Y,'y'):-X>0, X<8, Y>0, Y<7. 	% yellow
% Tests : 	true : piece(1,1,'y'),piece(7,6,'r')
% 			false : piece(11,6,'r'),piece(5,6,'z')
% 			valeur : piece(1,1,C)

% Prédicat displayBoard (1,6) pour afficher
displayBoard(7,1):-piece(7,1,C), write(C), writeln(' | '), writeln('__________________').
displayBoard(1,Y):-piece(1,Y,C), writeln('__________________'), write(' | '),
    write(C), write(' | '), displayBoard(2,Y).
displayBoard(7,Y):-piece(7,Y,C), write(C), writeln(' | '), Y1 is Y-1, displayBoard(1,Y1).
displayBoard(X,Y):-piece(X,Y,C), write(C), write(' | '), X1 is X+1, displayBoard(X1,Y).

% Prédicat isBoardFull (1) pour vérifier si la grille est pleine
isBoardFull(7):-piece(7,6,C),!, C\=='?'.
isBoardFull(X):-piece(X,6,C),!, C\=='?', X1 is X+1, isBoardFull(X1).
% Tests : 	true : piece(1,6,'r'),piece(2,6,'r'),piece(3,6,'r'),piece(4,6,'r'),piece(5,6,'r'),piece(6,6,'r'),piece(7,6,'r').
% 		false : piece(1,6,'?'),piece(2,6,'?'),piece(3,6,'?'),piece(4,6,'?'),piece(5,6,'?'),piece(6,6,'r'),piece(7,6,'?')
% 			piece(1,6,'?'),piece(2,6,'r'),piece(3,6,'?'),piece(4,6,'?'),piece(5,6,'r'),piece(6,6,'r'),piece(7,6,'?')

% Prédicat endGame(Winner si on est en conf gagnante ou 'Draw' si la grille est pleine)
endGame(Winner):-checkStatus(X,Y,Winner).
endGame('Draw'):-isBoardFull.

/*ajout d'un jeton dans une position valide*/
add(NC,Player):-
    column(NC,N),
    N<7,
    N1 is N+1,
    retract(piece(NC,N1,'?')),
    asserta(piece(NC,N1,Player)),
    retract(column(NC,N)),
assert(column(NC,N1)).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CONDITIONS DE FIN DU JEU POUR SAVOIR SI UN JOUEUR A GAGNE/PERDU
   
   Les conditions de fin de jeu sont les suivantes :
   - Alignement de quatre pièces de même couleur horizontalement
   - Alignement de quatre pièces de même couleur verticalement
   - Alignement de quatre pièces de même couleur dans la direction de la diagonale principale
   - Alignement de quatre pièces de même couleur dans la direction de la diagonale secondaire
   
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%Verification d'un alignement gagnant à partir d'une pièce (X,Y) avec sa couleur
checkStatus(_,_,_).
checkStatus(X,Y,Color):-
	fourInARowCheck(X,Y),
	(   Color == r -> write('Le joueur rouge a gagné !');
	    Color == y -> write('Le joueur jaune a gagné !')
	).

% Comptage du nombre de pièce de même couleur à la suite dans une direction donnée
% - (X,Y) la position de la pièce dans le jeu
% - (DirectX, DirectY) le vecteur directeur de la direction dans laquelle on vérifie l'alignement
% - sumInARow le nombre de pièces de même couleur à la suite trouvées dans cette direction
numberInARow(_,_,_,_,1).
numberInARow(X,Y,DirectX,DirectY,SumInARow):-
    NewX is X+DirectX,
    NewY is Y+DirectY,
    piece(X,Y,C1),
    piece(NewX,NewY,C2),
    C1==C2,
    numberInARow(NewX,NewY,DirectX,DirectY,NewSum),
    SumInARow is NewSum +1,!.

%Verification d'un alignement horizontal
fourInARowCheck(X,Y):-
    numberInARow(X,Y,1,0,Sum1),
    numberInARow(X,Y,-1,0,Sum2),
    Sum is Sum1+Sum2-1,
    Sum>=4,!.

%Verification d'un alignement vertical
fourInARowCheck(X,Y):-
    numberInARow(X,Y,0,1,Sum1),
    numberInARow(X,Y,0,-1,Sum2),
    Sum is Sum1+Sum2-1,
    Sum>=4,!.

%Verification d'un alignement dans la direction de la diagonale principale
fourInARowCheck(X,Y):-
    numberInARow(X,Y,-1,1,Sum1),
    numberInARow(X,Y,1,-1,Sum2),
    Sum is Sum1+Sum2-1,
    Sum>=4,!.

%Verification d'un alignement dans la direction de la diagonale secondaire
fourInARowCheck(X,Y):-
    numberInARow(X,Y,1,1,Sum1),
    numberInARow(X,Y,-1,-1,Sum2),
    Sum is Sum1+Sum2-1,
    Sum>=4,!.
