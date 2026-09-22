-- ========================================
-- DELIVERY SUS - BANCO DE DADOS
-- Sistema de Entrega de Medicamentos
-- ========================================

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS delivery_sus;
USE delivery_sus;

-- ========================================
-- TABELA: USUARIOS
-- ========================================
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    condicao_mobilidade ENUM('idoso', 'deficiencia', 'mobilidade_reduzida', 'tratamento') NOT NULL,
    notificacoes BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    INDEX idx_cpf (cpf),
    INDEX idx_email (email)
);

-- ========================================
-- TABELA: ENDERECOS
-- ========================================
CREATE TABLE enderecos (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    cep VARCHAR(10) NOT NULL,
    rua VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(50),
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    referencia VARCHAR(200),
    endereco_principal BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);

-- ========================================
-- TABELA: UBS (Unidades Básicas de Saúde)
-- ========================================
CREATE TABLE ubs (
    id_ubs INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    telefone VARCHAR(20),
    horario_funcionamento VARCHAR(100),
    ativa BOOLEAN DEFAULT TRUE
);

-- ========================================
-- TABELA: MEDICAMENTOS
-- ========================================
CREATE TABLE medicamentos (
    id_medicamento INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    dosagem VARCHAR(50),
    quantidade_estoque INT DEFAULT 0,
    estoque_minimo INT DEFAULT 10,
    ativo BOOLEAN DEFAULT TRUE,
    INDEX idx_nome (nome)
);

-- ========================================
-- TABELA: MEDICAMENTOS_UBS (Relação M:N)
-- ========================================
CREATE TABLE medicamentos_ubs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_medicamento INT NOT NULL,
    id_ubs INT NOT NULL,
    quantidade_disponivel INT DEFAULT 0,
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento) ON DELETE CASCADE,
    FOREIGN KEY (id_ubs) REFERENCES ubs(id_ubs) ON DELETE CASCADE,
    UNIQUE KEY unique_med_ubs (id_medicamento, id_ubs)
);

-- ========================================
-- TABELA: SOLICITACOES
-- ========================================
CREATE TABLE solicitacoes (
    id_solicitacao INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_medicamento INT NOT NULL,
    id_ubs INT NOT NULL,
    quantidade INT NOT NULL,
    observacoes TEXT,
    data_solicitacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('aguardando', 'aprovada', 'em_separacao', 'em_entrega', 'entregue', 'cancelada') DEFAULT 'aguardando',
    data_aprovacao TIMESTAMP NULL,
    aprovado_por VARCHAR(100),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento),
    FOREIGN KEY (id_ubs) REFERENCES ubs(id_ubs),
    INDEX idx_status (status),
    INDEX idx_data (data_solicitacao)
);

-- ========================================
-- TABELA: ENTREGADORES
-- ========================================
CREATE TABLE entregadores (
    id_entregador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    veiculo VARCHAR(50),
    placa VARCHAR(10),
    ativo BOOLEAN DEFAULT TRUE
);

-- ========================================
-- TABELA: ENTREGAS
-- ========================================
CREATE TABLE entregas (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitacao INT NOT NULL,
    id_entregador INT NOT NULL,
    data_saida TIMESTAMP NULL,
    data_entrega TIMESTAMP NULL,
    codigo_confirmacao VARCHAR(10) NOT NULL,
    status ENUM('preparando', 'em_transito', 'entregue', 'falhou') DEFAULT 'preparando',
    observacoes_entrega TEXT,
    assinatura_recebimento VARCHAR(255),
    FOREIGN KEY (id_solicitacao) REFERENCES solicitacoes(id_solicitacao) ON DELETE CASCADE,
    FOREIGN KEY (id_entregador) REFERENCES entregadores(id_entregador),
    INDEX idx_codigo (codigo_confirmacao)
);

-- ========================================
-- TABELA: HISTORICO_STATUS
-- ========================================
CREATE TABLE historico_status (
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitacao INT NOT NULL,
    status_anterior VARCHAR(50),
    status_novo VARCHAR(50) NOT NULL,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacao TEXT,
    FOREIGN KEY (id_solicitacao) REFERENCES solicitacoes(id_solicitacao) ON DELETE CASCADE
);

-- ========================================
-- TABELA: ADMINISTRADORES
-- ========================================
CREATE TABLE administradores (
    id_admin INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    nivel ENUM('admin', 'ubs', 'farmaceutico') DEFAULT 'ubs',
    id_ubs INT,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_ubs) REFERENCES ubs(id_ubs) ON DELETE SET NULL
);

-- ========================================
-- INSERÇÃO DE DADOS INICIAIS
-- ========================================

-- UBS
INSERT INTO ubs (nome, endereco, telefone, horario_funcionamento) VALUES
('UBS Pioneiras', 'Rua das Pioneiras, 123 - Campo Grande/MS', '(67) 3321-1234', 'Segunda a Sexta: 7h às 17h'),
('UBS Botafogo', 'Av. Botafogo, 456 - Campo Grande/MS', '(67) 3321-5678', 'Segunda a Sexta: 7h às 17h');

-- Medicamentos
INSERT INTO medicamentos (nome, descricao, dosagem, quantidade_estoque) VALUES
('Losartana', 'Anti-hipertensivo', '50mg', 500),
('Metformina', 'Antidiabético', '850mg', 300),
('Sinvastatina', 'Redutor de colesterol', '20mg', 250),
('Omeprazol', 'Protetor gástrico', '20mg', 400),
('Captopril', 'Anti-hipertensivo', '25mg', 350),
('Paracetamol', 'Analgésico e antipirético', '500mg', 600),
('Amoxicilina', 'Antibiótico', '500mg', 200),
('Dipirona', 'Analgésico', '500mg', 450);

-- Medicamentos disponíveis nas UBS
INSERT INTO medicamentos_ubs (id_medicamento, id_ubs, quantidade_disponivel) VALUES
(1, 1, 250), (1, 2, 250),
(2, 1, 150), (2, 2, 150),
(3, 1, 125), (3, 2, 125),
(4, 1, 200), (4, 2, 200),
(5, 1, 175), (5, 2, 175),
(6, 1, 300), (6, 2, 300),
(7, 1, 100), (7, 2, 100),
(8, 1, 225), (8, 2, 225);

-- Entregadores
INSERT INTO entregadores (nome, cpf, telefone, veiculo, placa) VALUES
('Carlos Silva', '123.456.789-00', '(67) 99999-1111', 'Moto Honda CG', 'ABC-1234'),
('Maria Santos', '987.654.321-00', '(67) 99999-2222', 'Moto Yamaha Factor', 'XYZ-5678'),
('João Oliveira', '456.789.123-00', '(67) 99999-3333', 'Moto Honda Biz', 'DEF-9012');

-- Administrador padrão
INSERT INTO administradores (nome, email, senha, nivel) VALUES
('Admin Sistema', 'admin@deliverysus.com.br', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');
-- Senha: password (use hash real em produção)

-- ========================================
-- VIEWS ÚTEIS
-- ========================================

-- View: Solicitações com detalhes
CREATE VIEW vw_solicitacoes_detalhadas AS
SELECT 
    s.id_solicitacao,
    u.nome_completo AS usuario,
    u.telefone,
    m.nome AS medicamento,
    s.quantidade,
    ubs.nome AS ubs,
    s.data_solicitacao,
    s.status,
    e.data_entrega,
    ent.nome AS entregador
FROM solicitacoes s
JOIN usuarios u ON s.id_usuario = u.id_usuario
JOIN medicamentos m ON s.id_medicamento = m.id_medicamento
JOIN ubs ON s.id_ubs = ubs.id_ubs
LEFT JOIN entregas e ON s.id_solicitacao = e.id_solicitacao
LEFT JOIN entregadores ent ON e.id_entregador = ent.id_entregador;

-- View: Estoque baixo
CREATE VIEW vw_estoque_baixo AS
SELECT 
    m.nome AS medicamento,
    m.quantidade_estoque,
    m.estoque_minimo,
    ubs.nome AS ubs,
    mu.quantidade_disponivel
FROM medicamentos m
JOIN medicamentos_ubs mu ON m.id_medicamento = mu.id_medicamento
JOIN ubs ON mu.id_ubs = ubs.id_ubs
WHERE mu.quantidade_disponivel <= m.estoque_minimo;

-- ========================================
-- PROCEDURES
-- ========================================

-- Procedure: Criar nova solicitação
DELIMITER //
CREATE PROCEDURE sp_criar_solicitacao(
    IN p_id_usuario INT,
    IN p_id_medicamento INT,
    IN p_id_ubs INT,
    IN p_quantidade INT,
    IN p_observacoes TEXT
)
BEGIN
    DECLARE v_estoque INT;
    
    -- Verificar estoque
    SELECT quantidade_disponivel INTO v_estoque
    FROM medicamentos_ubs
    WHERE id_medicamento = p_id_medicamento AND id_ubs = p_id_ubs;
    
    IF v_estoque >= p_quantidade THEN
        -- Criar solicitação
        INSERT INTO solicitacoes (id_usuario, id_medicamento, id_ubs, quantidade, observacoes)
        VALUES (p_id_usuario, p_id_medicamento, p_id_ubs, p_quantidade, p_observacoes);
        
        SELECT 'Solicitação criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Estoque insuficiente!' AS mensagem;
    END IF;
END //
DELIMITER ;

-- Procedure: Aprovar solicitação
DELIMITER //
CREATE PROCEDURE sp_aprovar_solicitacao(
    IN p_id_solicitacao INT,
    IN p_aprovado_por VARCHAR(100)
)
BEGIN
    UPDATE solicitacoes
    SET status = 'aprovada',
        data_aprovacao = NOW(),
        aprovado_por = p_aprovado_por
    WHERE id_solicitacao = p_id_solicitacao;
    
    -- Registrar histórico
    INSERT INTO historico_status (id_solicitacao, status_anterior, status_novo)
    VALUES (p_id_solicitacao, 'aguardando', 'aprovada');
END //
DELIMITER ;

-- ========================================
-- TRIGGERS
-- ========================================

-- Trigger: Atualizar estoque após aprovação
DELIMITER //
CREATE TRIGGER trg_atualizar_estoque_aprovacao
AFTER UPDATE ON solicitacoes
FOR EACH ROW
BEGIN
    IF NEW.status = 'aprovada' AND OLD.status = 'aguardando' THEN
        UPDATE medicamentos_ubs
        SET quantidade_disponivel = quantidade_disponivel - NEW.quantidade
        WHERE id_medicamento = NEW.id_medicamento 
        AND id_ubs = NEW.id_ubs;
    END IF;
END //
DELIMITER ;

-- ========================================
-- ÍNDICES ADICIONAIS PARA PERFORMANCE
-- ========================================
CREATE INDEX idx_usuario_status ON solicitacoes(id_usuario, status);
CREATE INDEX idx_medicamento_ubs ON medicamentos_ubs(id_medicamento, id_ubs);
CREATE INDEX idx_data_entrega ON entregas(data_entrega);

-- ========================================
-- FIM DO SCRIPT
-- ========================================