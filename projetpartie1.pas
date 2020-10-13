Program projet;
{$IFDEF FPC}{$MODE OBJFPC}{H$H+}{$ENDIF}

USES Crt, sysutils;


const
	N = 5;
	M = N * N;
	MORT = 0;
	VIE = 1;
{ exercise 3.1 et 3.2 }
Type 
	typePosition = record
		x, y : integer;
	end;

	tabPosition = array[0..M-1] of typePosition; 

	typeGrille = array[0..N-1,0..N-1] of Integer;

procedure afficherGrille(grille: typeGrille); forward;
	
{ fonction supplémentaire, Initialisation, Remettre à Zero toutes les cellules de la grille à l'état MORT }
Function RAZGrille : typeGrille;
Var
i, j : integer;
Mat : typeGrille;
Begin
	for i := 0 to (N-1) do
        Begin
	  for j := 0 to (N-1) do
	     Mat[i,j] := MORT; 
	End;
	RAZGrille := Mat;
End;

{ procedure supplémentaire, pour pouvoir voir l'évolution pendant la simulation, avec ou sans effacer les données pécédentes}
Procedure afficheMessageGrille(message : string; Mat : typeGrille; doitEffacer :boolean );
Begin
	if ( doitEffacer = True ) then ClrScr;
	writeln(message);
	writeln('******************************************************');	
	afficherGrille(Mat);
End;


{ exercise 3.3 }
Function remplirGrille(tableau: tabPosition) : typeGrille;
Var 
Mat : typeGrille;
k: integer;
Begin
	Mat := RAZGrille;
	For k := 0 to M-1 do 
        begin
			if ( (tableau[k].x >= 0) and  (tableau[k].x < N) and (tableau[k].y >=0 ) and (tableau[k].y < N) ) then Mat[tableau[k].x,tableau[k].y] := 1;
		end;
	afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE APRES REMPLISSAGE', Mat, True);	
	remplirGrille := Mat;
		
End;


{ exercise 3.4 }
Function initGrille(nb: real) : typeGrille;
Var	
i, j : integer;
Mat : typeGrille;
Begin
	Mat := RAZGrille;
	j := round((M*nb) / (100.0)) ;  {round permet de calculer des réels avec des entiers}
	writeln('NOMBRE DE CELLULES VIVANTES PAR RAPPORT AU POURCENTAGE SAISIE : '+ IntToStr(j));
	readln;
	For i :=0 to (j-1) do
		begin
			Mat[random(N-1),random(N-1)] :=VIE;
		end;
	afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE APRES INITIALISATION',Mat, True);
	initGrille := Mat;		
end;

{ exercise 3.5 }
Function compteCellule(grille: typeGrille) : Integer;
Var compte,i,j : integer;
Begin
compte := 0;
For i:= 0 to (N-1) do
	Begin
		For j:=0 to (N-1) do
			if grille[i,j]= VIE then 
				compte := compte+1;
	End;
	compteCellule := compte;
End;

{ exercise 3.6 }
Function calculerValeurCellule(grille: typeGrille; x,y: Integer) : Integer;
Var  nbvivante, i, j,coord_i,coord_j, valeurcellule : integer;
Begin
	nbvivante := 0;
	For i:= x-1 to x+1 do
	begin
		For j:=y-1 to y+1 do
		begin
            coord_i:= i;
            coord_j:= j;
            if (i < 0) then coord_i := N-1  { changement de coord  de x et  y si en dehors de la limite du tableau càd < 0 ou > N-1}
            else if (i > N-1) then coord_i:= 0;
                
            if (j < 0) then coord_j := N-1
            else if (j > N-1) then coord_j :=0;
							
            if ( ((i <> x) or (j <> y)) and (grille[coord_i,coord_j] = VIE) ) then   nbvivante := nbvivante+1;
        end;		
	end;	
	if (  (grille[x,y]= VIE) and (nbvivante >= 2) and (nbvivante <= 3) ) then valeurcellule := VIE {  règle 1 }
	else if (  (grille[x,y]= VIE) and (nbvivante >= 4) ) then valeurcellule := MORT 	{  règle 2 }
	else if (  (grille[x,y]= VIE) and (nbvivante <= 1) ) then  valeurcellule := MORT {  règle 2 }
	else if (  (grille[x,y]= MORT) and (nbvivante = 3) ) then valeurcellule := VIE  { règle 3 }
	else valeurcellule := grille[x,y];
	calculerValeurCellule := valeurcellule;
End;

{ exercise 3.7 }
Function calculerNouvelleGrille(grille: typeGrille) : typeGrille;
Var nouvelleGrille : typeGrille;
 x, y : integer;
Begin
    
	For x:= 0 to N-1 do
	Begin
		For y:=0 to N-1 do
			Begin
				nouvelleGrille[x,y] := calculerValeurCellule(grille, x, y);
			end;		
	End;
	calculerNouvelleGrille := nouvelleGrille;
End;

{ exercise 3.8 }
procedure afficherGrille(grille: typeGrille);	
var
x, y : integer;
affichetext: string;
Begin
	
	For x:= 0 to N-1 do
	begin
		affichetext := ' ';
		For y:=0 to N-1 do
			begin
				if ( grille[x,y] = MORT ) then affichetext := affichetext + ' . ' 
                else if ( grille[x,y] = VIE ) then affichetext := affichetext + ' v '
				else affichetext := affichetext + ' ? ';
			end;		
              writeln(affichetext);
    end;
   
    readln; 
End;
	

{ exercise 3.9 }
function run(grilleInitiale: typeGrille; n: Integer) : typeGrille;
Var i : integer;
Begin

    if ( n > 0 ) then 
	begin
        For i:=1 to n do
		Begin
			grilleInitiale := calculerNouvelleGrille(grilleInitiale);
            afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE APRES L''ITERATION ' + IntToStr(i), grilleInitiale, False);
		end;
	end
    else 
        While(n <= 0) do
        Begin
            grilleInitiale := calculerNouvelleGrille(grilleInitiale);
            afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE - ITERATION EN BOUCLE', grilleInitiale, False);
        End;
        run := grilleInitiale;
 End;

{fonction supplémentaire}
function InitTableau : tabPosition;
var
  Input: string;
  nbvivante: Integer;
  x, y, i  : Integer;

tableau: tabPosition;

Begin
	for i:=0 to M-1 do
	Begin
		tableau[i].x := -1;
		tableau[i].y := -1;
	end;
	Write('VEUILLEZ SAISIR LE NOMBRE DE CELLULES VIVANTES : ');
	readln(nbvivante);
	Writeln('DONNEZ LES COORDONEES DES CELLULES VIVANTES : ');
    for i:=0 to nbvivante-1 do
    Begin
		write('COORDONEES ' + IntToStr(i+1) + ' DE X : ');
		readln(x);
		write('COORDONEES ' + IntToStr(i+1) + ' DE Y : ');
		readln(y);
		if ( x >= 0) and (x  < N) and ( y >= 0) and  (y <N) then begin
			tableau[i].x := x;
			tableau[i].y := y;
		end
    end;	
	InitTableau := tableau;
End;

{Procedure menu  choix1 }
Procedure Choix1 (nbreiter : integer);
Var grille : typeGrille;
tableau : tabPosition;

Begin

    tableau := InitTableau;
    grille := remplirGrille(tableau);
    grille := run(grille,nbreiter);
    afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE FINALE APRES LA SIMULATION', grille, true);
  
End;


{Procedure  menu choix2}
Procedure Choix2(nbreiter : integer);
Var pourcentage : real;
p1 : string;
 grille : typeGrille;
Begin
        writeln('VEUILLEZ SAISIR UN POURCENTAGE !');
        Readln(pourcentage);
         grille := InitGrille(pourcentage);
         grille := run(grille,nbreiter);
         afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE FINALE APRES LA SIMULATION', grille, true);
        
End;

{ exercise 3.10 }
function menu : integer;
Var choix, pourcentage,n : integer;
grille : typeGrille;
tableau : tabPosition;
Begin
    choix := 0;
    
	repeat
            ClrScr;
            writeln('*********** MENU DU PROGRAMME *****************');
			writeln('[1] : REMPLIR LA GRILLE');
			writeln('[2] : INITIALISER LA GRILLE');
			writeln('[3] : QUITTER');
			try                                       {exécute les commandes du menu sauf s'il y a une exception comme une lettre à la place d'un nombre}
                Readln(choix);
                if  (choix = 1) or ( choix = 2 ) then begin
                    write('DONNEZ LE NOMBRE D"ITERATIONS POUR LA SIMULATION : ');
                    readln(n);
                end;
                case choix of
                    1 :    begin
                                Choix1(n);
                            end;
                    2 :    begin
                                Choix2(n);
                            end;   
                    
                end;{ fin du  case}
            Except    
                on E :Exception do begin
                   writeln('VALEUR NON AUTORISEE, APPUYER SUR UNE TOUCHE POUR RECOMMENCER SVP !');
                   readkey;
                end;
            end; { end of try}
    until ( choix = 3);
	
	menu := choix;
end;




Var choix : integer;
Begin
   
    choix := menu;
    if (  choix = 3 ) then begin
        writeln('LE JEU EST TERMINE. A BIENTOT  ! Appuyez sur une touche pour sortir');
    end;
end.  { fin du programme }
