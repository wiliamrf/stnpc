# STBNPC Translation Keys

## Squad System

| Key | Description |
|------|-------------|
| STBNPC_LOG_SQUAD_ADD | NPC entrou no grupo |
| STBNPC_LOG_SQUAD_REMOVE | NPC saiu do grupo |
| STBNPC_LOG_SQUAD_NO_TARGET | Nenhum alvo selecionado |

---

## Commands

| Key | Description |
|------|-------------|
| STBNPC_COMMAND_FOLLOW | Comando seguir |
| STBNPC_COMMAND_HOLD | Comando manter posição |
| STBNPC_COMMAND_PATROL | Comando patrulhar |
| STBNPC_COMMAND_GUARD | Comando guardar |

---

## Survival

| Key | Description |
|------|-------------|
| STBNPC_NEED_FOOD | NPC precisa comer |
| STBNPC_NEED_REST | NPC precisa descansar |
| STBNPC_SLEEPING | NPC indo dormir |
| STBNPC_EATING | NPC comendo |

---

## Production

| Key | Description |
|------|-------------|
| STBNPC_FARMING | NPC trabalhando na fazenda |
| STBNPC_GATHERING | NPC coletando recursos |
| STBNPC_CLEANING | NPC limpando base |

---



function STBNPC_T(key)
    local text = getText(key)

    if text == key then
        print("[STBNPC] Missing Translation: " .. key)
    end

    return text
end