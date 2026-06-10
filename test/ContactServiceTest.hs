module Main where

import Models.Contact
import Services.ContactService

main :: IO ()
main = do
  assertEqual "proximoId [] deve retornar 1" 1 (proximoId [])
  assertEqual "proximoId deve considerar o maior ID existente" 8 (proximoId [Contato 1 "Ana" "9999" "a@a.com" [], Contato 4 "Bia" "8888" "b@b.com" [], Contato 7 "Cai" "7777" "c@c.com" []])
  assertEqual "buscarPorNome deve achar correspondencia parcial" 1 (length (buscarPorNome "ana" [Contato 1 "Ana Silva" "9999" "ana@x.com" [], Contato 2 "Carlos" "8888" "c@x.com" []]))
  assertEqual "buscarPorTelefone deve achar correspondencia parcial" 1 (length (buscarPorTelefone "9999" [Contato 1 "Ana Silva" "9999" "ana@x.com" [], Contato 2 "Carlos" "8888" "c@x.com" []]))
  case removerContato 2 [Contato 1 "Ana" "9999" "a@a.com" [], Contato 2 "Bia" "8888" "b@b.com" []] of
    Left err -> failTest ("removerContato nao deveria falhar: " ++ err)
    Right contatos -> assertEqual "removerContato deve remover um contato existente" 1 (length contatos)
  case editarContato 1 "Ana Atualizada" "0000" "ana@nova.com" [Contato 1 "Ana" "9999" "a@a.com" []] of
    Left err -> failTest ("editarContato nao deveria falhar: " ++ err)
    Right contatos -> do
      assertEqual "editarContato deve atualizar nome" "Ana Atualizada" (nome (head contatos))
      assertEqual "editarContato deve atualizar telefone" "0000" (telefone (head contatos))
      assertEqual "editarContato deve manter o ID" 1 (contatoId (head contatos))
  case adicionarContato "" "9999" "a@a.com" [] [] of
    Left _ -> pure ()
    Right _ -> failTest "adicionarContato deve rejeitar nome vazio"
  putStrLn "Todos os testes da Pessoa 2 passaram."

assertEqual :: (Eq a, Show a) => String -> a -> a -> IO ()
assertEqual mensagem esperado obtido
  | esperado == obtido = pure ()
  | otherwise = failTest (mensagem ++ " (esperado: " ++ show esperado ++ ", obtido: " ++ show obtido ++ ")")

failTest :: String -> IO a
failTest mensagem = do
  putStrLn ("FAIL: " ++ mensagem)
  error mensagem
