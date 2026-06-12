module Services.GroupService
    ( criarGrupo
    , apagarGrupo
    , editarNomeGrupo
--    , adicionarContatoAoGrupo
--    , removerContatoDoGrupo
--    , listarContatosPorGrupo
--    , listarContatosPorGrupos
--    , buscarPorNomeNoGrupo
    ) where

import Models.Group
import Utils.Validation

-- Grupo novo é criado e adicionado à agenda.
criarGrupo :: String -> [Grupo] -> Either String [Grupo]
criarGrupo nome grupos
    | nomeValido == "" = Left "Nome vazio não é permitido."
    | grupoExistente nomeValido grupos = Left "Grupo já foi criado anteriormente."
    | otherwise = Right (novoGrupo : grupos)
    where
        nomeValido = normalizarNomeGrupo nome
        novoGrupo = Grupo { nomeGrupoId = nomeValido
                          , idsContatos = []}


-- Grupo válido é apagado da agenda.
apagarGrupo :: String -> [Grupo] -> Either String [Grupo]
apagarGrupo nome grupos
    | not (grupoExistente nomeFormatado grupos) = Left "Grupo digitado não existe."
    | otherwise = Right (removeGrupo nomeFormatado grupos)
    where
        nomeFormatado = normalizarNomeGrupo nome

-- Função auxiliar que remove o grupo da agenda e cria a nova lista.
removeGrupo :: String -> [Grupo] -> [Grupo]
removeGrupo _ [] = []
removeGrupo nome (g:gs)
    | nomeGrupoId g == nome = removeGrupo nome gs
    | otherwise = g : removeGrupo nome gs


-- Nome de um grupo é editado.
editarNomeGrupo :: String -> String -> [Grupo] -> Either String [Grupo]
editarNomeGrupo nomeAntigo nomeNovo grupos
    | nomeNovoFormatado == "" = Left "Novo nome vazio não é permitido."
    | not (grupoExistente nomeAtgFormatado grupos) = Left "Grupo digitado não existe."
    | otherwise = Right (mudaNomeGrupo nomeAtgFormatado nomeNovoFormatado grupos)
    where
        nomeAtgFormatado = normalizarNomeGrupo nomeAntigo
        nomeNovoFormatado = normalizarNomeGrupo nomeNovo

-- Função auxiliar para mudar nome do grupo e fazer a nova lista.
mudaNomeGrupo :: String -> String -> [Grupo] -> [Grupo]
mudaNomeGrupo _ _ [] = []
mudaNomeGrupo nomeAntigo nomeNovo (g:gs)
    | nomeGrupoId g == nomeAntigo = g {nomeGrupoId = nomeNovo} : gs
    | otherwise = g : mudaNomeGrupo nomeAntigo nomeNovo gs














-- Verifica se grupo já existe
grupoExistente :: String -> [Grupo] -> Bool
grupoExistente _ [] = False
grupoExistente nome (g:gs)
    | nomeGrupoId g == nome = True
    | otherwise = grupoExistente nome gs
    
