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
import Models
import Text.Read (readMaybe)

{-|
 * Le uma entrada numerica inteira do terminal.
 * A recursividade e aplicada quando a entrada nao pode ser convertida para inteiro, repetindo a leitura ate receber um valor valido.
 *
 * @param mensagem Texto exibido ao usuario antes da leitura.
 * @return Acao de IO que retorna o numero inteiro lido.
 -}
lerInteiro :: String -> IO Int
lerInteiro mensagem = do
  putStrLn mensagem
  entrada <- getLine
  case readMaybe entrada of
    Just numero -> pure numero
    Nothing -> do
      putStrLn "Entrada invalida. Digite um numero inteiro."
      lerInteiro mensagem

{-|
 * Le um texto obrigatorio do terminal, removendo espacos nas extremidades.
 * A recursividade e aplicada quando a entrada fica vazia, repetindo a leitura ate receber texto valido.
 *
 * @param mensagem Texto exibido ao usuario antes da leitura.
 * @return Acao de IO que retorna o texto nao vazio informado.
 -}
lerTextoNaoVazio :: String -> IO String
lerTextoNaoVazio mensagem = do
  putStrLn mensagem
  entrada <- getLine
  let texto = trim entrada
  if null texto
    then do
      putStrLn "Entrada invalida. O texto nao pode ser vazio."
      lerTextoNaoVazio mensagem
    else pure texto

{-|
 * Le um texto opcional do terminal, removendo espacos nas extremidades.
 *
 * @param mensagem Texto exibido ao usuario antes da leitura.
 * @return Acao de IO que retorna o texto informado ou uma string vazia.
 -}
lerTextoOpcional :: String -> IO String
lerTextoOpcional mensagem = do
  putStrLn mensagem
  trim <$> getLine

{-|
 * Solicita confirmacao textual do usuario e converte a resposta para booleano.
 *
 * @param mensagem Texto exibido ao usuario antes da leitura.
 * @return Acao de IO que retorna True para respostas afirmativas e False para respostas negativas, vazias ou invalidas.
 -}
confirmar :: String -> IO Bool
confirmar mensagem = do
  putStrLn mensagem
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

{-|
 * Exibe no terminal os campos principais de um contato.
 *
 * @param contato Contato que sera exibido.
 * @return Acao de IO sem valor relevante; apenas imprime os dados do contato.
 -}
exibirContato :: Contato -> IO ()
exibirContato contato = do
  putStrLn "----------------------------------------"
  putStrLn ("ID: " ++ show (contatoId contato))
  putStrLn ("Nome: " ++ nome contato)
  putStrLn ("Telefone: " ++ telefone contato)
  putStrLn ("Email: " ++ email contato)
  putStrLn ("Grupos: " ++ formatarGrupos (grupos contato))

{-|
 * Exibe uma lista de contatos ou uma mensagem quando a lista esta vazia.
 *
 * @param contatos Lista de contatos que sera exibida.
 * @return Acao de IO sem valor relevante; apenas imprime a lista ou a mensagem de ausencia.
 -}
exibirContatos :: [Contato] -> IO ()
exibirContatos [] = putStrLn "Nenhum contato encontrado."
exibirContatos contatos = mapM_ exibirContato contatos

{-|
 * Exibe uma lista de grupos ou uma mensagem quando nao existem grupos cadastrados.
 *
 * @param gruposEncontrados Lista de nomes de grupos que sera exibida.
 * @return Acao de IO sem valor relevante; apenas imprime os grupos ou a mensagem de ausencia.
 -}
exibirGrupos :: [String] -> IO ()
exibirGrupos [] = putStrLn "Nenhum grupo cadastrado."
exibirGrupos gruposEncontrados = mapM_ putStrLn gruposEncontrados

{-|
 * Converte a lista de grupos de um contato para texto legivel.
 *
 * @param gruposContato Lista de grupos associados ao contato.
 * @return Texto formatado com os grupos separados por virgula ou mensagem padrao para lista vazia.
 -}
formatarGrupos :: [String] -> String
formatarGrupos [] = "(sem grupos)"
formatarGrupos gruposContato = intercalate ", " gruposContato

{-|
 * Remove espacos em branco do inicio e do fim de um texto.
 *
 * @param texto Texto original.
 * @return Texto sem espacos nas extremidades.
 -}
trim :: String -> String
trim = removerEspacosFim . dropWhile isSpace

{-|
 * Remove espacos em branco do fim de um texto.
 *
 * @param texto Texto original.
 * @return Texto sem espacos finais.
 -}
removerEspacosFim :: String -> String
removerEspacosFim = reverse . dropWhile isSpace . reverse
