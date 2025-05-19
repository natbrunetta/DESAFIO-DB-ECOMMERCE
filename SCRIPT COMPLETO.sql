-- criação do banco de dados para cenario de E-commerce

create database ecommerce;

use ecommerce;

-- criando tabela clientes
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    tipo ENUM('PF', 'PJ') NOT NULL,
    CNAME VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    endereco VARCHAR(45)
);


-- criando tabela clientes_PF (tabela herança)
CREATE TABLE clientes_pf (
    id_cliente INT PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    data_nascimento DATE,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- criando tabela clientes_PJ (tabela herança)

CREATE TABLE clientes_pj (
    id_cliente INT PRIMARY KEY,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    inscricao_estadual VARCHAR(20),
    nome_fantasia VARCHAR(100),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);


-- criando tabela produto
CREATE TABLE produtos (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(50) NOT NULL, 
    tamanho VARCHAR(10),            
    preco DECIMAL(10,2) NOT NULL
    );


-- criando tabela pedido
CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- status do pedido (pode ser uma tabela separada para mais flexibilidade)
    status ENUM(
        'PENDENTE', 
        'PROCESSANDO', 
        'ENVIADO', 
        'ENTREGUE', 
        'CANCELADO', 
        'DEVOLVIDO'
    ) DEFAULT 'PENDENTE',
    
    -- Informações de entrega
    status_entrega ENUM(
        'PREPARANDO_ENVIO',
        'ENVIADO',
        'EM_TRANSITO',
        'ENTREGUE',
        'DEVOLVIDO',
        'EXTRAVIADO'
    ) DEFAULT 'PREPARANDO_ENVIO',
    
    codigo_rastreio VARCHAR(50), -- Código único fornecido pela transportadora
    data_envio DATE,
    data_entrega_estimada DATE,
    data_entrega_real DATE,
    
    -- Informações de frete
    valor_frete DECIMAL(10,2) NOT NULL DEFAULT 0,
    tipo_frete ENUM('CORREIOS', 'TRANSPORTADORA', 'RETIRADA') NOT NULL,
    
    -- Informações adicionais
    descricao TEXT, -- Observações do pedido
    subtotal DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(10,2) DEFAULT 0,
    valor_total DECIMAL(10,2) NOT NULL,
    
    -- Chaves estrangeiras
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Tabela de Itens do Pedido (relacionamento com produtos)
CREATE TABLE pedido_itens (
    id_item INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,
    desconto_unitario DECIMAL(10,2) DEFAULT 0,
    total_item DECIMAL(10,2) AS (quantidade * (preco_unitario - desconto_unitario)),
    
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);


CREATE TABLE pagamentos (
    id_pagamento INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_cliente INT NOT NULL,  -- Nova FK para clientes
    forma_pagamento ENUM('CARTAO', 'BOLETO', 'PIX', 'TRANSFERENCIA') NOT NULL,
    status ENUM('PENDENTE', 'PROCESSANDO', 'APROVADO', 'RECUSADO', 'ESTORNADO') DEFAULT 'PENDENTE',
    valor DECIMAL(10,2) NOT NULL,
    data_pagamento DATETIME,
    codigo_transacao VARCHAR(100), -- ID da transação no gateway de pagamento
    
    -- Para cartão de crédito
    parcelas INT DEFAULT 1,
    ultimos_digitos VARCHAR(4),
    nome_titular VARCHAR(100), -- Nome do titular do cartão (se aplicável)
    
    -- Chaves estrangeiras
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);




-- criando tabela estoque
CREATE TABLE estoque (
    id_estoque INT PRIMARY KEY AUTO_INCREMENT,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    localizacao VARCHAR(100) NOT NULL COMMENT 'Local físico do estoque (prateleira, depósito, loja)',
    lote VARCHAR(50) COMMENT 'Número do lote do produto',
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto) ON DELETE CASCADE
);

-- criando tabela fornecedor

CREATE TABLE fornecedores (
    id_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    nome_fantasia VARCHAR(100) NOT NULL,
    razao_social VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    inscricao_estadual VARCHAR(20),
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado CHAR(2) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- criando tabela de Relacionamento Fornecedor-Produto (Muitos para Muitos)
CREATE TABLE fornecedor_produtos (
    id_fornecedor INT NOT NULL,
    id_produto INT NOT NULL,
    codigo_fornecedor VARCHAR(50) COMMENT 'Código do produto no fornecedor',
    preco_custo DECIMAL(10,2) NOT NULL,
    prazo_entrega INT COMMENT 'Prazo em dias',
    PRIMARY KEY (id_fornecedor, id_produto),
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor) ON DELETE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto) ON DELETE CASCADE
);


-- criando tabela vendedor - terceiros (venda no ecommerce) 

-- Tabela de Vendedores Terceiros
CREATE TABLE VENDEDORES_TERCEIROS (
    id_vendedor INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(100),
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    inscricao_estadual VARCHAR(20),
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL
);

-- Tabela de Relacionamento Vendedor-Produto
CREATE TABLE vendedor_produtos (
    id_relacao INT PRIMARY KEY AUTO_INCREMENT,
    id_vendedor INT NOT NULL,
    id_produto INT NOT NULL,
    preco_vendedor DECIMAL(10,2) NOT NULL COMMENT 'Preço definido pelo vendedor',
    estoque_disponivel INT NOT NULL DEFAULT 0,
    status ENUM('ATIVO', 'INATIVO', 'ESGOTADO') DEFAULT 'ATIVO',
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_vendedor_produto (id_vendedor, id_produto),
    FOREIGN KEY (id_vendedor) REFERENCES VENDEDORES_TERCEIROS(id_vendedor) ON DELETE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto) ON DELETE CASCADE
);

-- adicionando valores as tabelas 

INSERT INTO clientes (tipo, CNAME, email, telefone, endereco) VALUES
('PF', 'João Silva', 'joao.silva@email.com', '(11) 99999-9999', 'Rua das Flores, 123 - São Paulo/SP'),
('PF', 'Maria Oliveira', 'maria.oliveira@email.com', '(21) 98888-8888', 'Av. Brasil, 456 - Rio de Janeiro/RJ'),
('PJ', 'Tech Solutions Ltda', 'contato@techsolutions.com', '(31) 97777-7777', 'Rua da Inovação, 789 - Belo Horizonte/MG'),
('PJ', 'Moda Fashion S.A.', 'vendas@modafashion.com.br', '(41) 96666-6666', 'Alameda Shopping, 101 - Curitiba/PR');

INSERT INTO clientes_pf (id_cliente, cpf, data_nascimento) VALUES
(1, '123.456.789-01', '1985-05-15'),
(2, '987.654.321-09', '1990-08-22');

INSERT INTO clientes_pj (id_cliente, cnpj, inscricao_estadual, nome_fantasia) VALUES
(3, '12.345.678/0001-99', '123456789', 'Tech Solutions'),
(4, '98.765.432/0001-11', '987654321', 'Moda Fashion');

INSERT INTO produtos (nome, descricao, categoria, tamanho, preco) VALUES
('Smartphone Galaxy S21', 'Smartphone Samsung Galaxy S21 128GB', 'Eletrônicos', NULL, 3499.99),
('Camiseta Básica Branca', 'Camiseta 100% algodão, gola redonda', 'Vestuário', 'M', 49.90),
('Notebook Dell Inspiron', 'Notebook Dell Inspiron 15, i5, 8GB RAM, 256GB SSD', 'Eletrônicos', NULL, 4299.00),
('Tênis Esportivo', 'Tênis para corrida, amortecimento premium', 'Calçados', '42', 299.90);


INSERT INTO pedidos (id_cliente, status, status_entrega, codigo_rastreio, data_envio, data_entrega_estimada, valor_frete, tipo_frete, subtotal, desconto, valor_total) VALUES
(1, 'ENTREGUE', 'ENTREGUE', 'BR123456789', '2023-05-10', '2023-05-15', 15.00, 'CORREIOS', 3499.99, 0, 3514.99),
(2, 'ENVIADO', 'EM_TRANSITO', 'BR987654321', '2023-05-12', '2023-05-18', 12.50, 'CORREIOS', 99.80, 0, 112.30),
(3, 'PROCESSANDO', 'PREPARANDO_ENVIO', NULL, NULL, NULL, 0, 'RETIRADA', 4299.00, 200.00, 4099.00),
(4, 'PENDENTE', 'PREPARANDO_ENVIO', NULL, NULL, NULL, 25.00, 'TRANSPORTADORA', 299.90, 0, 324.90);

INSERT INTO pedido_itens (id_pedido, id_produto, quantidade, preco_unitario, desconto_unitario) VALUES
(1, 1, 1, 3499.99, 0),
(2, 2, 2, 49.90, 0),
(3, 3, 1, 4299.00, 200.00),
(4, 4, 1, 299.90, 0);

INSERT INTO pagamentos (id_pedido, id_cliente, forma_pagamento, status, valor, data_pagamento, codigo_transacao, parcelas, ultimos_digitos, nome_titular) VALUES
(1, 1, 'CARTAO', 'APROVADO', 3514.99, '2023-05-09 14:30:22', 'PAG123456', 3, '1234', 'João Silva'),
(2, 2, 'PIX', 'APROVADO', 112.30, '2023-05-11 09:15:47', 'PIX987654', 1, NULL, NULL),
(3, 3, 'BOLETO', 'PENDENTE', 4099.00, NULL, 'BOL123456', 1, NULL, NULL),
(4, 4, 'CARTAO', 'PROCESSANDO', 324.90, '2023-05-13 16:45:12', 'PAG654321', 1, '4321', 'Moda Fashion S.A.');

INSERT INTO estoque (id_produto, quantidade, localizacao, lote) VALUES
(1, 15, 'Prateleira A1', 'LOTE20230501'),
(2, 50, 'Prateleira B3', 'LOTE20230415'),
(3, 8, 'Depósito Central', 'LOTE20230505'),
(4, 20, 'Prateleira C2', 'LOTE20230420');

INSERT INTO fornecedores (nome_fantasia, razao_social, cnpj, inscricao_estadual, email, telefone, endereco, cidade, estado, cep) VALUES
('EletroTech', 'EletroTech Comércio de Eletrônicos Ltda', '11.111.111/0001-11', '111111111', 'contato@eletrotech.com.br', '(11) 2222-2222', 'Av. Paulista, 1000', 'São Paulo', 'SP', '01310-100'),
('Malhas & Cia', 'Malhas e Confecções Ltda', '22.222.222/0001-22', '222222222', 'vendas@malhasecia.com.br', '(21) 3333-3333', 'Rua da Alfândega, 200', 'Rio de Janeiro', 'RJ', '20070-020'),
('InfoDistribuidora', 'Info Distribuidora de Informática S.A.', '33.333.333/0001-33', '333333333', 'compras@infodist.com.br', '(31) 4444-4444', 'Av. Amazonas, 500', 'Belo Horizonte', 'MG', '30180-001'),
('Calçados Premium', 'Calçados Premium Indústria e Comércio Ltda', '44.444.444/0001-44', '444444444', 'sac@calcpremium.com.br', '(41) 5555-5555', 'Rua das Araucárias, 300', 'Curitiba', 'PR', '80010-010');


INSERT INTO VENDEDORES_TERCEIROS (razao_social, nome_fantasia, cnpj, inscricao_estadual, email, telefone) VALUES
('Tech Importação Ltda', 'Tech Import', '55.555.555/0001-55', '555555555', 'vendas@techimport.com.br', '(11) 6666-6666'),
('Moda Jovem ME', 'Moda Jovem', '66.666.666/0001-66', '666666666', 'contato@modajovem.com.br', '(21) 7777-7777'),
('Eletro Distribuidora S.A.', 'EletroDist', '77.777.777/0001-77', '777777777', 'comercial@eletrodist.com.br', '(31) 8888-8888'),
('Esportes & Aventura Ltda', 'Esportes Aventura', '88.888.888/0001-88', '888888888', 'sac@esportesaventura.com.br', '(41) 9999-9999');

INSERT INTO vendedor_produtos (id_vendedor, id_produto, preco_vendedor, estoque_disponivel, status) VALUES
(1, 1, 3299.99, 10, 'ATIVO'),
(2, 2, 54.90, 30, 'ATIVO'),
(3, 3, 4199.00, 5, 'ATIVO'),
(4, 4, 279.90, 15, 'ATIVO');



-- QUERIES

-- queries basicas de select statement 
SELECT * FROM clientes;

SELECT * FROM produtos;

SELECT CNAME, email FROM clientes;

SELECT * FROM vendedor_produtos;

-- PERGUNTAS 

-- Clientes pessoa física cadastrados após 01/01/2023
SELECT * FROM clientes 
WHERE tipo = 'PF' AND data_cadastro > '2023-01-01';

-- Produtos com preço acima da média
SELECT * FROM produtos 
WHERE preco > (SELECT AVG(preco) FROM produtos);

-- Vendedores com mais de 5 produtos cadastrados

SELECT v.id_vendedor, v.nome_fantasia, COUNT(*) as total_produtos
FROM VENDEDORES_TERCEIROS v
JOIN vendedor_produtos vp ON v.id_vendedor = vp.id_vendedor
GROUP BY v.id_vendedor, v.nome_fantasia
HAVING COUNT(*) > 5;


-- Clientes que NÃO são de São Paulo (analisando endereço)
SELECT * FROM clientes 
WHERE endereco NOT LIKE '%/SP' AND endereco NOT LIKE '%São Paulo%';



-- Disponibilidade de produtos por vendedor
SELECT 
    v.id_vendedor,
    v.nome_fantasia,
    COUNT(*) AS total_produtos_cadastrados,
    SUM(CASE WHEN vp.estoque_disponivel > 0 THEN 1 ELSE 0 END) AS produtos_disponiveis,
    CONCAT(ROUND(SUM(CASE WHEN vp.estoque_disponivel > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2), '%') AS percentual_disponivel
FROM VENDEDORES_TERCEIROS v
JOIN vendedor_produtos vp ON v.id_vendedor = vp.id_vendedor
GROUP BY v.id_vendedor, v.nome_fantasia;

-- Clientes ordenados por nome crescente
SELECT id_cliente, CNAME, email, data_cadastro
FROM clientes
ORDER BY CNAME ASC;

-- Produtos mais caros primeiro, depois por nome
SELECT id_produto, nome, categoria, preco
FROM produtos
ORDER BY preco DESC, nome ASC;

-- Produtos com estoque abaixo de 10 unidades
SELECT p.id_produto, p.nome, SUM(e.quantidade) AS total_estoque
FROM produtos p
JOIN estoque e ON p.id_produto = e.id_produto
GROUP BY p.id_produto, p.nome
HAVING SUM(e.quantidade) < 10;

-- Lista de clientes com seus pedidos
SELECT c.CNAME AS cliente, p.id_pedido, p.data_pedido, p.valor_total
FROM clientes c
JOIN pedidos p ON c.id_cliente = p.id_cliente
ORDER BY c.CNAME, p.data_pedido DESC;

-- Detalhes dos itens de um pedido específico
SELECT p.nome AS produto, pi.quantidade, pi.preco_unitario, pi.total_item
FROM pedido_itens pi
JOIN produtos p ON pi.id_produto = p.id_produto
WHERE pi.id_pedido = 1;

-- Pedidos e suas formas de pagamento
SELECT p.id_pedido, c.CNAME AS cliente, pg.forma_pagamento, pg.status, pg.valor
FROM pedidos p
JOIN clientes c ON p.id_cliente = c.id_cliente
JOIN pagamentos pg ON p.id_pedido = pg.id_pedido
ORDER BY p.data_pedido DESC;