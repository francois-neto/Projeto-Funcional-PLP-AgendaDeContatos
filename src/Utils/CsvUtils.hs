module Utils.CsvUtils
  ( splitOnDelim
  , splitCommas
  , splitPipe
  , joinWithComma
  , joinWithPipe
  ) where

import Data.List (intercalate)

splitOnDelim :: Char -> String -> [String]
splitOnDelim _ "" = [""]
splitOnDelim delim str = go str ""
  where
    go [] acc = [reverse acc]
    go (c:cs) acc
      | c == delim = reverse acc : go cs ""
      | otherwise = go cs (c:acc)

splitCommas :: String -> [String]
splitCommas = splitOnDelim ','

splitPipe :: String -> [String]
splitPipe = splitOnDelim '|'

joinWithComma :: [String] -> String
joinWithComma = intercalate ","

joinWithPipe :: [String] -> String
joinWithPipe = intercalate "|"
