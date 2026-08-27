-- Pergunta: quais colunas cada tabela do dataset consolidado tem, e quais delas
--           são candidatas a coluna de data para definir granularidade e janela?
-- Fonte: BigQuery ${GCP_PROJECT_ID}.${BQ_DATASET}.INFORMATION_SCHEMA.COLUMNS
-- Granularidade: uma linha por coluna de cada tabela
-- Janela: não se aplica (metadado)
-- Fuso: não se aplica
-- Definições: nenhuma; query de inventário
-- Validada: NÃO VALIDADA (rede bloqueada e sem credencial em 2026-08-27)

SELECT
  table_name                                                    AS tabela,
  ordinal_position                                              AS posicao,
  column_name                                                   AS coluna,
  data_type                                                     AS tipo,
  is_partitioning_column = 'YES'                                AS eh_particao,
  clustering_ordinal_position IS NOT NULL                       AS eh_cluster,
  data_type IN ('DATE', 'DATETIME', 'TIMESTAMP')                AS candidata_a_data
FROM `${GCP_PROJECT_ID}.${BQ_DATASET}`.INFORMATION_SCHEMA.COLUMNS
ORDER BY tabela, posicao;
