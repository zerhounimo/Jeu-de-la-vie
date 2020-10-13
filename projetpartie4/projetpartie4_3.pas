Program Simulationprairie2;
{$IFDEF FPC}{$MODE OBJFPC}{H$H+}{$ENDIF}
{$APPTYPE CONSOLE}
USES Crt, sysutils, classes;

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


{***********************************************************************************************************************}
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
    procedure GetInitialPositions(var positioninitale : position; strCoords: string); forward;

{***********************************************************************************************************************}
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
	writeln('AVEC LES COORDONNEES DES POSITIONS DES HERBES ET MOUTONS INITIALES');
	writeln;
	writeln(' -o ficout =>  NOM DU FICHIER DE SORTIE A SAUVEGARDER');
	writeln('APRES LA SIMULATION D''UNE NOUVELLE GENERATION');
	writeln;
	
End;

{***********************************************************************************************************************}
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

{***********************************************************************************************************************}
{fonction supplémentaire}
procedure InitPositions2(var nbIteration : integer; var posInititialeHerbe,posInitialeMouton:position);
var
    nbherbes, x, y, i  : Integer;
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
            GetInitialPositions(posInititialeHerbe,strCoord);
           
            Writeln('VEUILLEZ SAISIR LES COORDONEES DES MOUTONS VIVANTS DANS CE FORMAT (x y)  : ');
            writeln('X et Y ENTRE PARENTHESE SEPARE PAR UN ESPACE');
            Writeln('EXEMPLE D''UTILISATION : POUR TROIS MOUTONS VIVANTS AYANT LES COORDONNEES');
            writeln('0,0 2,3 et 4,4 SAISIR : (0 0) (2 3) (4 4) ');
             Writeln('LE NON RESPECT DE CETTE REGLE INITIALISERA LES POSITIONS A -1 !'); 
           readln(strCoord);
           GetInitialPositions(posInitialeMouton,strCoord);
           
           ClrScr;
            
	
End;

{***********************************************************************************************************************}
//  strcoords :  chaine des coordonnées sous forme de (x y) (x y) etc...
procedure GetInitialPositions(var positioninitale : position; strCoords: string);
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

{***********************************************************************************************************************}
procedure SaveToDisk(  positionH,positionM : position; nb : integer; fileName, msg: string; isSortie: boolean;grille : typeGeneration2);
var
    i,j, len : integer;
    ch : char;
    strCoordsH,strCoordsM : string;
    tfIn: TextFile;
Begin
	write('Voulez-vous sauvegarder ' + msg + ' dans un fichier (O/N) ? :  ');
	ch:=ReadKey;
    if ( ch = 'o' ) or (ch = 'O') then begin
    try
        AssignFile(tfIn, fileName);  //  définir le nom du fichier qui sera crée
        rewrite(tfIn); // Creation du fichier.
        writeln(tfIn, 'Vie');
        len := length(positionH);
        strCoordsH := 'Position_Herbes = [';
        for i := 0 to len-1 do
        begin
            strCoordsH := strCoordsH + '(' + IntToStr(positionH[i].x) + ' ' + IntToStr(positionH[i].y) + ') ';
        end;
         strCoordsH := copy(strCoordsH,1,length(strCoordsH)-1)  + ']';  // pour supprimer le dernier espace
          writeln(tfIn, strCoordsH);  // écriture des position initiales ou les positions en vie des herbes après run génération
        len := length(positionM);
        strCoordsM := 'Position_Moutons = [';
        for j:= 0 to len-1 do
        begin
            strCoordsM := strCoordsM + '(' + IntToStr(positionM[j].x) + ' ' + IntToStr(positionM[j].y) + ') ';
        end;
         strCoordsM := copy(strCoordsM,1,length(strCoordsM)-1)  + ']'; 
        
        writeln(tfIn, strCoordsM); // écriture des position initiales ou les positions en vie des moutons après run génération
        if ( isSortie ) then 
          begin
          	 len := length(positionH);
             strCoordsH := 'Energie_Age_Herbes = [';
        	for i := 0 to len-1 do
            begin
                strCoordsH := strCoordsH + '(' + IntToStr(grille[positionH[i].x,positionH[i].y].Herbe.energie) +' '+  IntToStr(grille[positionH[i].x,positionH[i].y].Herbe.age) + ') ';
            end;
            writeln(tfIn, strCoordsH); // écriture de l'energie et de l'age des herbes après run génération
                 len := length(positionM);
                strCoordsM := 'Energie_Age_Moutons = [';
                for j:= 0 to len-1 do
            begin
                strCoordsM := strCoordsM + '(' + IntToStr(grille[positionM[j].x,positionM[j].y].Mouton.energie) +' '+  IntToStr(grille[positionM[j].x,positionM[j].y].Mouton.age) + ') ';
            end;
            writeln(tfIn, strCoordsM); // écriture de l'energie et de l'age des Moutons après run génération
                
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

{***********************************************************************************************************************}
function IsValidPositions(var s : string;var posCoord: position): boolean;
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

{***********************************************************************************************************************}
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
	    
{***********************************************************************************************************************}	    
procedure GetInputFromFile(input_filename: string; var nbIteration : integer;positionInitialeH,positionInitialeM : position);
var
    posCoord : position ;
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
    
	
End;

 {***********************************************************************************************************************}	   
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


{***********************************************************************************************************************}
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


{***********************************************************************************************************************}
function IsMoutonPresentDansCellule(Mouton: ObjetDef) : boolean;
Var
bPresent :  boolean;
Begin
	{If (Mouton.age < AGE_MORT_MOUTON) and (Mouton.energie > 0) then bPresent := true}
	If (Mouton.age <> PRAIRIE_OBJET_ABSENT) then bPresent := true
	else  bPresent := false;
	IsMoutonPresentDansCellule := bPresent;
End;

{***********************************************************************************************************************}
function IsHerbePresentDansCellule(Herbe: ObjetDef) : boolean;
Var
bPresent :  boolean;
Begin
	{if  (Herbe.age < AGE_MORT_HERBE) and  (Herbe.energie >= ENERGIE_INITIALE_HERBE) then  bPresent := true}
	if  (Herbe.age <> PRAIRIE_OBJET_ABSENT)  then  bPresent := true
	else  bPresent := false;
	IsHerbePresentDansCellule := bPresent;
End;

{***********************************************************************************************************************}
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
End;

{***********************************************************************************************************************}
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

{***********************************************************************************************************************}

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

{***********************************************************************************************************************}
 
Function ReproduireVoisins(generation : typeGeneration2; x,y: Integer; var lstNonModifiable : position) :typeGeneration2 ;
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
							
            if  ((i <> x) or (j <> y)) and (generation[coord_i,coord_j].Herbe.energie = PRAIRIE_OBJET_ABSENT )  and (generation[coord_i,coord_j].Herbe.age = PRAIRIE_OBJET_ABSENT ) then   
            begin
            	writeln(IntToStr(coord_i) + '-' + IntToStr(coord_j)+ '/' + IntToStr(generation[coord_i,coord_j].Herbe.energie) + '/'  + IntToStr(generation[coord_i,coord_j].Herbe.age));
            	generation[coord_i,coord_j].Herbe.energie  := ENERGIE_INITIALE_HERBE;
            	generation[coord_i,coord_j].Herbe.age  := 0;
            	setLength(lstNonModifiable, len+1);
                lstNonModifiable[len].x := coord_i;
                lstNonModifiable[len].y := coord_j;
                isReproduced := true;
                len := len +1;
            end	
        end;		
	end;	
	if ( isReproduced ) then generation[x,y].Herbe.energie  := generation[x,y].Herbe.energie  - ENERGIE_REPRODUCTION_HERBE;
	ReproduireVoisins := generation;
End;

{***********************************************************************************************************************}

Procedure afficheMessageGrille(message : string; generation : typeGeneration2; doitEffacer :boolean );
Begin
	if ( doitEffacer = True ) then ClrScr;
	writeln(message);
	
	writeln('******************************************************');	
	afficherGeneration2(generation);
End;

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

{***********************************************************************************************************************}


 {Fonction qui retourne un objet Herbe
Herbe : la position x,y de l'herbe à traiter
doitReproduire :  boolean qui permet de reproduire les herbes dans la fonction appelante, sans modifier la grille initiale}
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
 
{***********************************************************************************************************************}
 
{fonction supplémentaire}
function IsPositionIn_NonModifedList(x,y : integer;lstNonModifiable: position) : boolean;
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

{***********************************************************************************************************************}
{fonction qui retourne PrairieObjets - 
celluleObjet : contient l'herbe et le mouton de la grille initiale
nouvelleGenerationH : grille de la nouvelleGeneration des herbes calculée dans cet iteration
listeNonModifiableHerbe :  tableau des positions des herbes reproduits - à ne pas prendre en compte}

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
End;            

{***********************************************************************************************************************}
{fonction qui tourne une nouvellegenration de typeGeneration2 pour chaque itération
generation => generation initiale}
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

{***********************************************************************************************************************}

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
 
 {***********************************************************************************************************************}

Procedure SaveTheGame( positionInitialeH,positionInitialeM: position;grille:typeGeneration2;nbiteration: integer; input_filename, output_filename: string);
 var posFinaleM,posFinaleH : position;
 x,y, lenH, lenM : integer;
 Begin
	// sauvegarder les positions initiale des herbes et les moutons
 	SaveToDisk(  positionInitialeH,positionInitialeM, nbiteration, input_filename, 'les coordonnées de la grille initiale ', false,grille);
	lenH := 0;
	lenM := 0; 
 	setlength(posFinaleH,0);  // on part à zero, posfInale contient aucun objet en vie pour les herbes
 	setlength(posFinaleM,0);  // on part à zero, posfInale contient aucun objet en vie pour les moutons
 	For y:= 0 to N-1 do
	begin
		For x:=0 to N-1 do
			begin
				if ( grille[x,y].Herbe.energie >= 0) and ( grille[x,y].Herbe.age < 5 ) then begin
                    setlength(posFinaleH,lenH+1);  
                    posFinaleH[lenH].x := x;
                    posFinaleH[lenH].y := y;
                    lenH := lenH +1;
				end;
                if ( grille[x,y].Mouton.energie > 0) and ( grille[x,y].Mouton.age <15  ) then begin
                    setlength(posFinaleM,lenM+1);  
                    posFinaleM[lenM].x := x;
                    posFinaleM[lenM].y := y;
                    lenM := lenM +1;
                end
			end;		
    end;
    SaveToDisk( posFinaleH,posFinaleM, nbiteration, output_filename, 'les coordonnées de la grille finale après la simulation ', true, grille);
 End;

{***********************************************************************************************************************}
//programme principal
Var positionInitialeH,positionInitialeM,positionInit : position;
    nbiteration : integer;
    str, input_filename, output_filename: string;
	Var grille : typeGeneration2;
Begin
	
	try
        if ( ParamCount < 4 ) or ( ( lowercase(ParamStr(1))  <> '-i') and ( lowercase(ParamStr(1)) <> '-o') )   or ( ( lowercase(ParamStr(3))  <> '-i') and ( lowercase(ParamStr(3)) <> '-o') ) then 
        begin
            afficherUtilisation;
        end	
        else begin
            GetFileNames(input_filename, output_filename);
            If FileExists(input_filename) Then GetInputFromFile(input_filename,nbiteration,positionInitialeH,positionInitialeM)
			else  InitPositions2(nbiteration,positionInitialeH,positionInitialeM);
			grille := initialiserGeneration2(positionInitialeH,positionInitialeM);
			grille := runGeneration2(grille,nbiteration);
			afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE FINALE APRES LA SIMULATION', grille, true);
			SaveTheGame(positionInitialeH,positionInitialeM,grille,nbiteration,input_filename, output_filename);
        end;   
     Except    
         on E :Exception do begin
               writeln(E.message);
               readkey;
          end
    end;
          
end.  { fin du programme }
