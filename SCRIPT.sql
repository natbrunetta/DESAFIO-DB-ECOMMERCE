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

