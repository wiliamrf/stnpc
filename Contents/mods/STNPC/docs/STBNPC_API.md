# STBNPC API

## Objetivo

Centralizar funções públicas utilizadas por outros módulos.

---

## Squad System

### STBNPC_SquadSystem_Add(npc)

Adiciona NPC ao esquadrão ativo.

Parâmetros:
- npc (IsoPlayer)

Retorno:
- boolean

---

### STBNPC_SquadSystem_Remove(npc)

Remove NPC do esquadrão.

Parâmetros:
- npc (IsoPlayer)

Retorno:
- boolean

---

### STBNPC_SquadSystem_SetMode(mode)

Altera o modo operacional do esquadrão.

Modos:

FOLLOW
HOLD
PATROL
GUARD
STEALTH

---

## Recruit System

### STBNPC_RecruitSystem_RecruitNPC(npc)

Tenta recrutar um NPC.

Retorno:
- true
- false

---

## Target System

### STBNPC_GetTargetNPC(player)

Retorna NPC atualmente selecionado.