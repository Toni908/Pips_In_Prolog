:- consult('pips.pl').

% -------------------------------------------------------------------------------------------------------------------
%    SECCIO DEL COMPROBADOR
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
% Esta regla nos dara el valor que hay en una coordenada a partir de un mapa y sus fichas
% Esto nos servira para saber si vamos por el camino correcto para otras reglas.
% Los dos primeros casos es para comprobar el valor, ya que tenemos fichas con dos posibles coordenadas
% hay que comprobarlo en ambas posiciones. El tercer caso es el iterador de la lista.
% Parametros:
%   - Coord: La coordenada especifica a consultar.
%   - Peces: La lista de piezas de domino disponibles.
%   - Mapa: La lista que dice donde esta cada pieza, esta es la que vamos probando mediante backtracking
%   - Valor: El numero que hay en la coordenada Coord.

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

    % La regió és 'empty' (buit)
    comprova_regio(region(empty, _, _), _, _).

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


% -------------------------------------------------------------------------------------------------------------------
%    SECCIO DEL GENERADOR
% -------------------------------------------------------------------------------------------------------------------
% coordenada_valida(-Coord)
% Genera o verifica una coordenada [Fila, Columna] dins els límits del tauler que hem establezcut (0-8).
% Paràmetres:
%   - Coord: Llista [Fila, Columna].

    coordenada_valida([F, C]) :- between(0, 3, F), between(0, 3, C).

%-------------------------------------------------------------------------------------------------------------------
% casella_lliure(+Coord, +Mapa)
% Verifica que una coordenada no hagi estat ocupada per cap peça ja col·locada.
% Paràmetres:
%   - Coord: La coordenada [F, C] a comprovar. Ejemplo [4,5]
%   - Mapa: La llista de peces actualment al tauler. Ejemplo [ [[0,0], [0,1]], [[4,5], [5,5]] ]

    casella_lliure(Coord, Mapa) :- not(member([Coord, _], Mapa)),  not(member([_, Coord], Mapa)).
    % La funcio member tambien puede verificar listas de array donde solo coincida un elemento de la lista

% -------------------------------------------------------------------------------------------------------------------
% genera_solucio(+PecesRestants, +MapaActual, -MapaFinal)
% Aquesta regla és la base del backtracking. S'encarrega d'anar col·locant cada peça de dominó
% en dues coordenades que siguin adjacents i que no estiguin ocupades prèviament.
% Paràmetres:
%   - PecesRestants: Les fitxes que encara no hem posat al tauler.
%   - MapaActual: La llista de posicions que portem acumulada fins ara.
%   - MapaFinal: La llista completa de posicions un cop col·locades totes les peces.

    % Cas base: Ja hem col·locat totes les peces.
    genera_solucio([], Mapa, Mapa).

    % Cas recursiu: Cerquem lloc per a la següent peça.
    genera_solucio([[_, _]|RestaPeces], MapaActual, Solucio) :-
        coordenada_valida(C1),          % Triem una casella per al valor V1
        casella_lliure(C1, MapaActual), % Mirem que no estigui ocupada
        
        adyacents(C1, C2),              % Han d'estar una al costat de l'altra
        coordenada_valida(C2),          % Triem una casella per al valor V2
        casella_lliure(C2, MapaActual), % També ha d'estar lliure
        
        % Si tot va bé, afegim la peça al mapa i continuem amb la resta
        genera_solucio(RestaPeces, [[C1, C2]|MapaActual], Solucio).

% -------------------------------------------------------------------------------------------------------------------
%  INTERFAZ DE USUARIO
% -------------------------------------------------------------------------------------------------------------------
% solucio_pips(+Regions, +Peces, -Solucio)
% Predicat principal que resol el trencaclosques Pips.
% Paràmetres:
%   - Regions: Llista de regions del fitxer pips.pl.
%   - Peces: Llista de peces de dominó del fitxer pips.pl.
%   - Solucio: El mapa final amb les coordenades de cada peça.
    solucio_pips(Regions, Peces, Solucio) :-
        genera_solucio(Peces, [], Solucio),                     % Col·loca les peces al tauler
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