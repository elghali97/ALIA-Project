:-dynamic column/2.
:-dynamic piece/3.
/*init du jeu*/
init:-init_c(7),init_p(7,6).%,play('r'). 
/*init des colonnes à 0*/
init_c(0):-!.
init_c(N):-assert(column(N,0)),N1 is N-1,init_c(N1),!.

/* init des pieces à ?*/
init_p(0,6):-!.
init_p(I,1):-assert(piece(I,1,'?')),I1 is I-1,init_p(I1,6),!.
init_p(I,J):-assert(piece(I,J,'?')),J1 is J-1,init_p(I,J1),!.

play(Player) :-
        move(Player,X),!,
    	not(endGame(Player,X)),
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

/*remove un jeton dans une position valide*/
remove(NC):-
    column(NC,N),
    N<7,
    N1 is N-1,
    retract(piece(NC,N,_)),
    asserta(piece(NC,N,'?')),
    retract(column(NC,N)),
	assert(column(NC,N1)).
% Tests : 	init,add(4,'r'),displayBoard(1,6),writeln(""),remove(4),displayBoard(1,6)
% 			init,add(4,'r'),displayBoard(1,6),writeln(""),remove(X),displayBoard(1,6)

/* Prédicat isBoardFull (1) pour vérifier si la grille est pleine */
isBoardFull(7):-column(7,C), C==7,writeln('Egalite').
isBoardFull(X):-column(X,C), C==7, X1 is X+1, isBoardFull(X1).

endGame(Player,X):-column(X,N),checkStatus(X,N,Player),displayBoard(1,6),writeln(X),writeln(N),!.
endGame(_,_):-isBoardFull(1),displayBoard(1,6),!.

/* predicat permettant a un utilisateur de jouer*/
move(Player,X):-repeat,random(1,7,X),X>0,X<8,column(X,N),N<6,add(X,Player).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CONDITIONS DE FIN DU JEU POUR SAVOIR SI UN JOUEUR A GAGNE/PERDU
   
   Les conditions de fin de jeu sont les suivantes :
   - Alignement de quatre pièces de même couleur horizontalement
   - Alignement de quatre pièces de même couleur verticalement
   - Alignement de quatre pièces de même couleur dans la direction de la diagonale principale
   - Alignement de quatre pièces de même couleur dans la direction de la diagonale secondaire
   
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/*Verification d'un alignement gagnant à partir d'une pièce (X,Y) avec sa couleur*/
checkStatus(X,Y,Player):-
	fourCheck(X,Y,Player),
	(   Player == 'r' -> writeln('Le joueur rouge a gagné !');
	    Player == 'y' -> writeln('Le joueur jaune a gagné !')
	).

/* Comptage du nombre de pièce de même couleur à la suite dans une direction donnée
 - (X,Y) la position de la pièce dans le jeu
 - (DirectX, DirectY) le vecteur directeur de la direction dans laquelle on vérifie l'alignement
 - sumInARow le nombre de pièces de même couleur à la suite trouvées dans cette direction
*/
fourCheck(X,Y,Player):-fourInARowCheck(X,Y,Player),!.
fourCheck(X,Y,Player):-fourInColumnCheck(X,Y,Player),!.
fourCheck(X,Y,Player):-fourInDiagPrincCheck(X,Y,Player),!.
fourCheck(X,Y,Player):-fourInDiagSecondCheck(X,Y,Player),!.



/*Verification d'un alignement horizontal*/
fourInARowCheck(X,Y,Player):-
    fourInARowCheckL(X,Y,Player,Sum1,4),
    fourInARowCheckR(X,Y,Player,Sum2,4),
    Sum is Sum1 + Sum2 + 1,
    Sum >= 4.

/*Verification d'un alignement horizontal droite*/
fourInARowCheckR(X,Y,Player,Sum,_):-
    X1 is X+1,
    not(piece(X1,Y,Player)),
    Sum is 0.
fourInARowCheckR(X,Y,Player,Sum,CountDown):-
    X1 is X+1,
    piece(X1,Y,Player),
    CountDown1 is CountDown - 1,
    fourInARowCheckR(X1,Y,Player,Sum1,CountDown1),
    Sum is Sum1+1.

/*test: init,add(1,'r'),add(2,'y'),add(3,'y'),add(4,'y'),add(5,'y'),fourInARowCheckR(2,1,'y',Sum,4).
  SUM =3*/    

 /*Verification d'un alignement horizontal gauche*/
fourInARowCheckL(X,Y,Player,Sum,_):-
    X1 is X-1,
    not(piece(X1,Y,Player)),
    Sum is 0.
fourInARowCheckL(X,Y,Player,Sum,CountDown):-
    X1 is X-1,
    piece(X1,Y,Player),
    CountDown1 is CountDown-1,
    fourInARowCheckL(X1,Y,Player,Sum1,CountDown1),
    Sum is Sum1+1.


/*test: init,add(1,'r'),add(2,'y'),add(3,'y'),add(4,'y'),add(5,'y'),fourInARowCheckL(4,1,'y',Sum,4).
 SUM =2*/ 



/*Verification d'un alignement vertical*/
fourInColumnCheck(X,Y,Player):-
    fourInAColumnCheckD(X,Y,Player,Sum1,4),
    fourInAColumnCheckU(X,Y,Player,Sum2,4),
    Sum is Sum1 + Sum2 + 1,
    Sum >= 4.

/*Verification d'un alignement vertical haut*/
fourInAColumnCheckU(X,Y,Player,Sum,_):-
    Y1 is Y+1,
    not(piece(X,Y1,Player)),
    Sum is 0.
fourInAColumnCheckU(X,Y,Player,Sum,CountDown):-
    Y1 is Y+1,
    piece(X,Y1,Player),
    CountDown1 is CountDown-1,
    fourInAColumnCheckU(X,Y1,Player,Sum1,CountDown1),
    Sum is Sum1+1.

/*test: init,add(1,'r'),add(1,'y'),add(1,'y'),add(1,'y'),add(1,'y'),fourInAColumnCheckU(1,3,'y',Sum,4).
 Sum = 2*/

/*Verification d'un alignement vertical bas*/
fourInAColumnCheckD(X,Y,Player,Sum,_):-
    Y1 is Y-1,
    not(piece(X,Y1,Player)),
    Sum is 0.
fourInAColumnCheckD(X,Y,Player,Sum,CountDown):-
    Y1 is Y-1,
    piece(X,Y1,Player),
    CountDown1 is CountDown-1,
    fourInAColumnCheckD(X,Y1,Player,Sum1,CountDown1),
    Sum is Sum1+1.

/*test: init,add(1,'r'),add(1,'y'),add(1,'y'),add(1,'y'),add(1,'y'),fourInAColumnCheckD(1,4,'y',Sum,4).
Sum = 2*/

/*Verification d'un alignement dans la direction de la diagonale principale(nord est et sud ouest)*/
fourInDiagPrincCheck(X,Y,Player):-
    fourInADiagCheckNE(X,Y,Player,Sum1,4),
    fourInADiagCheckSW(X,Y,Player,Sum2,4),
    Sum is Sum1 + Sum2 + 1,
    Sum >= 4.


/*Verification d'un alignement dans la direction de la diagonale nord est*/
fourInADiagCheckNE(X,Y,Player,Sum,_):-
    Y1 is Y+1,
    X1 is X+1,
    not(piece(X1,Y1,Player)),
    Sum is 0.
fourInADiagCheckNE(X,Y,Player,Sum,CountDown):-
    Y1 is Y+1,
    X1 is X+1,
    piece(X1,Y1,Player),
    CountDown1 is CountDown-1,
    fourInADiagCheckNE(X1,Y1,Player,Sum1,CountDown1),
    Sum is Sum1+1.

/*test: init,add(1,'r'),add(2,'y'),add(2,'r'),add(3,'y'),add(3,'y'),add(3,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),fourInADiagCheckNE(1,1,'r',Sum,4).
 Sum = 3
 test: init,add(1,'r'),add(2,'y'),add(2,'r'),add(3,'y'),add(3,'y'),add(3,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),fourInADiagCheckNE(2,2,'r',Sum,4).
 Sum = 2
*/

/*Verification d'un alignement dans la direction de la diagonale sud west*/
fourInADiagCheckSW(X,Y,Player,Sum,_):-
    Y1 is Y-1,
    X1 is X-1,
    not(piece(X1,Y1,Player)),
    Sum is 0.
fourInADiagCheckSW(X,Y,Player,Sum,CountDown):-
    Y1 is Y-1,
    X1 is X-1,
    piece(X1,Y1,Player),
    CountDown1 is CountDown-1,
    fourInADiagCheckSW(X1,Y1,Player,Sum1,CountDown1),
    Sum is Sum1+1.

/*test: init,add(1,'r'),add(2,'y'),add(2,'r'),add(3,'y'),add(3,'y'),
 add(3,'r'),add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),
 fourInADiagCheckSW(3,3,'r',Sum,4).
 Sum = 2
 
 test: init,add(1,'r'),add(2,'y'),add(2,'r'),add(3,'y'),add(3,'y'),
 add(3,'r'),add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),
 fourInADiagCheckSW(4,4,'r',Sum,4).
 Sum = 3
 */

/*Verification d'un alignement dans la direction de la diagonale secondaire(sud est et nord ouest)*/
fourInDiagSecondCheck(X,Y,Player):-
    fourInADiagCheckSE(X,Y,Player,Sum1,4),
    fourInADiagCheckNW(X,Y,Player,Sum2,4),
    Sum is Sum1 + Sum2 + 1,
    Sum >= 4.

/*Verification d'un alignement dans la direction de la diagonale sud est*/
fourInADiagCheckSE(X,Y,Player,Sum,_):-
    Y1 is Y-1,
    X1 is X+1,
    not(piece(X1,Y1,Player)),
    Sum is 0.
fourInADiagCheckSE(X,Y,Player,Sum,CountDown):-
    Y1 is Y-1,
    X1 is X+1,
    piece(X1,Y1,Player),
    CountDown1 is CountDown+1,
    fourInADiagCheckSE(X1,Y1,Player,Sum1,CountDown1),
    Sum is Sum1+1.
/*test: init,add(7,'r'),add(6,'y'),add(6,'r'),add(5,'y'),add(5,'y'),add(5,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),fourInADiagCheckSE(4,4,'r',Sum,4).
 Sum = 3.
 
 init,add(7,'r'),add(6,'y'),add(6,'r'),add(5,'y'),add(5,'y'),add(5,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),
fourInADiagCheckSE(5,3,'r',Sum,4).
 Sum = 2.
 */

/*Verification d'un alignement dans la direction de la diagonale nord west*/
fourInADiagCheckNW(X,Y,Player,Sum,_):-
    Y1 is Y+1,
    X1 is X-1,
    not(piece(X1,Y1,Player)),
    Sum is 0.
fourInADiagCheckNW(X,Y,Player,Sum,CountDown):-
    Y1 is Y+1,
    X1 is X-1,
    piece(X1,Y1,Player),
    CountDown1 is CountDown-1,
    fourInADiagCheckNW(X1,Y1,Player,Sum1,CountDown1),
    Sum is Sum1+1.
/*test: init,add(7,'r'),add(6,'y'),add(6,'r'),add(5,'y'),add(5,'y'),add(5,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),fourInADiagCheckNW(7,1,'r',Sum,4).
 SUM = 3
 
 init,add(7,'r'),add(6,'y'),add(6,'r'),add(5,'y'),add(5,'y'),add(5,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),fourInADiagCheckNW(7,1,'r',Sum,4).
 SUM = 2
 */

% Prédicat canWinColumn qui vérifie si un joueur a un coup gagnant dans une colonne(appelez canWinColumn(Player, column) )
canWinColumn(Player,X):-X>0,X<8,add(X,Player),column(X,N),fourCheck(X,N,Player),remove(X).

% Prédicat canWin qui vérifie si un joueur a un coup gagnant dans une colonne(appelez canWin(Player,X) qui renvoie X la colonne où jouer pour gagner)
canWin(Player, X):-
    canWinColumn(Player,1), X is 1;
    canWinColumn(Player,2), X is 2;
    canWinColumn(Player,3), X is 3;
    canWinColumn(Player,4), X is 4;
    canWinColumn(Player,5), X is 5;
    canWinColumn(Player,6), X is 6;
    canWinColumn(Player,7), X is 7.

/*Implementation min-max with alpha beta prunning*/
dispoMoves(0,[]).
dispoMoves(N,[N|Moves]):-column(N,Size),Size<7,N1 is N-1,dispoMoves(N1,Moves),!.
dispoMoves(N,Moves):-N1 is N-1,dispoMoves(N1,Moves).
/**test: init,retract(column(5,0)),assert(column(5,7)),dispoMoves(7,Y).*/

evaluate_and_choose([],D,Alpha,Beta,Move,[Move,Alpha]).

evaluate_and_choose(Move|Moves,D,Alpha,Beta,Move1,BestMove):-
    alpha_beta(D,Move,Alpha,Beta,MoveX,Value),
    Value1 is -Value,
    cutoff(Move,Value1,D,Alpha,Beta,Moves,Move1,BestMove).

alpha_beta(0,Alpha,Beta,Move,Value):-
    value(Value).

alpha_beta(D,Alpha,Beta,Move,Value):-
    column(Move,N),
    assert(piece(Move,N)),
    dispoMoves(7,Moves),
    retract(piece(Move,N)),
    Alpha1 is -Beta,
    Beta1 is -Alpha,
    D1 is D - 1,
    evaluate_and_choose(Moves,D1,Alpha1,Beta1,nil,[Move,Value]).

cutoff(Move,Value,D,Alpha,Beta,Moves,Move1,(Move,Value)):-
    Value >= Beta.

cutoff(Move,Value,D,Alpha,Beta,Moves,Move1,(Move,Value)):-
    Alpha < Value,Value < Beta,
    evaluate_and_choose(Moves,D,Value,Beta,Move,BestMove).

cutoff(Move,Value,D,Alpha,Beta,Moves,Move1,(Move,Value)):-
    Alpha =< Value,
    evaluate_and_choose(Moves,D,Alpha,Beta,Move1,BestMove).

/*Heuristique*/
value(Value).