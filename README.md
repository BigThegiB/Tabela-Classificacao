## Grupo

**- Bruno Rogério Coutinho Moretoni**

**- Eduardo Henrique Chechin Teixeira**

**- Lunna Damo Perera**

**- Samuel Santos Bicudo de Oliveira**

## Como Compilar e Executar

**Ambiente utilizado:** GHC local (via GHCup)

Na pasta raiz do projeto, crie primeiro a pasta `build` para manter os arquivos temporários (`.o` e `.hi`) e os executáveis separados da raiz:

```bash
mkdir build
```

### Programa principal (`Main.hs`)

(obs: Caso a pasta build não esteja presente, deve ser criada com `mkdir build`)

```bash
ghc -Wall -isrc -outputdir build src/Main.hs -o build/campeonato
```

Para executar:

- **Windows (PowerShell/CMD):** `.\build\campeonato.exe`
- **Git Bash / Linux / macOS:** `./build/campeonato`

### Bateria de testes (`Testes.hs`)

```bash
ghc -Wall -isrc -outputdir build tests/Testes.hs -o build/testes
```

Para executar:

- **Windows (PowerShell/CMD):** `.\build\testes.exe`
- **Git Bash / Linux / macOS:** `./build/testes`

### Execução rápida sem gerar executáveis (`runghc`)

```bash
runghc -isrc src/Main.hs
runghc -isrc tests/Testes.hs
```

## Camada 1: Tipos e Consultas (`src/Tipos.hs`)

```haskell
type Time = String
data Resultado = Vitoria | Empate | Derrota deriving (Show, Eq)
```

Define o sinônimo de tipo para o nome dos times e o tipo soma `Resultado`, garantindo que apenas os três resultados possíveis possam ser representados.

```haskell
resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p
    | not (participou t p) = Nothing
    | Just t == vencedor p = Just Vitoria
    | gols_mandante p == gols_visitante p = Just Empate
    | otherwise = Just Derrota
```

Retorna o resultado da partida do ponto de vista de um time específico, devolvendo `Nothing` caso o time não tenha participado da partida.

```haskell
times :: [Partida] -> [Time]
times ts = sort $ nub $ foldr etapa [] ts
    where etapa h t = mandante h : visitante h : t
```

Extrai todos os times presentes na lista de partidas, removendo repetições com `nub` e ordenando alfabeticamente com `sort`.

## Camada 2: Classificação e Estatísticas (`src/Classificacao.hs`)

```haskell
linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime ps t = foldr etapa linha ps
```

Percorre a lista de partidas com `foldr` acumulando jogos, vitórias, empates, derrotas, gols pró e gols contra de um time em um único registro `Linha`.

```haskell
classificacao :: [Partida] -> [Linha]
classificacao = sortBy criterio . linhasCampeonato
    where
        criterio =
            comparing (Down . pontosLinha)
            <> comparing (Down . vitorias)
            <> comparing (Down . saldo)
            <> comparing (Down . gols_pro)
            <> comparing time
```

Gera a linha de cada time e ordena a tabela seguindo os critérios de desempate do Brasileirão: pontos, vitórias, saldo de gols, gols pró (todos em ordem decrescente com `Down`) e, por fim, ordem alfabética do nome do time.

```haskell
maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada [] = Nothing
maiorGoleada ps = Just $ maximumBy (comparing goleadas) ps
```

Calcula a partida com maior diferença de gols sem risco de erro em lista vazia, retornando `Nothing` quando não há partidas. A função `mediaGols` segue a mesma ideia para a média de gols por partida.

## Camada 3: Leitura, Validação e Saída (`src/Leitura.hs`)

```haskell
lerPartida :: Int -> String -> Either Erro Partida
```

Quebra cada linha pelo separador `;`, converte os campos numéricos com `readMaybe` dentro de um bloco `do` na mônada `Either`, e valida placares negativos e times jogando contra si mesmos.

```haskell
lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato s =
    let linhas = filter (ignorarComentarios . snd) $ zip [1..] (lines s)
    in do
        partidas <- traverse (uncurry lerPartida) linhas
        verificaRepetidos partidas
```

Numera todas as linhas antes de filtrar comentários (`#`) e linhas vazias para preservar o número real da linha nos erros. Usa `traverse` para parar no primeiro erro de leitura e depois verifica times repetidos na mesma rodada.

```haskell
todosOsErros :: String -> [Erro]
todosOsErros s =
    let
        resultado = map (uncurry lerPartida) $ filter (ignorarComentarios . snd) $ zip [1..] (lines s)
    in lefts resultado ++ verificarTodosRepetidos (rights resultado)
```

Percorre todas as linhas sem interromper no primeiro erro, coletando os erros de parsing com `lefts` e somando com os erros de times repetidos encontrados nas partidas válidas (`rights`).

```haskell
tabelaFormatada :: [Linha] -> String
tabelaFormatada ls = unlines $ cabecalho : zipWith formatacao [1 :: Int ..] ls
```

Numera as posições da tabela com `zipWith` e junta os campos de cada linha com `intercalate " - "`, devolvendo a tabela pronta para impressão no `Main.hs`.
