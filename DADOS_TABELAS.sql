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



