CREATE OR ALTER VIEW VW_SYSO_ESTOQUE_PROD_ENTREGUE(
    ID_PRODUTO,
    CODIGO_FABRICA,
    CODIGO_BARRAS,
    PRODUTO,
    SITUACAO,
    FRACAO,
    QTDE_INTEIRA,
    QTDE_FRACAO,
    DATAHORA,
    IDENTIFICA_OS,
    ID_MOVIMENTO,
    TIPO_OPERACAO,
    NOME_EXECUTOR,
    NOME_ESTOQUISTA,
    ID_USUARIO,
    ID_EXECUTOR,
    DATA_ULT_OPERACAO,
    LOCALIZACAO,
    DATA_MOVIMENTO)
AS
select pro.id_produto,
       pro.codigo_fabricante,
       pro.codigo_barras,
       pd.descricao produto,
       (case when mi.posicao_estoque = 1
             then '1 - EM ESTOQUE'
             when mi.posicao_estoque = 2
             then '2 - ENTREGUE'
             when mi.posicao_estoque = 3
             then '3 - DEVOLVIDO'
             else '4 - DESCONHECIDO'
             end) situacao_estoque,
       (pro.fracao) fracao,
       (mi.quant_inteira) qtde_inteira,
       (mi.quant_fracao) qtde_fracao,
       mov.data_operacao,
       mos.id_adicional_os,
       mov.id_movimento,
       (case when mov.tipo_movimento = 1
             then '1 - SAIDA'
             when mov.tipo_movimento = 2
             then '2 - DEVOLU��O'
             else 'DESCONHECIDO'
       end) tipo_movimento,
       u_executor.nome_usuario,
       u_estoquista.nome_usuario,
       u_estoquista.id_usuario,
       u_executor.id_usuario,
       data_ult_operacao,
       prol.localizacao,
       formatdatetime('dd/mm/yyyy', mov.data_operacao)
       from movimento_itens mi
join movimento mov on mov.id_empresa = mi.id_empresa
                  and mov.id_filial = mi.id_filial
                  and mov.id_movimento = mi.id_movimento

left join movimento_os mos on mos.id_empresa = mov.id_empresa
                          and mos.id_filial = mov.id_filial
                          and mos.id_movimento = mov.id_movimento

join produtos pro on pro.id_empresa = mi.id_empresa
                 and pro.id_produto = mi.id_produto

left join produtos_localizacao prol on pro.id_empresa = mi.id_empresa
                 and prol.id_produto = mi.id_produto


join produtos_descricoes pd on pd.id_empresa = pro.id_empresa
                           and pd.id_produto = pro.id_produto
                           and pd.id_descricao = 1

join movimento_itens_usuarios miuex on miuex.id_empresa = mi.id_empresa
                                and miuex.id_filial = mi.id_filial
                                and miuex.id_movimento = mi.id_movimento
                                and miuex.id_pacote = mi.id_pacote
                                and miuex.id_produto = mi.id_produto
                                and miuex.id_produto_composto = mi.id_produto_composto
                                and miuex.operacao = 2

join usuarios u_executor on u_executor.id_empresa = miuex.id_empresa
                and u_executor.id_filial = miuex.id_filial
                and u_executor.id_usuario = miuex.id_usuario

join usuarios u_estoquista ON u_estoquista.id_empresa = mi.id_empresa
                          AND u_estoquista.id_filial = mi.id_filial
                          AND u_estoquista.id_usuario = mi.id_estoquista

where mov.id_empresa = 1
  and mov.id_filial = 1
  and mov.tipo_movimento in (1,2)
  and mov.situacao in (1,4)
  and mi.produto_servico = 1
  and mi.posicao_estoque = 2
  and mov.data_operacao between current_timestamp - 30 and current_timestamp

order by ID_MOVIMENTO desc
;
