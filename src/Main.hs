module Main where

import Repository.ContactRepository
import UI.Terminal

csvPath :: FilePath
csvPath = "data/contatos.csv"

main :: IO ()
main = do
  putStrLn "Carregando contatos..."
  loaded <- carregarContatos csvPath
  case loaded of
    Left err -> do
      putStrLn "Nao foi possivel iniciar a agenda."
      putStrLn err
      putStrLn "Verifique o arquivo data/contatos.csv antes de executar novamente."
    Right contacts -> do
      updatedContacts <- menuPrincipal contacts
      saved <- salvarContatos csvPath updatedContacts
      case saved of
        Left err -> do
          putStrLn "Falha ao salvar os contatos."
          putStrLn err
        Right _ ->
          putStrLn "Contatos salvos com sucesso. Ate logo."
