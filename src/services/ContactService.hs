module Services.ContactService
  ( proximoId
  , adicionarContato
  , buscarPorId
  , buscarPorNome
  , buscarPorTelefone
  , editarContato
  , removerContato
  , ordenarPorNome
  ) where

import Data.Char (toLower)
import Data.List (isInfixOf, sortBy)
import Models.Contact

-- Gera o próximo ID disponível para um novo contato.
proximoId :: [Contato] -> Int
proximoId [] = 1
proximoId contatos = maximum (map contatoId contatos) + 1

-- Adiciona um contato à lista após validar nome e telefone.
adicionarContato :: String -> String -> String -> [String] -> [Contato] -> Either String [Contato]
adicionarContato rawNome rawTelefone rawEmail rawGrupos contatos =
  case (trim rawNome, trim rawTelefone) of
    ("", _) -> Left "Nome nao pode ser vazio."
    (_, "") -> Left "Telefone nao pode ser vazio."
    (nomeValido, telefoneValido) ->
      Right (contatos ++ [Contato
        { contatoId = proximoId contatos
        , nome = nomeValido
        , telefone = telefoneValido
        , email = trim rawEmail
        , grupos = filtrarGrupos rawGrupos
        }])

-- Busca um contato pelo ID.
buscarPorId :: Int -> [Contato] -> Maybe Contato
buscarPorId _ [] = Nothing
buscarPorId targetId (contato:resto)
  | contatoId contato == targetId = Just contato
  | otherwise = buscarPorId targetId resto

-- Busca contatos cujo nome contenha a consulta (ignora maiúsculas/minúsculas).
buscarPorNome :: String -> [Contato] -> [Contato]
buscarPorNome query = filter (textoContem (trim query) . nome)

-- Busca contatos cujo telefone contenha a consulta.
buscarPorTelefone :: String -> [Contato] -> [Contato]
buscarPorTelefone query = filter (textoContem (trim query) . telefone)

-- Edita os campos principais de um contato existente.
editarContato :: Int -> String -> String -> String -> [Contato] -> Either String [Contato]
editarContato targetId rawNome rawTelefone rawEmail contatos =
  case buscarPorId targetId contatos of
    Nothing -> Left "Contato nao encontrado."
    Just contatoAtual ->
      case (trim rawNome, trim rawTelefone) of
        ("", _) -> Left "Nome nao pode ser vazio."
        (_, "") -> Left "Telefone nao pode ser vazio."
        (nomeValido, telefoneValido) ->
          Right (atualizarContato targetId nomeValido telefoneValido (trim rawEmail) contatoAtual contatos)

-- Remove um contato da lista com base no ID.
removerContato :: Int -> [Contato] -> Either String [Contato]
removerContato targetId contatos =
  case buscarPorId targetId contatos of
    Nothing -> Left "Contato nao encontrado."
    Just _ -> Right (filter ((/= targetId) . contatoId) contatos)

-- Ordena a lista de contatos pelo nome, ignorando maiúsculas/minúsculas.
ordenarPorNome :: [Contato] -> [Contato]
ordenarPorNome = sortBy compararNome

-- Auxiliares internos.
compararNome :: Contato -> Contato -> Ordering
compararNome a b = compare (normalizarTexto (nome a)) (normalizarTexto (nome b))

textoContem :: String -> String -> Bool
textoContem query texto =
  let textoNormalizado = normalizarTexto texto
      queryNormalizado = normalizarTexto query
  in queryNormalizado `isInfixOf` textoNormalizado

normalizarTexto :: String -> String
normalizarTexto = map toLower . trim

filtrarGrupos :: [String] -> [String]
filtrarGrupos = filter (not . null . trim)

trim :: String -> String
trim = reverse . dropWhile (== ' ') . reverse . dropWhile (== ' ')

atualizarContato :: Int -> String -> String -> String -> Contato -> [Contato] -> [Contato]
atualizarContato targetId novoNome novoTelefone novoEmail contatoAtual =
  map (
    \contato ->
      if contatoId contato == targetId
        then contato { nome = novoNome, telefone = novoTelefone, email = novoEmail, grupos = grupos contatoAtual }
        else contato
  )
