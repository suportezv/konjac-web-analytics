-- Pergunta: quais tabelas o dataset consolidado tem, com quantas linhas, de que
--           tamanho e quando cada uma foi atualizada pela última vez?
-- Fonte: BigQuery ${GCP_PROJECT_ID}.${BQ_DATASET}, INFORMATION_SCHEMA + __TABLES__
-- Granularidade: uma linha por tabela
-- Janela: não se aplica (metadado)
-- Fuso: America/Sao_Paulo (last_modified convertido na saída)
-- Definições: nenhuma; query de inventário. O "frescor" aqui é a data da última
--             ESCRITA na tabela, que não é o mesmo que a data mais recente DENTRO
--             dela. A data mais recente do dado exige olhar a coluna de data de
--             cada tabela, um passo depois deste.
-- Validada: NÃO VALIDADA (rede bloqueada e sem credencial em 2026-08-27)

SELECT
  t.table_id                                                    AS tabela,
  t.row_count                                                   AS linhas,
  ROUND(t.size_bytes / POW(1024, 3), 3)                         AS tamanho_gb,
  DATETIME(TIMESTAMP_MILLIS(t.last_modified_time),
           'America/Sao_Paulo')                                 AS ultima_escrita_sp,
  CASE t.type WHEN 1 THEN 'tabela' WHEN 2 THEN 'view'
              WHEN 5 THEN 'view materializada' ELSE CAST(t.type AS STRING) END
                                                                AS tipo
FROM `${GCP_PROJECT_ID}.${BQ_DATASET}.__TABLES__` AS t
ORDER BY ultima_escrita_sp DESC;
