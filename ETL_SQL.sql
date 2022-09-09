SELECT * FROM ids;
SELECT * FROM dados_mutuarios;
SELECT * FROM emprestimos;
SELECT * FROM historicos_banco;
SELECT DISTINCT propriedade_sit from dados_mutuarios;

--  Tradução de colunas da tabela ids.

ALTER TABLE ids
    CHANGE COLUMN person_id pessoa_id VARCHAR(16) NOT NULL,
    CHANGE COLUMN loan_id emprestimo_id VARCHAR(16) NOT NULL,
    CHANGE COLUMN cb_id hst_id VARCHAR(16) NOT NULL;
    
    
 --  Tradução de colunas da tabela dados_mutuarios.
ALTER TABLE dados_mutuarios
    CHANGE COLUMN person_id pessoa_id VARCHAR(16) NULL,
    CHANGE COLUMN person_age pessoa_idade INT NULL,
    CHANGE COLUMN person_income salario_ano INT NULL,
    CHANGE COLUMN person_home_ownership propriedade_sit VARCHAR(12),
    CHANGE COLUMN person_emp_length ano_trabalhado tinyint;


--  Tradução de conteudo da tabela dados_mutuarios.
UPDATE analise_risco.dados_mutuarios
SET propriedade_sit  =
    CASE
        WHEN propriedade_sit = 'Rent' THEN 'Alugada'
        WHEN propriedade_sit = 'Own' THEN 'Própria'
        WHEN propriedade_sit = 'Mortgage' THEN 'Hipotecada'
        WHEN propriedade_sit = 'Other' THEN 'Outros'
        WHEN propriedade_sit = '' THEN '-'
	END
;

--  Tradução de colunas da tabela emprestimos.
ALTER TABLE emprestimos
    CHANGE COLUMN loan_id emprestimo_id VARCHAR(16) NULL,
    CHANGE COLUMN loan_intent motivo_emprestimo VARCHAR(32),
    CHANGE COLUMN loan_grade pontuacao_emprestimos VARCHAR(1),
    CHANGE COLUMN loan_amnt vl_total int NULL,
    CHANGE COLUMN loan_int_rate tx_juros NUMERIC(10,2) NULL,
    CHANGE COLUMN loan_status inadimplencia BIT NULL,
    CHANGE COLUMN loan_percent_income tx_renda_divida NUMERIC(3,2);    

--  Tradução de conteudo da tabela emprestimos.
UPDATE analise_risco.emprestimos
SET motivo_emprestimo = 
    CASE
        WHEN motivo_emprestimo = 'Homeimprovement' THEN 'Melhora do lar'
        WHEN motivo_emprestimo = 'Venture'THEN 'Empreendimento'
        WHEN motivo_emprestimo = 'Personal'THEN 'Pessoal'
        WHEN motivo_emprestimo = 'Medical'THEN 'Médico'
        WHEN motivo_emprestimo = 'Education'THEN'Educativo'
        WHEN motivo_emprestimo = 'Debtconsolidation'THEN 'Pagamento de débitos'
        WHEN motivo_emprestimo =  ''THEN '-'
    END
;

--  Tradução de colunas da tabela historicos_banco.
--  Nesta tabela é necessário traduzir os dados primeiro irei trocar Y por 1 e N por 0 e então transformar em valor bit.
UPDATE analise_risco.historicos_banco 
SET 
    cb_person_default_on_file = CASE
        WHEN cb_person_default_on_file = 'Y' THEN '1'
        WHEN cb_person_default_on_file = 'N' THEN '0'
    END
;
--  Tradução de colunas da tabela historicos_banco.
ALTER TABLE historicos_banco
    CHANGE COLUMN cb_id hst_id VARCHAR(16),
    CHANGE COLUMN cb_person_default_on_file hst_inadimplencia BIT NULL,
    CHANGE COLUMN cb_person_cred_hist_length hst_primeiro_credito INT NULL;

-- Após tentar transformar pessoa_id em chave primária, foi identificado que há ids nulos
SELECT * FROM DADOS_MUTUARIOS where pessoa_id = '';

-- Remover as linhas duplicadas ja que não eram relevantes pois o id estava vazio.
DELETE FROM dados_mutuarios WHERE pessoa_id = '';

-- Chaves Primárias criadas..
ALTER TABLE dados_mutuarios ADD CONSTRAINT PK_Pessoa PRIMARY KEY (pessoa_id);
ALTER Table emprestimos ADD CONSTRAINT PK_Emprestimos PRIMARY KEY (emprestimo_id);
ALTER TABLE historicos_banco ADD CONSTRAINT PK_historicos PRIMARY KEY (hst_id);


-- Ao tentar criar as chaves estrangeiras, um erro aconteceu por haver inconsistência de dados entre as tabelas.
-- Haviam alguns registros na tabela ids que não estavam nas outras tabelas.
SELECT pessoa_id FROM ids
WHERE pessoa_id not in (select pessoa_id from dados_mutuarios);
-- Deletando os dados
DELETE FROM ids WHERE pessoa_id = '';



--  Chaves Estrangeiras criadas.
ALTER TABLE ids ADD FOREIGN KEY (pessoa_id) REFERENCES dados_mutuarios(pessoa_id);
ALTER TABLE ids ADD FOREIGN KEY (emprestimo_id) REFERENCES emprestimos(emprestimo_id);
ALTER TABLE ids ADD FOREIGN KEY (hst_id) REFERENCES historicos_banco(hst_id);


    

    

-- Criando uma tabela unindo os dados
CREATE TABLE dados_juntos AS SELECT 

dm.pessoa_idade,
dm.salario_ano,
dm.propriedade_sit,
dm.ano_trabalhado,
e.motivo_emprestimo,
e.pontuacao_emprestimos,
e.vl_total,
e.tx_juros,
e.inadimplencia,
e.tx_renda_divida,
hb.hst_inadimplencia,
hb.hst_primeiro_credito

FROM ids i

JOIN dados_mutuarios dm ON dm.pessoa_id = i.pessoa_id 
JOIN emprestimos e ON e.emprestimo_id = i.emprestimo_id 
join historicos_banco hb ON hb.hst_id = i.hst_id;

SELECT * FROM dados_juntos;







