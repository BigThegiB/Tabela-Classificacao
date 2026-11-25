module Leitura where
    import Classificacao
    import Tipos
    import Text.Read (readMaybe)
    import Data.Char (isSpace)
    import Data.List (group, sort, intercalate)
    import Data.Either (rights, lefts)

    data Erro = CamposInvalidos Int | NumeroInvalido Int | PlacarNegativo Int | MesmoTime Int | TimeRepetidoNaRodada Int deriving (Show, Eq)

    formatarErro :: Erro -> String
    formatarErro (CamposInvalidos l) = "Linha " ++ show l ++ ": campos invalidos"
    formatarErro (NumeroInvalido l) = "Linha " ++ show l ++ ": numero invalido"
    formatarErro (PlacarNegativo l) = "Linha " ++ show l ++ ": placar negativo"
    formatarErro (MesmoTime l) = "Linha " ++ show l ++ ": mesmo time como mandante e visitante"
    formatarErro (TimeRepetidoNaRodada r) = "Rodada " ++ show r ++ ": time repetido na rodada"

    trim :: String -> String
    trim = reverse . dropWhile isSpace . reverse . dropWhile isSpace

    separar :: Char -> String -> [String]
    separar _ [] = []
    separar c s =
        let (h, t) = break (== c) s
        in case t of
            [] -> [h]
            (_:[]) -> [h, ""]
            (_:t2) -> h : separar c t2

    lerPartida :: Int -> String -> Either Erro Partida
    lerPartida l s =
        let campos = map trim (separar ';' s)
        in case campos of
            [r, m, gm, gv, v] ->
                if null m || null v then Left (CamposInvalidos l)
                else do
                    rod <- maybe (Left (NumeroInvalido l)) Right (readMaybe r :: Maybe Int)
                    gmandante <- maybe (Left (NumeroInvalido l)) Right (readMaybe gm :: Maybe Int)
                    gvisitante <- maybe (Left (NumeroInvalido l)) Right (readMaybe gv :: Maybe Int)
                    if rod <= 0 then Left (NumeroInvalido l)
                    else if gmandante < 0 || gvisitante < 0 then Left (PlacarNegativo l)
                    else if m == v then Left (MesmoTime l)
                    else Right (Partida rod m gmandante gvisitante v)
            _ -> Left (CamposInvalidos l)

    ignorarComentarios :: String -> Bool
    ignorarComentarios l =
        case dropWhile isSpace l of
            "" -> False
            ('#':_) -> False
            _ -> True

    verificarTodosRepetidos :: [Partida] -> [Erro]
    verificarTodosRepetidos ps = [TimeRepetidoNaRodada (fst x) | (x:_:_) <- group (sort grupos)]
        where
            grupos = concatMap (\p -> [(rodada p, mandante p), (rodada p, visitante p)]) ps

    verificaRepetidos :: [Partida] -> Either Erro [Partida]
    verificaRepetidos ps =
        case verificarTodosRepetidos ps of
            []    -> Right ps
            (e:_) -> Left e

    lerCampeonato :: String -> Either Erro [Partida]
    lerCampeonato s =
        let linhas = filter (ignorarComentarios . snd) $ zip [1..] (lines s)
        in do
            partidas <- traverse (uncurry lerPartida) linhas
            verificaRepetidos partidas

    todosOsErros :: String -> [Erro]
    todosOsErros s =
        let
            resultado = map (uncurry lerPartida) $ filter (ignorarComentarios . snd) $ zip [1..] (lines s)
        in lefts resultado ++ verificarTodosRepetidos (rights resultado)

    formatarAprov :: Double -> String
    formatarAprov x =
        let (inteiro, dec) = divMod (round (x * 10) :: Int) 10
        in show inteiro ++ "." ++ show dec ++ "%"

    tabelaFormatada :: [Linha] -> String
    tabelaFormatada ls = unlines $ cabecalho : zipWith formatacao [1 :: Int ..] ls
        where
            cabecalho = "Posicao - Time - Jogos - Vitorias - Empates - Derrotas - Gols Pro - Gols Contra - Saldo - Pontos - Aproveitamento"
            formatacao pos l = intercalate " - " $
                [show pos, time l]
                ++ map (\f -> show (f l)) [jogos, vitorias, empates, derrotas, gols_pro, gols_contra, saldo, pontosLinha]
                ++ [(formatarAprov (aproveitamento l))]