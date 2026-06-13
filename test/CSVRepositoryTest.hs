module Main where

import System.Directory (removeFile, doesFileExist)
import CSVRepository
import Models

-- Test harness minimal: cria arquivos temporarios, escreve exemplos, carrega e verifica.
main :: IO ()
main = do
  putStrLn "Executando testes manuais de CSVRepository..."
  let path = "data/test_contatos.csv"
  -- prepara um CSV valido
  let linhas = unlines [cabecalhoEsperado, "1,Ana Silva,83999999999,ana@email.com,Familia|Favoritos", "2,Carlos Souza,83988888888,carlos@email.com,Trabalho"]
  writeFile path linhas
  loaded <- carregarContatos path
  case loaded of
    Left err -> do
      putStrLn $ "Falha ao carregar CSV valido: " ++ err
      cleanup path
    Right contatos -> do
      putStrLn $ "Carregado com " ++ show (length contatos) ++ " contatos (esperado 2)."
      -- testa salvar e recarregar
      let contatosAlterados = contatos ++ [Contato { contatoId = 3, nome = "Joao Teste", telefone = "83900000000", email = "joao@t.com", grupos = ["Teste"] }]
      saved <- salvarContatos path contatosAlterados
      case saved of
        Left err -> putStrLn $ "Falha ao salvar: " ++ err
        Right _ -> putStrLn "Salvo com sucesso. Recarregando..."
      reloaded <- carregarContatos path
      case reloaded of
        Left err -> putStrLn $ "Falha ao recarregar: " ++ err
        Right rc -> putStrLn $ "Recarregado com " ++ show (length rc) ++ " contatos (esperado 3)."
      cleanup path
  putStrLn "Testes concluídos."

cleanup :: FilePath -> IO ()
cleanup p = do
  exists <- doesFileExist p
  if exists then removeFile p else return ()
  putStrLn "Testes concluídos."
