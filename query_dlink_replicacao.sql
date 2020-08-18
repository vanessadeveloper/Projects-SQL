
SELECT DBLINK_CONNECT('conn', 'dbname=universo host=127.0.0.1 password=postgres user=postgres port=5432');

SELECT * FROM dblink('conn', 'select codigo, nome  from clientes')
  AS t1(codigo integer , nome varchar);



  SELECT DBLINK_DISCONNECT('conn');


  create table replicacao.alt_cadastro (data_alteracao date);






create or replace function replicacao.data_cadastro()
  returns trigger as $$
  begin
     new.data_alteracao = now();
     return new;
  end;
  $$ language 'plpgsql';





  create trigger "replicacao.data_cadastro_cliente"
  before insert

  on public.clientes
  for each row
  execute procedure replicacao.data_cadastro();





select * from information_schema.triggers

select * from replicacao.alt_cadastro;

delete from replicacao.produtos_alterados;

-CREATE TABLE replicacao.produtos_alterados (
  codigo INTEGER,
  descricao VARCHAR(50),
  codigodefabrica VARCHAR(20),
  codbarra VARCHAR(14),
  cod_ncm VARCHAR(9),
  cest VARCHAR(7),
  precovenda NUMERIC,
  preco_minimo NUMERIC,
  cfop_compra INTEGER,
  cfop_venda INTEGER,
  st_fora VARCHAR(4),
  situacaotributaria VARCHAR(4),
  ipi NUMERIC,
  ipi_entrada NUMERIC,
  vendersemestoque NUMERIC
)
WITH (oids = true);

----****----inserir produtos

DO $$DECLARE

rc record;

BEGIN

For rc in

select
p.codigo,
p.descricao,
p.codigodefabrica,
p.codbarra,
p.cod_ncm,
p.cest,
p.precovenda,
p.preco_minimo,
p.cfop_compra,
p.cfop_venda,
p.st_fora,
p.situacaotributaria,
p.ipi,
p.ipi_entrada,
p.vendersemestoque
 from
public.produtos p join public.alterados a on a.produto = p.codigo
 where p.ativo = 0
 and a.data = CURRENT_DATE;


 loop

 insert into replicacao.produtos_alterados
 values  (rc.codigo,
          rc.descricao,
          rc.codigodefabrica,
          rc.codbarra,
          rc.cod_ncm,
          rc.cest,
          rc.precovenda,
          rc.preco_minimo,
          rc.cfop_compra,
          rc.cfop_venda,
          rc.st_fora,
          rc.situacaotributaria,
          rc.ipi,
          rc.ipi_entrada,
          rc.vendersemestoque);
 end loop;

 END$$;



 select * from replicacao.produtos_alterados;



  SELECT DBLINK_CONNECT('conn_local', 'dbname=irmaos_matriz host=127.0.0.1 user=postgres password=postgres port=5432');
   select DBLINK_disCONNECT('conn_local');



----*****-alterados*****------
-----*****tirar CFOP E CST ****----


DO $$DECLARE

 rc_alterados record;
 vret integer;
BEGIN


--SELECT dblink_exec('conn_local', 'SELECT get_usuario(1)') into vret;

FOR rc_alterados in
 select
 rpa.*
 from
(SELECT * FROM
                    dblink('conn_local',
                                   'select
                                    p.codigo,
                                    p.descricao,
                                    p.codigodefabrica,
                                    p.codbarra,
                                    p.cod_ncm,
                                    p.cest,
                                    p.precovenda,
                                    p.preco_minimo,
                                    p.cfop_compra,
                                    p.cfop_venda,
                                    p.st_fora,
                                    p.situacaotributaria,
                                    p.ipi,
                                    p.ipi_entrada,
                                    p.vendersemestoque
                                     from
                                    public.produtos p
                                     where p.ativo = 0')
  AS t1(codigo INTEGER,
        descricao VARCHAR,
        codigodefabrica VARCHAR,
        codbarra VARCHAR,
        cod_ncm VARCHAR,
        cest VARCHAR,
        precovenda NUMERIC,
        preco_minimo NUMERIC,
        cfop_compra INTEGER,
        cfop_venda INTEGER,
        st_fora VARCHAR,
        situacaotributaria VARCHAR,
        ipi NUMERIC,
        ipi_entrada NUMERIC,
        vendersemestoque NUMERIC)) sub   JOIN replicacao.produtos_alterados rpa ON rpa.codigo = sub.codigo
  loop

 perform dblink_exec('conn_local', format('update public.produtos set

                          descricao          = %L,
                          codigodefabrica    = %L,
                          codbarra 		     = %L,
                          cod_ncm            = %L,
                          cest               = %L,
                          precovenda         = %L,
                          preco_minimo       = %L,
                          cfop_compra        = %L,
                          cfop_venda         = %L,
                          st_fora            = %L,
                          situacaotributaria = %L,
                          ipi                = %L,
                          ipi_entrada        = %L,
                          vendersemestoque   = %L
                          where codigo = %L',

                          rc_alterados.descricao,
                          rc_alterados.codigodefabrica,
                          rc_alterados.codbarra,
                          rc_alterados.cod_ncm,
                          rc_alterados.cest,
                          rc_alterados.precovenda,
                          rc_alterados.preco_minimo,
                          rc_alterados.cfop_compra,
                          rc_alterados.cfop_venda,
                          rc_alterados.st_fora,
                          rc_alterados.situacaotributaria,
                          rc_alterados.ipi,
                          rc_alterados.ipi_entrada,
                          rc_alterados.vendersemestoque,
                          rc_alterados.codigo
                          ));

  END LOOP;
  END$$;


-----*******CADASTRO DE PRODUTOS*******------





DO $$DECLARE

 rc_alterados record;
 vret integer;
BEGIN


--SELECT dblink_exec('conn_local', 'SELECT get_usuario(1)') into vret;

FOR rc_alterados in
 select
 rpa.*
 from
(SELECT * FROM
                    dblink('conn_local',
                                   'select
                                    p.codigo,
                                    p.descricao,
                                    p.codigodefabrica,
                                    p.codbarra,
                                    p.cod_ncm,
                                    p.cest,
                                    p.precovenda,
                                    p.preco_minimo,
                                    p.cfop_compra,
                                    p.cfop_venda,
                                    p.st_fora,
                                    p.situacaotributaria,
                                    p.ipi,
                                    p.ipi_entrada,
                                    p.vendersemestoque
                                     from
                                    public.produtos p
                                     where p.ativo = 0')
  AS t1(codigo INTEGER,
        descricao VARCHAR,
        codigodefabrica VARCHAR,
        codbarra VARCHAR,
        cod_ncm VARCHAR,
        cest VARCHAR,
        precovenda NUMERIC,
        preco_minimo NUMERIC,
        cfop_compra INTEGER,
        cfop_venda INTEGER,
        st_fora VARCHAR,
        situacaotributaria VARCHAR,
        ipi NUMERIC,
        ipi_entrada NUMERIC,
        vendersemestoque NUMERIC)) sub   JOIN replicacao.produtos_alterados rpa ON rpa.codigo != sub.codigo
  loop

 perform dblink_exec('conn_local', format('update public.produtos set

                          descricao          = %L,
                          codigodefabrica    = %L,
                          codbarra 		     = %L,
                          cod_ncm            = %L,
                          cest               = %L,
                          precovenda         = %L,
                          preco_minimo       = %L,
                          cfop_compra        = %L,
                          cfop_venda         = %L,
                          st_fora            = %L,
                          situacaotributaria = %L,
                          ipi                = %L,
                          ipi_entrada        = %L,
                          vendersemestoque   = %L
                          where codigo = %L',

                          rc_alterados.descricao,
                          rc_alterados.codigodefabrica,
                          rc_alterados.codbarra,
                          rc_alterados.cod_ncm,
                          rc_alterados.cest,
                          rc_alterados.precovenda,
                          rc_alterados.preco_minimo,
                          rc_alterados.cfop_compra,
                          rc_alterados.cfop_venda,
                          rc_alterados.st_fora,
                          rc_alterados.situacaotributaria,
                          rc_alterados.ipi,
                          rc_alterados.ipi_entrada,
                          rc_alterados.vendersemestoque,
                          rc_alterados.codigo
                          ));

  END LOOP;
  END$$;
 