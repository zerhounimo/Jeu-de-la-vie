Program SimulationPrairie;
{$IFDEF FPC}{$MODE OBJFPC}{H$H+}{$ENDIF}
USES Crt, sysutils;

Const 
    AGE_MORT_HERBE = 5;
    ENERGIE_REPRODUCTION_HERBE = 10;
    ENERGIE_INITIALE_HERBE = 1;
    ENERGIE_INCREMENT_HERBE = 4;
    AGE_MORT_MOUTON = 15;
    ENERGIE_REPRODUCTION_MOUTON = 20;
    ENERGIE_MANGE_MOUTON = 14;
    ENERGIE_INITIALE_MOUTON = 11;
    ENERGIE_DEPLACER_MOUTON = -2;
    ENERGIE_RIENFAIRE_MOUTON = -1;
    PRAIRIE_OBJET_ABSENT = -1;
    LE_VIDE = '--';
    UNE_HERBE = 'h_';
    UN_MOUTON = '_m';
    UNE_HERBE_PLUS_MOUTON = 'hm';
    N = 5;
           
 {Question 5.1}          
Type 
     ObjetDef = record
        energie : integer;
        age : integer;
    end;
     
    GrillePos = record    
       x,y : integer;     {postion des mouton et des herbes}
     end;   
     PrairieObjets = object
        Herbe : ObjetDef;
        Mouton : ObjetDef;
        
    end;
    
    typeGeneration2 = array[0..N-1,0..N-1] of PrairieObjets ; {Demander la valeur de M et N à l'utilisateur}
    position =   array of GrillePos;
    procedure afficherGeneration2(generation2: typeGeneration2); forward;
    function IsMoutonPresentDansCellule(Mouton: ObjetDef) : boolean; forward;
    function IsHerbePresentDansCellule(Herbe: ObjetDef) : boolean; forward;
    
{ procedure supplémentaire, pour pouvoir voir l'évolution pendant la simulation, avec ou sans effacer les données précédentes}
Procedure afficheMessageGrille(message : string; generation2 : typeGeneration2; doitEffacer :boolean );
Begin
	if ( doitEffacer = True ) then ClrScr;
	writeln(message);
	writeln('******************************************************');	
	afficherGeneration2(generation2);
End;
 
 {Question 5.3}
procedure afficherGeneration2(generation2 : typeGeneration2);	
var
x, y : integer;
affichetext: string;
moutonPresent, HerbePresent : boolean;
Begin
	
	For x:= 0 to N-1 do
	begin
		For y:=0 to N-1 do
			begin
				
				herbePresent := IsHerbePresentDansCellule(generation2[x,y].Herbe);
                moutonPresent := IsMoutonPresentDansCellule(generation2[x,y].Mouton);
				
				 if  ( herbePresent = true ) and ( moutonPresent = false ) then affichetext :=  UNE_HERBE +  IntToStr(generation2[x,y].Herbe.energie) + '_' +  IntToStr(generation2[x,y].Herbe.age)
				else if ( herbePresent = false ) and ( moutonPresent = true  ) then affichetext :=   UN_MOUTON + IntToStr(generation2[x,y].Mouton.energie) + '_' +  IntToStr(generation2[x,y].Mouton.age)
				else if ( herbePresent = true ) and ( moutonPresent = true  ) then affichetext :=   UNE_HERBE_PLUS_MOUTON  + IntToStr(generation2[x,y].Herbe.energie) + '_'  + IntToStr(generation2[x,y].Herbe.age) + '/' + IntToStr(generation2[x,y].Mouton.energie) + '_' + IntToStr(generation2[x,y].Mouton.age)
                else affichetext :=   LE_VIDE;
				write(affichetext:15);
				{
				if  ( herbePresent = true ) and ( moutonPresent = false ) then affichetext := affichetext + UNE_HERBE
				else if ( herbePresent = false ) and ( moutonPresent = true  ) then affichetext := affichetext + UN_MOUTON
				else if ( herbePresent = true ) and ( moutonPresent = true  ) then affichetext := affichetext + UNE_HERBE_PLUS_MOUTON 
                else affichetext := affichetext + LE_VIDE
                }
			end;		
              writeln;
    end;
   
    readln; 
End;
   
Function RAZGeneration : typeGeneration2;
Var
x,y : integer;
Prairie: typeGeneration2;
Begin
	for x := 0 to (N-1) do
    Begin
	  for y := 0 to (N-1) do
	  Begin 
	     Prairie[x,y].Herbe.energie := PRAIRIE_OBJET_ABSENT; 
	     Prairie[x,y].Herbe.age := PRAIRIE_OBJET_ABSENT; 
	     Prairie[x,y].Mouton.energie := PRAIRIE_OBJET_ABSENT; 
	     Prairie[x,y].Mouton.age := PRAIRIE_OBJET_ABSENT; 
    end;  
	end;
	RAZGeneration := Prairie;
End;    


{fonction supplémentaire}


procedure initPositions(var positionMoutons, positionHerbes:  Position);
var
    nb: Integer;
    x, y, i  : Integer;
    
Begin
	
    Write('VEUILLEZ SAISIR LE NOMBRE DE MOUTONS VIVANTS :');
    readln(nb);
    setlength(positionMoutons,nb); 
    Write('DONNEZ LES COORDONEES DES MOUTONS VIVANTS ...');
    for i:=0 to nb-1 do
    Begin
        write('COORDONEES ' + IntToStr(i+1) + ' DE X : ');
		readln(x);
		write('COORDONEES ' + IntToStr(i+1) + ' DE Y : ');
		readln(y);

        if ( x >= 0) and (x  < N) and ( y >= 0) and  (y <N) then 
        begin
        	positionMoutons[i].x := x;
        	positionMoutons[i].y := y;
        end
    end;	
    Write('VEUILLEZ SAISIR LE NOMBRE D''HERBES VIVANTES :');
    readln(nb);
    setlength(positionHerbes,nb); 
    Writeln( 'DONNEZ LES COORDONEES DES HERBES VIVANTES ...');
    for i:=0 to nb-1 do
    Begin
		write('COORDONEES ' + IntToStr(i+1) + ' DE X : ');
		readln(x);
		write('COORDONEES ' + IntToStr(i+1) + ' DE Y : ');
		readln(y);
;

        if ( x >= 0) and (x  < N) and ( y >= 0) and  (y <N) then 
        begin
        	positionHerbes[i].x := x;
        	positionHerbes[i].y := y;
        end
    end;	
 
End;


{Question 5.2}

function initialiserGeneration2(vecteurPositionMoutons,vecteurPositionHerbes : Position) : typeGeneration2  ;  
Var 
Prairie : typeGeneration2;
i , nbVivant : integer;
Begin
	Prairie := RAZGeneration;
	
	nbVivant := length(vecteurPositionMoutons);
	For i := 0 to nbVivant-1 do 
        begin
			if ( (vecteurPositionMoutons[i].x >= 0) and  (vecteurPositionMoutons[i].x < N) and (vecteurPositionMoutons[i].y >=0 ) and (vecteurPositionMoutons[i].y < N) ) then
			 begin
                 Prairie[vecteurPositionMoutons[i].x,vecteurPositionMoutons[i].y].Mouton.energie:= ENERGIE_INITIALE_MOUTON;
                 Prairie[vecteurPositionMoutons[i].x,vecteurPositionMoutons[i].y].Mouton.age:= 0;
             end    
		end;
	nbVivant := length(vecteurPositionHerbes);
	For i := 0 to nbVivant-1 do 
        begin
			if ( (vecteurPositionHerbes[i].x >= 0) and  (vecteurPositionHerbes[i].x < N) and (vecteurPositionHerbes[i].y >=0 ) and (vecteurPositionHerbes[i].y < N) ) then
			 begin
                 Prairie[vecteurPositionHerbes[i].x,vecteurPositionHerbes[i].y].Herbe.energie:= ENERGIE_INITIALE_HERBE;
                 Prairie[vecteurPositionHerbes[i].x,vecteurPositionHerbes[i].y].Herbe.age:= 0;
             end    
		end;	
		initialiserGeneration2 := Prairie;
End;

function IsMoutonPresentDansCellule(Mouton: ObjetDef) : boolean;
Var
bPresent :  boolean;
Begin
	{If (Mouton.age < AGE_MORT_MOUTON) and (Mouton.energie > 0) then bPresent := true}
	If (Mouton.age <> PRAIRIE_OBJET_ABSENT) then bPresent := true
	else  bPresent := false;
	IsMoutonPresentDansCellule := bPresent;
End;

function IsHerbePresentDansCellule(Herbe: ObjetDef) : boolean;
Var
bPresent :  boolean;
Begin
	{if  (Herbe.age < AGE_MORT_HERBE) and  (Herbe.energie >= ENERGIE_INITIALE_HERBE) then  bPresent := true}
	if  (Herbe.age <> PRAIRIE_OBJET_ABSENT)  then  bPresent := true
	else  bPresent := false;
	IsHerbePresentDansCellule := bPresent;
End;
{fonction supplémentaire}
function ReproduireMoutons(generation: typeGeneration2; x,y: Integer;var listeNonModifiableMotuon : Position) :typeGeneration2 ;
Var  
i,j,coord_i,coord_j, save_i, save_j,len : integer;
isBabyCreated : boolean;
Begin 
	len := length(listeNonModifiableMotuon);
	isBabyCreated := false;
	save_i := -1; save_j := -1;
	For i:= x-1 to x+1 do
	begin
		for j := y-1 to y+1 do
		begin
			coord_i:= i;
			coord_j:= j;
			if (i < 0) then coord_i := N-1  { changement de coord  de x et  y si en dehors de la limite du tableau càd < 0 ou > N-1}
			else if (i > N-1) then coord_i:= 0;
			if (j < 0) then coord_j := N-1
			else if (j > N-1) then coord_j :=0;
			if  ((i <> x) or (j <> y)) and (generation[coord_i,coord_j].Mouton.energie = PRAIRIE_OBJET_ABSENT )  and (generation[coord_i,coord_j].Mouton.age = PRAIRIE_OBJET_ABSENT ) then
			begin
				save_i :=  coord_i;
				save_j := coord_j;
				if ( IsHerbePresentDansCellule(generation[coord_i,coord_j].Herbe) = true ) and (generation[coord_i,coord_j].Herbe.age < AGE_MORT_HERBE) then 
				begin
					isBabyCreated := true;
                    break;
				end
			end;    	
		end; 
		if ( isBabyCreated = true ) then break;             
		
	end;
	if ( save_i <> -1) and ( save_j <> -1 ) then
	begin
		{writeln('reproduction mouton : ' + IntToStr(coord_i) + IntToStr(coord_j));}
        generation[save_i,save_j].Mouton.energie  := ENERGIE_INITIALE_MOUTON;
        generation[save_i,save_j].Mouton.age  := 0;
        generation[x,y].Mouton.energie  :=generation[x,y].Mouton.energie - ENERGIE_REPRODUCTION_MOUTON;
        isBabyCreated := true;
        setLength(listeNonModifiableMotuon, len+1);
        listeNonModifiableMotuon[len].x := save_i;
        listeNonModifiableMotuon[len].y := save_j;
        len := len +1;
    end;
	ReproduireMoutons := generation;
end;

function DeplacerMouton(generation: typeGeneration2; x,y: Integer; var isPositionChanged : boolean;var listeNonModifiableMouton : Position) : typeGeneration2 ;
Var  
i,j,coord_i,coord_j , len: integer;
moutonPresent, herbePresent : boolean;
placeTrouve : grillePos;

Begin 
	
	placeTrouve.x := -1;
	placeTrouve.y := -1;
	isPositionChanged := false;
	len := length(listeNonModifiableMouton);
	For i:= x-1 to x+1 do
	begin
		for j := y-1 to y+1 do
		 begin
			coord_i:= i;
			coord_j:= j;
			if (i < 0) then coord_i := N-1  { changement de coord  de x et  y si en dehors de la limite du tableau càd < 0 ou > N-1}
			else if (i > N-1) then coord_i:= 0;
			if (j < 0) then coord_j := N-1
			else if (j > N-1) then coord_j :=0;
			if  (i <> x) or (j <> y)then
			begin
				herbePresent := IsHerbePresentDansCellule(generation[coord_i,coord_j].Herbe);
				moutonPresent := IsMoutonPresentDansCellule(generation[coord_i,coord_j].Mouton);
				if ( herbePresent = true) and ( moutonPresent = false ) then
				begin
					{
					writeln('position changing to ' + IntToStr(coord_i) + IntToStr(coord_j));
					readln;
					}
					placeTrouve.x := coord_i;
					placeTrouve.y := coord_j;
					isPositionChanged := true;
					break;
				end
				
				else if ( herbePresent = false ) and ( moutonPresent = false ) then
				begin 
					placeTrouve.x := coord_i;
					placeTrouve.y := coord_j;
					isPositionChanged := true;
					break;
				end;  
			end;    	
		end;    
		if (  isPositionChanged = true ) then break;           
	end;
	if ( placeTrouve.x <> -1) and ( placeTrouve.y <> -1) then
	begin
		isPositionChanged := true;
		{writeln('position changing to ' + IntToStr(placeTrouve.x) + IntToStr(placeTrouve.y));}
		setLength(listeNonModifiableMouton, len+1);
        listeNonModifiableMouton[len].x := placeTrouve.x;
		listeNonModifiableMouton[len].y := placeTrouve.y;
		generation[ placeTrouve.x, placeTrouve.y].Mouton.energie  := generation[x,y].Mouton.energie + ENERGIE_DEPLACER_MOUTON;
		generation[ placeTrouve.x, placeTrouve.y].Mouton.age  := generation[x,y].Mouton.age;
		generation[x,y].Mouton.energie  := PRAIRIE_OBJET_ABSENT;
		generation[x,y].Mouton.age  := PRAIRIE_OBJET_ABSENT;
		
	end ;
	DeplacerMouton := generation;
end;
{
fonction qui retourne vrai ou faux pour indiquer si on doit traiter certains logiques dans les autres fonctions
lstNonModifiable : coord des cellules non modifiables
x, y - coord de la cellule à vérifier
}
function IsPositionIn_NonModifedList(x,y : integer;lstNonModifiable: Position) : boolean;
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
			break; {  premier position dnas la liste no modifiable est  detecté, donc on sort du boucle avec un break }
		end
    end;
    IsPositionIn_NonModifedList := present_inlist;
end;

{
fonction qui retourne PrairieObjets - 
celluleObjet : contient l'herbe et le mouton de la grille initiale
nouvelleGenerationH : grille de la nouvelleGeneration des herbes calculée dans cet iteration
listeNonModifiableHerbe :  tableau des positions des herbes reproduits - à ne pas prendre en compte
}

function calculerValeurMouton(celluleObjet : PrairieObjets;  var doitReproduire, doitDeplacer : boolean; x,y: Integer;  listeNonModifiableHerbe : Position) : PrairieObjets;
Var i,j ,coord_i,coord_j, arrayLen: integer;
moutonPresent, herbePresent : boolean;
Begin
	doitReproduire := false;
	doitDeplacer := false;
	herbePresent := IsHerbePresentDansCellule(celluleObjet.Herbe);
	moutonPresent := IsMoutonPresentDansCellule(celluleObjet.Mouton);
	if ( IsPositionIn_NonModifedList(x,y,listeNonModifiableHerbe) = true ) then herbePresent := false; { test si l'herbe a été reproduit pendant cet itération, si oui, le mouton ne sait pas encore }
	if ( moutonPresent = true ) then celluleObjet.Mouton.age := celluleObjet.Mouton.age + 1;
	
	If (celluleObjet.Mouton.age >= AGE_MORT_MOUTON) or (celluleObjet.Mouton.energie <=0) then  {priroité 1}
	begin
		celluleObjet.Mouton.energie := PRAIRIE_OBJET_ABSENT;
        celluleObjet.Mouton.age := PRAIRIE_OBJET_ABSENT;
        
    end    
	else if ( moutonPresent = true) and ( herbePresent = true) then  
	begin
       celluleObjet.Mouton.energie := celluleObjet.Mouton.energie+ENERGIE_MANGE_MOUTON  ; {priorité 2}
	   celluleObjet.Herbe.energie := PRAIRIE_OBJET_ABSENT;
	   celluleObjet.Herbe.age := PRAIRIE_OBJET_ABSENT;
	end
	else if (celluleObjet.Mouton.energie >= ENERGIE_REPRODUCTION_MOUTON) then {priorité 3}
		   doitReproduire := true         
	else if  ( moutonPresent = true) and ( herbePresent = false) and (celluleObjet.Mouton.energie >= 2 ) then  doitDeplacer := true {priorité 4}    
	else if  ( moutonPresent = true) and (celluleObjet.Mouton.energie < 2 ) then celluleObjet.Mouton.energie := celluleObjet.Mouton.energie +  ENERGIE_RIENFAIRE_MOUTON;  {priorité 5}    
			  { Appeller function deplacerMouton dans calculerNouvelleGeneration2, si il n y pas d'herbes on reduira son energie RIENFAIRE dans cette fonction même }       
    { A valider avec le prof }
    if (celluleObjet.Mouton.energie <=0) then
    begin 
    	celluleObjet.Mouton.energie := PRAIRIE_OBJET_ABSENT;
        celluleObjet.Mouton.age := PRAIRIE_OBJET_ABSENT;
    end;
    calculerValeurMouton := celluleObjet;
end;            
            


Function ReproduireHerbes(generation : typeGeneration2; x,y: Integer;var listeNonModifiableHerbe : Position) :typeGeneration2 ;
 Var   i, j,coord_i,coord_j , len: integer;
 isReproduced : boolean;
Begin
	len := length(listeNonModifiableHerbe);
	isReproduced := false; { permet de savoir si on doit diminuer l'energie de l'herbe ou pas }
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
			{ test : si  on n'est pas dans la position initiale et la position trouvée ne contient pas les herbes, alors => reproduire }				
            if  ((i <> x) or (j <> y)) and (generation[coord_i,coord_j].Herbe.energie = PRAIRIE_OBJET_ABSENT )  and (generation[coord_i,coord_j].Herbe.age = PRAIRIE_OBJET_ABSENT ) then   
            begin
            	setLength(listeNonModifiableHerbe, len+1); { augmenter la taille du tableau dynamiquement et sauvegarde des coord de la nouvelle cellule dans le tableau, pour ne pa traiter pendant cet iteration }
                listeNonModifiableHerbe[len].x := coord_i;
                listeNonModifiableHerbe[len].y := coord_j;
            	generation[coord_i,coord_j].Herbe.energie  := ENERGIE_INITIALE_HERBE;
            	generation[coord_i,coord_j].Herbe.age  := 0;
            	len := len +1;
				isReproduced := true; {  l'energie de l'herbe sera diminuée à la fin de la  boucle for}
            end	
            
        end;		
	end;	
	if ( isReproduced = true ) then generation[x,y].Herbe.energie  := generation[x,y].Herbe.energie  - ENERGIE_REPRODUCTION_HERBE
	else generation[x,y].Herbe.energie  := generation[x,y].Herbe.energie  +  ENERGIE_INCREMENT_HERBE;
	ReproduireHerbes := generation;
End;

{ 
Fonction qui retourne un objet Herbe
Herbe : la position x,y de l'herbe à traiter
doitReproduire :  boolean qui permet de reproduire les herbes dans la fonction appelante, sans modifier la grille initiale
}
Function calculerValeurCelluleHerbe(Herbe: ObjetDef; var doitReproduire : boolean; x,y : integer) : ObjetDef;

Begin
	doitReproduire := false;
	 if ( Herbe.energie >= ENERGIE_INITIALE_HERBE )   then  { test condition de présence d'une herbe avant d'agir sur l'objet }
	 begin
        if (Herbe.age >= AGE_MORT_HERBE ) then { mourir }
        begin
            Herbe.energie := -1;
            Herbe.age := -1;
            {writeln(IntToStr(x) + '-' + IntToStr(y) + '/Mourir'); }
        end
        else if ( Herbe.energie >= ENERGIE_REPRODUCTION_HERBE ) then { reproduction }
        begin
             doitReproduire := true;
             Herbe.age := Herbe.age + 1;
            { nous allons voirs les cases voisins pour la reproduction dans la fonction appelante}
        end
        else if ( Herbe.energie >= ENERGIE_INITIALE_HERBE )  and (Herbe.age <AGE_MORT_HERBE ) then 
         begin
            Herbe.energie := Herbe.energie + ENERGIE_INCREMENT_HERBE;
           Herbe.age := Herbe.age + 1;
        end;
    end;
	  
    calculerValeurCelluleHerbe :=Herbe ;
End;

{
fonction permet de visualiser les cordonnées mémorisés par la reproduction ou deplacement
Function DisplayCelluleNonModifiable( lstCelluleNonModifiable : Position; x, y : integer): boolean;
var bypass : boolean;
i,len : integer;
begin 
	bypass := true;
	len := length(lstCelluleNonModifiable);
	writeln('length of cells not to be modified, calling at position :' + IntToStr(x) + IntToStr(y) + ':' + IntToStr(len));
	for i := 0 to length(lstCelluleNonModifiable)-1 do
	begin
	 writeln('cell treating' + IntToStr(lstCelluleNonModifiable[i].x) + '/' + IntToStr(lstCelluleNonModifiable[i].y));
	 end;
    DisplayCelluleNonModifiable := bypass;
end;
}


{
fonction qui tourne une nouvellegenration de typeGeneration2 pour chaque itération
generation => generation initiale
}
function calculerNouvelleGeneration2(generation: typeGeneration2;numIter: integer) : typeGeneration2;
Var 

x, y : integer;
doitReproduire, doitDeplacer : boolean; { permet de savoir si on doit reproduire  les herbes et les moutons - 'doitDeplacer' concerne  uniquement les moutons }
listeNonModifiableHerbe , listeNonModifiableMotuon : position; { tableau qui contient les positions des herbes et les moutons reproduit ou deplacé pendant cet iteration, ces positions ne seront pas traités}

Begin
	 { ici, nous ne traitons que les herbes à partir de la grille initiale 'generation'  et sauvegarde leurs valeurs modifiées dans 'novelleGenerationH'}
	For x:=0 to N-1 do
	Begin
		For y:=0 to N-1 do
		Begin
			if ( IsPositionIn_NonModifedList(x,y, listeNonModifiableHerbe) = false ) then  { ici, nous ne traitons que les herbes à partir de la grille  'generation'  et sauvegarde leurs valeurs modifiées, nous ne traitons pas les herbes reproduit
                                                                                                                                            dans la le tabelau 'listeNonModifiableHerbe'}
			begin
				generation[x,y].Herbe := calculerValeurCelluleHerbe(generation[x,y].Herbe,doitReproduire, x, y);
				if ( doitReproduire = true ) then 
				begin
					generation := ReproduireHerbes(generation,x,y,listeNonModifiableHerbe);
				end;
            end; 
           
            if ( IsPositionIn_NonModifedList(x,y, listeNonModifiableMotuon) = false )  then  { ici, nous ne traitons que les moutons à partir de la grille  'generation'  et sauvegarde leurs valeurs modifiées, nous ne traitons pas les moutons reproduit
                                                                                                                                            dans la le tabelau 'listeNonModifiableMoutons'}
			begin
				generation[x,y] := calculerValeurMouton(generation[x,y],doitReproduire, doitDeplacer , x, y,listeNonModifiableHerbe);
				if ( doitReproduire = true ) then generation := ReproduireMoutons(generation,x,y,listeNonModifiableMotuon)
				else if ( doitDeplacer = true ) then 
				begin
					{writeln('Deplacer mouton de la position  '  +IntToStr(x) + IntToStr(y));}
					generation := DeplacerMouton(generation,x,y, doitDeplacer,listeNonModifiableMotuon);
                    if ( doitDeplacer = false ) then 
					begin
					generation[x,y].Mouton.energie  :=  generation[x,y].Mouton.energie +  ENERGIE_RIENFAIRE_MOUTON;  
					{writeln('Mouton non deplacé '  +IntToStr(x) + IntToStr(y));}
					end
					{afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE APRES L''ITERATION ' +IntToStr(x) + IntToStr(y), nouvelleGenerationM, False);}
				end;
			end;
			
		end;
			
	end;
	 
	
	calculerNouvelleGeneration2 := generation;
End;

{Question 5.4} 
function runGeneration2(generation : typeGeneration2; nombreIteration : integer) : typeGeneration2;
Var i : integer;


Begin
	afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE DEBUT ' , generation, False);
	 if ( nombreIteration> 0 ) then 
     begin
        For i:=1 to nombreIteration do
        Begin
       
			generation := calculerNouvelleGeneration2(generation,i);
            afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE APRES L''ITERATION ' + IntToStr(i), generation, False);
		end;
	end
    else 
        While(nombreIteration <= 0) do
        Begin
            generation := calculerNouvelleGeneration2(generation,i);
            afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE - ITERATION EN BOUCLE', generation, False);
        End;
        runGeneration2 := generation;
 End;

var
generation, newgen : typegeneration2;
positionHerbes, positionMoutons : Position;
nb : integer;

Begin
	try 	
        ClrScr;
	   generation := RAZGeneration;
	   initPositions(positionMoutons,positionHerbes);
	   generation := initialiserGeneration2(positionMoutons,positionHerbes);
	   writeln('VEUILLEZ SAISIR LE NOMBRE D''ITERATIONS... ');
	   readln(nb);
	   clrscr;
	   runGeneration2(generation,nb);
	   writeln('LE JEU EST TERMINE. A BIENTOT  ! Appuyez sur une touche pour sortir');
	Except    
		begin
           writeln('VALEUR NON AUTORISEES, FIN DU PROGRAMME !');
           readkey;
        end;
    end; { end of try}
    
    
end.  { fin du programme }
