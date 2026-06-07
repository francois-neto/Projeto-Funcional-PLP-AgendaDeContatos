# Plano de Implementação do Projeto
## Agenda de Contatos em Haskell

**Disciplina:** Paradigmas de Linguagens de Programação  
**Tipo de aplicação:** CLI — aplicação executada no terminal  
**Equipe:** 5 integrantes  
**Linguagem:** Haskell  
**Persistência:** arquivo CSV local  
**Versão planejada:** MVP acadêmico funcional  

---

# 1. Finalidade deste documento

Este documento descreve como a equipe deve implementar, integrar, testar e entregar a aplicação **Agenda de Contatos em Haskell**.

O objetivo não é apenas listar funcionalidades. O documento define:

- o escopo obrigatório;
- as decisões técnicas;
- a arquitetura do projeto;
- a estrutura de pastas;
- os contratos entre módulos;
- a ordem correta de implementação;
- a divisão de responsabilidades;
- o fluxo de trabalho com Git;
- os critérios de aceite;
- os testes mínimos;
- os riscos e medidas de mitigação;
- o roteiro de apresentação final.

A aplicação deve permanecer pequena e compreensível. O foco é demonstrar fundamentos de programação funcional: tipos, funções puras, imutabilidade, modularização e separação entre regras de negócio e operações de entrada e saída.

---

# 2. Visão geral do sistema

A aplicação será uma agenda de contatos utilizada pelo terminal.

Ao iniciar, o programa deverá:

1. localizar o arquivo `data/contatos.csv`;
2. validar o cabeçalho do arquivo;
3. carregar os contatos para a memória;
4. apresentar o menu principal;
5. permitir consultas e alterações;
6. manter as alterações em memória durante a execução;
7. salvar o CSV atualizado quando o usuário escolher sair;
8. encerrar somente após a confirmação de que o arquivo foi salvo corretamente.

A aplicação não deverá utilizar banco de dados, interface gráfica, autenticação, API externa ou conexão com a internet.

---

# 3. Objetivos do projeto

## 3.1 Objetivo geral

Implementar uma agenda de contatos em Haskell com persistência em CSV, organização modular e interface de terminal.

## 3.2 Objetivos específicos

A aplicação deverá permitir:

- cadastrar contatos;
- listar contatos;
- editar contatos;
- remover contatos;
- buscar contatos por ID;
- buscar contatos por nome;
- buscar contatos por telefone;
- associar contatos a grupos;
- remover contatos de grupos;
- listar grupos existentes;
- buscar contatos por grupo;
- salvar os dados em CSV;
- recarregar os dados preservados após reiniciar o programa.

---

# 4. Escopo do MVP

## 4.1 Funcionalidades obrigatórias

| Código | Funcionalidade | Descrição |
|---|---|---|
| F01 | Carregar CSV | Ler os contatos ao iniciar o sistema. |
| F02 | Validar CSV | Verificar se o cabeçalho está correto antes de processar os registros. |
| F03 | Listar contatos | Exibir os contatos cadastrados de forma legível. |
| F04 | Cadastrar contato | Criar contato com ID automático. |
| F05 | Editar contato | Alterar os campos de um contato localizado por ID. |
| F06 | Remover contato | Excluir contato somente após confirmação. |
| F07 | Buscar por ID | Localizar exatamente um contato. |
| F08 | Buscar por nome | Retornar correspondências parciais ignorando maiúsculas e minúsculas. |
| F09 | Buscar por telefone | Retornar correspondências parciais usando comparação textual. |
| F10 | Listar grupos | Exibir grupos existentes sem duplicação. |
| F11 | Adicionar grupo | Associar um contato existente a um grupo. |
| F12 | Remover grupo | Remover somente a associação entre contato e grupo. |
| F13 | Buscar por grupo | Listar contatos associados a um grupo. |
| F14 | Salvar CSV | Gravar os dados ao encerrar. |
| F15 | Tratar entradas inválidas | Impedir que erros simples encerrem inesperadamente o programa. |

## 4.2 Itens fora do escopo

Não fazem parte da primeira versão:

- autenticação;
- múltiplos usuários;
- banco de dados;
- interface gráfica;
- API web;
- histórico de alterações;
- sincronização em rede;
- importação de outros formatos;
- exportação para outros formatos;
- criptografia;
- grupos com atributos próprios;
- edição concorrente;
- armazenamento em nuvem.

Esses itens podem ser registrados como melhorias futuras, mas não devem ser implementados antes da conclusão integral do MVP.

---

# 5. Regras de negócio

## 5.1 Contatos

| Código | Regra |
|---|---|
| RN01 | Cada contato possui um ID inteiro único. |
| RN02 | O ID é gerado automaticamente. |
| RN03 | O próximo ID é o maior ID existente somado a 1. |
| RN04 | IDs removidos não são reutilizados automaticamente. |
| RN05 | Nome não pode ser vazio. |
| RN06 | Telefone não pode ser vazio. |
| RN07 | Telefone deve ser armazenado como texto. |
| RN08 | E-mail será armazenado como texto. A equipe deve decidir se ele será obrigatório ou opcional e registrar essa decisão no README. |
| RN09 | Edição e remoção devem localizar contatos pelo ID. |
| RN10 | Remoção exige confirmação explícita. |
| RN11 | A busca por nome deve aceitar correspondência parcial. |
| RN12 | A busca por telefone deve aceitar correspondência parcial. |

## 5.2 Grupos

| Código | Regra |
|---|---|
| RN13 | Um contato pode pertencer a zero, um ou vários grupos. |
| RN14 | Grupo é representado apenas pelo nome. |
| RN15 | Não existirá arquivo separado para grupos. |
| RN16 | Um grupo surge implicitamente quando é associado ao primeiro contato. |
| RN17 | Um grupo deixa de aparecer quando nenhum contato permanece associado a ele. |
| RN18 | Um contato não pode possuir o mesmo grupo duplicado. |
| RN19 | A verificação de duplicidade ignora diferenças entre maiúsculas e minúsculas. |
| RN20 | A remoção de um grupo não remove o contato. Remove apenas a associação. |

## 5.3 Persistência

| Código | Regra |
|---|---|
| RN21 | O CSV deve ser carregado no início do programa. |
| RN22 | Os dados devem ser mantidos em memória durante a execução. |
| RN23 | O CSV deve ser salvo quando o usuário escolher sair. |
| RN24 | O cabeçalho deve ser validado antes da leitura dos registros. |
| RN25 | O sistema não deve sobrescrever automaticamente um CSV inválido. |
| RN26 | O salvamento deve preferencialmente utilizar arquivo temporário antes da substituição do arquivo principal. |
| RN27 | Vírgulas não serão aceitas dentro dos campos na primeira versão. |
| RN28 | A barra vertical `|` não será aceita dentro dos nomes de grupos. |

---

# 6. Modelo de dados

## 6.1 Estrutura do contato

O tipo principal do sistema será `Contato`.

```haskell
data Contato = Contato
  { contatoId :: Int
  , nome      :: String
  , telefone  :: String
  , email     :: String
  , grupos    :: [String]
  } deriving (Show, Eq)
```

## 6.2 Justificativa

A estrutura usa:

- `Int` para o ID porque ele representa um identificador numérico interno;
- `String` para telefone porque zeros à esquerda e símbolos não devem ser perdidos;
- `[String]` para grupos porque um contato pode pertencer a múltiplos grupos.

## 6.3 CSV esperado

Arquivo:

```text
data/contatos.csv
```

Cabeçalho:

```csv
id,nome,telefone,email,grupos
```

Exemplo:

```csv
id,nome,telefone,email,grupos
1,Ana Silva,83999999999,ana@email.com,Familia|Favoritos
2,Carlos Souza,83988888888,carlos@email.com,Trabalho
3,Joao Lima,83977777777,joao@email.com,Familia|Trabalho
4,Marina Costa,83966666666,marina@email.com,
5,Beatriz Alves,83955555555,beatriz@email.com,Faculdade|Favoritos
```

---

# 7. Arquitetura

## 7.1 Princípio central

A aplicação deve separar:

- **dados**;
- **regras de negócio**;
- **persistência**;
- **entrada e saída**;
- **orquestração dos menus**;
- **inicialização**.

A arquitetura evita que todo o programa seja escrito em `Main.hs`.

## 7.2 Fluxo geral

```text
Usuário
  ↓
Menu.hs
  ↓
ContactService.hs / GroupService.hs
  ↓
Lista de contatos em memória
  ↓
CSVRepository.hs
  ↓
data/contatos.csv
```

## 7.3 Funções puras e funções com IO

As funções de serviço devem ser puras sempre que possível.

Exemplo de função pura:

```haskell
buscarPorNome :: String -> [Contato] -> [Contato]
```

Ela recebe dados e devolve dados. Não lê arquivo, não pede entrada do teclado e não imprime mensagens.

Exemplo de função com IO:

```haskell
carregarContatos :: FilePath -> IO (Either String [Contato])
```

Ela acessa o sistema de arquivos, portanto utiliza `IO`.

---

# 8. Estrutura de pastas

```text
agenda-contatos/
├── app/
│   └── Main.hs
│
├── src/
│   ├── Models.hs
│   ├── CSVRepository.hs
│   ├── ContactService.hs
│   ├── GroupService.hs
│   ├── InputUtils.hs
│   └── Menu.hs
│
├── data/
│   ├── contatos.csv
│   └── contatos.backup.csv
│
├── test/
│   ├── ContactServiceTest.hs
│   ├── GroupServiceTest.hs
│   ├── CSVRepositoryTest.hs
│   └── IntegrationTest.md
│
├── README.md
├── ESTRUTURA_DO_PROJETO.md
├── PLANO_DE_IMPLEMENTACAO.md
└── agenda-contatos.cabal
```

---

# 9. Responsabilidade de cada arquivo

## 9.1 `app/Main.hs`

### Responsabilidade

Inicializar e encerrar a aplicação.

### Deve conter

- caminho do CSV;
- chamada para carregar os contatos;
- tratamento do erro inicial;
- chamada para o menu principal;
- chamada para salvar antes de encerrar.

### Não deve conter

- regras de cadastro;
- lógica de busca;
- parser CSV completo;
- submenus extensos;
- validações repetidas.

### Assinatura conceitual

```haskell
main :: IO ()
```

---

## 9.2 `src/Models.hs`

### Responsabilidade

Definir os tipos centrais.

### Deve conter

```haskell
data Contato = Contato
  { contatoId :: Int
  , nome      :: String
  , telefone  :: String
  , email     :: String
  , grupos    :: [String]
  } deriving (Show, Eq)
```

Também pode conter funções diretamente associadas à estrutura, como formatadores básicos, desde que não envolvam entrada, saída ou regras extensas.

### Não deve conter

- leitura de CSV;
- escrita de CSV;
- menus;
- cadastro;
- remoção;
- busca.

---

## 9.3 `src/CSVRepository.hs`

### Responsabilidade

Converter arquivo CSV em lista de contatos e lista de contatos em arquivo CSV.

### Funções esperadas

```haskell
cabecalhoEsperado :: String

carregarContatos :: FilePath -> IO (Either String [Contato])

salvarContatos :: FilePath -> [Contato] -> IO (Either String ())

linhaParaContato :: String -> Either String Contato

contatoParaLinha :: Contato -> String
```

### Deve conter

- validação do cabeçalho;
- leitura de linhas;
- conversão textual;
- serialização de grupos com `|`;
- gravação segura;
- erro claro quando o CSV estiver inválido.

### Não deve conter

- cadastro;
- remoção;
- busca;
- menus.

---

## 9.4 `src/ContactService.hs`

### Responsabilidade

Executar as operações relacionadas aos contatos.

### Funções esperadas

```haskell
proximoId :: [Contato] -> Int

adicionarContato
  :: String
  -> String
  -> String
  -> [String]
  -> [Contato]
  -> Either String [Contato]

buscarPorId :: Int -> [Contato] -> Maybe Contato

buscarPorNome :: String -> [Contato] -> [Contato]

buscarPorTelefone :: String -> [Contato] -> [Contato]

editarContato
  :: Int
  -> String
  -> String
  -> String
  -> [Contato]
  -> Either String [Contato]

removerContato :: Int -> [Contato] -> Either String [Contato]

ordenarPorNome :: [Contato] -> [Contato]
```

### Deve conter

- validações de campos obrigatórios;
- geração automática do ID;
- transformações imutáveis sobre a lista;
- buscas;
- edição;
- remoção.

### Não deve conter

- `putStrLn`;
- `getLine`;
- leitura ou escrita do CSV.

---

## 9.5 `src/GroupService.hs`

### Responsabilidade

Executar regras relacionadas aos grupos.

### Funções esperadas

```haskell
normalizarTexto :: String -> String

listarGrupos :: [Contato] -> [String]

buscarPorGrupo :: String -> [Contato] -> [Contato]

adicionarGrupo
  :: Int
  -> String
  -> [Contato]
  -> Either String [Contato]

removerGrupo
  :: Int
  -> String
  -> [Contato]
  -> Either String [Contato]
```

### Deve conter

- normalização de nomes;
- busca por grupo;
- listagem sem duplicação;
- adição de associação;
- remoção de associação;
- prevenção de grupos repetidos.

### Não deve conter

- leitura de teclado;
- escrita em arquivo;
- menus.

---

## 9.6 `src/InputUtils.hs`

### Responsabilidade

Tornar a interação no terminal segura e padronizada.

### Funções esperadas

```haskell
lerInteiro :: String -> IO Int

lerTextoNaoVazio :: String -> IO String

lerTextoOpcional :: String -> IO String

confirmar :: String -> IO Bool

exibirContato :: Contato -> IO ()

exibirContatos :: [Contato] -> IO ()
```

### Deve conter

- uso de `readMaybe`;
- repetição da pergunta em entradas inválidas;
- mensagens consistentes;
- formatação legível dos contatos.

### Não deve conter

- regras de cadastro;
- regras de grupo;
- persistência.

---

## 9.7 `src/Menu.hs`

### Responsabilidade

Orquestrar o fluxo do terminal.

### Funções esperadas

```haskell
menuPrincipal :: [Contato] -> IO [Contato]

menuPesquisa :: [Contato] -> IO ()

menuGrupos :: [Contato] -> IO [Contato]

fluxoCadastrar :: [Contato] -> IO [Contato]

fluxoEditar :: [Contato] -> IO [Contato]

fluxoRemover :: [Contato] -> IO [Contato]
```

### Deve conter

- exibição dos menus;
- leitura de opções;
- chamadas aos serviços;
- mensagens de sucesso e erro;
- retorno ao menu;
- atualização da lista em memória.

### Não deve conter

- duplicação das regras implementadas nos serviços;
- parser CSV;
- manipulação direta do arquivo.

---

# 10. Contratos entre módulos

Antes de iniciar o desenvolvimento paralelo, a equipe deve aprovar as assinaturas públicas.

## 10.1 Contrato mínimo

```haskell
-- Models.hs
data Contato = Contato
  { contatoId :: Int
  , nome      :: String
  , telefone  :: String
  , email     :: String
  , grupos    :: [String]
  } deriving (Show, Eq)

-- CSVRepository.hs
carregarContatos :: FilePath -> IO (Either String [Contato])
salvarContatos   :: FilePath -> [Contato] -> IO (Either String ())

-- ContactService.hs
proximoId         :: [Contato] -> Int
buscarPorId       :: Int -> [Contato] -> Maybe Contato
buscarPorNome     :: String -> [Contato] -> [Contato]
buscarPorTelefone :: String -> [Contato] -> [Contato]
removerContato    :: Int -> [Contato] -> Either String [Contato]

-- GroupService.hs
listarGrupos   :: [Contato] -> [String]
buscarPorGrupo :: String -> [Contato] -> [Contato]
adicionarGrupo :: Int -> String -> [Contato] -> Either String [Contato]
removerGrupo   :: Int -> String -> [Contato] -> Either String [Contato]

-- InputUtils.hs
lerInteiro       :: String -> IO Int
lerTextoNaoVazio :: String -> IO String
confirmar        :: String -> IO Bool
exibirContato    :: Contato -> IO ()
exibirContatos   :: [Contato] -> IO ()

-- Menu.hs
menuPrincipal :: [Contato] -> IO [Contato]
```

## 10.2 Regra de alteração de contrato

Uma assinatura pública não deve ser modificada unilateralmente.

Qualquer alteração exige:

1. justificativa;
2. registro no grupo;
3. validação de impacto;
4. atualização dos módulos dependentes;
5. nova rodada de testes.

---

# 11. Fluxos funcionais detalhados

## 11.1 Inicialização

```text
Iniciar programa
   ↓
Verificar data/contatos.csv
   ↓
Ler arquivo
   ↓
Validar cabeçalho
   ↓
Converter linhas em [Contato]
   ↓
Exibir menu principal
```

### Critérios de aceite

- CSV válido carrega normalmente;
- CSV inválido gera mensagem clara;
- CSV inválido não é sobrescrito;
- falha de leitura não encerra com mensagem técnica incompreensível.

---

## 11.2 Cadastro

```text
Selecionar "Cadastrar contato"
   ↓
Solicitar nome
   ↓
Solicitar telefone
   ↓
Solicitar e-mail
   ↓
Solicitar grupos iniciais
   ↓
Validar campos
   ↓
Gerar próximo ID
   ↓
Criar novo Contato
   ↓
Retornar nova lista
```

### Critérios de aceite

- nome vazio não é aceito;
- telefone vazio não é aceito;
- novo ID é maior que todos os IDs existentes;
- lista antiga não é alterada diretamente;
- novo contato aparece na listagem.

---

## 11.3 Listagem

```text
Selecionar "Listar contatos"
   ↓
Ordenar apenas para exibição
   ↓
Exibir todos os campos
```

### Critérios de aceite

- ID aparece;
- nome aparece;
- telefone aparece;
- e-mail aparece;
- grupos aparecem;
- contato sem grupo é exibido corretamente.

---

## 11.4 Busca

### Busca por ID

- solicita um inteiro;
- utiliza `buscarPorId`;
- mostra exatamente um resultado ou mensagem de ausência.

### Busca por nome

- aceita trecho parcial;
- ignora maiúsculas e minúsculas;
- retorna todos os resultados compatíveis.

### Busca por telefone

- trata telefone como texto;
- aceita trecho parcial;
- pode normalizar apenas dígitos.

### Busca por grupo

- ignora maiúsculas, minúsculas e espaços periféricos;
- retorna todos os contatos associados.

---

## 11.5 Edição

```text
Selecionar "Editar contato"
   ↓
Solicitar ID
   ↓
Localizar contato
   ↓
Exibir dados atuais
   ↓
Solicitar novos valores
   ↓
Criar versão atualizada do contato
   ↓
Substituir contato na nova lista
```

### Decisão recomendada

Entrada vazia durante a edição deve preservar o valor anterior.

### Critérios de aceite

- ID inexistente não altera a lista;
- apenas o contato selecionado é alterado;
- o ID permanece o mesmo;
- grupos não são perdidos acidentalmente.

---

## 11.6 Remoção

```text
Selecionar "Remover contato"
   ↓
Solicitar ID
   ↓
Localizar contato
   ↓
Exibir contato
   ↓
Solicitar confirmação
   ↓
Remover somente se confirmado
```

### Critérios de aceite

- ID inexistente não altera a lista;
- resposta negativa preserva a lista;
- resposta inválida cancela por padrão;
- resposta positiva remove somente o contato selecionado.

---

## 11.7 Grupos

### Listar grupos

A função deve reunir todos os grupos presentes nos contatos e remover duplicatas normalizadas.

### Adicionar contato a grupo

```text
Solicitar ID
   ↓
Solicitar nome do grupo
   ↓
Validar contato
   ↓
Verificar duplicidade
   ↓
Adicionar grupo
```

### Remover contato de grupo

```text
Solicitar ID
   ↓
Solicitar nome do grupo
   ↓
Validar contato
   ↓
Validar associação
   ↓
Remover somente associação
```

### Critérios de aceite

- contato pode ter vários grupos;
- grupo repetido não é adicionado;
- `Familia` e `familia` são considerados equivalentes;
- remover grupo não remove contato;
- remover a última associação faz o grupo desaparecer da listagem geral.

---

## 11.8 Encerramento

```text
Selecionar "Salvar e sair"
   ↓
Serializar lista atual
   ↓
Escrever arquivo temporário
   ↓
Confirmar gravação
   ↓
Substituir arquivo principal
   ↓
Encerrar
```

### Critérios de aceite

- o cabeçalho é preservado;
- alterações sobrevivem à reinicialização;
- falha de salvamento não destrói o arquivo anterior;
- mensagem de sucesso é exibida.

---

# 12. Menu esperado

## 12.1 Menu principal

```text
----------------------------------------
AGENDA DE CONTATOS
----------------------------------------
1. Listar contatos
2. Cadastrar contato
3. Editar contato
4. Remover contato
5. Pesquisar contato
6. Gerenciar grupos
0. Salvar e sair
----------------------------------------
Escolha uma opção:
```

## 12.2 Menu de pesquisa

```text
PESQUISAR CONTATO
1. Buscar por nome
2. Buscar por telefone
3. Buscar por ID
4. Buscar por grupo
0. Voltar
```

## 12.3 Menu de grupos

```text
GERENCIAR GRUPOS
1. Listar grupos
2. Adicionar contato a um grupo
3. Remover contato de um grupo
0. Voltar
```

---

# 13. Divisão da equipe

## 13.1 Pessoa 1 — Modelagem e persistência

### Arquivos principais

- `src/Models.hs`
- `src/CSVRepository.hs`
- `data/contatos.csv`
- `test/CSVRepositoryTest.hs`

### Entregas

- tipo `Contato`;
- cabeçalho oficial;
- parser das linhas;
- serialização;
- carregamento;
- salvamento;
- gravação segura;
- CSV inicial;
- testes de recarga.

### Critério de conclusão

Executar:

```text
CSV inicial → carregar → salvar cópia → recarregar → comparar
```

O conteúdo recarregado deve representar os mesmos contatos.

---

## 13.2 Pessoa 2 — Operações de contatos

### Arquivos principais

- `src/ContactService.hs`
- `test/ContactServiceTest.hs`

### Entregas

- `proximoId`;
- cadastro;
- busca por ID;
- busca por nome;
- busca por telefone;
- edição;
- remoção;
- ordenação para exibição.

### Critério de conclusão

Todas as funções devem ser testadas com listas criadas diretamente no código, sem depender do CSV ou do terminal.

---

## 13.3 Pessoa 3 — Operações de grupos

### Arquivos principais

- `src/GroupService.hs`
- `test/GroupServiceTest.hs`

### Entregas

- normalização;
- listagem de grupos;
- busca por grupo;
- adição de grupo;
- remoção de grupo;
- prevenção de duplicatas.

### Critério de conclusão

Testar:

- contato sem grupo;
- contato com um grupo;
- contato com vários grupos;
- grupo duplicado com grafias diferentes;
- remoção da última associação.

---

## 13.4 Pessoa 4 — Entrada, validação e exibição

### Arquivos principais

- `src/InputUtils.hs`

### Entregas

- leitura segura de inteiro;
- leitura de texto obrigatório;
- leitura de texto opcional;
- confirmação;
- exibição de contato;
- exibição de lista;
- mensagens padronizadas.

### Critério de conclusão

Entradas como `abc`, vazio e opções fora do menu não devem encerrar o programa.

---

## 13.5 Pessoa 5 — Menus, integração e documentação

### Arquivos principais

- `src/Menu.hs`
- `app/Main.hs`
- `README.md`
- `test/IntegrationTest.md`

### Entregas

- menu principal;
- menu de pesquisa;
- menu de grupos;
- integração incremental;
- salvamento no encerramento;
- README;
- roteiro de demonstração;
- coordenação dos testes integrados.

### Critério de conclusão

Executar o fluxo completo no terminal, salvar, reiniciar e confirmar persistência.

---

# 14. Estratégia de implementação

## 14.1 Ordem obrigatória

A equipe não deve começar pelos menus completos.

A ordem recomendada é:

| Etapa | Objetivo | Responsáveis | Resultado esperado |
|---|---|---|---|
| 1 | Aprovar modelo e contratos | Todos | Assinaturas comuns congeladas |
| 2 | Criar estrutura do repositório | Pessoa 5 | Pastas e arquivos iniciais |
| 3 | Implementar `Models.hs` | Pessoa 1 | Tipo `Contato` disponível |
| 4 | Implementar persistência | Pessoa 1 | CSV carrega e salva corretamente |
| 5 | Implementar contatos | Pessoa 2 | CRUD e buscas testados |
| 6 | Implementar grupos | Pessoa 3 | Associações testadas |
| 7 | Implementar utilitários | Pessoa 4 | Entradas inválidas tratadas |
| 8 | Integrar listagem | Pessoa 5 | Primeiro fluxo funcional |
| 9 | Integrar cadastro | Pessoa 5 | Alteração simples funcionando |
| 10 | Integrar buscas | Pessoa 5 | Consultas funcionando |
| 11 | Integrar edição e remoção | Pessoa 5 | CRUD completo |
| 12 | Integrar grupos | Pessoa 5 | Escopo completo |
| 13 | Integrar salvamento | Pessoas 1 e 5 | Persistência completa |
| 14 | Executar testes finais | Todos | Versão pronta para entrega |

## 14.2 Motivo dessa ordem

A dependência principal é o tipo `Contato`.

Sem ele, os demais módulos não possuem um contrato comum.

Os serviços devem ser testados antes dos menus porque funções puras são mais fáceis de verificar. Quando um erro surgir no terminal, a equipe saberá se o problema está na orquestração e não na regra de negócio.

---

# 15. Plano de trabalho sugerido

## 15.1 Sprint 0 — Preparação

### Objetivo

Eliminar ambiguidades antes da implementação.

### Tarefas

- aprovar campos do contato;
- decidir se e-mail será obrigatório;
- aprovar cabeçalho CSV;
- aprovar separadores;
- aprovar assinaturas públicas;
- criar repositório;
- criar branches;
- incluir CSV inicial;
- registrar regras no README.

### Saída

Documento de contratos aprovado pela equipe.

---

## 15.2 Sprint 1 — Núcleo funcional

### Objetivo

Implementar os módulos independentes.

### Paralelização

- Pessoa 1: modelos e persistência;
- Pessoa 2: contatos;
- Pessoa 3: grupos;
- Pessoa 4: entrada e exibição;
- Pessoa 5: estrutura do menu e documentação.

### Saída

Módulos isolados funcionando.

---

## 15.3 Sprint 2 — Integração

### Objetivo

Conectar gradualmente os módulos.

### Ordem

1. carregar CSV;
2. listar contatos;
3. cadastrar;
4. buscar;
5. editar;
6. remover;
7. gerenciar grupos;
8. salvar;
9. reiniciar;
10. comparar CSV.

### Saída

Aplicação funcional no terminal.

---

## 15.4 Sprint 3 — Estabilização

### Objetivo

Eliminar regressões e preparar entrega.

### Tarefas

- executar roteiro completo;
- restaurar base inicial;
- testar entradas inválidas;
- revisar mensagens;
- verificar CSV final;
- testar em outra máquina;
- revisar README;
- ensaiar apresentação.

### Saída

Versão reproduzível.

---

# 16. Fluxo de Git

## 16.1 Branches

Utilizar:

```text
main
develop
feature/models-csv
feature/contact-service
feature/group-service
feature/input-utils
feature/menu-integration
```

## 16.2 Regras

- `main` contém somente versões estáveis;
- desenvolvimento ocorre em branches `feature/...`;
- integração intermediária ocorre em `develop`;
- ninguém envia diretamente para `main`;
- cada alteração relevante deve passar por revisão;
- antes de abrir merge, executar testes do módulo;
- conflitos devem ser resolvidos com atenção especial a `Models.hs`.

## 16.3 Commits

Utilizar mensagens objetivas:

```text
feat: adiciona tipo Contato
feat: implementa busca parcial por nome
feat: implementa associação de contatos a grupos
fix: impede duplicação de grupos normalizados
test: adiciona cenário de CSV com cabeçalho inválido
docs: atualiza instruções de execução
```

## 16.4 Pull requests

Cada pull request deve informar:

- objetivo;
- arquivos alterados;
- testes executados;
- possíveis impactos;
- pendências;
- prints ou exemplos de execução quando aplicável.

---

# 17. Estratégia de testes

## 17.1 Testes unitários

Devem testar funções puras isoladamente.

### Contatos

| Código | Cenário | Resultado esperado |
|---|---|---|
| T01 | `proximoId []` | `1` |
| T02 | IDs `[1, 4, 7]` | próximo ID `8` |
| T03 | busca por nome `"ana"` | encontra `"Ana Silva"` |
| T04 | busca por telefone `"9999"` | retorna contatos compatíveis |
| T05 | remoção de ID existente | lista sem o contato |
| T06 | remoção de ID inexistente | erro controlado |
| T07 | edição válida | somente um contato alterado |
| T08 | cadastro com nome vazio | erro controlado |

### Grupos

| Código | Cenário | Resultado esperado |
|---|---|---|
| T09 | adicionar `"Familia"` | associação criada |
| T10 | adicionar `"familia"` após `"Familia"` | não duplicar |
| T11 | remover grupo existente | associação removida |
| T12 | remover grupo inexistente | erro controlado ou lista preservada |
| T13 | listar grupos | grupos únicos |
| T14 | buscar por grupo `"familia"` | contatos compatíveis |

---

## 17.2 Testes de persistência

| Código | Cenário | Resultado esperado |
|---|---|---|
| T15 | CSV com cabeçalho correto | carregar contatos |
| T16 | CSV com cabeçalho incorreto | retornar erro |
| T17 | linha inválida | retornar erro claro |
| T18 | salvar contatos | gerar CSV válido |
| T19 | salvar e recarregar | preservar dados |
| T20 | contato sem grupo | preservar última coluna vazia |

---

## 17.3 Testes de validação

| Código | Cenário | Resultado esperado |
|---|---|---|
| T21 | menu recebe `"abc"` | nova solicitação |
| T22 | menu recebe `"99"` | opção inválida e novo menu |
| T23 | ID recebe `"x"` | nova solicitação |
| T24 | nome obrigatório vazio | nova solicitação |
| T25 | confirmação recebe `"n"` | cancelar operação |
| T26 | confirmação recebe valor desconhecido | cancelar por padrão |

---

## 17.4 Testes integrados

| Código | Cenário | Resultado esperado |
|---|---|---|
| T27 | iniciar programa | carregar CSV e exibir menu |
| T28 | cadastrar e listar | contato aparece |
| T29 | editar e listar | dados atualizados aparecem |
| T30 | adicionar grupo e buscar | contato aparece na busca |
| T31 | remover grupo | associação desaparece |
| T32 | remover contato com confirmação negativa | contato permanece |
| T33 | remover contato com confirmação positiva | contato desaparece |
| T34 | salvar e reiniciar | alterações permanecem |
| T35 | CSV inválido | programa interrompe sem sobrescrever arquivo |

---

# 18. Definition of Done

Uma funcionalidade somente será considerada concluída quando:

- estiver implementada;
- respeitar os contratos definidos;
- não duplicar regras existentes;
- possuir pelo menos um teste válido;
- possuir teste de erro quando aplicável;
- estiver revisada por outro integrante;
- não quebrar os fluxos já integrados;
- estiver documentada quando alterar comportamento visível.

---

# 19. Checklist de aceite final

| Item | Critério | Situação |
|---|---|---|
| Inicialização | Programa inicia e carrega o CSV | ☐ |
| CSV | Cabeçalho é validado | ☐ |
| Listagem | Todos os campos aparecem corretamente | ☐ |
| Cadastro | Novo ID é gerado automaticamente | ☐ |
| Busca por ID | Contato correto é localizado | ☐ |
| Busca por nome | Pesquisa parcial funciona | ☐ |
| Busca por telefone | Pesquisa parcial funciona | ☐ |
| Edição | Apenas contato selecionado é alterado | ☐ |
| Remoção | Exclusão depende de confirmação | ☐ |
| Grupos | Associação múltipla funciona | ☐ |
| Duplicidade | Grupo equivalente não é duplicado | ☐ |
| Busca por grupo | Resultados são coerentes | ☐ |
| Persistência | Salvar e reiniciar preserva alterações | ☐ |
| Segurança CSV | CSV inválido não é sobrescrito | ☐ |
| Entradas inválidas | Programa não encerra inesperadamente | ☐ |
| README | Outra pessoa consegue executar o projeto | ☐ |
| Git | `main` contém versão estável | ☐ |
| Apresentação | Roteiro foi ensaiado | ☐ |

---

# 20. Riscos e mitigação

| Risco | Probabilidade | Impacto | Mitigação | Responsável |
|---|---|---|---|---|
| Alterar `Contato` tardiamente | Média | Alto | Congelar contrato na Sprint 0 | Pessoa 5 e equipe |
| Sobrescrever CSV incorretamente | Média | Alto | Backup e arquivo temporário | Pessoa 1 |
| Misturar IO e regras de negócio | Média | Médio | Revisar serviços puros | Pessoas 2 e 3 |
| Entrada inválida encerrar o sistema | Alta | Médio | Usar `readMaybe` | Pessoa 4 |
| Duplicar grupos | Média | Médio | Normalizar antes de comparar | Pessoa 3 |
| Criar menus antes dos serviços | Média | Médio | Respeitar ordem de integração | Pessoa 5 |
| Aumentar escopo | Média | Médio | Priorizar MVP | Equipe |
| Conflitos no Git | Média | Médio | Branches separadas e PRs pequenos | Equipe |
| Falta de conhecimento em Haskell | Alta | Médio | Implementar funções pequenas e revisar em pares | Equipe |
| Testar no CSV oficial | Média | Alto | Usar cópia de teste | Pessoa 1 |

---

# 21. README mínimo

O `README.md` deverá conter:

1. descrição do projeto;
2. funcionalidades;
3. estrutura de pastas;
4. pré-requisitos;
5. instruções para compilar;
6. instruções para executar;
7. instruções para testar;
8. formato do CSV;
9. limitações conhecidas;
10. exemplo de uso;
11. integrantes e responsabilidades.

---

# 22. Roteiro de demonstração

A apresentação deve utilizar uma cópia conhecida do CSV.

## 22.1 Preparação

- restaurar `data/contatos.csv`;
- abrir terminal;
- mostrar brevemente a estrutura de pastas;
- iniciar aplicação.

## 22.2 Demonstração funcional

Executar:

1. listar contatos;
2. buscar `"ana"` por nome;
3. buscar `"familia"` por grupo;
4. cadastrar novo contato;
5. listar contatos;
6. editar o novo contato;
7. adicionar o novo contato ao grupo `"Faculdade"`;
8. buscar por grupo;
9. tentar adicionar `"faculdade"` novamente;
10. mostrar que não houve duplicação;
11. remover uma associação de grupo;
12. tentar remover contato e cancelar;
13. remover contato com confirmação;
14. salvar e sair;
15. abrir novamente;
16. provar que os dados foram preservados.

## 22.3 Demonstração técnica

Explicar:

- `Contato` como tipo de dado;
- serviços como funções puras;
- `IO` concentrado nos módulos adequados;
- uso de nova lista em vez de alteração direta;
- persistência em CSV;
- tratamento seguro com `readMaybe`;
- separação de responsabilidades.

---

# 23. Melhorias futuras

Somente após concluir o MVP, a equipe poderá avaliar:

- autenticação;
- banco de dados;
- interface gráfica;
- API web;
- exportação;
- testes automatizados mais amplos;
- biblioteca real de CSV;
- validação mais rigorosa de e-mail;
- padronização de telefone;
- uso de `Text` em vez de `String`;
- uso de `Map` para buscas mais eficientes;
- histórico de alterações.

---

# 24. Conclusão

A implementação deve priorizar clareza, previsibilidade e separação de responsabilidades.

A regra central é:

```text
Models.hs          → define os dados
CSVRepository.hs   → lê e salva o CSV
ContactService.hs  → executa regras de contatos
GroupService.hs    → executa regras de grupos
InputUtils.hs      → trata entradas e exibição
Menu.hs            → coordena o terminal
Main.hs            → inicia e encerra a aplicação
```

O projeto estará pronto quando a equipe conseguir executar o fluxo completo, salvar o arquivo, reiniciar o programa e demonstrar que os dados persistiram sem perda ou inconsistência.
