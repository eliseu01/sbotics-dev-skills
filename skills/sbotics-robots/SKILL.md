---
name: sbotics-robots
description: >
  Módulo especializado para inspecionar, descriptografar, modelar, validar e gerar arquivos de robôs (.sBot) para a plataforma sBotics. Use quando o usuário mencionar '.sbot', 'sbot', 'robô sbotics', 'criar robô', 'gerar robô', 'modificar robô', 'descriptografar robô' ou 'peças do robô'.
license: MIT
metadata:
  author: ronaldylf
  version: "0.1.0"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(mkdir:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(ls:*)
  - Bash(cat:*)
---

# sBotics Robots — Módulo de Manipulação e Criação de Robôs (.sBot)

Esta skill é um submódulo dedicado **exclusivamente aos robôs da plataforma sBotics** (arquivos `.sBot`). Ela não cobre a criação de arenas ou escrita de código de simulação, focando 100% em:
1. Descriptografar e inspecionar a anatomia de arquivos `.sBot`.
2. Modelar novos robôs ou editar robôs existentes em formato JSON.
3. Validar a consistência física, limites da grade e integridade de juntas (`anchor`).
4. Criptografar e assinar o robô gerando um `.sBot` válido para o simulador.

## Entradas

- `$action`: Ação desejada (`decrypt`, `encrypt`, `validate`, `generate`, `info`).
- `$input_file`: Caminho para o arquivo `.sBot` ou `.json`.
- `$output_file`: Caminho de saída desejado.
- `$robot_name`: Nome de identificação do robô na simulação.

## Objetivo

Gerenciar o ciclo de vida completo de arquivos de robôs (`.sBot`):
- Permitir engenharia reversa e inspeção de robôs existentes.
- Garantir que qualquer robô gerado programaticamente respeite as regras físicas da engine Unity do sBotics.
- Produzir arquivos binários/criptografados `.sBot` com assinatura HMAC íntegra.

---

## Passos de Execução

> [!NOTE]
> **Resolução de `<skill-dir>`:** O identificador `<skill-dir>` nos comandos abaixo representa a pasta onde este arquivo `SKILL.md` reside (seja no repositório local em `skills/sbotics-robots`, seja instalado no harness do usuário como `~/.gemini/antigravity-cli/skills/sbotics-robots` ou `~/.claude/skills/sbotics-robots`). Substitua `<skill-dir>` pelo caminho real do diretório desta skill.

### 1. Inspecionar ou Descriptografar Robô (`decrypt` / `info`)
Para extrair a estrutura, lista de peças ou nomes de sensores de um robô existente:
- Executa a descriptografia AES-256-CBC com verificação do hash HMAC-SHA256 usando a chave oficial:
  `JCZWRVPvlhQ0iSkIIxqeRyE6TFWHg6f2qP1tbK0del8=`
- Decodifica o Base64 e produz o arquivo JSON legível.

Comandos:
```bash
# Ver resumo e contagem de peças
python <skill-dir>/scripts/sbotics.py info -i "Caminho/Robo.sBot"

# Descriptografar para JSON editável
python <skill-dir>/scripts/sbotics.py decrypt -i "Caminho/Robo.sBot" -o "Caminho/Robo.json"
```

**Critério de sucesso**: Obter um arquivo JSON válido contendo `name` e a lista `blocks`, com HMAC validado sem erros.

### 2. Modelar ou Gerar Estrutura do Robô (`generate`)
Ao criar um novo robô ou editar um chassi:

> [!IMPORTANT]
> **Liberdade de Montagem:** Sensores, atuadores e blocos podem ser posicionados em **qualquer lugar e em qualquer orientação** (frente, laterais, traseira, para cima ou para baixo, garras de resgate, etc.), de acordo com a estratégia do robô (seguidor de linha, desvio de obstáculos, rampa, sala de resgate).

Ao posicionar qualquer peça, atente-se às seguintes diretrizes:
- **Origem (0, 0, 0) é exclusiva do Core:** NUNCA coloque blocos em `position = {x: 0, y: 0, z: 0}`. Essa posição é instanciada automaticamente pelo simulador para o "Core" (`RobotController`). Peças centrais devem ficar adjacentes (ex: `z: 1`, `z: -1`, `x: 1`, `x: -1`) e usar `"anchor": {x: 0, y: 0, z: 0}`.
- **Estrutura e Chassi:** Adicione blocos estruturais (`Cube`, `Wedge`, `Slab`, `Corner`).
- **Atuadores e Rodas:** Posicione servomotores (`Servomotor`, `Hinge`) e rodas (`SmallWheel`, `LargeWheel`).
- **Sensores:** Posicione `ColorSensor`, `UltrasonicSensor`, `TouchSensor`, `Camera`, atribuindo nomes descritivos e únicos (ex: `"ultra_frente"`, `"ultra_lateral_dir"`, `"cor_resgate"`, `"toque_garra"`).
- **Âncoras Físicas (`anchor`):** Toda peça adicionada precisa apontar seu `"anchor"` para as coordenadas do bloco pai ao qual está fisicamente conectada, garantindo a árvore de juntas rígidas da física Unity.

Comando para gerar robô base a partir de template:
```bash
python <skill-dir>/scripts/sbotics.py generate -n "MeuRobo" -o "MeuRobo.json"
```

**Critério de sucesso**: Ter uma lista de blocos com coordenadas consistentes e âncoras válidas.

### 3. Validar Regras e Restrições da Plataforma (`validate`)
Antes de compilar, o robô deve passar pelas **regras invioláveis da plataforma**:
1. **Regra do Core:** Nenhum bloco em `{x: 0, y: 0, z: 0}`.
2. **Limites Espaciais:** Coordenadas estritamente dentro de $-8 \le x \le 8$, $-4 \le y \le 12$, $-8 \le z \le 8$.
3. **Catálogo de Peças:** O campo `type` deve ser um dos 18 tipos do catálogo `Placeables`.
4. **Catálogo de Cores:** Se especificada, `color` deve ser um dos 16 materiais de `ObjectMaterials`.
5. **Conectividade de Âncoras:** Todo `anchor` (exceto `0,0,0`) deve coincidir com as coordenadas de uma peça real existente.
6. **Nomes Únicos:** Não pode haver nomes de componentes duplicados no mesmo robô.

Comando:
```bash
python <skill-dir>/scripts/sbotics.py validate -i "Caminho/Robo.json"
```

**Critério de sucesso**: Relatório de validação com 0 erros de limites ou âncoras órfãs.

### 4. Compilar e Assinar o Robô (`encrypt`)
- O JSON validado é criptografado com **AES-256-CBC (PKCS7)** com IV aleatório de 16 bytes.
- Chave oficial estática: `JCZWRVPvlhQ0iSkIIxqeRyE6TFWHg6f2qP1tbK0del8=`
- É calculado o HMAC-SHA256 da concatenação `iv_b64 + value_b64` para garantir a assinatura de integridade aceita pelo sBotics.
- Salvo com extensão `.sBot`.

Comando:
```bash
python <skill-dir>/scripts/sbotics.py encrypt -i "Caminho/Robo.json" -o "Caminho/Robo.sBot"
```

**Critério de sucesso**: Arquivo `.sBot` gerado e testado pelo decodificador, pronto para carregar na simulação.

---

## Referência Técnica Rápida

### Orientações Comuns de Sensores
* **Sensores de Linha / Chão:** `rotation: { x: 0, y: 0, z: 0 }` (a lente aponta naturalmente para o chão).
* **Sensores de Obstáculo / Paredes Dianteiros:** `rotation: { x: 270, y: 0, z: 0 }` (sensor de cor) ou `rotation: { x: 0, y: 0, z: 0 }` (ultrassônico).
* **Sensores Laterais (Direita):** `rotation: { x: 0, y: 90, z: 0 }`.
* **Sensores Laterais (Esquerda):** `rotation: { x: 0, y: 270, z: 0 }`.
* **Sensores Traseiros:** `rotation: { x: 0, y: 180, z: 0 }`.

### Catálogo de Peças (`Placeables`)
`Cube`, `Wedge`, `Hinge`, `SmallWheel`, `LargeWheel`, `Buzzer`, `Light`, `Servomotor`, `ColorSensor`, `UltrasonicSensor`, `TouchSensor`, `Slab`, `Camera`, `Pen`, `Pyramid`, `WedgeColorSensor`, `WedgeUltrasonicSensor`, `Corner`.

### Catálogo de Cores (`ObjectMaterials`)
`ColorWhite`, `ColorGray`, `ColorDarkGray`, `ColorBlack`, `ColorGreen`, `ColorLime`, `ColorTeal`, `ColorCyan`, `ColorBlue`, `ColorPurple`, `ColorMagenta`, `ColorPink`, `ColorRed`, `ColorBrown`, `ColorOrange`, `ColorYellow`.

### Regras Mandatórias da Plataforma
- **Core Fixo:** A coordenada `(0, 0, 0)` é o ponto de ancoragem do Core e não aceita peças sobrepostas.
- **Grid de Construção:** Limites máximos $[-8, 8] \times [-4, 12] \times [-8, 8]$.
- **Fórmula de Spawn:** $\text{SpawnHeight} = 0.3 + (-\text{minY} \times 0.6)$
- **Ligação física:** Blocos adjacentes conectados pelo vetor `"anchor"` geram `Joint.connectedBody`.
