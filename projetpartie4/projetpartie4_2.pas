Program Simulationprairie2;
{$IFDEF FPC}{$MODE OBJFPC}{H$H+}{$ENDIF}
{$APPTYPE CONSOLE}
USES Crt, sysutils, classes;

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

procedure GetInitialPositions(var positioninitale : listePositions; strCoords: string); forward;
    
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

// procédure qui affiche les arguments nécessaires dans la ligne de commande  pour le bon fonctionmment . Aide à l'utilisateur
procedure afficherUtilisation;
Begin
	Writeln('***** Utilisation du programme *******');
	writeln;
	writeln('SimulationPrairie -i ficin -o ficout');
	writeln;
	writeln('*************  ou ********************');
	writeln;
	writeln('SimulationPrairie -o ficout -i ficin');
	writeln;
	writeln(' -i ficin => -i NOM DU FICHIER D''ENTREE A LIRE OU A SAUVEGARDER');
	writeln('AVEC LES COORDONNEES DES POSITIONS DES HERBES INITIALES');
	writeln;
	writeln(' -o ficout =>  NOM DU FICHIER DE SORTIE A SAUVEGARDER');
	writeln('APRES LA SIMULATION D''UNE NOUVELLE GENERATION');
	writeln;
	
End;

// récuperer les nom des fichiers d'entrée et de sortie selon les paramètres de commandes saisies par l'utilisateur 
procedure GetFileNames(var input_filename, output_filename: string);
Begin
	input_filename := '';
	output_filename := '';
	case  lowercase(ParamStr(1)) of
        '-i' : begin
                    input_filename := ParamStr(2);
                end;
         '-o' : begin
                    output_filename := ParamStr(2);
                  end;       
    end;
     case  lowercase(ParamStr(3)) of
        '-i' : begin
                    input_filename := ParamStr(4);
                end;
         '-o' : begin
                    output_filename := ParamStr(4);
                  end;       
    end;   
    if ( length(output_filename) <= 0 ) or (  length(input_filename) <= 0 )   then
    begin
    	writeln('LE NOM DU FICHIER D''ENTREE ET/OU SORTIE N''EST PAS VALIDE !');
    	exit;
    end;     
End;


{fonction supplémentaire}
function InitPositions2(var nbIteration : integer): listePositions;
var
    nbherbes, x, y, i  : Integer;
    positioninitale: listePositions;
    strCoord: string;
    isValid : boolean;

Begin
	ClrScr;
			write('VEUILLEZ DONNER LE NOMBRE D''ITERATIONS POUR LA SIMULATION : ');
            readln(nbIteration);
			clrscr;
            Writeln('VEUILLEZ SAISIR LES COORDONEES DES HERBES VIVANTES DANS CE FORMAT (x y)  : ');
            writeln('X et Y ENTRE PARENTHESE SEPARE PAR UN ESPACE');
            Writeln('EXEMPLE D''UTILISATION : POUR TROIS HERBES VIVANTES AYANT LES COORDONNEES');
            writeln('0,0 2,3 et 4,4 SAISIR : (0 0) (2 3) (4 4) ');
            Writeln('LE NON RESPECT DE CETTE REGLE INITIALISERA LES POSITIONS A -1 !'); 
            readln(strCoord);
           GetInitialPositions(positioninitale,strCoord);
            
	InitPositions2 := positioninitale;
End;

//  strcoords :  chaine des coordonnées sous forme de (x y) (x y) etc...
procedure GetInitialPositions(var positioninitale : listePositions; strCoords: string);
var
    separateur,str  : string;
    i, p,x, y, len: Integer;
    OutPutList: TStringList;
Begin
   // Creation d'une liste pour  recuperer les coord
  separateur := ' '; // espace pour separer les coord x et y
  OutPutList := TStringList.Create;
  len := length(positioninitale);
  try
    // Utiliser le caractère fermeture de parenthèse pour decouper
    OutPutList.Delimiter := ')';
    OutPutList.StrictDelimiter := true; // oui, ce format est attendu, (x y) (x y)
    // Fournir la chaine saisie par l'utilisateur pour decouper
    OutPutList.DelimitedText := strCoords;
    // si la saisie est correcte, nous obtenons (x,y (x,y etc.. dans outputList
    for i := 0 to OutPutList.Count - 1 do   //  attention, il y a toujours un élément en trop après decoupage
    begin
      x := -1; y := -1; // nous ne savons pas si les valeurs sont correctes, par précaution initialisation à un état non supporté
      str := Trim(OutPutList[i]); // suppression des espaces  du début et fin
      if ( length(str) > 0 ) and (str[1] = '(') then // attention, l'indice de string commence tjrs à 1 non à zero comme le tableau (array)
      begin
            str := copy(str,2,length(str)); // supprime le premier caractère '('  et copier le retse
            p := Pos(separateur,str); // trouvé la position du caractère espace
            if p > 0 then begin
            	x := strToInt(Copy(str, 1, p-1));
                y := strToInt(Copy(str, p + length(separateur), length(str)));
               // writeln('x :'  + IntToStr(x) + ' y :' + IntToStr(y));
            end;
             if ( x >= 0) and (x  < N) and ( y >= -1) and  (y <N) then begin
                setlength(positioninitale,len+1);  
                 positioninitale[len].x := x;
                positioninitale[len].y := y;
                len := len +1;
             end 
         end     // fin if
      end; // fin for    
      finally
        // liberation de la mémoire
        OutPutList.Free;
      end;
End;


procedure SaveToDisk( position : listePositions; nb : integer; fileName, msg: string; isSortie: boolean;grille : typeGeneration);
var
    i, len : integer;
    ch : char;
    strCoords : string;
    tfIn: TextFile;
Begin
	write('Voulez-vous sauvegarder ' + msg + ' dans un fichier (O/N) ? :  ');
	ch:=ReadKey;
    if ( ch = 'o' ) or (ch = 'O') then begin
    try
        len := length(position);
        strCoords := 'Position = [';
        for i := 0 to len-1 do
        begin
            strCoords := strCoords + '(' + IntToStr(position[i].x) + ' ' + IntToStr(position[i].y) + ') ';
        end;
         strCoords := copy(strCoords,1,length(strCoords)-1)  + ']'; // pour supprimer le dernier espace
         // Set the name of the file that will be created
        AssignFile(tfIn, fileName);
        rewrite(tfIn); // Creation du fichier.
        writeln(tfIn, 'Vie');
        writeln(tfIn, strCoords); // écriture des position initiales ou les positions en vie après run génération
        if ( isSortie ) then 
          begin
             strCoords := 'Energie_Age = [';
        	for i := 0 to len-1 do
            begin
                strCoords := strCoords + '(' + IntToStr(grille[position[i].x,position[i].y].energie) +' '+  IntToStr(grille[position[i].x,position[i].y].age) + ') ';
            end;
            writeln(tfIn, strCoords); // écriture de l'energie et de l'age après run génération
        end;	
        writeln(tfIn,'NombreGeneration = ' + IntToStr(nb));
        CloseFile(tfIn);
          // Information à l'utilisateur et attendre la saisie d'une touche
        writeln('Fichier ', fileName, ' A ETE CREE AVCE SUCCES ! APPUYEZ SUR UNE TOUCHE POUR CONTINUER.');
        readkey;
        
    except
        // If there was an error the reason can be found here
        on E: EInOutError do
        writeln('ERREUR FICHIER DETAILS: ', E.ClassName, '/', E.Message);
		end;
	end;
End;	


function IsValidPositions(var s : string;var posCoord: listePositions): boolean;
var
    isvalid : boolean;
    tmp : string;
Begin
	isvalid := true;  // au depart , on dit tout va bien avant de tester le contenu de la ligne 2 lu dans le fichier
	// la ligne 2 doit commencer par 'Position = [' => minimum 12 caractères
	if ( length(s) < 12 ) then isvalid := false
	else
	begin
		tmp := copy(s,1,12); tmp := upcase(tmp);
		s := copy(s,13,length(s)-13); // pour supprimer le dernier caracctère ']'
		if ( tmp <> 'POSITION = [' ) then 
		begin
			s := 'FORMAT NON VALIDE, VALEUR ATTENDU LIGNE 2 => POSITION = [(x,y)]';
			isvalid := false;
        end;
		GetInitialPositions(posCoord,s);
    end;
    IsValidPositions := isvalid;
End;

function IsValidIteration(var s : string;var nbIteration: integer): boolean;
var
    isvalid : boolean;
    tmp : string;
Begin
	isvalid := true;  // au depart , on dit tout va bien avant de tester le contenu de la ligne 3 lu dans le fichier
	// la ligne 3 doit commencer par 'NombreGeneration = ' => minimum 19 caractères
	if ( length(s) < 19 ) then isvalid := false
	else
	begin
		tmp := copy(s,1,19); tmp := upcase(tmp); // convertir en majuscule et stock la même valeur dans tmp
		s := copy(s,20,length(s));
		s := Trim(s);
		writeln(s);
		writeln(tmp);
		if ( tmp <> 'NOMBREGENERATION = ' ) then 
		begin
			s := 'FORMAT NON VALIDE, VALEUR ATTENDU LIGNE 3 => NOMBREGENERATION =  Valeur';
			isvalid := false;
        end
		else nbIteration := strToInt(s);
    end;
    IsValidIteration := isvalid;
End;
	    
function GetInputFromFile(input_filename: string; var nbIteration : integer): listePositions;
var
    posCoord : listePositions ;
    tfIn: TextFile;
    s : string;
    count : integer;
Begin
	count := 0;
	nbIteration := 0; 
    writeln('Lecture du contenu du fichier : ', input_filename);
    writeln('=========================================');

    // Set the name of the file that will be read
    AssignFile(tfIn, input_filename);

    // Embed the file handling in a try/except block to handle errors gracefully
    try
    // Open the file for reading
    reset(tfIn);

    // Keep reading lines until the end of the file is reached
    while not eof(tfIn) do
    begin
      readln(tfIn, s);
      count := count + 1;
      case count of
        1 : begin
                if ( s <> 'Vie' ) then raise exception.create('FORMAT INCORRECTE :  VALEUR ATTENDU LIGNE 1=> Vie');
             end;       
        2 : begin
                if ( IsValidPositions(s, posCoord) = false ) then raise exception.create(s);
             end;
         3 : begin
                    if ( IsValidIteration(s, nbIteration) = false ) then raise exception.create(s);
              end; 
        end;
    end;
    finally
       // Done so close the file
        CloseFile(tfIn);    
    end; { end of try}
    
	GetInputFromFile := posCoord;
End;

 	   
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
        	{writeln('Appel reproduire voisins ' + IntToStr(x) + IntToStr(y));}
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
	setlength(listeNonModifiable,0); { position de coord non modifiable est RAZ, ce tableau nous servira pour ne pas toucher les voisins reproduit }
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



Procedure SaveTheGame(positionInitiale: listepositions;grille:typeGeneration;nbiteration: integer; input_filename, output_filename: string);
 var posFinale: listepositions;
 x,y, len : integer;
 Begin
 	SaveToDisk( positionInitiale, nbiteration, input_filename, 'les coordonnées de la grille initiale ', false,grille);
 	len := 0;
 	setlength(posFinale,0);  // on part à zero, posfInale contient aucun objet en vie
 	For y:= 0 to N-1 do
	begin
		For x:=0 to N-1 do
			begin
				if ( grille[x,y].energie >= 0) and ( grille[x,y].age < 5 ) then begin
                    setlength(posFinale,len+1);  
                    posFinale[len].x := x;
                    posFinale[len].y := y;
                    len := len +1;
                end
			end;		
    end;
    SaveToDisk( posFinale, nbiteration, output_filename, 'les coordonnées de la grille finale après la simulation ', true, grille);
 End;


Var positionInitiale : listePositions;
    nbiteration : integer;
    str, input_filename, output_filename: string;
	Var grille : typeGeneration;
Begin
	
	try
        if ( ParamCount < 4 ) or ( ( lowercase(ParamStr(1))  <> '-i') and ( lowercase(ParamStr(1)) <> '-o') )   or ( ( lowercase(ParamStr(3))  <> '-i') and ( lowercase(ParamStr(3)) <> '-o') ) then 
        begin
            afficherUtilisation;
        end	
        else begin
            GetFileNames(input_filename, output_filename);
            If FileExists(input_filename) Then positionInitiale := GetInputFromFile(input_filename,nbiteration)
			else positionInitiale := InitPositions2(nbiteration);
			grille := initialiserGeneration(positionInitiale);
			grille := runGeneration(grille,nbiteration);
			afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE FINALE APRES LA SIMULATION', grille, true);
			SaveTheGame(positionInitiale,grille,nbiteration,input_filename, output_filename);
        end;   
     Except    
         on E :Exception do begin
               writeln(E.message);
               readkey;
          end
    end;
          
end.  { fin du programme }
