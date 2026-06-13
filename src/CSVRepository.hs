module CSVRepository
  ( cabecalhoEsperado
  , carregarContatos
  , salvarContatos
  , linhaParaContato
  , contatoParaLinha
  ) where

import System.IO (withFile, IOMode(WriteMode), hPutStrLn)
import System.Directory (renameFile, removeFile, doesFileExist)
import Text.Read (readMaybe)
import Data.List (intercalate)
import Models (Contato(..))
import Utils.CsvUtils (splitCommas, splitPipe, joinWithPipe, joinWithComma)

-- Cabeçalho esperado do CSV
cabecalhoEsperado :: String
cabecalhoEsperado = "id,nome,telefone,email,grupos"

-- Carrega contatos de um arquivo CSV.
carregarContatos :: FilePath -> IO (Either String [Contato])
carregarContatos path = do
  exists <- doesFileExist path
  if not exists
    then return $ Right []
    else do
      content <- readFile path
      let ls = lines content
      case ls of
        [] -> return $ Right []
        (h:rs)
          | h /= cabecalhoEsperado -> return $ Left ("Cabecalho invalido: esperado " ++ cabecalhoEsperado)
          | otherwise ->
              case traverse linhaParaContato rs of
                Left err -> return $ Left err
                Right contatos -> return $ Right contatos

-- Salva contatos em CSV de forma segura (arquivo temporário + substituição).
salvarContatos :: FilePath -> [Contato] -> IO (Either String ())
salvarContatos path contatos = do
  let tmp = path ++ ".tmp"
      linhas = cabecalhoEsperado : map contatoParaLinha contatos
  -- escreve em arquivo temporario
  withFile tmp WriteMode $ \h -> mapM_ (hPutStrLn h) linhas
  -- substitui arquivo antigo com seguranca
  exists <- doesFileExist path
  if exists
    then do
      removeFile path
      renameFile tmp path
      return $ Right ()
    else do
      renameFile tmp path
      return $ Right ()

-- Converte uma linha CSV (sem cabecalho) em Contato.
linhaParaContato :: String -> Either String Contato
linhaParaContato line =
  case splitCommas line of
    [sId, sNome, sTelefone, sEmail, sGrupos] ->
      case readMaybe sId :: Maybe Int of
        Nothing -> Left ("ID invalido na linha: " ++ line)
        Just nid -> Right Contato
          { contatoId = nid
          , nome = sNome
          , telefone = sTelefone
          , email = sEmail
          , grupos = if null sGrupos then [] else splitPipe sGrupos
          }
    _ -> Left ("Linha CSV com numero de campos invalido: " ++ line)

-- Converte um Contato em uma linha CSV.
contatoParaLinha :: Contato -> String
contatoParaLinha c = joinWithComma [show (contatoId c), nome c, telefone c, email c, joinWithPipe (grupos c)]
