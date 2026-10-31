-- Databricks notebook source
-- DBTITLE 1,Visualizando Tabelas
select * from matches;

select * from performance;

select * from playingtime;

select * from p_perf;

select * from p_matches;

select * from partidas
order by 1;

-- COMMAND ----------

-- DBTITLE 1,Tratamento de Dados Nulos/Duplicados/Incorretos
delete from matches
where Result is null;

update matches
set Notes = "-"
where Notes is null;

delete from performance
where MP = 0;

delete from playingtime
where MP = 0;

alter table matches drop column `Match Report`;

update matches
set Opponent = 'Barracas Central'
where Opponent = 'ar Barracas Central';

update matches
set Opponent = 'Ind. Medellín'
where Opponent = 'co Ind. Medellín';

update matches
set Opponent = 'Olimpia'
where Opponent = 'py Olimpia';

update matches
set Opponent = 'Audax Italiano'
where Opponent = 'cl Audax Italiano';

update matches
set Opponent = 'Santa Fe'
where Opponent = 'co Santa Fe';

update matches
set Opponent = 'Boca Juniors'
where Opponent = 'ar Boca Juniors';

update partidas
set resultado = "E"
where resultado = "D";

update partidas
set resultado = "V"
where resultado = "W";

update partidas
set resultado = "D"
where resultado = "L";

select resultado
from partidas
where resultado = "L";

update partidas
set mando_de_campo = "Casa"
where mando_de_campo = "Home";

update partidas
set mando_de_campo = "Fora"
where mando_de_campo = "Away";

insert into matches values('2026-10-24','18:30','Série A','Matchweek 32','Wed','Home','W','3','2','Corinthians','64','19048','Thiago Mendes','4-2-3-1','4-2-3-1','Wilton Pereira Sampaio','-');

insert into partidas values('2026-04-21','21:30','Copa do Brasil','5ª Fase','Tue','Fora','V','2','0','Paysandu','58','25933','Thiago Mendes','4-2-3-1','4-2-3-1','Ramon Abatti Abel');

insert into partidas values('2026-05-13','19:00','Copa do Brasil','5ª Fase','Sat','Casa','E','2','2','Paysandu','48','16653','Thiago Mendes','4-2-3-1','4-2-3-1','Braulio da Silva Machado');

insert into partidas values('2026-08-01','17:30','Copa do Brasil','Oitavas de Final','Sat','Casa','E','0','0','Fluminense','50','36608','Jair','4-2-3-1','4-2-3-1','Ramon Abatti Abel');

insert into partidas values('2026-08-05','21:30','Copa do Brasil','Oitavas de Final','Wed','Fora','V','3','1','Fluminense','39','48794','Thiago Mendes','4-3-3','4-2-3-1','Wilton Pereira Sampaio');

insert into partidas values('2026-08-26','21:30','Copa do Brasil','Quartas de Final','Wed','Casa','V','1','0','Vitória','36','19194','Thiago Mendes','4-2-3-1','4-1-4-1','Matheus Candançan');

insert into partidas values('2026-09-02','21:30','Copa do Brasil','Quartas de Final','Wed','Fora','V','2','0','Vitória','38','28499','Thiago Mendes','4-3-3','4-2-3-1','Rafael Rodrigo Klein');

-- COMMAND ----------

-- DBTITLE 1,Removendo Jogadores Transferidos
delete from p_perf
where jogador in ('Philippe Coutinho','Matheus França','Hugo Moura');

delete from p_matches
where jogador in ('Philippe Coutinho','Matheus França','Hugo Moura');

-- COMMAND ----------

-- DBTITLE 1,Camada Silver (Limpeza e Transformação de Dados)
create table p_perf as
select
Player as jogador,
Nation as nacionalidade,
Pos as posicao,
Age as idade,
MP as partidas_jogadas,
Starts as partidas_titular,
Min	as minutos_jogados,
Gls	as gols_marcados,
Ast	as assistencias,
`G+A`	as participacoes,
`G-PK` as gols_sem_penalti,
PK as cobrancas_penalti,
PKatt as cobrancas_convertidas,
CrdY as cartoes_amarelos,
CrdR as cartoes_vermelhos,
`G+A-PK` as gols_assts_sem_penalti
from performance;

create table p_matches as
select
Player as jogador,
Nation as nacionalidade,
Pos as posicao,
Age as idade,
MP as partidas_jogadas,
Min	as minutos_jogados,
`Mn/MP` as minutos_por_partida,
`Min%` as porcentagem_minutos,
Starts as partidas_titular,
`Mn/Start` as minutos_partidas_titular,
Compl as partidas_completas,
Subs as partidas_jogadas_nao_titular,
`Mn/Sub` as minutos_subs,
unSub as reserva_nao_utilizado,
PPM	as pontos_por_partida,
onG	as gols_marcados_pela_equipe,
onGA as gols_sofridos_pela_equipe,
`+/-` as marcados_menos_sofridos_equipe,
`+/-90` as marcados_menos_sofridos_equipe90,
`On-Off` as saldo_equipe
from playingtime;

create table partidas as
select
`Date` as `data`,
`Time` as horario,
Comp as competicao,	
Round as rodada,
`Day` as dia_semana,
Venue as mando_de_campo,
Result as resultado,
GF as gols_pro,
GA as gols_contra,
Opponent as adversario,
Poss as posse,
Attendance as publico,
Captain	as capitao,
Formation as formacao,
`Opp Formation` as formacao_adversario,
Referee	as arbitragem
from matches;


-- COMMAND ----------

-- DBTITLE 1,Análises de Performance, Elenco e Desempenho
-- análises jogadores

-- média de idade por posição
select posicao, round(avg(idade),2) as media_idade_posicao
from p_perf
group by posicao;

-- jogadores com maiores médias de cartões amarelos por jogo
select jogador, round(cartoes_amarelos/partidas_jogadas,2) as media_cartoes_amarelos
from p_perf
where partidas_jogadas > 10
order by 2 desc
limit 5;

-- quantidade de jogadores de cada nacionalidade
select nacionalidade, count(*) as qntd_jogadores
from p_perf
group by nacionalidade
order by qntd_jogadores desc;

-- participacoes em gols por partidas vs impacto no resultado (pontos conquistados por jogo)
select p.jogador, round(p.participacoes/p.partidas_jogadas,2) as participacoes_em_gol, m.pontos_por_partida
from p_perf p
inner join p_matches m
on p.jogador = m.jogador
where p.participacoes/p.partidas_jogadas > 0
order by p.participacoes/p.partidas_jogadas desc, m.pontos_por_partida desc
limit 10;

-- dependência/rotação em campo dos 15 jogadores mais utilizados
select jogador, round(minutos_jogados/partidas_jogadas) as pct_tempo_em_campo, partidas_titular
from p_perf
where partidas_jogadas >= partidas_titular
and minutos_jogados > 500
order by pct_tempo_em_campo desc
limit 15;

-- análises do time

-- desempenho casa vs fora
select mando_de_campo, count(*) as partidas, 
count(*) filter (where resultado = 'V') as vitorias,  count(*) filter (where resultado = 'E') as empates, count(*) filter (where resultado = 'D') as derrotas,
(partidas)*3 as pontos_possiveis, (vitorias)*3 + empates as pontos_conquistados, round(pontos_conquistados/pontos_possiveis,2) as aproveitamento
from partidas
group by mando_de_campo
order by 1 asc;

-- desempenho são januário x maracanã
select 
    case 
        when data in ('2026-10-20', '2026-03-18', "2026-08-01") then 'Maracanã'
        else 'São Januário'
    end as estadio, resultado, count(*) as quantidade
from partidas
where mando_de_campo = 'Casa'
group by estadio, resultado
order by estadio desc, resultado desc; 

-- COMMAND ----------

-- DBTITLE 1,Tabelas para Análises Power BI
