Program SimulationPrairie;
{$IFDEF FPC}{$MODE OBJFPC}{H$H+}{$ENDIF}

USES Crt, sysutils, classes;
Const
     N = 5;
     VIE = 1;
     MORT = 0;
Type 
    
    Position = record    
        x,y : integer;     {position des objets en vie}
    end;   
    
    listePositions = array of Position;
	typeGrille = array[0..N-1,0..N-1] of Integer;

	procedure afficherGrille(grille: typeGrille); forward;
	procedure GetInitialPositions(var positioninitale : listePositions; strCoords: string); forward;


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

{ procedure supplémentaire, pour pouvoir voir l'évolution pendant la simulation, avec ou sans effacer les données précédentes}
Procedure afficheMessageGrille(message : string; Mat : typeGrille; doitEffacer :boolean );
Begin
	if ( doitEffacer = True ) then ClrScr;
	writeln(message);
	writeln('******************************************************');	
	afficherGrille(Mat);
End;
 
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
	writeln('AVEC LES COORDONNEES DES POSITIONS DE VIE INITIALE');
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
function InitPositions(var nbIteration : integer): listePositions;
var
    
    positioninitale: listePositions;
    strCoord: string;
    

Begin
			write('VEUILLEZ DONNER LE NOMBRE D''ITERATIONS POUR LA SIMULATION : ');
            readln(nbIteration);
			clrscr;
            Writeln('VEUILLEZ SAISIR LES COORDONEES DES CELLULES VIVANTES DANS CE FORMAT (x y)  : ');
            writeln('X et Y ENTRE PARENTHESE SEPARE PAR UN ESPACE');
            Writeln('EXEMPLE D''UTILISATION : POUR TROIS CELLULES VIVANTES AYANT LES COORDONNEES');
            writeln('0,0 2,3 et 4,4 SAISIR : (0 0) (2 3) (4 4) ');
            Writeln('LE NON RESPECT DE CETTE REGLE INITIALISERA LES POSITIONS A -1 !'); 
            readln(strCoord);
           GetInitialPositions(positioninitale,strCoord);
            
	InitPositions := positioninitale;
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
            p := Pos(separateur,str); // trouvé la position du caractère espace dans la chaine str
            if p > 0 then begin //  p > 0 vaut 
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

procedure SaveToDisk( positioninitale : listePositions; nb : integer; fileName, msg: string);
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
        len := length(positioninitale);
        strCoords := 'Position = [';
        for i := 0 to len-1 do
        begin
            strCoords := strCoords + '(' + IntToStr(positioninitale[i].x) + ' ' + IntToStr(positioninitale[i].y) + ') ';
        end;
         if ( len > 0 ) then strCoords := copy(strCoords,1,length(strCoords)-1)  + ']'  // pour supprimer le dernier espace, si il y a au moins une vie
         else strCoords := strCoords  + ']';  //  aucune vie après la simulation , la ligne reste comme celle ci : Position =[]
         // Set the name of the file that will be created
        AssignFile(tfIn, fileName);
        rewrite(tfIn); // Creation du fichier.
        writeln(tfIn, 'Vie');
        writeln(tfIn, strCoords);
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
		s := copy(s,20,length(s)); // copier le reste après le mot 'NombreGeneration = '
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

    // Définir le nom du fichier que on va lire
    AssignFile(tfIn, input_filename);

    // Incorporer le traitement des fichiers dans un bloc try / except pour gérer les erreurs avec élégance
    try
    // Ouvrez le fichier à lire
    reset(tfIn);

    // Continuez à lire les lignes jusqu'à la fin du fichier
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
       // Dans tous les cas , nous fermons le  fichier avec ou sans exceptions
        CloseFile(tfIn);    
    end; { efin du bloc try}
    
	GetInputFromFile := posCoord;
End;

// fonction remplissage de grille
Function remplirGrille(tableau: listePositions) : typeGrille;
Var 
Mat : typeGrille;
k, len: integer;
Begin
	Mat := RAZGrille;
	len := length(tableau);
	For k := 0 to len-1 do 
        begin
			if ( (tableau[k].x >= 0) and  (tableau[k].x < N) and (tableau[k].y >=0 ) and (tableau[k].y < N) ) then Mat[tableau[k].x,tableau[k].y] := 1;
		end;
	afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE APRES REMPLISSAGE', Mat, True);	
	remplirGrille := Mat;
		
End;


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
 Procedure SaveTheGame(positionInitiale: listepositions;grille:typeGrille;nbiteration: integer; input_filename, output_filename: string);
 var posFinale: listepositions;
 x,y, len : integer;
 Begin
 	SaveToDisk( positionInitiale, nbiteration, input_filename, 'les coordonnées de la grille initiale ');
 	len := 0;
 	setlength(posFinale,0);  // on part à zero, posfInale contient aucun objet en vie
 	For y:= 0 to N-1 do
	begin
		For x:=0 to N-1 do
			begin
				if ( grille[x,y] = VIE ) then begin
                    setlength(posFinale,len+1);  
                    posFinale[len].x := x;
                    posFinale[len].y := y;
                    len := len +1;
                end
			end;		
    end;
    SaveToDisk( posFinale, nbiteration, output_filename, 'les coordonnées de la grille finale après la simulation ');
 End;
// programme principale
Var 
    positionInitiale : listePositions;
    nbiteration : integer;
    input_filename, output_filename: string;
	Var grille : typeGrille;
Begin
	
	try
        // si le valeurs attendues des arguments de 1 ou 3 est différents de -i ou -o, nous informons l'utilsateur le fonctionnement du programme
        if ( ParamCount < 4 ) or ( ( lowercase(ParamStr(1))  <> '-i') and ( lowercase(ParamStr(1)) <> '-o') )   or ( ( lowercase(ParamStr(3))  <> '-i') and ( lowercase(ParamStr(3)) <> '-o') ) then 
        begin
            afficherUtilisation;
        end	
        else begin
            GetFileNames(input_filename, output_filename); // on recupère le nom du fichier d'entrée et sortie à partir du argument 2 et 4 , les arguments peuvent être inversés, cette fn doit le traiter correctement
            If FileExists(input_filename) Then positionInitiale := GetInputFromFile(input_filename,nbiteration) // si le fichier d'entrée est présent, on recupère les valeurs initiales à partir de ce fichier dans le tableau positionInitiale
			else positionInitiale := InitPositions(nbiteration); // si non, on demande l'utilisatur de les saisir dans un format attendu
			grille := remplirGrille(positionInitiale);
			grille := run(grille,nbiteration);
			afficheMessageGrille('VALEURS DES CELLULES DE LA GRILLE FINALE APRES LA SIMULATION', grille, true);
			SaveTheGame(positionInitiale,grille,nbiteration,input_filename, output_filename); // sauvegarde de jeu d'entrée et sortie  avec les noms des fichiers saisie par l'utilisateur  dans la ligne de commande
        end;   
     Except    
         on E :Exception do begin
               writeln(E.message);
               readkey;
          end
    end;
          
end.  { fin du programme }