module Main where
    import Tipos
    import Classificacao
    import Leitura
    import Dados
    import Data.Either (isRight)

    testar :: (Eq a, Show a) => String -> a -> a -> IO ()
    testar nome obtido esperado
        | obtido == esperado = putStrLn ("OK " ++ nome)
        | otherwise = putStrLn ("FALHOU " ++ nome ++ ": " ++ show obtido)

    main :: IO ()
    main = do
        let partidaExemplo = Partida 1 "Coritiba" 2 1 "Athletico"
        let partidaEmpate = Partida 1 "Parana" 0 0 "Operario"
        testar "Camada 1 - participou mandante" (participou "Coritiba" partidaExemplo) True
        testar "Camada 1 - participou nao jogou" (participou "Parana" partidaExemplo) False
        testar "Camada 1 - resultadoPara mandante" (resultadoPara "Coritiba" partidaExemplo) (Just Vitoria)
        testar "Camada 1 - resultadoPara visitante" (resultadoPara "Athletico" partidaExemplo) (Just Derrota)
        testar "Camada 1 - resultadoPara empate" (resultadoPara "Parana" partidaEmpate) (Just Empate)
        testar "Camada 1 - resultadoPara nao jogou" (resultadoPara "Parana" partidaExemplo) Nothing

        case lerCampeonato dadosCampeonato of
            Left erro -> putStrLn ("FALHOU ao ler dadosCampeonato: " ++ show erro)
            Right partidas -> do
                let timesEsperados = ["Athletico", "Coritiba", "Londrina", "Maringa", "Operario", "Parana"]
                testar "Camada 1 - times sem repeticao" (times partidas) timesEsperados

                let classificacaoFinalEsperada =
                        [ Linha "Coritiba" 5 4 0 1 8 5
                        , Linha "Athletico" 5 3 1 1 9 3
                        , Linha "Maringa" 5 3 1 1 7 6
                        , Linha "Londrina" 5 2 1 2 7 6
                        , Linha "Operario" 5 0 2 3 3 6
                        , Linha "Parana" 5 0 1 4 1 9
                        ]
                let tabelaFinal = classificacao partidas
                testar "Camada 2 - classificacao completa" tabelaFinal classificacaoFinalEsperada

                let ordemDesempate = map time (take 2 (drop 1 tabelaFinal))
                testar "Camada 2 - desempate por saldo de gols (Athletico 6 vs Maringa 1)" ordemDesempate ["Athletico", "Maringa"]

                let classificacaoRodada3Esperada =
                        [ Linha "Coritiba" 3 3 0 0 5 1
                        , Linha "Athletico" 3 2 0 1 7 2
                        , Linha "Maringa" 3 2 0 1 4 4
                        , Linha "Operario" 3 0 2 1 2 3
                        , Linha "Londrina" 3 0 1 2 2 5
                        , Linha "Parana" 3 0 1 2 0 5
                        ]
                let tabelaRodada3 = classificacao (ateRodada 3 partidas)
                testar "Camada 2 - classificacao ateRodada 3" tabelaRodada3 classificacaoRodada3Esperada
                testar "Camada 2 - ateRodada 3 diferente da final" (tabelaRodada3 /= tabelaFinal) True
                testar "Camada 2 - maiorGoleada campeonato" (maiorGoleada partidas) (Just (Partida 2 "Athletico" 4 0 "Parana"))
                testar "Camada 2 - mediaGols campeonato" (mediaGols partidas) (Just (35 / 15))

        testar "Camada 2 - aproveitamento sem jogos" (aproveitamento (Linha "Coritiba" 0 0 0 0 0 0)) 0.0
        testar "Camada 2 - classificacao lista vazia" (classificacao []) []
        testar "Camada 2 - maiorGoleada lista vazia" (maiorGoleada []) Nothing
        testar "Camada 2 - mediaGols lista vazia" (mediaGols []) Nothing

        testar "Camada 3 - lerCampeonato entrada valida" (isRight (lerCampeonato dadosCampeonato)) True
        testar "Camada 3 - lerCampeonato entrada vazia" (lerCampeonato "") (Right [])
        testar "Camada 3 - Erro CamposInvalidos" (lerPartida 1 "1;Coritiba;2;1") (Left (CamposInvalidos 1))
        testar "Camada 3 - Erro CamposInvalidos ponto e virgula no final" (lerPartida 1 "1;Coritiba;2;1;Athletico;") (Left (CamposInvalidos 1))
        testar "Camada 3 - Erro CamposInvalidos time vazio" (lerPartida 1 "1;;2;1;Athletico") (Left (CamposInvalidos 1))
        testar "Camada 3 - Erro CamposInvalidos time apenas espacos" (lerPartida 1 "1;Coritiba;2;1;   ") (Left (CamposInvalidos 1))
        testar "Camada 3 - Erro NumeroInvalido" (lerPartida 2 "1;Coritiba;dois;1;Athletico") (Left (NumeroInvalido 2))
        testar "Camada 3 - Erro NumeroInvalido rodada <= 0" (lerPartida 1 "0;Coritiba;1;0;Athletico") (Left (NumeroInvalido 1))
        testar "Camada 3 - Erro PlacarNegativo" (lerPartida 3 "1;Coritiba;-1;1;Athletico") (Left (PlacarNegativo 3))
        testar "Camada 3 - Erro MesmoTime" (lerPartida 4 "1;Coritiba;1;1;Coritiba") (Left (MesmoTime 4))
        testar "Camada 3 - Erro TimeRepetidoNaRodada"
            (lerCampeonato (unlines ["1;Coritiba;2;1;Athletico", "1;Coritiba;0;0;Parana"]))
            (Left (TimeRepetidoNaRodada 1))

        let errosEsperados =
                [ NumeroInvalido 3
                , PlacarNegativo 4
                , MesmoTime 5
                , CamposInvalidos 6
                , TimeRepetidoNaRodada 1
                ]
        testar "Camada 3 - todosOsErros" (todosOsErros dadosInvalidos) errosEsperados