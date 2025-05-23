-- Banco:
DROP DATABASE bibliotecaonline;
CREATE DATABASE bibliotecaonline;
USE bibliotecaonline;
-- Tabela: Autores (IDs de 100+)
CREATE TABLE Autores (
 id INT PRIMARY KEY,
 nome VARCHAR(100)
);
INSERT INTO Autores (id, nome) VALUES
(101, 'Machado de Assis'),
(102, 'Monteiro Lobato'),
(103, 'Clarice Lispector'),
(104, 'Paulo Coelho');
-- Tabela: Editoras (IDs de 200+)
CREATE TABLE Editoras (
 id INT PRIMARY KEY,
 nome VARCHAR(100)
);
INSERT INTO Editoras (id, nome) VALUES
(201, 'Companhia das Letras'),
(202, 'Editora Globo'),
(203, 'Rocco'),
(204, 'Saraiva');
-- Tabela: Livros (IDs de 300+)
CREATE TABLE Livros (
 id INT PRIMARY KEY,
 titulo VARCHAR(100),
 id_autor INT,
 id_editora INT,
 ano_publicacao INT,
 FOREIGN KEY (id_autor) REFERENCES Autores(id),
 FOREIGN KEY (id_editora) REFERENCES Editoras(id)
);
INSERT INTO Livros (id, titulo, id_autor, id_editora, ano_publicacao) VALUES
(301, 'Dom Casmurro', 101, 201, 1899),
(302, 'O Alienista', 101, 201, 1882),
(303, 'Reinações de Narizinho', 102, 204, 1931),
(304, 'A Hora da Estrela', 103, 203, 1977),
(305, 'O Alquimista', 104, 202, 1988);
-- Tabela: Leitores (IDs de 400+)
CREATE TABLE Leitores (
 id INT PRIMARY KEY,
 nome VARCHAR(100)
);
INSERT INTO Leitores (id, nome) VALUES
(401, 'Ana Clara'),
(402, 'Bruno Martins'),
(403, 'Carlos Souza');
-- Tabela: Emprestimos (IDs de 500+)
CREATE TABLE Emprestimos (
 id INT PRIMARY KEY,
 id_livro INT,
 id_leitor INT,
 data_emprestimo DATE,
 data_devolucao DATE,
 FOREIGN KEY (id_livro) REFERENCES Livros(id),
 FOREIGN KEY (id_leitor) REFERENCES Leitores(id)
);
INSERT INTO Emprestimos (id, id_livro, id_leitor, data_emprestimo, data_devolucao) VALUES
(501, 301, 401, '2025-05-01', '2025-05-10'),
(502, 304, 401, '2025-05-05', NULL),
(503, 303, 402, '2025-05-02', '2025-05-09');


-- FAÇA TODOS COM SUBCONSULTA
-- 1. Mostre o título e o ano de publicação dos livros cuja editora é “Companhia das Letras”. (subconsulta no Where)
SELECT Livros.titulo AS Livros, Livros.ano_publicacao AS Ano_Publicação
FROM Livros
WHERE id_editora = (SELECT id FROM Editoras WHERE nome = 'Companhia das Letras' );



-- 2. Liste os nomes dos autores que possuem livros da editora “Rocco”. (subconsulta no Where)
SELECT nome AS Autores
FROM Autores
WHERE id IN( SELECT id_autor FROM Livros WHERE id_editora = (SELECT id FROM Editoras WHERE nome = 'Rocco' )
);


-- 3. Mostre os títulos dos livros que foram emprestados por algum leitor com o nome “Ana Clara”. (subconsulta da subconsulta no Where)
SELECT titulo AS Livros
FROM Livros
WHERE Livros.id IN(
	SELECT Emprestimos.id_livro
    FROM Emprestimos
    WHERE Emprestimos.id_leitor =(
		SELECT leitores.id FROM leitores WHERE nome = ('Ana Clara')
    )
);

-- 4. Mostre os livros que ainda estão emprestados (sem data de devolução).A subconsulta deve retornar os IDs dos livros em aberto.
SELECT titulo AS Livros
FROM Livros
WHERE id IN (
	SELECT id_livro
    FROM Emprestimos
    WHERE data_devolucao IS NULL
);

-- 5. Mostre os nomes dos autores que escreveram livros que ainda estão emprestados (sem data de devolução). (subconsulta da subconsulta no Where)
SELECT nome AS Autores
FROM Autores
WHERE id IN (
	SELECT id_autor
    FROM Livros
    WHERE id IN (
	SELECT  id_livro
    FROM Emprestimos
    WHERE data_devolucao IS  NULL
	)
);
-- 6. Liste os nomes dos leitores que ainda têm livros emprestados.(subconsulta no Where)
SELECT nome AS Leitores
FROM Leitores
WHERE id IN (
	SELECT id_leitor
    FROM Emprestimos
);

-- 7. Mostre os nomes dos leitores e, ao lado, o nome do último livro que cada um pegou emprestado. (Mesmo que os dados estejam fixos, o foco é o uso no SELECT)
SELECT Leitores.nome AS Leitores, Livros.titulo As Livros
FROM Leitores
INNER JOIN Emprestimos ON Leitores.id = Emprestimos.id_leitor
INNER JOIN Livros ON Emprestimos.id_livro = Livros.id
WHERE Emprestimos.data_emprestimo = (
	SELECT MAX(Emprestimos.data_emprestimo) -- o max serve para pegar a maior data, no caso as ultima de cada id de leitor, ent se o leitor fez 2 empréstimos vai ser pegado a data com maior valor, a última.
    FROM Emprestimos
    WHERE Emprestimos.id_leitor = Leitores.id
);

-- 8. Liste os livros com o nome da editora ao lado, usando subconsulta no SELECT.
SELECT titulo AS Livros,
	(SELECT nome FROM Editoras WHERE Editoras.id = Livros.id_editora) AS Editora
FROM Livros;




-- O que é alias no SQL?
-- 	Alias é um apelido temporário que você dá para uma tabela, coluna, ou resultado de uma subconsulta, só para facilitar a leitura e referência na consulta.

-- Por que usar alias?
-- 	Para deixar os nomes mais curtos ou claros.
-- 	Para dar um nome para o resultado de uma subconsulta (obrigatório no FROM).
-- 	Para evitar confusão quando a mesma tabela aparece mais de uma vez na consulta.
-- 	Para deixar a query mais legível.

-- 9. Liste os nomes e títulos de livros emprestados atualmente, usando uma subconsulta no FROM.
SELECT 
    Emprestimos.Leitor, -- ALIAS
    Emprestimos.Livro -- ALIAS
FROM (
-- Aqui a gente faz o select certinho e afins
    SELECT 
        Leitores.nome AS Leitor, -- TEM QUE SER O MESMO NOME DO PRIMEIRO SELECT PARA ELE ENTENDER, É NECESSÁRIO USAR ALIAS
        Livros.titulo AS Livro -- TAMBÉM TEM QUE DEIXAR O MESMO NOME DO PRIMEIRO SELECT
    FROM Emprestimos
    INNER JOIN Leitores ON Emprestimos.id_leitor = Leitores.id
    INNER JOIN Livros ON Emprestimos.id_livro = Livros.id
) AS emprestimos;

-- 10. Mostre os nomes das editoras que publicaram livros emprestados, usando uma subconsulta no FROM.
SELECT Editoras.nome AS Editoras -- não é uma alias
-- selecionou a editora, onde o livro está no emprestado, faz o inner join para conseguir ligar as tabelas e chama todo esse fom de Subconsultinha, faz um INNER JOIN para ligar editora com todo o from
FROM (
    SELECT Livros.id_editora
    FROM Emprestimos
    INNER JOIN Livros ON Emprestimos.id_livro = Livros.id
) AS Subconsultinha
INNER JOIN Editoras ON Subconsultinha.id_editora = Editoras.id;
