create database if not exists sprint1;

use sprint1;

create table usuario(
	id_usuario int primary key auto_increment,
	nome varchar(150) not null,
	email varchar(150) not null,
	senha_hash varchar(150) not null,
	empresa_id int,
	-- idEmpresa seria uma foreign key que ligaria com a empresa
	contato varchar(20),
	data_criacao datetime default current_timestamp,
	data_modificacao datetime default current_timestamp
) auto_increment = 1000;

create table empresa(
	id_empresa int primary key auto_increment,
	razao_social varchar(150) not null unique,
	nome_fantasia varchar(150) not null,
	cnpj varchar(14) not null unique,
	enderecoId int,
	-- enderecoId seria uma foreign key que ligaria a empresa com a table endereço
	contato varchar(16),
	id_usuario int,
	-- usuarioId seria uma foreign key que ligaria com o usuario
	data_criacao datetime default current_timestamp,
	data_atualizacao datetime default current_timestamp
) auto_increment = 1000;

CREATE TABLE bloco (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    empresa INT NOT NULL,
    nome_ambiente VARCHAR(50) NOT NULL,
    tipo VARCHAR(50) CHECK(tipo IN ('entrada', 'saida', 'ambiente')),
	data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao DATETIME DEFAULT CURRENT_TIMESTAMP
);

create table sensor(
	id_sensor int primary key auto_increment,
	descricao varchar(150),
	bloco_id int,
	-- blocoId seria uma foreign key que ligaria os sensores com os blocos
	data_criacao datetime default current_timestamp,
	data_atualizacao datetime default current_timestamp
);

create table sensor_evento(
	id_evento int primary key auto_increment,
	detectado tinyint(1) not null,
	duracao time,
	data_evento datetime default current_timestamp,
	data_atualizacao datetime default current_timestamp,
	sensor_id int
);
-- sensorId seria uma foreign key que ligaria o evento ao sensor ativou

create table alerta (
	id_alerta int primary key auto_increment,
	descricao varchar(150) not null,
	tipo varchar(40) check(tipo in('baixa movimentação', 'movimentação moderada', 'alta movimentação')),
	sensor_id int,
	-- sensorId seria uma foreign key que ligaria o alerta ao sensor que ativou
	data_alerta datetime default current_timestamp,
	data_atualizacao datetime default current_timestamp
);

create table endereco(
	id_endereco int primary key auto_increment,
	cep char(9) not null,
	numero int not null,
	complemento varchar(45),
	logradouro varchar(150) not null,
	bairro varchar(150) not null,
	cidade varchar(150) not null,
	estado char(2) not null,
	pais varchar(150) not null
);


-- INSERT

	-- Usuario insert
insert into usuario (nome, email, senha_hash, empresaId, contato)
values
('Carlos Mendes', 'carlos@techmonitor.com', 'hash123', 1000, '11999998888'),
('Ana Silva', 'ana@safesensors.com', 'hash456', 1001, '11988887777'),
('Lucas Pereira', 'lucas@datavision.com', 'hash789', 1002, '11977776666');

	-- Empresa insert
insert into endereco (cep, numero, complemento, logradouro, bairro, cidade, estado, pais)
values
('01234-567', 123, 'Loja 1', 'Rua Exemplo', 'Centro', 'São Paulo', 'SP', 'Brasil'),
('09876-543', 456, null, 'Avenida Teste', 'Vila Mariana', 'São Paulo', 'SP', 'Brasil'),
('04567-890', 789, 'Andar 2', 'Rua Fictícia', 'Moema', 'São Paulo', 'SP', 'Brasil');


	-- Bloco insert
insert into bloco (empresa, nome_ambiente, tipo)
values
(1000, 'Entrada Principal', 'entrada'),
(1000, 'Corredor Administrativo', 'ambiente'),
(1000, 'Saída de Emergência', 'saida'),
(1001, 'Entrada Visitantes', 'entrada'),
(1001, 'Sala de Reunião', 'ambiente'),
(1001, 'Saída Funcionários', 'saida'),
(1002, 'Portão Estacionamento', 'entrada'),
(1002, 'Área de Estoque', 'ambiente'),
(1002, 'Saída Carga', 'saida');

	-- Sensor insert
insert into sensor (descricao, blocoId)
values
('Sensor corredor principal', 1),
('Sensor entrada prédio', 1),
('Sensor sala reunião', 2),
('Sensor estoque', 3),
('Sensor estacionamento', 3);

	-- Sensor evento insert
insert into sensor_evento (detectado, quantoTempo, data_evento, sensorId)
values
(1, '00:03:15', '2026-10-11 13:05:20', 1),
(0, '00:01:10', '2026-10-11 13:15:40', 1),
(1, '00:05:20', '2026-10-11 13:22:11', 2),
(0, '00:02:00', '2026-10-11 13:33:05', 3),
(1, '00:07:45', '2026-10-11 11:45:00', 2),
(1, '00:04:20', '2026-10-11 12:10:32', 4),
(0, '00:02:30', '2026-10-11 14:20:15', 5),
(1, '00:06:10', '2026-10-11 14:50:40', 3),
(0, '00:01:55', '2026-10-11 15:10:11', 1);

	-- Alerta insert
insert into alerta (descricao, tipo, sensorId)
values
('Pouca movimentação detectada no corredor', 'baixa movimentação', 1),
('Movimentação normal na entrada', 'movimentação moderada', 2),
('Alta movimentação no estoque', 'alta movimentação', 4),
('Baixa movimentação estacionamento', 'baixa movimentação', 5);


-- QUERY

-- Mostra o endereço de todas as unidades no estado de São Paulo
select * from endereco where cidade = 'SP';

/* Mostra a atividade dos sensores durante uma hora*/
select 
	data_evento,
    quanto_tempo,
    case
		when detectado = 1 then 'Tem alguém'
		when detectado = 0 then 'Não tem ninguém'
	end as 'detecção'
from sensor_evento
where 
	data_evento between "2026-10-11 13:00:00" and "2026-10-11 13:59:59" 
order by data_evento;

/* Mostrar quanto tempo cada sensor detectou presença durante o dia inteiro,
para saber as areas que tiveram mais movimento*/
select 
	data_evento, 
    quanto_tempo 
from sensor_evento 
where 
	data_evento between '2026-10-11 00:00:00' and '2026-10-11 23:59:59' 
and 
	detectado = 1 
order by quanto_tempo; 

/* Mostrar quanto tempo cada sensor ficou sem detectar presença durante o dia inteiro,
para saber as areas que tiveram menos movimento*/
select 
	data_evento, 
    quanto_tempo 
from sensor_evento 
where 
	data_evento between '2026-10-11 00:00:00' and '2026-10-11 23:59:59' 
and 
	detectado = 0
order by quanto_tempo;

/* Mostrar quanto tempo cada sensor detectou presença durante um periodo de tempo (como a hora do almoço)*/
select 
	data_evento, 
    quanto_tempo
from sensor_evento
where
	DATE(data_evento) = '2026-10-11'
and
    HOUR(data_evento) between '11:00:00' and '14:59:59'
and
	detectado = 1
order by quanto_tempo desc;

-- Mostra nome, email e empresa de todos os usuários
select 
	nome, 
	email, 
	empresa_id 
from usuario;

-- Mostra cnpj, nome fantasia e endereço de todos os restaurantes cadastrados
select 
	cnpj, 
    nome_fantasia, 
    enderecoId 
from empresa;