--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 04/04/2017
function EffectManager:startedEffects(effects)
    if effects ~= nil then
        for _, effect in pairs(effects) do
            if EffectManager:startedEffect(effect) then
                return true
            end
        end
    end
    return false
end

function EffectManager:startedEffect(effect)
    if effect ~= nil and effect.state ~= nil and (effect.state == ShaderPlaneEffect.STATE_TURNING_ON or effect.state == ShaderPlaneEffect.STATE_ON) then
        return true
    else
        return false
    end
end
