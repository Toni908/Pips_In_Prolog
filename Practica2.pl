% Pràctica final de Llenguatges de Programació.
% Prolog - PIPS
% Estudiants: Antonio Garcia Font.
% Professor: Miquel Cabot.
% Assignatura: 21721 – Llenguatges de Programació.
% Lliurament: primera convocatòria.
% Fitxer del controlador principal.

% ----------- Quines dificultats pot resoldre el Proyecte? -------------------------------------------------
% Fàcil: Bastant ràpid.
% Mitjà: Tarda una estona, entre 20 i 60 segons.
% Difícil: Ho vaig deixar una hora i no va trobar cap resultat. Probablement ho resoldria amb prou temps, però ho considerarem com que no ho resol.

% ----------- Instruccion inicials -------------------------------------------------
% Per executar aquest proyecte, recomano tenir al mateix nivell que l'arxius pips.pl, y executar resoldre, ya que podem pasar directament la id y la difficultat
% i ens retorna la o les solucions (ara explico), y si pasam una solucio ens diu si es certa.
% El programa retorna multiples solucion, ya que no distingueix la simetria, es a dir, si hi ha una ficha 2|2, retornara una solucion de pos [0,1],[0,2] y una altra igual
% pero girades [0,2],[0,1].

% ----------- Funcions -------------------------------------------------
% Hi ha 3 funcions:
%   solucio_pips(Regions, Peces, Solucio):
%       La funcio del enunciat, necesita regions y peces, per donar o comprobar la solucio.
%   resoldre(ID, Dificultat, Solucio)
%       Aquesta es la funcio que si o si hauriem de executar, li pasam la id y la dificultad del puzzle, y retorna la solucio, molt mes comode 
%       de utilitzar que solucio_pips
%   comprovacio_solucion(ID, Dificultat)
%       Aixo practicament crida solucio pips, y retorna true en cas de que la solucio que genera el meu solucio_pips sigui igual que la solucio 
%       que esta guardada.

% ----------- Logica ------------------------------------------------------
% El disseny lògic de la solució s’ha basat en separar el problema en diferents regles independents i reutilitzables.
% Primerament, es defineixen regles bàsiques per gestionar el tauler, com ara comprovar si dues coordenades són adjacents,
% verificar si una casella està lliure o determinar si una coordenada és vàlida dins el tauler.
% Aquestes regles serveixen de base per construir la resta del programa.

% La implementació principal segueix una estratègia de backtracking pròpia de Prolog.
% La regla genera_solucio/4 és l’encarregada de generar possibles col·locacions de les fitxes de dominó.
% Per a cada peça, cerca dues coordenades adjacents i lliures del tauler i hi col·loca la fitxa.
% El procés continua recursivament fins que totes les peces han estat col·locades.
% Si en algun moment una configuració no és vàlida, Prolog retrocedeix automàticament i prova altres alternatives.

% Una vegada generada una possible solució, el programa comprova si compleix totes les restriccions del puzzle.
% Per fer-ho, s’han implementat regles específiques per a cada tipus de regió (sum, equals, less, greater, unequal i empty).
% Primer s’obtenen els valors presents a les coordenades de la regió i després es verifica la condició corresponent.
% Aquest disseny modular facilita afegir nous tipus de restriccions o modificar-ne el comportament sense afectar la resta del programa.

% Finalment, s’han creat predicats d’interfície per facilitar l’ús del sistema.
% El predicat solucio_pips/3 resol directament un puzzle a partir de les regions i les peces,
% mentre que resoldre/3 permet carregar un puzzle concret mitjançant el seu identificador i dificultat.
% També s’ha implementat comprovacio_solucion/2 per verificar que la solució calculada coincideix
% amb la solució oficial emmagatzemada al fitxer de dades.

:- consult('pips.pl').

% -------------------------------------------------------------------------------------------------------------------
%    REGLES
% -------------------------------------------------------------------------------------------------------------------
% adyacents(+Coord1, +Coord2)
% Regles per definir que dos casilles son adyacents:
% Paràmetres:
%   - Coord1: La primera coordenada [Fila, Columna].
%   - Coord2: La segona coordenada [Fila, Columna].
    adyacents([F, C1], [F, C2]) :- C2 is C1 + 1.   % Vecinas en la misma fila (derecha)
    adyacents([F, C1], [F, C2]) :- C2 is C1 - 1.   % Vecinas en la misma fila (izquierda)
    adyacents([F1, C], [F2, C]) :- F2 is F1 + 1.   % Vecinas en la misma columna (abajo)
    adyacents([F1, C], [F2, C]) :- F2 is F1 - 1.   % Vecinas en la misma columna (arriba)

% -------------------------------------------------------------------------------------------------------------------
% valor_en_casella(+Coord, +Peces, +Mapa, -Valor)
% Donat un mapa i les seves fitxes, retorna el valor que hi ha en una coordenada concreta.
% Ens servirà per saber si anem pel camí correcte en altres regles.
% Els dos primers casos comproven el valor en ambdues posicions possibles d'una fitxa,
% ja que cada fitxa té dues coordenades. El tercer cas és l'iterador de la llista.
% Paràmetres:
%   - Coord: La coordenada específica a consultar.
%   - Peces: La llista de fitxes de dominó disponibles.
%   - Mapa: La llista que indica on està cada fitxa, és la que anem provant mitjançant backtracking.
%   - Valor: El número que hi ha a la coordenada Coord.

    % 1. Buscamos en la primera pieza (CASO A)
    valor_en_casella(Coord, [[V1, _]|_], [[Coord, _]|_], V1).
    % 2. Buscamos en la primera pieza (CASO B)
    valor_en_casella(Coord, [[_, V2]|_], [[_, Coord]|_], V2).
    % 3. La iteracion para buscar toda la lista
    valor_en_casella(Coord, [_|RestaPeces], [_|RestaSol], Valor) :- valor_en_casella(Coord, RestaPeces, RestaSol, Valor).

% -------------------------------------------------------------------------------------------------------------------
% obte_valors_regio(+LlistaCoordenades, +Peces, +Mapa, -LlistaValors)
% Transforma la llista de coordenadas en els numeros de la peça de domino que estan
% en aquestes coordenades, en forma de llista, s'utilitza sobretot en comprova_regio
% Paràmetres:
%   - LlistaCoordenades: La llista de punts [Fila, Columna] que formen una regió.
%   - Peces: La llista de fitxes de dominó disponibles al joc.
%   - Mapa: La llista de posicions (on hem col·locat cada fitxa).
%   - LlistaValors: La llista resultant amb els números (pips) trobats en cada coordenada.

    % Cas base: Si no hi ha mes coordenades que mirar, la llista de valors esta vuida.
    obte_valors_regio([], _, _, []).

    % Cas recursiu: agafam tots els valors en la regio i els retornam en una llista
    obte_valors_regio([C|RestaC], Peces, Mapa, [V|RestaV]) :-
        valor_en_casella(C, Peces, Mapa, V),                % 1. Buscamos el valor V de la primera coordenada C
        obte_valors_regio(RestaC, Peces, Mapa, RestaV).     % 2. Hacemos lo mismo con el resto

% -------------------------------------------------------------------------------------------------------------------
% suma_llista(+Llista, -Total)
% Aquesta regla suma tots els valors d'una llista de números. 
% S'utilitza per comprovar si una regió de tipus 'sum', 'less' o 'greater' compleix l'objectiu.
% Paràmetres:
%   - Llista: La llista de números que hem extret d'una regió.
%   - Total: La variable on es guardarà el resultat de la suma.

    % Cas base: la suma d'una llista buida és 0.
    suma_llista([], 0).

    % Cas recursiu: Sumem el primer element (X) al total de la suma de la resta (Resta).
    suma_llista([X|Resta], Total) :- 
        suma_llista(Resta, SumaResta), 
        Total is X + SumaResta.

%-------------------------------------------------------------------------------------------------------------------
% tots_iguals(+Llista)
% Aquesta regla verifica si tots els elements d'una llista tenen el mateix valor.
% És fonamental per a les regions de tipus 'equals', on totes les caselles han de tenir el mateix número.
% Paràmetres:
%   - Llista: La llista de valors de la regió a comprovar.

    % Una llista buida o amb un sol element sempre compleix que tots els seus elements són iguals.
    tots_iguals([]).
    tots_iguals([_]).
    % Comprobam la resta de casos
    tots_iguals([X, X | Resta]) :- tots_iguals([X | Resta]).

% -------------------------------------------------------------------------------------------------------------------
% tots_diferents(+Llista)
% Aquesta regla verifica que tots els elements d'una llista siguin únics (cap valor repetit).
% Serveix per a les regions de tipus 'unequal', on cap casella pot tenir el mateix número que una altra.
% Paràmetres:
%   - Llista: La llista de valors (pips) extrets de la regió a comprovar.

    tots_diferents([]).
    tots_diferents([X|Resta]) :- 
        not(member(X, Resta)), 
        tots_diferents(Resta).

% -------------------------------------------------------------------------------------------------------------------
% comprova_regio(+Regio, +Peces, +Mapa)
% Aquí comprovarem les diferents regions depenent de l'objectiu. Com que hi ha 5 tipus
% de regions, tindrem 5 regles diferents, un per a cada objectiu.
% Paràmetres:
%   - Regio: Estructura region(Tipus, Objectiu, Coordenades) que defineix la zona, aixo el pasarem directament el regio del pips.pl.
%   - Peces: La llista de fitxes de dominó del joc.
%   - Mapa: La configuració actual de les peces al tauler (Solució).

    % La regió és 'sum' (suma)
    comprova_regio(region(sum, Objectiu, Coordenades), Peces, Mapa) :-
        obte_valors_regio(Coordenades, Peces, Mapa, Valors),
        suma_llista(Valors, Suma),
        Suma =:= Objectiu.

    % La regió és 'equals' (tots iguals)
    comprova_regio(region(equals, _, Coordenades), Peces, Mapa) :-
        obte_valors_regio(Coordenades, Peces, Mapa, Valors),
        tots_iguals(Valors).

    % La regió és 'less' (menor que)
    comprova_regio(region(less, Objectiu, Coordenades), Peces, Mapa) :-
        obte_valors_regio(Coordenades, Peces, Mapa, Valors),
        suma_llista(Valors, Suma),
        Suma < Objectiu.

    % La regió és 'greater' (major que)
    comprova_regio(region(greater, Objectiu, Coordenades), Peces, Mapa) :-
        obte_valors_regio(Coordenades, Peces, Mapa, Valors),
        suma_llista(Valors, Suma),
        Suma > Objectiu.

    % La regió és 'empty' (da igual)
    comprova_regio(region(empty, _, _), _, _).

    % La regió és 'unequal' (diferents)
    comprova_regio(region(unequal, _, Coordenades), Peces, Mapa) :-
        obte_valors_regio(Coordenades, Peces, Mapa, Valors),
        tots_diferents(Valors).

% -------------------------------------------------------------------------------------------------------------------
% comprova_totes_les_regions(+LlistaRegions, +Peces, +Mapa)
% Aquesta regla recorre de forma recursiva tota la llista de regions del trencaclosques.
% S'assegura que cada regió compleixi la seva condició (sum, equals, etc.) segons el Mapa actual.
% Paràmetres:
%   - LlistaRegions: La llista completa de les regions definides al fitxer pips.pl.
%   - Peces: La llista de fitxes de dominó utilitzades.
%   - Mapa: La solució generada (on hem posat cada fitxa).

    comprova_totes_les_regions([], _, _).
    comprova_totes_les_regions([R|Resta], Peces, Mapa) :-
        comprova_regio(R, Peces, Mapa),
        comprova_totes_les_regions(Resta, Peces, Mapa).

% coordenada_valida(+Coord, +CoordenadesValides)
% Comprova que una coordenada pertany al tauler de joc.
% Paràmetres:
%   - Coord: La coordenada [Fila, Columna] a comprovar.
%   - CoordenadesValides: La llista de totes les coordenades vàlides del tauler.

    coordenada_valida(Coord, CoordenadesValides) :- member(Coord, CoordenadesValides).


% -------------------------------------------------------------------------------------------------------------------
% obtenir_coordenades(+Regions, -Coordenades)
% Extreu totes les coordenades del tauler a partir de la llista de regions.
% Recorre recursivament totes les regions i concatena les seves coordenades en una sola llista.
% Paràmetres:
%   - Regions: La llista de regions del puzle, cada una amb les seves coordenades.
%   - Coordenades: La llista resultant amb totes les coordenades del tauler.

    obtenir_coordenades([], []).

    obtenir_coordenades( [region(_, _, CoordenadesRegion)|Resta], TotesCoordenades) :-
        obtenir_coordenades(Resta, CoordenadesResta),
        append(CoordenadesRegion, CoordenadesResta, TotesCoordenades).

%-------------------------------------------------------------------------------------------------------------------
% casella_lliure(+Coord, +Mapa)
% Verifica que una coordenada no hagi estat ocupada per cap peça ja col·locada.
% Paràmetres:
%   - Coord: La coordenada [F, C] a comprovar. Ejemplo [4,5]
%   - Mapa: La llista de peces actualment al tauler. Ejemplo [ [[0,0], [0,1]], [[4,5], [5,5]] ]

    casella_lliure(Coord, Mapa) :- not(member([Coord, _], Mapa)),  not(member([_, Coord], Mapa)).
    % La funcio member tambien puede verificar listas de array donde solo coincida un elemento de la lista

% -------------------------------------------------------------------------------------------------------------------
% genera_solucio(+PecesRestants, +MapaActual, ?MapaFinal)
% Aquesta regla és la base del backtracking. S'encarrega d'anar col·locant cada peça de dominó
% en dues coordenades que siguin adjacents i que no estiguin ocupades prèviament.
% Paràmetres:
%   - PecesRestants: Les fitxes que encara no hem posat al tauler.
%   - MapaActual: La llista de posicions que portem acumulada fins ara.
%   - MapaFinal: La llista completa de posicions un cop col·locades totes les peces.

    % Cas base: Ja hem col·locat totes les peces.
    genera_solucio(_, [], Mapa, Mapa).

    % Cas recursiu: Cerquem lloc per a la següent peça.
    genera_solucio(CoordenadesValides, [[_, _]|RestaPeces], MapaActual, Solucio) :-

        coordenada_valida(C1, CoordenadesValides),
        casella_lliure(C1, MapaActual),

        adyacents(C1, C2),

        coordenada_valida(C2, CoordenadesValides),
        casella_lliure(C2, MapaActual),

        genera_solucio( CoordenadesValides, RestaPeces, [[C1, C2]|MapaActual], Solucio).

% -------------------------------------------------------------------------------------------------------------------
%  REGLES PER L'USUARI
% -------------------------------------------------------------------------------------------------------------------
% solucio_pips(+Regions, +Peces, ?Solucio)
% Predicat principal que resol el trencaclosques Pips.
% Paràmetres:
%   - Regions: Llista de regions del fitxer pips.pl.
%   - Peces: Llista de peces de dominó del fitxer pips.pl.
%   - Solucio: El mapa final amb les coordenades de cada peça.
    solucio_pips(Regions, Peces, Solucio) :-
        obtenir_coordenades(Regions, CoordenadesValides),       % Agafa les posibles coordenades
        genera_solucio(CoordenadesValides, Peces, [], Solucio), % Col·loca les peces al tauler
        comprova_totes_les_regions(Regions, Peces, Solucio).    % Mira si és vàlid la solucio de genera_solucio

% -------------------------------------------------------------------------------------------------------------------
% resoldre(+ID, +Dificultat, ?Solucio)
% Aquest predicat serveix d'interfície per resoldre un puzzle específic del fitxer pips.pl.
% Permet tant generar una solució nova com verificar-ne una de ja existent.
% Paràmetres:
%   - ID: L'identificador numèric del trencaclosques (exemple: 20250818).
%   - Dificultat: El nivell del trencaclosques (easy, medium, hard).
%   - Solucio: Si es passa una variable (S), el programa hi retornarà la solució trobada.
%              Si es passa una llista de coordenades, el programa verificarà si és vàlida.

    resoldre(ID, Dificultat, Solucio) :-
        puzzle(ID, Dificultat, Regions, Peces, _), % Ignoramos la solución del archivo por ahora
        solucio_pips(Regions, Peces, Solucio).

% -------------------------------------------------------------------------------------------------------------------
% comprovacio_solucion(+ID, +Dificultat)
% Comprova si la solució calculada pel sistema coincideix amb la 
% solució enregistrada a la base de coneixements per a un puzle donat.
% Paràmetres:
%   - ID: L'identificador numèric del trencaclosques (exemple: 20250818).
%   - Dificultat: El nivell del trencaclosques (easy, medium, hard).

    comprovacio_solucion(ID, Dificultat) :-
        puzzle(ID, Dificultat, Regions, Peces, SolucioEsperada),
        solucio_pips(Regions, Peces, SolucioCalculada),
        SolucioEsperada = SolucioCalculada.