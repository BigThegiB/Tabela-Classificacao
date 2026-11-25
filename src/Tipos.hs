module Tipos where
    import Data.List (nub, sort)

    type Time = String
    data Resultado = Vitoria | Empate | Derrota deriving (Show, Eq)

    data Partida = Partida {
        rodada :: Int,
        mandante :: Time,
        gols_mandante :: Int,
        gols_visitante :: Int,
        visitante :: Time
    } deriving (Show, Eq)

    data Linha = Linha {
        time :: Time,
        jogos :: Int,
        vitorias :: Int,
        empates :: Int,
        derrotas :: Int,
        gols_pro :: Int,
        gols_contra :: Int
    } deriving (Show, Eq)

    participou :: Time -> Partida -> Bool
    participou t p = (mandante p == t) || (visitante p == t)

    vencedor :: Partida -> Maybe Time
    vencedor p
        | gols_mandante p > gols_visitante p = Just (mandante p)
        | gols_mandante p < gols_visitante p = Just (visitante p)
        | otherwise = Nothing

    resultadoPara :: Time -> Partida -> Maybe Resultado
    resultadoPara t p
        | not (participou t p) = Nothing
        | Just t == vencedor p = Just Vitoria
        | gols_mandante p == gols_visitante p = Just Empate
        | otherwise = Just Derrota

    times :: [Partida] -> [Time]
    times ts = sort $ nub $ foldr etapa [] ts 
        where etapa h t = mandante h : visitante h : t
    



