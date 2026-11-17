# Catálogo externo licenciado

O Espectro mantém o acervo editorial curado em `assets/data/` e um slot
separado para dados de terceiros em `assets/data/external_catalog.json`.

Esse slot existe por dois motivos:

1. permitir ampliar cobertura sem sobrescrever fichas revisadas;
2. manter explícita a diferença entre curadoria local e importação.

## Licença

O repositório do 12axes declara **“All rights reserved”** e não concede licença
para copiar, redistribuir ou criar obras derivadas dos perfis, vetores, textos,
perguntas ou do algoritmo. Por isso o Espectro **não inclui** esse acervo.

O importador só deve ser usado se você tiver autorização escrita do detentor
dos direitos. Ele exige a flag `--confirm-rights` e registra a URL da licença
em cada ficha importada.

## Formato de entrada

O importador lê uma pasta com os arquivos abaixo. O formato é o mesmo de um
export de catálogo com 12 eixos em percentual para a esquerda (`0..100`).

```text
ideologies.json + ideology-profiles.json
personalities.json + personality-profiles.json
countries.json + countries-profiles.json
parties.json + parties-profiles.json
```

Cada perfil precisa de um `vector` com os 12 eixos:

```json
{
  "ideologyId": "exemplo",
  "vector": {
    "estrutura": 50,
    "representacao": 50,
    "poder": 50,
    "imigracao": 50,
    "diplomacia": 50,
    "intervencao": 50,
    "economia": 50,
    "controle": 50,
    "comercio": 50,
    "religiao": 50,
    "moral": 50,
    "tecnologia": 50
  }
}
```

## Conversão

- `mu = 1 - 2 * (leftPercent / 100)`, portanto `0%` → `+1` (direita) e
  `100%` → `-1` (esquerda).
- `sigma = 0.35`, `relevance = 0.7`: valores provisórios, não uma calibração
  empírica.
- `triangles` fica vazio: o importador **não inventa** as seis tríades.
- `nativeMatchingEligible: false`: as fichas importadas são exploráveis no
  Atlas, mas não entram no diagnóstico nativo até revisão editorial.
- Livros são ignorados nesta versão: o formato de origem não traz vetores.

## Uso

```bash
python3 tool/curation/import_external_catalog.py \
  --source-dir /caminho/do/export \
  --source-url https://exemplo.org/licenca \
  --confirm-rights
```

Para conferir sem gravar:

```bash
python3 tool/curation/import_external_catalog.py \
  --source-dir /caminho/do/export \
  --source-url https://exemplo.org/licenca \
  --confirm-rights \
  --dry-run
```

O script faz deduplicação por ID e nome normalizado contra o acervo local e
contra importações anteriores. O destino padrão é
`assets/data/external_catalog.json`.

## O que não é feito

- Não há download automático de dados de terceiros.
- Não há mistura de vetores importados com notas editoriais locais.
- Não há conversão de ausência em centro.
- Não há promoção automática de uma ficha importada a perfil nativo.
