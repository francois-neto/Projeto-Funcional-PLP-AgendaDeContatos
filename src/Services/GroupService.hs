module Services.GroupService
    ( criarGrupo
    , apagarGrupo
    , editarNomeGrupo
    , adicionarContatoEmGrupo
    , removerContatoDeGrupo
    , listarContatosPorGrupo
    , listarContatosPorGrupos
    , buscarPorNomeOuTelefoneNosGrupos
    ) where

import Models.Group
import Models.Contact
import Utils.Validation
import Data.List (sortBy)
import Data.Ord (comparing)

-- Grupo novo é criado e adicionado à agenda.
criarGrupo :: String -> [Grupo] -> Either String [Grupo]
criarGrupo nome grupos
    | nomeValido == "" = Left "Nome vazio não é permitido."
    | existeGrupo nomeValido grupos = Left "Grupo já foi criado anteriormente."
    | otherwise = Right (novoGrupo : grupos)
    where
        nomeValido = normalizarNomeGrupo nome
        novoGrupo = Grupo { nomeGrupoId = nomeValido
                          , idsContatos = []}


-- Grupo válido é apagado da agenda.
apagarGrupo :: String -> [Grupo] -> Either String [Grupo]
apagarGrupo nome grupos
    | not (existeGrupo nomeFormatado grupos) = Left "Grupo digitado não existe."
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
    | not (existeGrupo nomeAtgFormatado grupos) = Left "Grupo digitado não existe."
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


-- contato é adicionado a um grupo usando seu id.
adicionarContatoEmGrupo :: String -> String -> [Grupo] -> [Contato] -> Either String [Grupo]
adicionarContatoEmGrupo nomeGrupo telefoneContato grupos contatos
    | not (existeGrupo nomeGrupoFormatado grupos) = Left "Grupo digitado não existe."
    | not (existeContato telefoneContato contatos) = Left "Contato digitado não existe."
    | contatoEstaNoGrupo nomeGrupoFormatado contatoId grupos = Left "O contato já está neste grupo." 
    | otherwise = Right (addContatoEmGrupo nomeGrupoFormatado contatoId grupos)
    where
        contatoId = buscarIdPorTelefone telefoneContato contatos
        nomeGrupoFormatado = normalizarNomeGrupo nomeGrupo

-- Função auxiliar para adicionar contato em grupo.
addContatoEmGrupo :: String -> Int -> [Grupo] -> [Grupo]
addContatoEmGrupo _ _ [] = []
addContatoEmGrupo nomeGrupo contatoId (g:gs)
    | nomeGrupoId g == nomeGrupo = g { idsContatos = contatoId : idsContatos g } : gs
    | otherwise = g : addContatoEmGrupo nomeGrupo contatoId gs


-- Contato é removido de um grupo.
removerContatoDeGrupo ::  String -> String -> [Grupo] -> [Contato] -> Either String [Grupo]
removerContatoDeGrupo nomeGrupo telefoneContato grupos contatos
    | not (existeGrupo nomeGrupoFormatado grupos) = Left "Grupo digitado não existe."
    | not (existeContato telefoneContato contatos) = Left "Contato digitado não existe."
    | not (contatoEstaNoGrupo nomeGrupoFormatado contatoId grupos) = Left "O contato não está neste grupo."
    | otherwise = Right (remvContatoDeGrupo nomeGrupoFormatado contatoId grupos)
    where
        contatoId = buscarIdPorTelefone telefoneContato contatos
        nomeGrupoFormatado = normalizarNomeGrupo nomeGrupo

-- Função auxiliar para remover contato de um grupo.
remvContatoDeGrupo :: String -> Int -> [Grupo] -> [Grupo]
remvContatoDeGrupo _ _ [] = []
remvContatoDeGrupo nomeGrupo contatoId (g:gs)
    | nomeGrupoId g == nomeGrupo = g { idsContatos = removerId contatoId (idsContatos g) } : gs
    | otherwise = g : remvContatoDeGrupo nomeGrupo contatoId gs

removerId :: Int -> [Int] -> [Int]
removerId _ [] = []
removerId iD (x:xs)
    | x == iD = removerId iD xs      
    | otherwise   = x : removerId iD xs

-- Retorna Lista de contatos de um grupo
listarContatosPorGrupo :: String -> [Grupo] -> [Contato] -> Either String [Contato]
listarContatosPorGrupo nomeGrupo grupos contatos = 
    tratarErro (buscarGrupo nomeGrupoFormatado grupos)
    where
        nomeGrupoFormatado = normalizarNomeGrupo nomeGrupo
        tratarErro (Left erro) = Left erro
        tratarErro (Right grupo) = Right (ordenarContatosPorNome (filtrarContatos (idsContatos grupo) contatos))

-- Retorna Lista de contatos de dois ou mais grupos
listarContatosPorGrupos :: [String] -> [Grupo] -> [Contato] -> Either String [Contato]
listarContatosPorGrupos nomesGrupos grupos contatos =
    tratarResultado (buscarVariosGrupos nomesFormatados grupos)
    where
        nomesFormatados = normalizarNomesGrupos nomesGrupos
        tratarResultado (Left erro) = Left erro
        tratarResultado (Right gruposEncontrados) = 
            Right (ordenarContatosPorNome (filtrarContatos (extrairTodosIds gruposEncontrados) contatos))

-- Busca contatos dentro de dois ou mais grupos pelo nome ou pelo telefone.
buscarPorNomeOuTelefoneNosGrupos :: [String] -> String -> [Grupo] -> [Contato] -> Either String [Contato]
buscarPorNomeOuTelefoneNosGrupos nomesGrupos termoBusca grupos contatos =
    tratarBusca termoBusca (listarContatosPorGrupos nomesGrupos grupos contatos)
    where
        tratarBusca _ (Left erro) = Left erro
        tratarBusca termo (Right contatosDosGrupos) = 
            Right (filtrarPorNomeOuTelefone termo contatosDosGrupos)

-- Função auxiliar que varre uma lista de contatos procurando pelo nome ou telefone
filtrarPorNomeOuTelefone :: String -> [Contato] -> [Contato]
filtrarPorNomeOuTelefone _ [] = []
filtrarPorNomeOuTelefone termo (c:cs)
    | nome c == termo || telefone c == termo = c : filtrarPorNomeOuTelefone termo cs
    | otherwise = filtrarPorNomeOuTelefone termo cs


-- Função auxiliar que ordena os contatos alfabeticamente pelo nome.
ordenarContatosPorNome :: [Contato] -> [Contato]
ordenarContatosPorNome contatos = sortBy (comparing nome) contatos

-- Função auxiliar normaliza todos os nomes de grupos uma lista.
normalizarNomesGrupos :: [String] -> [String]
normalizarNomesGrupos [] = []
normalizarNomesGrupos (n:ns) = normalizarNomeGrupo n : normalizarNomesGrupos ns

-- Função auxiliar que cria lista com grupos específicos.
buscarVariosGrupos :: [String] -> [Grupo] -> Either String [Grupo]
buscarVariosGrupos [] _ = Right []
buscarVariosGrupos (nome:nomes) grupos =
    juntarResultados (buscarGrupo nome grupos) (buscarVariosGrupos nomes grupos)
    where
        juntarResultados (Left _) _ = Left ("O grupo '" ++ nome ++ "' não existe.")
        juntarResultados _ (Left erroResto) = Left erroResto
        juntarResultados (Right grupoAprovado) (Right listaGrupos) = Right (grupoAprovado : listaGrupos)

-- Função auxiliar que junta as listas de ids de vários grupos.
extrairTodosIds :: [Grupo] -> [Int]
extrairTodosIds [] = []
extrairTodosIds (g:gs) = idsContatos g ++ extrairTodosIds gs

-- Pega grupo a partir do seu nome.
buscarGrupo :: String -> [Grupo] -> Either String Grupo
buscarGrupo _ [] = Left "Grupo digitado não existe."
buscarGrupo nome (g:gs)
    | nomeGrupoId g == nome = Right g
    | otherwise = buscarGrupo nome gs

-- Pega contatos a partir da lista de id.
filtrarContatos :: [Int] -> [Contato] -> [Contato]
filtrarContatos _ [] = []
filtrarContatos ids (c:cs)
    | contatoId c `elem` ids = c : filtrarContatos ids cs
    | otherwise = filtrarContatos ids cs

-- Pega idContato a partir do telefone.
buscarIdPorTelefone :: String -> [Contato] -> Int
buscarIdPorTelefone _ [] = -1
buscarIdPorTelefone telefoneContato (c:cs)
    | telefoneContato == telefone c = contatoId c
    | otherwise = buscarIdPorTelefone telefoneContato cs

-- Verifica se contato já está em um grupo específico.
contatoEstaNoGrupo :: String -> Int -> [Grupo] -> Bool
contatoEstaNoGrupo _ _ [] = False
contatoEstaNoGrupo nomeGrupo contatoId (g:gs)
    | nomeGrupoId g == nomeGrupo = contatoId `elem` idsContatos g
    | otherwise = contatoEstaNoGrupo nomeGrupo contatoId gs

-- Verifica se um contato existe pelo telefone.
existeContato :: String -> [Contato] -> Bool
existeContato _ [] = False
existeContato tele (c:cs)
    | tele == telefone c = True
    | otherwise = existeContato tele cs

-- Verifica se grupo já existe
existeGrupo :: String -> [Grupo] -> Bool
existeGrupo _ [] = False
existeGrupo nome (g:gs)
    | nomeGrupoId g == nome = True
    | otherwise = existeGrupo nome gs
