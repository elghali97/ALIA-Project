:-dynamic column/2.
:-dynamic piece/3.
/*init du jeu*/
/*N: nombre de parties,, M1,M2: les modes des joueurs 1 et 2*/
init(N,M1,M2):-init_c(7),init_p(7,6),play(['r',M1],['y',M2],N,Vic,Defeat,_),write('victoires :'),writeln(Vic),write('defaites :'),writeln(Defeat),!.
/*init des colonnes à 0*/
init_c(0):-!.
init_c(N):-assert(column(N,0)),N1 is N-1,init_c(N1),!.


/* init des pieces à ?*/
init_p(0,6):-!.
init_p(I,1):-assert(piece(I,1,'?')),I1 is I-1,init_p(I1,6),!.
init_p(I,J):-assert(piece(I,J,'?')),J1 is J-1,init_p(I,J1),!.

play(_,_,0,Vic,Defeat,_):-Vic is 0,Defeat is 0.
play([Player,M],NextPlayer,N,Vic,Defeat,_) :-
    move(Player,X,M),
    /*displayBoard(1,6),
    writeln('***********'),*/
    not(endGame(Player,X)),
    play(NextPlayer,[Player,M],N,Vic,Defeat,X).
/*la nouvelle partie debute avec le gagnant de la precedente*/
play([Player,M],NextPlayer,N,Vic,Defeat,Final) :-
    (isBoardFull(1) ->  Test is 1; Test is 0),
    retractall(column(_,_)),
    retractall(piece(_,_,_)),
    init_c(7),
    init_p(7,6),
    N1 is N-1,
    play([Player,M],NextPlayer,N1,Vic1,Defeat1,Final),
    (Test == 1 -> Vic is Vic1 , Defeat is Defeat1;
    Player == 'r' -> Vic is Vic1 + 1, Defeat is Defeat1;
    Player == 'y' -> Vic is Vic1, Defeat is Defeat1 + 1
    ).


changePlayer('r','y').
changePlayer('y','r').

/* Prédicat displayBoard (1,6) pour afficher */
displayBoard(7,1):-piece(7,1,X),write(' | '),write(X),writeln(' | '),writeln('_______________________').
displayBoard(7,J):-piece(7,J,X),write(' | '),write(X),writeln(' | '),writeln('_______________________'),J1 is J-1,displayBoard(1,J1),!.
displayBoard(I,J):-piece(I,J,X),write(' | '),write(X),write(' | '),I1 is I+1,displayBoard(I1,J),!.


/*ajout d'un jeton dans une position valide*/
add(NC,Player):-
    column(NC,N),
    N<6,
    NC=<7,
    N1 is N+1,
    retract(column(NC,N)),
        assert(column(NC,N1)),
    retract(piece(NC,N1,_)),
    asserta(piece(NC,N1,Player)).
    
/*remove un jeton dans une position valide*/
remove(NC):-
    column(NC,N),
    N>0,
    N1 is N-1,
    retract(column(NC,N)),
        assert(column(NC,N1)),
    retract(piece(NC,N,_)),
    asserta(piece(NC,N,'?')).
% Tests : init,add(4,'r'),displayBoard(1,6),writeln(""),remove(4),displayBoard(1,6)
% init,add(4,'r'),displayBoard(1,6),writeln(""),remove(X),displayBoard(1,6)

/* Prédicat isBoardFull (1) pour vérifier si la grille est pleine */
isBoardFull(7):-column(7,C), C==7,writeln('Egalite').
isBoardFull(X):-column(X,C), C==7, X1 is X+1, isBoardFull(X1).

endGame(Player,X):-column(X,N),checkStatus(X,N,Player),displayBoard(1,6),writeln(X),writeln(N).
endGame(_,_):-isBoardFull(1),displayBoard(1,6),!.

/* predicat permettant a un utilisateur de jouer*/
move('r',X,-1):-displayBoard(1,6),repeat,read(X),X>0,X<8,column(X,N),N<6,add(X,'r'),!.
move('r',X,0):-repeat,random(1,7,X),X>0,X<8,column(X,N),N<6,add(X,'r'),!.
move('r',Move,M):-alpha_beta(M,4,[], 'y', 'r', -inf, inf, Move, _),add(Move,'r'),!.

move('y',X,-1):-displayBoard(1,6),repeat,read(X),X>0,X<8,column(X,N),N<6,add(X,'y'),!.
move('y',X,0):-repeat,random(1,7,X),X>0,X<8,column(X,N),N<6,add(X,'y'),!.
move('y',Move,M):-alpha_beta(M,4,[], 'r', 'y', -inf, inf, Move, _),add(Move,'y'),!.

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
    fourInARowCheckL(X,Y,Player,Sum1),
    fourInARowCheckR(X,Y,Player,Sum2),
    Sum is Sum1 + Sum2 + 1,
    Sum >= 4.

/*Verification d'un alignement horizontal droite*/
fourInARowCheckR(X,Y,Player,Sum):-
    X1 is X+1,
    not(piece(X1,Y,Player)),
    Sum is 0.
fourInARowCheckR(X,Y,Player,Sum):-
    X1 is X+1,
    piece(X1,Y,Player),
    fourInARowCheckR(X1,Y,Player,Sum1),
    Sum is Sum1+1.

/*test: init,add(1,'r'),add(2,'y'),add(3,'y'),add(4,'y'),add(5,'y'),fourInARowCheckR(2,1,'y',Sum,4).
  SUM =3*/    

 /*Verification d'un alignement horizontal gauche*/
fourInARowCheckL(X,Y,Player,Sum):-
    X1 is X-1,
    not(piece(X1,Y,Player)),
    Sum is 0.
fourInARowCheckL(X,Y,Player,Sum):-
    X1 is X-1,
    piece(X1,Y,Player),
    fourInARowCheckL(X1,Y,Player,Sum1),
    Sum is Sum1+1.


/*test: init,add(1,'r'),add(2,'y'),add(3,'y'),add(4,'y'),add(5,'y'),fourInARowCheckL(4,1,'y',Sum,4).
 SUM =2*/



/*Verification d'un alignement vertical*/
fourInColumnCheck(X,Y,Player):-
    fourInAColumnCheckD(X,Y,Player,Sum1),
    fourInAColumnCheckU(X,Y,Player,Sum2),
    Sum is Sum1 + Sum2 + 1,
    Sum >= 4.

/*Verification d'un alignement vertical haut*/
fourInAColumnCheckU(X,Y,Player,Sum):-
    Y1 is Y+1,
    not(piece(X,Y1,Player)),
    Sum is 0.
fourInAColumnCheckU(X,Y,Player,Sum):-
    Y1 is Y+1,
    piece(X,Y1,Player),
    fourInAColumnCheckU(X,Y1,Player,Sum1),
    Sum is Sum1+1.

/*test: init,add(1,'r'),add(1,'y'),add(1,'y'),add(1,'y'),add(1,'y'),fourInAColumnCheckU(1,3,'y',Sum,4).
 Sum = 2*/

/*Verification d'un alignement vertical bas*/
fourInAColumnCheckD(X,Y,Player,Sum):-
    Y1 is Y-1,
    not(piece(X,Y1,Player)),
    Sum is 0.
fourInAColumnCheckD(X,Y,Player,Sum):-
    Y1 is Y-1,
    piece(X,Y1,Player),
    fourInAColumnCheckD(X,Y1,Player,Sum1),
    Sum is Sum1+1.

/*test: init,add(1,'r'),add(1,'y'),add(1,'y'),add(1,'y'),add(1,'y'),fourInAColumnCheckD(1,4,'y',Sum,4).
Sum = 2*/

/*Verification d'un alignement dans la direction de la diagonale principale(nord est et sud ouest)*/
fourInDiagPrincCheck(X,Y,Player):-
    fourInADiagCheckNE(X,Y,Player,Sum1),
    fourInADiagCheckSW(X,Y,Player,Sum2),
    Sum is Sum1 + Sum2 + 1,
    Sum >= 4.


/*Verification d'un alignement dans la direction de la diagonale nord est*/
fourInADiagCheckNE(X,Y,Player,Sum):-
    Y1 is Y+1,
    X1 is X+1,
    not(piece(X1,Y1,Player)),
    Sum is 0.
fourInADiagCheckNE(X,Y,Player,Sum):-
    Y1 is Y+1,
    X1 is X+1,
    piece(X1,Y1,Player),
    fourInADiagCheckNE(X1,Y1,Player,Sum1),
    Sum is Sum1+1.

/*test: init,add(1,'r'),add(2,'y'),add(2,'r'),add(3,'y'),add(3,'y'),add(3,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),fourInADiagCheckNE(1,1,'r',Sum,4).
 Sum = 3
 test: init,add(1,'r'),add(2,'y'),add(2,'r'),add(3,'y'),add(3,'y'),add(3,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),fourInADiagCheckNE(2,2,'r',Sum,4).
 Sum = 2
*/

/*Verification d'un alignement dans la direction de la diagonale sud west*/
fourInADiagCheckSW(X,Y,Player,Sum):-
    Y1 is Y-1,
    X1 is X-1,
    not(piece(X1,Y1,Player)),
    Sum is 0.
fourInADiagCheckSW(X,Y,Player,Sum):-
    Y1 is Y-1,
    X1 is X-1,
    piece(X1,Y1,Player),
    fourInADiagCheckSW(X1,Y1,Player,Sum1),
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
    fourInADiagCheckSE(X,Y,Player,Sum1),
    fourInADiagCheckNW(X,Y,Player,Sum2),
    Sum is Sum1 + Sum2 + 1,
    Sum >= 4.

/*Verification d'un alignement dans la direction de la diagonale sud est*/
fourInADiagCheckSE(X,Y,Player,Sum):-
    Y1 is Y-1,
    X1 is X+1,
    not(piece(X1,Y1,Player)),
    Sum is 0.
fourInADiagCheckSE(X,Y,Player,Sum):-
    Y1 is Y-1,
    X1 is X+1,
    piece(X1,Y1,Player),
    fourInADiagCheckSE(X1,Y1,Player,Sum1),
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
fourInADiagCheckNW(X,Y,Player,Sum):-
    Y1 is Y+1,
    X1 is X-1,
    not(piece(X1,Y1,Player)),
    Sum is 0.
fourInADiagCheckNW(X,Y,Player,Sum):-
    Y1 is Y+1,
    X1 is X-1,
    piece(X1,Y1,Player),
    fourInADiagCheckNW(X1,Y1,Player,Sum1),
    Sum is Sum1+1.
/*test: init,add(7,'r'),add(6,'y'),add(6,'r'),add(5,'y'),add(5,'y'),add(5,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),fourInADiagCheckNW(7,1,'r',Sum,4).
 SUM = 3
 
 init,add(7,'r'),add(6,'y'),add(6,'r'),add(5,'y'),add(5,'y'),add(5,'r'),
 add(4,'y'),add(4,'y'),add(4,'y'),add(4,'r'),fourInADiagCheckNW(7,1,'r',Sum,4).
 SUM = 2
 */

% Prédicat canWinColumn qui vérifie si un joueur a un coup gagnant dans une colonne(appelez canWinColumn(Player, column) )
canWinColumn(Player,X):-X>0,X<8,add(X,Player),column(X,N),test(X,N,Player),!.
test(X,N,Player):-fourCheck(X,N,Player),remove(X),!.
test(X,_,_):-remove(X),fail.

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
dispoMoves(N,[N|Moves]):-column(N,Size),Size<6,N1 is N-1,dispoMoves(N1,Moves),!.
dispoMoves(N,Moves):-N1 is N-1,dispoMoves(N1,Moves).

/**test: init,retract(column(5,0)),assert(column(5,7)),dispoMoves(7,Y).*/


/*alpha_beta(D, Board,CurrentPlayer, MainPlayer, Alpha, Beta, Move, Value) :-
    (canWin('r',_);canWin('y',_)),
        value(CurrentPlayer, V1),
        changePlayer(CurrentPlayer, NewPlayer),
        value(NewPlayer, V2),
        (CurrentPlayer == MainPlayer, !, Value is V1 - V2; Value is V2 - V1).*/

alpha_beta(Mode, 0, _, CurrentPlayer, _, _, _, Move, Value) :-
        ( Mode == 1 ->  value(CurrentPlayer,Value1);
          Mode == 2 ->  valueOffensive(CurrentPlayer,Move,Value1);
          Mode == 3 ->  valueDefensive(CurrentPlayer, Move, Value1);
          Mode == 4 ->  valuesumColumn(CurrentPlayer,Value1,1,6);
          Mode == 5 ->  valueConnexeVide(CurrentPlayer,Value1,1,6)
    	),
    	Value is -Value1.

alpha_beta(Mode, D, Board, CurrentPlayer, MainPlayer, Alpha, Beta, Move, Value) :-
        D > 0,
        dispoMoves(7, Moves),
        Alpha1 is -Beta,
        Beta1 is -Alpha,
        D1 is D - 1,
        changePlayer(CurrentPlayer, NewPlayer),
        evaluate_and_choose_Alpha_Beta(Mode, Moves, Board, NewPlayer, MainPlayer, D1, Alpha1, Beta1, nil, (Move, Value)).
        
evaluate_and_choose_Alpha_Beta(Mode, [Move|Moves],Board, CurrentPlayer, MainPlayer, D, Alpha, Beta, Move1, BestMove) :-
       add2(Board,Move,NewBoard,CurrentPlayer),
        (
                (canWin(CurrentPlayer,_),!;isBoardFull(1)),!,
                alpha_beta(Mode, 0, NewBoard, CurrentPlayer, MainPlayer, Alpha, Beta, _, Value);
                alpha_beta(Mode, D, NewBoard, CurrentPlayer, MainPlayer, Alpha, Beta, _, Value)
        ),
    	remove2(NewBoard,Board),
        Value1 is -Value,
        cutoff(Mode, CurrentPlayer, MainPlayer, Move, Value1, D ,Alpha, Beta, Moves,Board, Move1, BestMove).
        
evaluate_and_choose_Alpha_Beta(_, [], _, _, _, _, Alpha, _, Move, (Move, Alpha)).

cutoff(_, _, _, Move, Value, _, _, Beta, _,_, _, (Move,Value)) :-
        Value >= Beta.

cutoff(Mode, CurrentPlayer, MainPlayer, Move, Value, D, Alpha, Beta, Moves,Board, _, BestMove) :-
        Value > Alpha, Value < Beta,
        evaluate_and_choose_Alpha_Beta(Mode, Moves, Board, CurrentPlayer, MainPlayer, D, Value, Beta, Move, BestMove).

cutoff(Mode, CurrentPlayer, MainPlayer, _, Value, D, Alpha, Beta, Moves, Board, Move1, BestMove) :-
        Value =< Alpha,
        evaluate_and_choose_Alpha_Beta(Mode, Moves,Board,CurrentPlayer, MainPlayer, D, Alpha, Beta, Move1, BestMove).

/*ajout d'un jeton dans une position valide*/
add2(Board,NC,[[NC,N1,Player]|Board],Player):-
    column(NC,N),
    N<6,
    NC=<7,
    N1 is N+1,
    piece(NC,N1,'?'),
    retract(piece(NC,N1,'?')),
    retract(column(NC,N)),
        assert(column(NC,N1)),
    asserta(piece(NC,N1,Player)),!.

add2(Board,_,Board,_).
    
/*remove un jeton dans une position valide*/
remove2([[NC,N1,Player]|Board],Board):-
    column(NC,N1),
    piece(NC,N1,Player),
    N is N1-1,
    retract(piece(NC,N1,Player)),
    retract(column(NC,N1)),
        assert(column(NC,N)),
    asserta(piece(NC,N1,'?')),!.

remove2(Board,Board).

/*Heuristique*/
value(Player,Value):-canWin(Player,_),Value is 1000,!.
value(Player,Value):-changePlayer(Player,NextPlayer),canWin(NextPlayer,_),Value is 0,!.
value(_,Value):-Value is 500.


/*2 cotes*/

/*evaluer pour une piece*/
allOpen(X,Y,Color,Total):-
    open1(X, Y,Color,Total1),
    half_open2(X,Y,Color,Total2),
    open2(X, Y,Color,Total3),
    half_open3(X,Y,Color,Total4),
    open3(X, Y,Color,Total5),
    
    changePlayer(Color,ColorOpp),
    
    open1(X, Y,ColorOpp,Total6),
    half_open2(X,Y,ColorOpp,Total7),
    open2(X, Y,ColorOpp,Total8),
    half_open3(X,Y,ColorOpp,Total9),
    open3(X, Y,ColorOpp,Total10),
    
    Total is (Total1 + Total2*3 + Total3*9+Total4*20+
	    Total5*500) -
	(Total6 + Total7*3 + Total8*9+Total9*20+
	    Total10*500) + 23000 .
    
    


/* open check les pieces dans cette configuration  _r_*/
open1(X, Y,Color,Total):-
    piece(X,Y,Color),!,
    openHelperVertical1(X,Y,Color,PTotal1),
    openHelperHorizontal1(X,Y,Color,PTotal2),
    openHelperDiagPrinc1(X,Y,Color,PTotal3),
    openHelperDiagSec1(X,Y,Color,PTotal4),
    Total is PTotal1+PTotal2+PTotal3+PTotal4.
open1(_,_,_,Total):- Total is 0.

openHelperVertical1(X,Y,_,PTotal):-
    X1 is X+1,
    piece(X1,Y,'?'),
    X2 is X-1, 
   piece(X2,Y,'?'),!,
    PTotal is 1.

openHelperVertical1(_,_,_,PTotal):- PTotal is 0.

openHelperHorizontal1(X,Y,_,PTotal):-
    Y1 is Y+1,
    piece(X,Y1,'?'),
    Y2 is Y-1, 
    piece(X,Y2,'?'),!,
    PTotal is 1.

    
openHelperHorizontal1(_,_,_,PTotal):- PTotal is 0.

openHelperDiagPrinc1(X,Y,_,PTotal):-
    X1 is X+1,
    X2 is X-1,
    Y1 is Y+1,
    Y2 is Y-1, 
    piece(X1,Y1,'?'),
    piece(X2,Y2,'?'),!,
    PTotal is 1.
    
openHelperDiagPrinc1(_,_,_,PTotal):- PTotal is 0.


openHelperDiagSec1(X,Y,_,PTotal):-
    X1 is X+1,
    X2 is X-1,
    Y1 is Y+1,
    Y2 is Y-1, 
    piece(X2,Y1,'?'),
    piece(X1,Y2,'?'),!,
    PTotal is 1.
    
openHelperDiagSec1(_,_,_,PTotal):- PTotal is 0.
/*fin open*/

/*half_open compte les pieces dans cette positon rr_*/
half_open2(X,Y,Color,Total):-
    openHelperhalfVertical2(X,Y,Color,PTotal1),
    openHelperhalfHorizontal2(X,Y,Color,PTotal2),
    openHelperhalfDiagPrinc2(X,Y,Color,PTotal3),
    openHelperhalfDiagSec2(X,Y,Color,PTotal4),
    Total is PTotal1+PTotal2+PTotal3+PTotal4.

openHelperhalfVertical2(X,Y,Color,PTotal1):- 
    X1 is X+1,
    X2 is X+2,
    piece(X1,Y,Color),
    piece(X2,Y,'?'),!,
    PTotal1 is 1.
openHelperhalfVertical2(_,_,_,PTotal1):-
    PTotal1 is 0.


openHelperhalfHorizontal2(X,Y,Color,PTotal2):- 
    Y1 is Y+1,
    Y2 is Y+2,
    piece(X,Y1,Color),
    piece(X,Y2,'?'),!,
    PTotal2 is 1.
openHelperhalfHorizontal2(_,_,_,PTotal2):-
    PTotal2 is 0.


openHelperhalfDiagPrinc2(X,Y,Color,PTotal3):- 
    X1 is X+1,
    X2 is X+2,
    Y1 is Y+1,
    Y2 is Y+2, 
    piece(X1,Y1,Color),
    piece(X2,Y2,'?'),!,
    PTotal3 is 1.
openHelperhalfDiagPrinc2(_,_,_,PTotal3):-
    PTotal3 is 0.


openHelperhalfDiagSec2(X,Y,Color,PTotal4):- 
    X1 is X+1,
    X2 is X+2,
    Y1 is Y-1,
    Y2 is Y-2, 
    piece(X1,Y1,Color),
    piece(X2,Y2,'?'),!,
    PTotal4 is 1.
openHelperhalfDiagSec2(_,_,_,PTotal4):- 
    PTotal4 is 0.

/*-Fin half open */

/*open2 _rr_ */
open2(X, Y,Color,Total):-
    piece(X,Y,Color),!,
    openHelperVertical2(X,Y,Color,PTotal1),
    openHelperHorizontal2(X,Y,Color,PTotal2),
    openHelperDiagPrinc2(X,Y,Color,PTotal3),
    openHelperDiagSec2(X,Y,Color,PTotal4),
    Total is PTotal1+PTotal2+PTotal3+PTotal4.
open2(_,_,_,Total):- Total is 0.

openHelperVertical2(X,Y,Color,PTotal):-
    X1 is X+1,
    X2 is X+2,
    X3 is X-1,
    piece(X1,Y,Color), 
    piece(X2,Y,'?'),
    piece(X3,Y,'?'),!,
    PTotal is 1.
    
openHelperVertical2(_,_,_,PTotal):- PTotal is 0.


openHelperHorizontal2(X,Y,Color,PTotal):-
    Y1 is Y+1,
    Y2 is Y+2,
    Y3 is Y-1,
    piece(X,Y1,Color), 
    piece(X,Y2,'?'),
    piece(X,Y3,'?'),!,
    PTotal is 1.

    
openHelperHorizontal2(_,_,_,PTotal):- PTotal is 0.

openHelperDiagPrinc2(X,Y,Color,PTotal):-
    X1 is X+1,
    X2 is X+2,
    Y1 is Y+1,
    Y2 is Y+2,
    X3 is X-1,
    Y3 is Y-1,
    piece(X1,Y1,Color),
    piece(X2,Y2,'?'),
    piece(X3,Y3,'?'),!,
    PTotal is 1.
    
openHelperDiagPrinc2(_,_,_,PTotal):- PTotal is 0.


openHelperDiagSec2(X,Y,Color,PTotal):-
    X1 is X+1,
    X2 is X+2,
    Y1 is Y-1,
    Y2 is Y-2,
    X3 is X-1,
    Y3 is Y+1,
    piece(X1,Y1,Color),
    piece(X2,Y2,'?'),
    piece(X3,Y3,'?'),
    PTotal is 1.
    
openHelperDiagSec2(_,_,_,PTotal):- PTotal is 0.
/* Fin open2 _rr_ */

/* half open3 rrr_ */

half_open3(X,Y,Color,Total):-
    piece(X,Y,Color),!,
    openHelperhalfVertical3(X,Y,Color,PTotal1),
    openHelperhalfHorizontal3(X,Y,Color,PTotal2),
    openHelperhalfDiagPrinc3(X,Y,Color,PTotal3),
    openHelperhalfDiagSec3(X,Y,Color,PTotal4),
    Total is PTotal1+PTotal2+PTotal3+PTotal4.
half_open3(_,_,_,Total):- Total is 0.

openHelperhalfVertical3(X,Y,Color,PTotal1):- 
    X1 is X+1,
    X2 is X+2,
    X3 is X+3,
    piece(X1,Y,Color),
    piece(X2,Y,Color),
    piece(X3,Y,'?'),!,
    PTotal1 is 1.
openHelperhalfVertical3(_,_,_,PTotal1):-
    PTotal1 is 0.


openHelperhalfHorizontal3(X,Y,Color,PTotal2):- 
    Y1 is Y+1,
    Y2 is Y+2,
    Y3 is Y+3,
    piece(X,Y1,Color),
    piece(X,Y2,Color),
    piece(X,Y3,'?'),!,
    PTotal2 is 1.
openHelperhalfHorizontal3(_,_,_,PTotal2):-
    PTotal2 is 0.


openHelperhalfDiagPrinc3(X,Y,Color,PTotal3):- 
    X1 is X+1,
    X2 is X+2,
    Y1 is Y+1,
    Y2 is Y+2,
    X3 is X+3,
    Y3 is Y+3,
    piece(X1,Y1,Color),
    piece(X2,Y2,Color),
    piece(X3,Y3,'?'),!,
    PTotal3 is 1.
openHelperhalfDiagPrinc3(_,_,_,PTotal3):-
    PTotal3 is 0.


openHelperhalfDiagSec3(X,Y,Color,PTotal4):- 
    X1 is X+1,
    X2 is X+2,
    Y1 is Y-1,
    Y2 is Y-2,
    X3 is X+3,
    Y3 is Y-3,
    piece(X1,Y1,Color),
    piece(X2,Y2,Color),
    piece(X3,Y3,'?'),!,
    PTotal4 is 1.
openHelperhalfDiagSec3(_,_,_,PTotal4):- 
    PTotal4 is 0.
/* Fin half open3 rrr_ */

/* open3  _rrr_ */

open3(X, Y,Color,Total):-
    piece(X,Y,Color),!,
    openHelperVertical3(X,Y,Color,PTotal1),
    openHelperHorizontal3(X,Y,Color,PTotal2),
    openHelperDiagPrinc3(X,Y,Color,PTotal3),
    openHelperDiagSec3(X,Y,Color,PTotal4),
    Total is PTotal1+PTotal2+PTotal3+PTotal4.
open3(_,_,_,Total):- Total is 0.

openHelperVertical3(X,Y,Color,PTotal):-
    X1 is X+1,
    X2 is X+2,
    X3 is X+3,
    X4 is X-1,
    piece(X1,Y,Color), 
    piece(X2,Y,Color),
    piece(X3,Y,'?'),
    piece(X4,Y,'?'),!,
    PTotal is 1.
    
openHelperVertical3(_,_,_,PTotal):- PTotal is 0.


openHelperHorizontal3(X,Y,Color,PTotal):-
    Y1 is Y+1,
    Y2 is Y+2,
    Y3 is Y+3,
    Y4 is Y-1,
    piece(X,Y1,Color), 
    piece(X,Y2,Color),
    piece(X,Y3,'?'),
    piece(X,Y4,'?'),!,
    PTotal is 1.

    
openHelperHorizontal3(_,_,_,PTotal):- PTotal is 0.

openHelperDiagPrinc3(X,Y,Color,PTotal):-
    X1 is X+1,
    X2 is X+2,
    Y1 is Y+1,
    Y2 is Y+2,
    X3 is X-1,
    Y3 is Y-1,
    X4 is X+3,
    Y4 is Y+3,
    piece(X1,Y1, Color),
    piece(X2,Y2,Color),
    piece(X3,Y3,'?'),
    piece(X4,Y4,'?'),!,
    PTotal is 1.
    
openHelperDiagPrinc3(_,_,_,PTotal):- PTotal is 0.


openHelperDiagSec3(X,Y,Color,PTotal):-
    X1 is X+1,
    X2 is X+2,
    Y1 is Y-1,
    Y2 is Y-2,
    X3 is X-1,
    Y3 is Y+1,
    X4 is X+3,
    Y4 is Y-3,
    piece(X1,Y1,Color),
    piece(X2,Y2,Color),
    piece(X3,Y3,'?'),
    piece(X4,Y4,'?'),!,
    PTotal is 1.
    
openHelperDiagSec3(_,_,_,PTotal):- PTotal is 0.

/*Fin open3 _rrr_*/


valueOffensive(Player,Move,Value):-
    valueMax(Player,Move,Value).

valueDefensive(Player,Move,Value):-
    changePlayer(Player,NewPlayer),
    valueMax(NewPlayer,Move,Value).

valueConnexeVide(Player,Value,_,_):-canWin(Player,_),!,Value is 46000.
valueConnexeVide(Player,Value,_,_):-changePlayer(Player,Opp),canWin(Opp,_),!,Value is 46000.
valueConnexeVide(Player,Value,7,1):-allOpen(7,1,Player,Total),Value is Total.
valueConnexeVide(Player,Value,7,J):-allOpen(7,J,Player,Total),J1 is J-1,valueConnexeVide(Player,Value1,1,J1),Value is Value1+Total,!.
valueConnexeVide(Player,Value,I,J):-allOpen(I,J,Player,Total),I1 is I+1,valueConnexeVide(Player,Value1,I1,J),Value is Value1+Total,!.

    
valueMax(Player,Move,Value):-
    valueHorizontal(Player,Move,ValueH),
    valueVertical(Player,Move,ValueV),
    valueDiagPrinc(Player,Move,ValueDP),
    valueDiagSec(Player,Move,ValueDS),
    ValueMaxHV is max(ValueH,ValueV),
    ValueMaxBis is max(ValueDP,ValueMaxHV),
    Value is max(ValueMaxBis,ValueDS).

valueHorizontal(Player,Move,Value):-
    column(Move, Y),
    fourInARowCheckR(Move,Y,Player,R),
    fourInARowCheckL(Move,Y,Player,L),
    Value is 2*(R*L+R+L)+1.

valueVertical(Player,Move,Value):-
    column(Move, Y),
    fourInAColumnCheckU(Move,Y,Player,U),
    fourInAColumnCheckD(Move,Y,Player,D),
    Value is 2*(U*D+U+D)+1.

valueDiagPrinc(Player,Move,Value):-
    column(Move, Y),
    fourInADiagCheckNE(Move,Y,Player,U),
    fourInADiagCheckSW(Move,Y,Player,V),
    Value is 2*(U*V+U+V)+1.

valueDiagSec(Player,Move,Value):-
    column(Move, Y),
    fourInADiagCheckSE(Move,Y,Player,U),
    fourInADiagCheckNW(Move,Y,Player,V),
    Value is 2*(U*V+U+V)+1.


evalTable(1,1, 3).
evalTable(1,2, 4).
evalTable(1,3, 5).
evalTable(1,4, 5).
evalTable(1,5, 4).
evalTable(1,6, 3).

evalTable(2,1, 4).
evalTable(2,2, 6).
evalTable(2,3, 8).
evalTable(2,4, 8).
evalTable(2,5, 6).
evalTable(2,6, 4).

evalTable(3,1, 5).
evalTable(3,2, 8).
evalTable(3,3, 11).
evalTable(3,4, 11).
evalTable(3,5, 8).
evalTable(3,6, 5).

evalTable(4,1, 7).
evalTable(4,2, 10).
evalTable(4,3, 13).
evalTable(4,4, 13).
evalTable(4,5, 10).
evalTable(4,6, 7).

evalTable(5,1, 5).
evalTable(5,2, 8).
evalTable(5,3, 11).
evalTable(5,4, 11).
evalTable(5,5, 8).
evalTable(5,6, 5).

evalTable(6,1, 4).
evalTable(6,2, 6).
evalTable(6,3, 8).
evalTable(6,4, 8).
evalTable(6,5,6).
evalTable(6,6,4).

evalTable(7,1, 3).
evalTable(7,2, 4).
evalTable(7,3, 5).
evalTable(7,4, 5).
evalTable(7,5, 4).
evalTable(7,6, 3).

valuesumColumn(Player,Value,_,_):-canWin(Player,_),!,Value is 1000.
valuesumColumn(Player,Value,_,_):-changePlayer(Player,Opp),canWin(Opp,_),!,Value is 1000.
valuesumColumn(Player,Value,7,1):-evalTable(7,1,Total),
    (piece(7,1,Player) -> Value is Total;
     piece(7,1,'?') ->  Value is 0;
     Value is -Total
     ).
valuesumColumn(Player,Value,7,J):-evalTable(7,J,Total),J1 is J-1,valuesumColumn(Player,Value1,1,J1),
    (piece(7,J,Player) -> Value is Value1+Total;
     piece(7,J,'?') ->  Value is Value1;
     Value is Value1-Total
     ),!.
valuesumColumn(Player,Value,I,J):-evalTable(I,J,Total),I1 is I+1,valuesumColumn(Player,Value1,I1,J),
    (piece(I,J,Player) -> Value is Value1+Total;
     piece(I,J,'?') ->  Value is Value1;
     Value is Value1-Total
    ),!.
