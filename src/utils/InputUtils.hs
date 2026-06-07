module Utils.InputUtils
  ( lerInteiro
  , lerTextoNaoVazio
  , lerTextoOpcional
  , confirmar
  , exibirContato
  , exibirContatos
  , exibirGrupos
  ) where

import Data.Char (isSpace, toLower)
import Data.List (intercalate)
import Models.Contact
import Text.Read (readMaybe)

lerInteiro :: String -> IO Int
lerInteiro mensagem = do
  putStr mensagem
  entrada <- getLine
  case readMaybe entrada of
    Just numero -> pure numero
    Nothing -> do
      putStrLn "Entrada invalida. Digite um numero inteiro."
      lerInteiro mensagem

lerTextoNaoVazio :: String -> IO String
lerTextoNaoVazio mensagem = do
  putStr mensagem
  entrada <- getLine
  let texto = trim entrada
  if null texto
    then do
      putStrLn "Entrada invalida. O texto nao pode ser vazio."
      lerTextoNaoVazio mensagem
    else pure texto

lerTextoOpcional :: String -> IO String
lerTextoOpcional mensagem = do
  putStr mensagem
  trim <$> getLine

confirmar :: String -> IO Bool
confirmar mensagem = do
  putStr mensagem
  entrada <- getLine
  case map toLower (trim entrada) of
    "s" -> pure True
    "sim" -> pure True
    "n" -> pure False
    "nao" -> pure False
    "" -> pure False
    _ -> do
      putStrLn "Resposta invalida. Operacao cancelada."
      pure False

exibirContato :: Contato -> IO ()
exibirContato contato = do
  putStrLn "----------------------------------------"
  putStrLn ("ID: " ++ show (contatoId contato))
  putStrLn ("Nome: " ++ nome contato)
  putStrLn ("Telefone: " ++ telefone contato)
  putStrLn ("Email: " ++ email contato)
  putStrLn ("Grupos: " ++ formatarGrupos (grupos contato))

exibirContatos :: [Contato] -> IO ()
exibirContatos [] = putStrLn "Nenhum contato encontrado."
exibirContatos contatos = mapM_ exibirContato contatos

exibirGrupos :: [String] -> IO ()
exibirGrupos [] = putStrLn "Nenhum grupo cadastrado."
exibirGrupos gruposEncontrados = mapM_ putStrLn gruposEncontrados

formatarGrupos :: [String] -> String
formatarGrupos [] = "(sem grupos)"
formatarGrupos gruposContato = intercalate ", " gruposContato

trim :: String -> String
trim = removerEspacosFim . dropWhile isSpace

removerEspacosFim :: String -> String
removerEspacosFim = reverse . dropWhile isSpace . reverse
