-- Pergunta: quais datasets existem no projeto do BigQuery e onde ficam?
-- Fonte: BigQuery ${GCP_PROJECT_ID}, INFORMATION_SCHEMA.SCHEMATA da região
-- Granularidade: uma linha por dataset
-- Janela: não se aplica (metadado)
-- Fuso: America/Sao_Paulo (schema_created convertido na saída)
-- Definições: nenhuma; query de inventário, primeiro passo do levantamento
-- Validada: NÃO VALIDADA (rede bloqueada e sem credencial em 2026-08-27)

SELECT
  schema_name                                                   AS dataset,
  location,
  DATETIME(creation_time, 'America/Sao_Paulo')                  AS criado_em_sp,
  DATETIME(last_modified_time, 'America/Sao_Paulo')             AS modificado_em_sp
FROM `${GCP_PROJECT_ID}`.`region-${BQ_LOCATION}`.INFORMATION_SCHEMA.SCHEMATA
ORDER BY dataset;
