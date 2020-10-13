Program SimulationPrairie;
{$IFDEF FPC}{$MODE OBJFPC}{H$H+}{$ENDIF}

USES Crt, sysutils;

Const 
    AGE_MORT_HERBE = 5;
    ENERGIE_REPRODUCTION_HERBE = 10;
    ENERGIE_INITIALE_HERBE = 1;
    ENERGIE_INCREMENT_HERBE = 4;
    PRAIRIE_OBJET_ABSENT = -1;
    N = 5;
           
 {Question 4.1}          
Type 
    HerbeDef = record
        energie : integer;
        age : integer;
    end;
    Position = record    
        x,y : integer;     // position des herbes
    end;   
    typeGeneration = array[0..N-1,0..N-1] of HerbeDef ; 
    
    listePositions = array of Position; // array dynamique qui sera alloué  pendant la saisie des positions vivantes
    
procedure AfficherEnergie(generation: typeGeneration);
 var
 x, y  : integer;
  begin
 For x:= 0 to N-1 do
	Begin
		For y:=0 to N-1 do
			Begin
				writeln(IntToStr(x) + '-' + IntToStr(y) + '/' + IntToStr(generation[x,y].energie) + '/'  + IntToStr(generation[x,y].age));
			end;		
	end;

 	
end;   
Function RAZGeneration : typeGeneration;
Var
i, j : integer;
Prairie: typeGeneration;
Begin
	for i := 0 to (N-1) do
    Begin
	  for j := 0 to (N-1) do
	  Begin 
	     Prairie[i,j].energie := PRAIRIE_OBJET_ABSENT; 
	     Prairie[i,j].age := PRAIRIE_OBJET_ABSENT; 
        end;  
	End;
	RAZGeneration := Prairie;
End;    

{fonction supplémentaire}
function InitPositions : listePositions;
var
    nbherbes, x, y, i  : Integer;
    positioninitale: listePositions;

Begin
	
        Write('VEUILLEZ SAISIR LE NOMBRE D''HERBES VIVANTES : ');
		readln(nbherbes);
		setlength(positioninitale,nbherbes);
		 Writeln('DONNEZ LES COORDONEES DES HERBES VIVANTES : ');
        for i:=0 to nbherbes-1 do
        Begin
            write('COORDONEES ' + IntToStr(i+1) + ' DE X : ');
            readln(x);
            write('COORDONEES ' + IntToStr(i+1) + ' DE Y : ');
            readln(y);
            if ( x >= 0) and (x  < N) and ( y >= 0) and  (y <N) then 
              begin
                positioninitale[i].x := x;
                positioninitale[i].y := y;
            end
      end;	
	InitPositions := positioninitale;
End;

{Question 4.2}
function initialiserGeneration(positionHerbe : listePositions) : typeGeneration  ;  
Var 
    Prairie : typeGeneration;
    k, nMax: integer;
Begin
	Prairie := RAZGeneration;
	nMax := length(positionHerbe);
	For k := 0 to nMax-1 do 
        begin
			if ( (positionHerbe[k].x >= 0) and  (positionHerbe[k].x < N) and (positionHerbe[k].y >=0 ) and (positionHerbe[k].y < N) ) then
			 begin
                 Prairie[positionHerbe[k].x,positionHerbe[k].y].energie:= ENERGIE_INITIALE_HERBE;
                 Prairie[positionHerbe[k].x,positionHerbe[k].y].age:= 0;
             end    
		end;
		initialiserGeneration := Prairie;
End;

{Question 4.3 cette fonction qui ne retourne rien, donc peut-on déclarer comme une procédure ?}
procedure afficherGeneration(generation : typeGeneration) ;
var
    x, y : integer;
    affichetext: string;
Begin
	
	For x:= 0 to N-1 do
	begin
		affichetext := ' ';
		For y:=0 to N-1 do
			begin
				if ( generation[x,y].energie <> PRAIRIE_OBJET_ABSENT ) and ( generation[x,y].age <> PRAIRIE_OBJET_ABSENT  ) and ( generation[x,y].age < AGE_MORT_HERBE)   then affichetext :=  ' h_'  + IntToStr(generation[x,y].energie) + '_' + IntToStr(generation[x,y].age)
                else affichetext :=    '.';
                write(affichetext:10);
			end;		
              writeln;
    end;
   
    readln; 
End;


 
Function ReproduireVoisins(generation : typeGeneration; x,y: Integer; var lstNonModifiable : listePositions) :typeGeneration ;
 Var   
 i, j,coord_i,coord_j, len : integer;
 isReproduced : boolean;
Begin
	len := length(lstNonModifiable);
	isReproduced := false;
	For i:= x-1 to x+1 do
	begin
		For j:=y-1 to y+1 do
		begin
            coord_i:= i;
            coord_j:= j;
            if (i < 0) then coord_i := N-1  { changement de coord  de x et  y si en dehors de la limite du tableau càd < 0 ou > N-1 - grille thorique}
            else if (i > N-1) then coord_i:= 0;
                
            if (j < 0) then coord_j := N-1
            else if (j > N-1) then coord_j :=0;
							
            if  ((i <> x) or (j <> y)) and (generation[coord_i,coord_j].energie = PRAIRIE_OBJET_ABSENT )  and (generation[coord_i,coord_j].age = PRAIRIE_OBJET_ABSENT ) then   
            begin
            	writeln(IntToStr(coord_i) + '-' + IntToStr(coord_j)+ '/' + IntToStr(generation[coord_i,coord_j].energie) + '/'  + IntToStr(generation[coord_i,coord_j].age));
            	generation[coord_i,coord_j].energie  := ENERGIE_INITIALE_HERBE;
            	generation[coord_i,coord_j].age  := 0;
            	setLength(lstNonModifiable, len+1);
                lstNonModifiable[len].x := coord_i;
                lstNonModifiable[len].y := coord_j;
                isReproduced := true;
                len := len +1;
            end	
        end;		
	end;	
	if ( isReproduced ) then generation[x,y].energie  := generation[x,y].energie  - ENERGIE_REPRODUCTION_HERBE;
	ReproduireVoisins := generation;
End;


Procedure afficheMessageGrille(message : string; generation : typeGeneration; doitEffacer :boolean );
Begin
	if ( doitEffacer = True ) then ClrScr;
	writeln(message);
	
	writeln('******************************************************');	
	afficherGeneration(generation);
End;

 {fonction supplémentaire : x, y à supprimer après test}
 Function calculerValeurCellule(Herbe: HerbeDef; var doitReproduire : boolean; x,y : integer) : HerbeDef;
Begin
	doitReproduire := false;
	 if ( Herbe.energie >= ENERGIE_INITIALE_HERBE )   then  { test condition de présence d'une herbe avant d'agir sur l'objet }
	 begin
       
        if  (Herbe.age >= AGE_MORT_HERBE ) then { mourir }
        begin
            Herbe.energie := PRAIRIE_OBJET_ABSENT;
            Herbe.age := PRAIRIE_OBJET_ABSENT;
            writeln(IntToStr(x) + '-' + IntToStr(y) + '/Mourir'); 
        end
        else if ( Herbe.energie >= ENERGIE_REPRODUCTION_HERBE ) then { reproduction }
        begin
        	writeln('Appel reproduire voisins ' + IntToStr(x) + IntToStr(y));
        	readln; 
        	doitReproduire := true;
        	{generation := ReproduireVoisins(generation,x,y);}
        	{Herbe.energie := Herbe.energie - ENERGIE_REPRODUCTION_HERBE;}
        	{ nous allons voirs les cases voisins pour la reproduction}
        end
        else if ( Herbe.energie >= ENERGIE_INITIALE_HERBE )  and (Herbe.age <AGE_MORT_HERBE ) then 
         begin
            Herbe.energie := Herbe.energie + ENERGIE_INCREMENT_HERBE;
           Herbe.age := Herbe.age + 1;
        end;
  end ;
        
      calculerValeurCellule :=Herbe ;
End;
 

 
{fonction supplémentaire}
function IsPositionIn_NonModifedList(x,y : integer;lstNonModifiable: listePositions) : boolean;
var 
i : integer;
present_inlist : boolean;
begin
	present_inlist := false;
	for i := 0 to length(lstNonModifiable)-1 do
	begin
		if ( x = lstNonModifiable[i].x) and ( y = lstNonModifiable[i].y) then
		begin
			present_inlist := true;
			break; {  premier position de reproduction detecté, donc on sort du boucle avec un break }
		end
    end;
    IsPositionIn_NonModifedList := present_inlist;
end;
Function calculerNouvelleGeneration(generation: typeGeneration) : typeGeneration;
Var 
    x, y : integer;
    doitReproduire : boolean;
    listeNonModifiable : listePositions;
Begin
	setlength(listeNonModifiable,0); { position de coord non modifiable est RAZ, ce tableau nou servira pour ne pas toucher les voisins reproduit }
    For x:=0 to N-1 do
	Begin
		For y:=0 to N-1 do
			Begin
				if ( IsPositionIn_NonModifedList(x,y, listeNonModifiable) = false ) then
				begin
                    generation[x,y] := calculerValeurCellule(generation[x,y],doitReproduire, x, y);
                    if ( doitReproduire = true ) then generation := ReproduireVoisins(generation,x,y,listeNonModifiable);
				end
			end;		
	end;
	{afficherGeneration(generation);}
	
	calculerNouvelleGeneration := generation;
End;


{Question 4.4}
function runGeneration(generation : typeGeneration; nombreIteration: integer ) : typeGeneration;
Var i : integer;
Begin

    if ( nombreIteration> 0 ) then 
	begin
        For i:=1 to nombreIteration do
		Begin
			generation := calculerNouvelleGeneration(generation);
            afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE APRES L''ITERATION ' + IntToStr(i), generation, False);
           { AfficherEnergie(generation);}
		end;
	end
    else 
        While(nombreIteration <= 0) do
        Begin
            generation := calculerNouvelleGeneration(generation);
            afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE - ITERATION EN BOUCLE', generation, False);
        End;
        runGeneration := generation;
 End;

Var positionGlobale : listePositions;
generationHerbe: typeGeneration;
nb : integer;

Begin
   try 
        ClrScr;
       positionGlobale := InitPositions;
       generationHerbe := initialiserGeneration(positionGlobale);
       afficherGeneration(generationHerbe); 
       writeln('DONNEZ LE NOMBRE D''ITERATIONS ');
       readln(nb);
       runGeneration(generationHerbe,nb);
       writeln('LE JEU EST TERMINE. A BIENTOT  ! Appuyez sur une touche pour sortir');
   Except    
		begin
           writeln('VALEUR NON AUTORISEES, FIN DU PROGRAMME !');
           readkey;
        end;
    end; { end of try}
    
    
end.  { fin du programme }
