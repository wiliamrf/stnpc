-- =========================================================
-- STBNPC UTILS (LOG + TRANSLATION HELPER)
-- =========================================================

STBNPC_Utils = STBNPC_Utils or {}

-- =========================================================
-- LOG PADRÃO INTERNACIONALIZADO
-- =========================================================
function STBNPC_Log(key)

    -- pega tradução (fallback seguro)
    local msg = getText(key)

    -- se não existir tradução, usa chave mesmo
    if msg == nil or msg == "" then
        msg = key
    end

    print("[STBNPC] " .. msg)
end