module Dados where
    dadosCampeonato :: String
    dadosCampeonato = unlines
        [ "# rodada;mandante;gols_mandante;gols_visitante;visitante"
        , ""
        , "1;Coritiba;2;1;Athletico"
        , "1;Parana;0;0;Operario"
        , "1;Londrina;1;2;Maringa"
        , "2;Athletico;4;0;Parana"
        , "2;Operario;1;1;Londrina"
        , "2;Maringa;0;2;Coritiba"
        , "3;Coritiba;1;0;Parana"
        , "3;Athletico;2;0;Londrina"
        , "3;Maringa;2;1;Operario"
        , "4;Londrina;3;1;Coritiba"
        , "4;Operario;0;1;Athletico"
        , "4;Parana;1;2;Maringa"
        , "5;Athletico;1;1;Maringa"
        , "5;Coritiba;2;1;Operario"
        , "5;Londrina;2;0;Parana"
        ]

    dadosInvalidos :: String
    dadosInvalidos = unlines
        [ "# arquivo com erros"
        , "1;Coritiba;2;1;Athletico"
        , "1;Parana;dois;0;Operario"
        , "1;Londrina;-1;2;Maringa"
        , "2;Coritiba;1;1;Coritiba"
        , "2;Operario;1;0"
        , "1;Coritiba;3;0;Maringa"
        ]