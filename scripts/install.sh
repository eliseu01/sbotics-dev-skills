#!/usr/bin/env bash
# ==============================================================================
# install.sh — Instalador de skills para sbotics-dev-skills
# Suporta: Antigravity, Claude Code, OpenAI Codex, Pi, Hermes, Agents, Cursor, Copilot
# ==============================================================================

set -e

# Cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Diretório raiz do repositório
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

if [ ! -d "$SKILLS_SRC" ]; then
    echo -e "${RED}[ERRO] Pasta 'skills' não encontrada em $REPO_ROOT.${NC}"
    exit 1
fi

# Detectar Home (compatível com Linux, macOS e Windows Git Bash)
USER_HOME="${HOME:-$USERPROFILE}"

# Mapeamento de Harnesses suportados
declare -A HARNESS_PARENT=(
    ["antigravity"]="$USER_HOME/.gemini/antigravity-cli"
    ["claude"]="$USER_HOME/.claude"
    ["codex"]="$USER_HOME/.codex"
    ["pi"]="$USER_HOME/.pi"
    ["hermes"]="$USER_HOME/.hermes"
    ["agents"]="$USER_HOME/.agents"
    ["cursor"]="$USER_HOME/.cursor"
    ["copilot"]="$USER_HOME/.copilot"
)

declare -A HARNESS_SKILLS_DIR=(
    ["antigravity"]="$USER_HOME/.gemini/antigravity-cli/skills"
    ["claude"]="$USER_HOME/.claude/skills"
    ["codex"]="$USER_HOME/.codex/skills"
    ["pi"]="$USER_HOME/.pi/skills"
    ["hermes"]="$USER_HOME/.hermes/skills"
    ["agents"]="$USER_HOME/.agents/skills"
    ["cursor"]="$USER_HOME/.cursor/skills"
    ["copilot"]="$USER_HOME/.copilot/skills"
)

# Argumentos
INSTALL_ALL=false
TARGET_HARNESS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            INSTALL_ALL=true
            shift
            ;;
        --target)
            TARGET_HARNESS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Uso: $0 [opções]"
            echo ""
            echo "Opções:"
            echo "  --all             Instala em todos os harnesses suportados."
            echo "  --target <nome>   Instala em um harness específico (ex: antigravity, claude, codex, pi, hermes, agents, cursor, copilot)."
            echo "  -h, --help        Exibe esta ajuda."
            echo ""
            echo "Se nenhuma opção for informada, o instalador auto-detecta os harnesses presentes na sua máquina."
            exit 0
            ;;
        *)
            echo -e "${RED}Opção desconhecida: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}   sbotics-dev-skills — Instalador de Skills         ${NC}"
echo -e "${BLUE}=====================================================${NC}"

# Coletar skills presentes no repositório
SKILLS_TO_INSTALL=()
for skill_dir in "$SKILLS_SRC"/*; do
    if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
        SKILLS_TO_INSTALL+=("$(basename "$skill_dir")")
    fi
done

if [ ${#SKILLS_TO_INSTALL[@]} -eq 0 ]; then
    echo -e "${RED}[ERRO] Nenhuma skill válida encontrada em $SKILLS_SRC (necessário conter SKILL.md).${NC}"
    exit 1
fi

echo -e "Skills encontradas para instalação: ${YELLOW}${SKILLS_TO_INSTALL[*]}${NC}\n"

# Determinar harnesses alvo
TARGETS=()

if [ -n "$TARGET_HARNESS" ]; then
    if [[ -v HARNESS_SKILLS_DIR["$TARGET_HARNESS"] ]]; then
        TARGETS+=("$TARGET_HARNESS")
    else
        echo -e "${RED}[ERRO] Harness desconhecido: '$TARGET_HARNESS'.${NC}"
        echo "Opções válidas: ${!HARNESS_SKILLS_DIR[*]}"
        exit 1
    fi
elif [ "$INSTALL_ALL" = true ]; then
    for h in "${!HARNESS_SKILLS_DIR[@]}"; do
        TARGETS+=("$h")
    done
else
    # Auto-detecção
    echo "Auto-detectando harnesses de IA instalados no sistema..."
    for h in "${!HARNESS_PARENT[@]}"; do
        parent_dir="${HARNESS_PARENT[$h]}"
        if [ -d "$parent_dir" ]; then
            TARGETS+=("$h")
            echo -e "  ${GREEN}✔ Detectado:${NC} $h ($parent_dir)"
        fi
    done

    # Se nenhum for detectado automaticamente, instala nos padrões mais comuns
    if [ ${#TARGETS[@]} -eq 0 ]; then
        echo -e "${YELLOW}Nenhum harness detectado automaticamente em $USER_HOME.${NC}"
        echo -e "Instalando por padrão nos diretórios do ${GREEN}Antigravity (~/.gemini)${NC}, ${GREEN}Claude (~/.claude)${NC} e ${GREEN}Agents (~/.agents)${NC}..."
        TARGETS+=("antigravity" "claude" "agents")
    fi
fi

echo ""

# Executar a instalação
for target in "${TARGETS[@]}"; do
    dest_skills_dir="${HARNESS_SKILLS_DIR[$target]}"
    echo -e "Instalando no harness ${BLUE}[$target]${NC} em: $dest_skills_dir"
    mkdir -p "$dest_skills_dir"

    for skill_name in "${SKILLS_TO_INSTALL[@]}"; do
        src_dir="$SKILLS_SRC/$skill_name"
        dest_dir="$dest_skills_dir/$skill_name"

        rm -rf "$dest_dir"
        cp -r "$src_dir" "$dest_dir"
        echo -e "  ${GREEN}✔ Skill instalada:${NC} $skill_name"
    done
    echo ""
done

echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}   Instalação concluída com sucesso!                ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "Dica: Para atualizar as dependências Python necessárias, execute:"
echo -e "  ${YELLOW}pip install -r \"$REPO_ROOT/requirements.txt\"${NC}\n"
