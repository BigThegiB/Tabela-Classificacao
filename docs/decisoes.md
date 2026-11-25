## Decisões de Modelagem

### Camada 1 (`src/Tipos.hs`)

- **Modelagem de `Linha` com apenas contadores brutos:** `Linha` armazena somente `time`, `jogos`, `vitorias`, `empates`, `derrotas`, `gols_pro` e `gols_contra`, deixando `pontosLinha`, `saldo` e `aproveitamento` como funções derivadas na Camada 2. Isso evita dados redundantes no registro e elimina o risco de estados inconsistentes (por exemplo, um saldo ou total de pontos que não corresponda aos gols ou vitórias registrados).

- **Função auxiliar `vencedor`:** a verificação de quem venceu uma partida foi isolada em `vencedor :: Partida -> Maybe Time`, evitando repetir comparações de placar dentro de `resultadoPara`.

- **Extração de times com `foldr`, `nub` e `sort`:** em `times`, optou-se por coletar mandantes e visitantes em uma única passagem com `foldr` antes de remover duplicatas (`nub`) e ordenar (`sort`).

### Camada 2 (`src/Classificacao.hs`)

- **Escolha de `foldr` em `linhaDoTime`:** entre `foldl` e `foldr`, optou-se por `foldr` partindo de uma `Linha` zerada. Como a soma de jogos, resultados e gols é associativa e comutativa, a ordem da dobra não altera o resultado final.

- **Funções auxiliares `encontraGolPro` e `encontraGolContra` no escopo local:** a identificação de quais gols pertencem ao time analisado (mandante ou visitante) foi encapsulada no `where` de `linhaDoTime`, mantendo o `case` legível sem expor funções auxiliares que dependem de o time ter participado da partida.

- **`pontosLinha` delegando para `pontos`:** em vez de fixar `3 * vitorias + empates`, o cálculo multiplica todos os contadores (inclusive `derrotas`) pelo retorno de `pontos`, centralizando a regra de pontuação caso os pesos mudem no futuro.

- **Critérios de desempate adotados:** foi escolhida a ordem do Campeonato Brasileiro — pontos, número de vitórias, saldo de gols, gols pró (todos decrescentes) e ordem alfabética do nome do time como último critério.

### Camada 3 (`src/Leitura.hs`)

- **Numeração antes da filtragem:** em `lerCampeonato` e `todosOsErros`, o `zip [1..] (lines s)` é aplicado antes de descartar comentários (`#`) e linhas em branco, garantindo que os erros apontem para o número real da linha no texto original.

- **Normalização com `trim` e rejeição de campos vazios em `lerPartida`:** os campos extraídos por `separar` passam por `trim` (usando `isSpace`) para remover espaços extras e eventuais `\r` de arquivos Windows, e nomes de times vazios ou apenas com espaços são rejeitados com `CamposInvalidos`.

- **Detecção de times repetidos com `concatMap`, `sort` e `group`:** `verificarTodosRepetidos` gera pares `(rodada, time)` para mandante e visitante, ordena para deixar pares idênticos adjacentes e filtra grupos com dois ou mais elementos. A função `verificaRepetidos` reutiliza essa mesma lógica no fluxo de curto-circuito do `lerCampeonato`, evitando duplicação de código.

- **Separação de erros em `todosOsErros` com `lefts` e `rights`:** após aplicar `lerPartida` em todas as linhas válidas, `lefts` coleta os erros de linha e `rights` passa apenas as partidas válidas para `verificarTodosRepetidos`.

- **Colunas extras e formatação com `intercalate` na `tabelaFormatada`:** além das colunas mínimas exigidas, foram incluídos `Gols Pro`, `Gols Contra` e `Aproveitamento`. Os campos numéricos do mesmo tipo são convertidos em lote com `map` e unidos com `intercalate " - "`, usando `zipWith` sobre `[1 :: Int ..]` para gerar a posição sem aviso de tipo no `-Wall`.

- **Textos de saída sem acentuação:** o cabeçalho da tabela e as mensagens do `Main.hs` foram mantidos sem acentos para evitar falhas de codificação (`commitBuffer: invalid argument`) em terminais Windows que não estejam configurados em UTF-8.

## Limitações Conhecidas

- **Largura das colunas sem alinhamento fixo:** `tabelaFormatada` usa `" - "` para separar as colunas em vez de preenchimento por largura fixa, pois módulos de formatação como `Text.Printf` não fazem parte da lista de bibliotecas permitidas pelo enunciado.

- **Dados embutidos no código:** os jogos de teste ficam definidos como `String` em `src/Dados.hs` em vez de serem lidos de um arquivo externo em tempo de execução, mantendo a execução autocontida e compatível com o playground.

- **Saída sem acentuação:** cabeçalhos, mensagens e nomes de times nos dados de exemplo foram mantidos sem acentos para garantir compatibilidade com terminais Windows que não utilizam UTF-8 por padrão.
