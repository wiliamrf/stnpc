
---

# 📁 2. `/docs/ARCHITECTURE.md`

```md
# STBNPC ARCHITECTURE

## 🧠 Layers

### 1. CLIENT LAYER
File: STBNPC_Client.lua

Responsibilities:
- Mouse selection
- Input detection
- Debug tools

DO NOT:
- modify brain
- create tasks directly
- call BanditBrain.Update

---

### 2. INTEGRATION LAYER
File: STBNPC_Integration.lua

Responsibilities:
- task system
- AI state control
- squad sync
- combat state
- speech system

This is the CORE API of the mod.

---

### 3. BRAIN LAYER
File: BanditBrain.lua

Responsibilities:
- persistence (modData)
- validation helpers
- task queries
- state queries

This is the SOURCE OF TRUTH.

---

## 🔁 Data Flow

Client Input
    ↓
STBNPC_Client
    ↓
STBNPC_Integration.PushTask()
    ↓
Brain.tasks
    ↓
AI Processor (future system)

---

## ⚔️ Combat Flow

1. Enemy detected
2. Integration sets combatState
3. Task "ATTACK" pushed
4. Brain processed by AI loop
5. Bandit executes action

---

## 👥 Squad Flow

1. Leader receives command
2. BroadcastTask() called
3. Each NPC receives task
4. Brain synced

---

## ⚠️ Anti-Pattern

NEVER:
- duplicate integration logic in client
- bypass STBNPC_Integration
- modify brain without BanditBrain.Update