module Models.Group
  ( Grupo(..)
  ) where

data Grupo = Grupo
  { nomeGrupoId :: String
  , idsContatos :: [Int]
  } deriving (Show, Eq)
