module Utils.Validation
  ( validarTelefoneBrasil
  , normalizarTelefone
  ) where

import Data.Char (isDigit)

-- Valida telefones brasileiros com DDD, celulares, fixos e serviços.
validarTelefoneBrasil :: String -> Bool
validarTelefoneBrasil rawTelefone =
  let telefone = normalizarTelefone rawTelefone
  in case telefone of
    _ | length telefone == 11 && take 4 telefone `elem` ["0800", "0300", "0500", "1800", "1900"] ->
          length telefone == 11 && all isDigit telefone
    _ | length telefone == 11 && take 4 telefone `elem` ["4004", "4010", "4020", "4040", "4050", "4060", "4070", "4080", "4090"] ->
          length telefone == 11 && all isDigit telefone
    _ | length telefone == 10 ->
          let ddd = take 2 telefone
              prefixo = drop 2 telefone
          in ddd `elem` todosDdds && length prefixo == 8 && head prefixo `elem` ['2'..'5']
    _ | length telefone == 11 ->
          let ddd = take 2 telefone
              corpo = drop 2 telefone
          in ddd `elem` todosDdds && length corpo == 9 && head corpo == '9'
    _ -> False

normalizarTelefone :: String -> String
normalizarTelefone = filter isDigit

todosDdds :: [String]
todosDdds =
  [ "11", "12", "13", "14", "15", "16", "17", "18", "19"
  , "21", "22", "24"
  , "27", "28"
  , "31", "32", "33", "34", "35", "37", "38"
  , "41", "42", "43", "44", "45", "46"
  , "47", "48", "49"
  , "51", "53", "54", "55"
  , "61", "62", "63", "64", "65", "66", "67", "68", "69"
  , "71", "73", "74", "75", "77", "79"
  , "81", "82", "83", "84", "85", "86", "87", "88", "89"
  , "91", "92", "93", "94", "95", "96", "97", "98", "99"
  ]
