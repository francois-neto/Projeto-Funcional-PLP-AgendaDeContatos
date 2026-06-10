module Models.Contact
  ( Contato(..)
  ) where

-- Modelo principal da agenda de contatos.
data Contato = Contato
  { contatoId :: Int
  , nome      :: String
  , telefone  :: String
  , email     :: String
  , grupos    :: [String]
  } deriving (Show, Eq)
