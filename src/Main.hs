module Main where
    import Tipos
    import Classificacao
    import Leitura
    import Dados

    formatarPartida :: Partida -> String
    formatarPartida p =
        "Rodada " ++ show (rodada p) ++ ": "
        ++ mandante p ++ " " ++ show (gols_mandante p)
        ++ " x " ++ show (gols_visitante p) ++ " " ++ visitante p

    formatarDecimal :: Double -> String
    formatarDecimal x =
        let (inteiro, dec) = divMod (round (x * 100) :: Int) 100
            decStr = if dec < 10 then '0' : show dec else show dec
        in show inteiro ++ "." ++ decStr

    main :: IO ()
    main = do
        case lerCampeonato dadosCampeonato of
            Left erro -> putStrLn ("Erro ao ler campeonato: " ++ formatarErro erro)
            Right partidas -> do
                putStrLn "=== Classificacao Final ==="
                putStr (tabelaFormatada (classificacao partidas))
                putStrLn "=== Classificacao apos a Rodada 3 ==="
                putStr (tabelaFormatada (classificacao (ateRodada 3 partidas)))
                putStrLn "=== Estatisticas ==="
                putStrLn ("Maior goleada: " ++ maybe "Nenhuma partida" formatarPartida (maiorGoleada partidas))
                putStrLn ("Media de gols: " ++ maybe "Nenhuma partida" formatarDecimal (mediaGols partidas))
        putStrLn ""
        putStrLn "=== Teste com Entrada Invalida ==="
        case lerCampeonato dadosInvalidos of
            Left erro -> putStrLn ("Primeiro erro encontrado: " ++ formatarErro erro)
            Right _ -> putStrLn "Nenhum erro encontrado"
        putStrLn "Todos os erros encontrados:"
        putStr (unlines (map formatarErro (todosOsErros dadosInvalidos)))