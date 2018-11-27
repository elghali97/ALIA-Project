%%%%%%TODO HERE PUT USEFUL GENERAL PREDICATES %%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



play(Player) :- write('New turn for:'), writeln(Player),
		displayBoard %in order to print it
		
% Prédicat Colonne(indice, nbre de pièces dans la colonne)
column(I,N):-I>0, I<8, N>0, N<7.
% Tests : 	true : column(1,1),column(7,6)
% 			false : column(0,5),column(2,15)

% Prédicat piece(num col, num line, color)
piece(X,Y,C):-X>0, X<8, Y>0, Y<7, member(C,['y','r']),!.
% Tests : 	true : piece(1,1,'y'),piece(7,6,'r')
% 			false : piece(11,6,'r'),piece(5,6,'z')
% 			valeur : piece(1,1,C)