module UI.Terminal
  ( menuPrincipal
  ) where

import Models.Contact
import Services.ContactService
import Services.GroupService
import Utils.InputUtils

{-|
 * Controla o menu principal da agenda e direciona o usuario para cada fluxo.
 * A recursividade e aplicada chamando `menuPrincipal` novamente apos cada acao que nao encerra o sistema, mantendo o menu ativo com a lista atualizada.
 *
 * @param contacts Lista atual de contatos mantida em memoria.
 * @return Acao de IO que retorna a lista final de contatos quando o usuario escolhe salvar e sair.
 -}
menuPrincipal :: [Contato] -> IO [Contato]
menuPrincipal contacts = do
  exibirMenuPrincipal
  option <- lerInteiro "Escolha uma opcao: "
  case option of
    1 -> exibirContatos (ordenarPorNome contacts) >> menuPrincipal contacts
    2 -> fluxoCadastrar contacts >>= menuPrincipal
    3 -> fluxoEditar contacts >>= menuPrincipal
    4 -> fluxoRemover contacts >>= menuPrincipal
    5 -> menuPesquisa contacts >> menuPrincipal contacts
    6 -> menuGrupos contacts >>= menuPrincipal
    0 -> pure contacts
    _ -> putStrLn "Opcao invalida." >> menuPrincipal contacts

{-|
 * Controla o submenu de pesquisa e executa buscas sobre a lista atual de contatos.
 * A recursividade e aplicada chamando `menuPesquisa` novamente apos cada consulta, permitindo novas pesquisas ate o usuario escolher voltar.
 *
 * @param contacts Lista atual de contatos usada como base das pesquisas.
 * @return Acao de IO sem valor relevante; apenas exibe resultados e retorna ao menu anterior.
 -}
menuPesquisa :: [Contato] -> IO ()
menuPesquisa contacts = do
  exibirMenuPesquisa
  option <- lerInteiro "Escolha uma opcao: "
  case option of
    1 -> do
      query <- lerTextoNaoVazio "Nome ou trecho: "
      exibirContatos (buscarPorNome query contacts)
      menuPesquisa contacts
    2 -> do
      query <- lerTextoNaoVazio "Telefone ou trecho: "
      exibirContatos (buscarPorTelefone query contacts)
      menuPesquisa contacts
    3 -> do
      targetId <- lerInteiro "ID: "
      case buscarPorId targetId contacts of
        Nothing -> putStrLn "Nenhum contato encontrado."
        Just contact -> exibirContato contact
      menuPesquisa contacts
    4 -> do
      query <- lerTextoNaoVazio "Grupo: "
      exibirContatos (buscarPorGrupo query contacts)
      menuPesquisa contacts
    0 -> pure ()
    _ -> putStrLn "Opcao invalida." >> menuPesquisa contacts

{-|
 * Controla o submenu de grupos e direciona o usuario para listagem, adicao ou remocao de associacoes.
 * A recursividade e aplicada chamando `menuGrupos` novamente apos cada operacao, preservando a lista atualizada ate o usuario escolher voltar.
 *
 * @param contacts Lista atual de contatos mantida em memoria.
 * @return Acao de IO que retorna a lista de contatos apos as operacoes de grupo.
 -}
menuGrupos :: [Contato] -> IO [Contato]
menuGrupos contacts = do
  exibirMenuGrupos
  option <- lerInteiro "Escolha uma opcao: "
  case option of
    1 -> exibirGrupos (listarGrupos contacts) >> menuGrupos contacts
    2 -> do
      updated <- fluxoAdicionarGrupo contacts
      menuGrupos updated
    3 -> do
      updated <- fluxoRemoverGrupo contacts
      menuGrupos updated
    0 -> pure contacts
    _ -> putStrLn "Opcao invalida." >> menuGrupos contacts

{-|
 * Executa o fluxo de cadastro, coletando os campos no terminal e chamando o servico de contatos.
 *
 * @param contacts Lista atual de contatos antes do cadastro.
 * @return Acao de IO que retorna a lista original em caso de erro ou a lista atualizada em caso de sucesso.
 -}
fluxoCadastrar :: [Contato] -> IO [Contato]
fluxoCadastrar contacts = do
  putStrLn ""
  putStrLn "CADASTRAR CONTATO"
  rawName <- lerTextoNaoVazio "Nome: "
  rawPhone <- lerTextoNaoVazio "Telefone: "
  rawEmail <- lerTextoOpcional "Email: "
  rawGroups <- lerTextoOpcional "Grupos iniciais separados por |: "
  case adicionarContato rawName rawPhone rawEmail (separarGrupos rawGroups) contacts of
    Left err -> putStrLn err >> pure contacts
    Right updated -> putStrLn "Contato cadastrado com sucesso." >> pure updated

{-|
 * Executa o fluxo de edicao, localizando um contato por ID e preservando valores antigos quando a entrada fica vazia.
 *
 * @param contacts Lista atual de contatos antes da edicao.
 * @return Acao de IO que retorna a lista original em caso de erro ou a lista atualizada em caso de sucesso.
 -}
fluxoEditar :: [Contato] -> IO [Contato]
fluxoEditar contacts = do
  putStrLn ""
  putStrLn "EDITAR CONTATO"
  targetId <- lerInteiro "ID do contato: "
  case buscarPorId targetId contacts of
    Nothing -> putStrLn "Contato nao encontrado." >> pure contacts
    Just contact -> do
      exibirContato contact
      putStrLn "Deixe em branco para manter o valor atual."
      newName <- lerValorEditado "Novo nome: " (nome contact)
      newPhone <- lerValorEditado "Novo telefone: " (telefone contact)
      newEmail <- lerValorEditado "Novo email: " (email contact)
      case editarContato targetId newName newPhone newEmail contacts of
        Left err -> putStrLn err >> pure contacts
        Right updated -> putStrLn "Contato atualizado com sucesso." >> pure updated

{-|
 * Executa o fluxo de remocao, exibindo o contato encontrado e removendo apenas apos confirmacao do usuario.
 *
 * @param contacts Lista atual de contatos antes da remocao.
 * @return Acao de IO que retorna a lista original quando a remocao falha ou e cancelada, ou a lista atualizada quando confirmada.
 -}
fluxoRemover :: [Contato] -> IO [Contato]
fluxoRemover contacts = do
  putStrLn ""
  putStrLn "REMOVER CONTATO"
  targetId <- lerInteiro "ID do contato: "
  case buscarPorId targetId contacts of
    Nothing -> putStrLn "Contato nao encontrado." >> pure contacts
    Just contact -> do
      exibirContato contact
      confirmed <- confirmar "Confirmar remocao? (s/N): "
      if confirmed
        then
          case removerContato targetId contacts of
            Left err -> putStrLn err >> pure contacts
            Right updated -> putStrLn "Contato removido com sucesso." >> pure updated
        else putStrLn "Remocao cancelada." >> pure contacts

{-|
 * Executa o fluxo de associacao de um contato a um grupo, coletando ID e nome do grupo.
 *
 * @param contacts Lista atual de contatos antes da associacao.
 * @return Acao de IO que retorna a lista original em caso de erro ou a lista atualizada em caso de sucesso.
 -}
fluxoAdicionarGrupo :: [Contato] -> IO [Contato]
fluxoAdicionarGrupo contacts = do
  targetId <- lerInteiro "ID do contato: "
  rawGroup <- lerTextoNaoVazio "Grupo: "
  case adicionarGrupo targetId rawGroup contacts of
    Left err -> putStrLn err >> pure contacts
    Right updated -> putStrLn "Grupo adicionado com sucesso." >> pure updated

{-|
 * Executa o fluxo de remocao da associacao entre um contato e um grupo.
 *
 * @param contacts Lista atual de contatos antes da remocao da associacao.
 * @return Acao de IO que retorna a lista original em caso de erro ou a lista atualizada em caso de sucesso.
 -}
fluxoRemoverGrupo :: [Contato] -> IO [Contato]
fluxoRemoverGrupo contacts = do
  targetId <- lerInteiro "ID do contato: "
  rawGroup <- lerTextoNaoVazio "Grupo: "
  case removerGrupo targetId rawGroup contacts of
    Left err -> putStrLn err >> pure contacts
    Right updated -> putStrLn "Grupo removido do contato com sucesso." >> pure updated

{-|
 * Le um campo durante a edicao e retorna o valor informado ou preserva o valor atual quando a entrada fica vazia.
 *
 * @param prompt Mensagem exibida para solicitar o novo valor.
 * @param valorAtual Valor que sera preservado se a entrada for vazia.
 * @return Acao de IO que retorna o novo valor ou o valor atual preservado.
 -}
lerValorEditado :: String -> String -> IO String
lerValorEditado prompt valorAtual = do
  novoValor <- lerTextoOpcional prompt
  pure (if null novoValor then valorAtual else novoValor)

{-|
 * Converte um texto com grupos separados por barra vertical em uma lista de grupos.
 * A recursividade e aplicada separando o primeiro grupo antes de `|` e chamando `separarGrupos` para processar o restante do texto ate nao haver mais separador.
 *
 * @param texto Texto contendo zero, um ou varios grupos separados por `|`.
 * @return Lista de grupos extraidos do texto.
 -}
separarGrupos :: String -> [String]
separarGrupos "" = []
separarGrupos texto =
  case break (== '|') texto of
    (grupo, "") -> [grupo]
    (grupo, _ : resto) -> grupo : separarGrupos resto

{-|
 * Exibe no terminal as opcoes do menu principal.
 *
 * @param Nenhum.
 * @return Acao de IO sem valor relevante; apenas imprime o menu.
 -}
exibirMenuPrincipal :: IO ()
exibirMenuPrincipal = do
  putStrLn ""
  putStrLn "----------------------------------------"
  putStrLn "AGENDA DE CONTATOS"
  putStrLn "----------------------------------------"
  putStrLn "1. Listar contatos"
  putStrLn "2. Cadastrar contato"
  putStrLn "3. Editar contato"
  putStrLn "4. Remover contato"
  putStrLn "5. Pesquisar contato"
  putStrLn "6. Gerenciar grupos"
  putStrLn "0. Salvar e sair"
  putStrLn "----------------------------------------"

{-|
 * Exibe no terminal as opcoes do menu de pesquisa.
 *
 * @param Nenhum.
 * @return Acao de IO sem valor relevante; apenas imprime o menu.
 -}
exibirMenuPesquisa :: IO ()
exibirMenuPesquisa = do
  putStrLn ""
  putStrLn "PESQUISAR CONTATO"
  putStrLn "1. Buscar por nome"
  putStrLn "2. Buscar por telefone"
  putStrLn "3. Buscar por ID"
  putStrLn "4. Buscar por grupo"
  putStrLn "0. Voltar"

{-|
 * Exibe no terminal as opcoes do menu de gerenciamento de grupos.
 *
 * @param Nenhum.
 * @return Acao de IO sem valor relevante; apenas imprime o menu.
 -}
exibirMenuGrupos :: IO ()
exibirMenuGrupos = do
  putStrLn ""
  putStrLn "GERENCIAR GRUPOS"
  putStrLn "1. Listar grupos"
  putStrLn "2. Adicionar contato a um grupo"
  putStrLn "3. Remover contato de um grupo"
  putStrLn "0. Voltar"
