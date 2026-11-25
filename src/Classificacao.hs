module Classificacao where
    import Tipos

    import Data.List (sortBy, maximumBy)
    import Data.Ord  (comparing, Down(..))

    pontos :: Resultado -> Int
    pontos Vitoria = 3
    pontos Empate = 1
    pontos Derrota = 0

    linhaDoTime :: [Partida] -> Time -> Linha
    linhaDoTime ps t = foldr etapa linha ps
        where
            linha = Linha {time = t, jogos = 0, vitorias = 0, derrotas = 0, empates = 0, gols_pro = 0, gols_contra = 0}

            encontraGolPro :: Partida -> Int
            encontraGolPro p
                | t == mandante p = gols_mandante p
                | otherwise = gols_visitante p

            encontraGolContra :: Partida -> Int
            encontraGolContra p
                | t == mandante p = gols_visitante p
                | otherwise = gols_mandante p

            etapa p ls = case resultadoPara t p of
                Just Vitoria -> ls {jogos = jogos ls + 1, vitorias = vitorias ls + 1, gols_pro = gols_pro ls + encontraGolPro p, gols_contra = gols_contra ls + encontraGolContra p}
                Just Empate -> ls {jogos = jogos ls + 1, empates = empates ls + 1, gols_pro = gols_pro ls + encontraGolPro p, gols_contra = gols_contra ls + encontraGolContra p}
                Just Derrota -> ls {jogos = jogos ls + 1, derrotas = derrotas ls + 1, gols_pro = gols_pro ls + encontraGolPro p, gols_contra = gols_contra ls + encontraGolContra p}
                Nothing -> ls

    pontosLinha :: Linha -> Int
    pontosLinha l = ((pontos Vitoria) * (vitorias l)) + ((pontos Empate) * (empates l)) + ((pontos Derrota) * (derrotas l))

    saldo :: Linha -> Int
    saldo l = gols_pro l - gols_contra l

    aproveitamento :: Linha -> Double
    aproveitamento l = if jogos l == 0 then 0 else (fromIntegral (pontosLinha l) / fromIntegral (jogos l * pontos Vitoria)) * 100

    linhasCampeonato :: [Partida] -> [Linha]
    linhasCampeonato ps = map (linhaDoTime ps) (times ps)

    classificacao :: [Partida] -> [Linha]
    classificacao = sortBy criterio . linhasCampeonato
        where
            criterio =
                comparing (Down . pontosLinha)
                <> comparing (Down . vitorias)
                <> comparing (Down . saldo)
                <> comparing (Down . gols_pro)
                <> comparing time

    ateRodada :: Int -> [Partida] -> [Partida]
    ateRodada r ps = filter (\p -> rodada p <= r) ps

    goleadas :: Partida -> Int
    goleadas p = abs (gols_mandante p - gols_visitante p)

    maiorGoleada :: [Partida] -> Maybe Partida
    maiorGoleada [] = Nothing
    maiorGoleada ps = Just $ maximumBy (comparing goleadas) ps

    mediaGols :: [Partida] -> Maybe Double
    mediaGols [] = Nothing
    mediaGols ps = Just $ (fromIntegral $ sum $ map totalGols ps) / (fromIntegral (length ps))
        where totalGols p = gols_mandante p + gols_visitante p