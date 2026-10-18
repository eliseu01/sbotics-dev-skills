# sbotics-dev-skills🤖

> Coleção modular de skills inteligentes e ferramentas de engenharia reversa para a plataforma de simulação robótica **sBotics** (Olimpíada Brasileira de Robótica - OBR).

Compatível com os principais harnesses e agentes de IA do ecossistema ([agentskills.io](https://agentskills.io)), como **Antigravity (Gemini CLI)**, **Claude Code**, **OpenAI Codex**, **Pi**, **Hermes**, **Agents**, **Cursor** e **Copilot**.

---

## 📦 Skills Disponíveis e Roadmap

| Skill | Status | Descrição |
| :--- | :---: | :--- |
| **`sbotics-robots`** | 🟢 **Disponível** | Módulo de engenharia reversa, descriptografia, inspeção, validação física e geração programática de robôs (`.sBot`). |
| **`sbotics-arenas`** | 🟡 *Em breve* | Módulo para análise, engenharia reversa e geração procedural de arenas, ladrilhos e pistas de resgate da OBR. |
| **`sbotics-code`** | 🟡 *Em breve* | Módulo para criação, validação e templates de rotinas de código de controle em REduc e C# para os robôs na simulação. |

---

## 🚀 Instalação Rápida das Skills

Você pode instalar automaticamente todas as skills do repositório nos seus assistentes de IA utilizando os scripts inclusos.

### 1. Instalar Dependências Python
Para que os módulos realizem a criptografia AES-256 e HMAC oficial do sBotics:
```bash
pip install -r requirements.txt
```

### 2. Instalar nos Harnesses de IA

**No Linux, macOS ou Git Bash (Windows):**
```bash
# Auto-detecta os harnesses instalados na máquina (Antigravity, Claude, Codex, etc.)
bash scripts/install.sh

# Ou instala em todos os suportados:
bash scripts/install.sh --all

# Ou instala apenas em um específico:
bash scripts/install.sh --target antigravity
```

**No Windows (PowerShell Nativo):**
```powershell
# Auto-detecta e instala:
.\scripts\install.ps1

# Ou instala em um específico:
.\scripts\install.ps1 -Target claude
```

*(Para desinstalar no futuro, basta executar `bash scripts/uninstall.sh` ou `.\scripts\uninstall.ps1`).*

---

## 🛠️ Uso da Ferramenta CLI (`sbotics.py`)

O módulo `sbotics-robots` inclui um utilitário CLI em Python independente que você pode usar diretamente no terminal:

```bash
# 1. Inspecionar e ver contagem de peças de um robô
python skills/sbotics-robots/scripts/sbotics.py info -i "MeuRobo.sBot"

# 2. Descriptografar .sBot para JSON legível
python skills/sbotics-robots/scripts/sbotics.py decrypt -i "MeuRobo.sBot" -o "MeuRobo.json"

# 3. Validar se um robô atende aos limites e conexões físicas da simulação
python skills/sbotics-robots/scripts/sbotics.py validate -i "MeuRobo.json"

# 4. Compilar e assinar um arquivo JSON para .sBot
python skills/sbotics-robots/scripts/sbotics.py encrypt -i "MeuRobo.json" -o "MeuRobo.sBot"

# 5. Gerar um novo robô a partir do template inicial
python skills/sbotics-robots/scripts/sbotics.py generate -n "NovoRobo" -o "NovoRobo.json"
```

---

## 📚 Documentação Técnica

* 📄 **[Engenharia Reversa dos Robôs (.sBot)](docs/discovery-sbotics-robots.md)**: Análise detalhada da criptografia AES-256-CBC, HMAC-SHA256, dicionário de peças (`Placeables`), materiais (`ObjectMaterials`) e regras físicas da engine Unity.

---

## 🤝 Padrão e Compatibilidade

As skills deste repositório seguem rigorosamente a especificação aberta **[agentskills.io](https://agentskills.io)**, garantindo que qualquer agente compatível consiga invocar, orientar e executar os procedimentos de forma consistente.
