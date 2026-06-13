module Services.GroupService
  ( normalizarTexto
  , listarGrupos
  , buscarPorGrupo
  , adicionarGrupo
  , removerGrupo
  ) where

import Data.Char (toLower)
import Data.List (nubBy)
import Models
import Services.ContactService (buscarPorId)

-- Normaliza texto removendo case-sensitivity
normalizarTexto :: String -> String
normalizarTexto = map toLower . trim

-- Lista todos os grupos existentes sem duplicacao (ignorando maiusculas/minusculas)
listarGrupos :: [Contato] -> [String]
listarGrupos contatos =
  let allGroups = concatMap grupos contatos
      insertUnique acc g = if any ((== normalizarTexto g) . normalizarTexto) acc then acc else acc ++ [g]
  in foldl insertUnique [] allGroups

-- Busca contatos por grupo (ignora case e espaços perifericos)
buscarPorGrupo :: String -> [Contato] -> [Contato]
buscarPorGrupo g = filter (\t -> any ((== normalizarTexto g) . normalizarTexto) (grupos t))

-- Adiciona um grupo a um contato identificado por ID, evitando duplicatas
adicionarGrupo :: Int -> String -> [Contato] -> Either String [Contato]
adicionarGrupo targetId grupo contatos =
  case buscarPorId targetId contatos of
    Nothing -> Left "Contato nao encontrado."
    Just contato ->
      let gnorm = normalizarTexto grupo
          already = any ((== gnorm) . normalizarTexto) (grupos contato)
      in if already
           then Left "Contato ja possui esse grupo."
           else Right (map (\t -> if contatoId t == targetId then t { grupos = grupos t ++ [grupo] } else t) contatos)

-- Remove associacao de grupo de um contato
removerGrupo :: Int -> String -> [Contato] -> Either String [Contato]
removerGrupo targetId grupo contatos =
  case buscarPorId targetId contatos of
    Nothing -> Left "Contato nao encontrado."
    Just contato ->
      let gnorm = normalizarTexto grupo
          filtered = filter (not . (== gnorm) . normalizarTexto) (grupos contato)
      in if length filtered == length (grupos contato)
           then Left "Grupo nao associado ao contato."
           else Right (map (\t -> if contatoId t == targetId then t { grupos = filtered } else t) contatos)

-- Trim helper (copied minimal implementation)
trim :: String -> String
trim = reverse . dropWhile (== ' ') . reverse . dropWhile (== ' ')
