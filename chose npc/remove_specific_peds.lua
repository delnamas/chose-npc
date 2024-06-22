-- remove_specific_peds.lua

-- Liste des modèles de PNJ à supprimer
local pedsToRemove = {
    "s_f_y_cop_01",         -- FBI Agent
    "s_m_y_swat_01",        -- Agent de la NOOSE
    "s_m_m_fibsec_01",      -- Agent du FIB
    "s_m_y_sheriff_01",     -- Sheriff
    "s_m_y_fireman_01",     -- Pompier
    "s_m_m_paramedic_01",   -- Paramédic
    "s_m_m_prisguard_01",   -- Gardien de prison
    "s_m_y_cop_01",         -- Policier en moto
    "s_m_m_fiboffice_01",   -- Agent du FIB en costume
    "s_f_y_prisguard_01",   -- Gardien de prison (version féminine)
    "s_f_y_fireman_01",     -- Pompier (version féminine)
    "s_m_m_security_01",    -- Garde de sécurité
    "s_f_y_security_01"     -- Garde de sécurité féminin
    
}

    

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Vérifie toutes les secondes
        for ped in EnumeratePeds() do
            if DoesEntityExist(ped) then
                local pedModel = GetEntityModel(ped)
                for _, model in ipairs(pedsToRemove) do
                    if pedModel == GetHashKey(model) then
                        DeleteEntity(ped)
                    end
                end
            end
        end
    end
end)

-- Fonction pour énumérer tous les PNJ
function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, entity = initFunc()
        if not entity or entity == 0 then
            disposeFunc(iter)
            return
        end

        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
            coroutine.yield(entity)
            next, entity = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

-- Méta-table pour l'énumération des entités
entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}
