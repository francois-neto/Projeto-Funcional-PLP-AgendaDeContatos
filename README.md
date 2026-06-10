# Agenda de Contatos em Haskell

## Parte da Pessoa 5 - Davi

Minha responsabilidade no projeto e a camada de menu, integracao e documentacao.

Arquivos principais:

- `src/Main.hs`
- `src/UI/Terminal.hs`
- `README.md`
- `test/IntegrationTest.md`

## O que precisa estar implementado para minha parte funcionar

Para `Main.hs` e `Terminal.hs` compilarem, os outros modulos da equipe precisam fornecer estes contratos.

### Pessoa 1 - Modelos e persistencia

No modulo `Models.Contact`:

```haskell
data Contato = Contato
  { contatoId :: Int
  , nome      :: String
  , telefone  :: String
  , email     :: String
  , grupos    :: [String]
  } deriving (Show, Eq)
```

No modulo de repositorio:

```haskell
carregarContatos :: FilePath -> IO (Either String [Contato])
salvarContatos :: FilePath -> [Contato] -> IO (Either String ())
```

### Pessoa 2 - Servicos de contato

```haskell
adicionarContato :: String -> String -> String -> [String] -> [Contato] -> Either String [Contato]
buscarPorId :: Int -> [Contato] -> Maybe Contato
buscarPorNome :: String -> [Contato] -> [Contato]
buscarPorTelefone :: String -> [Contato] -> [Contato]
editarContato :: Int -> String -> String -> String -> [Contato] -> Either String [Contato]
removerContato :: Int -> [Contato] -> Either String [Contato]
ordenarPorNome :: [Contato] -> [Contato]
```

### Pessoa 3 - Servicos de grupo

```haskell
listarGrupos :: [Contato] -> [String]
buscarPorGrupo :: String -> [Contato] -> [Contato]
adicionarGrupo :: Int -> String -> [Contato] -> Either String [Contato]
removerGrupo :: Int -> String -> [Contato] -> Either String [Contato]
```

### Pessoa 4 - Entrada e exibicao

```haskell
lerInteiro :: String -> IO Int
lerTextoNaoVazio :: String -> IO String
lerTextoOpcional :: String -> IO String
confirmar :: String -> IO Bool
exibirContato :: Contato -> IO ()
exibirContatos :: [Contato] -> IO ()
exibirGrupos :: [String] -> IO ()
```

## O que minha parte faz

- Exibe o menu principal.
- Exibe o menu de pesquisa.
- Exibe o menu de grupos.
- Chama os servicos corretos conforme a opcao escolhida.
- Mantem a lista de contatos atualizada em memoria.
- Chama o carregamento no inicio.
- Chama o salvamento ao sair.
- Documenta o roteiro de teste integrado.

## Como rodar um projeto Haskell

### 1. Verificar se o GHC esta instalado

```powershell
ghc --version
```

Se o comando nao funcionar, use o caminho completo instalado pelo GHCup:

```powershell
& "C:\ghcup\ghc\9.6.7\bin\ghc.exe" --version
```

### 2. Compilar o projeto

Com `ghc` no PATH:

```powershell
ghc -isrc -outputdir build -odir build -hidir build -o agenda.exe src/Main.hs
```

Com caminho completo:

```powershell
& "C:\ghcup\ghc\9.6.7\bin\ghc.exe" -isrc -outputdir build -odir build -hidir build -o agenda.exe src/Main.hs
```

### 3. Executar

```powershell
.\agenda.exe
```

## Observacao

Enquanto os contratos dos outros integrantes nao estiverem implementados, o projeto completo pode nao compilar. Isso e esperado, porque `Main.hs` e `Terminal.hs` dependem dos modulos de modelo, persistencia, servicos e entrada.

## Parte da Pessoa 2 - Servicos de contato

Minha responsabilidade nesta etapa foi implementar as operacoes principais de contato no modulo `src/services/ContactService.hs`.

Arquivos principais:

- `src/services/ContactService.hs`
- `test/ContactServiceTest.hs`

### O que foi desenvolvido

- `proximoId`: calcula automaticamente o proximo ID disponivel.
- `adicionarContato`: valida nome e telefone antes de inserir o contato.
- `buscarPorId`: localiza um contato pelo ID.
- `buscarPorNome`: realiza busca parcial por nome ignorando maiusculas e minusculas.
- `buscarPorTelefone`: realiza busca parcial por telefone.
- `editarContato`: atualiza nome, telefone e email de um contato existente.
- `removerContato`: remove um contato apos localizar o ID.
- `ordenarPorNome`: ordena a lista para exibicao.
