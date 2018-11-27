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
% 			false : piece(1,6,'?'),piece(2,6,'?'),piece(3,6,'?'),piece(4,6,'?'),piece(5,6,'?'),piece(6,6,'r'),piece(7,6,'?')
% 					piece(1,6,'?'),piece(2,6,'r'),piece(3,6,'?'),piece(4,6,'?'),piece(5,6,'r'),piece(6,6,'r'),piece(7,6,'?')

% Prédicat endGame(Winner si on est en conf gagnante ou 'Draw' si la grill est pleine)
endGame(Winner):-winner(Winner).
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
