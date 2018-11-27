%%%%%%TODO HERE PUT USEFUL GENERAL PREDICATES %%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



play(Player) :- write('New turn for:'), writeln(Player),
		displayBoard %in order to print it
		
% Prédicat Colonne(indice, nbre de pièces dans la colonne)
column(I,N):-I>0, I<8, N>0, N<7.
% Tests : 	true : column(1,1),column(7,6)
% 			false : column(0,5),column(2,15)

% Prédicat piece(num col, num line, color)
piece(X,Y,'?'):-X>0, X<8, Y>0, Y<7. 	% empty case
piece(X,Y,'r'):-X>0, X<8, Y>0, Y<7. 	% red
piece(X,Y,'y'):-X>0, X<8, Y>0, Y<7. 	% yellow
% Tests : 	true : piece(1,1,'y'),piece(7,6,'r')
% 			false : piece(11,6,'r'),piece(5,6,'z')
% 			valeur : piece(1,1,C)

% Prédicat DisplayBoard (1,6) pour afficher
displayBoard(7,1):-piece(7,1,C), write(C), writeln(' | '), writeln('__________________').
displayBoard(1,Y):-piece(1,Y,C), writeln('__________________'), write(' | '),
    write(C), write(' | '), displayBoard(2,Y).
displayBoard(7,Y):-piece(7,Y,C), write(C), writeln(' | '), Y1 is Y-1, displayBoard(1,Y1).
displayBoard(X,Y):-piece(X,Y,C), write(C), write(' | '), X1 is X+1, displayBoard(X1,Y).

