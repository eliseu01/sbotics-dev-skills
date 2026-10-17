#!/usr/bin/env bash
# ==============================================================================
# uninstall.sh — Desinstalador de skills para sbotics-dev-skills
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

USER_HOME="${HOME:-$USERPROFILE}"

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

TARGET_HARNESS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --target)
            TARGET_HARNESS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Uso: $0 [opções]"
            echo ""
            echo "Opções:"
            echo "  --target <nome>   Desinstala de um harness específico (ex: antigravity, claude, codex, etc.)."
            echo "  -h, --help        Exibe esta ajuda."
            echo ""
            echo "Se nenhuma opção for informada, o desinstalador remove as skills de todos os harnesses onde estiverem presentes."
            exit 0
            ;;
        *)
            echo -e "${RED}Opção desconhecida: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}   sbotics-dev-skills — Desinstalador de Skills      ${NC}"
echo -e "${BLUE}=====================================================${NC}"

# Coletar nomes das skills do repositório
SKILLS_TO_REMOVE=()
if [ -d "$SKILLS_SRC" ]; then
    for skill_dir in "$SKILLS_SRC"/*; do
        if [ -d "$skill_dir" ]; then
            SKILLS_TO_REMOVE+=("$(basename "$skill_dir")")
        fi
    done
fi

if [ ${#SKILLS_TO_REMOVE[@]} -eq 0 ]; then
    # Fallback se a pasta skills local não estiver presente
    SKILLS_TO_REMOVE=("sbotics-robots" "sbotics-arenas" "sbotics-code")
fi

echo -e "Skills alvo para remoção: ${YELLOW}${SKILLS_TO_REMOVE[*]}${NC}\n"

TARGETS=()
if [ -n "$TARGET_HARNESS" ]; then
    if [[ -v HARNESS_SKILLS_DIR["$TARGET_HARNESS"] ]]; then
        TARGETS+=("$TARGET_HARNESS")
    else
        echo -e "${RED}[ERRO] Harness desconhecido: '$TARGET_HARNESS'.${NC}"
        exit 1
    fi
else
    for h in "${!HARNESS_SKILLS_DIR[@]}"; do
        TARGETS+=("$h")
    done
fi

REMOVED_COUNT=0

for target in "${TARGETS[@]}"; do
    dest_skills_dir="${HARNESS_SKILLS_DIR[$target]}"
    if [ -d "$dest_skills_dir" ]; then
        for skill_name in "${SKILLS_TO_REMOVE[@]}"; do
            target_skill_dir="$dest_skills_dir/$skill_name"
            if [ -d "$target_skill_dir" ]; then
                rm -rf "$target_skill_dir"
                echo -e "  ${GREEN}✔ Removido:${NC} $skill_name de [$target]"
                REMOVED_COUNT=$((REMOVED_COUNT + 1))
            fi
        done
    fi
done

echo ""
if [ $REMOVED_COUNT -gt 0 ]; then
    echo -e "${GREEN}=====================================================${NC}"
    echo -e "${GREEN}   Desinstalação concluída com sucesso!              ${NC}"
    echo -e "${GREEN}=====================================================${NC}"
else
    echo -e "${YELLOW}Nenhuma skill encontrada instalada para remoção.${NC}"
fi
