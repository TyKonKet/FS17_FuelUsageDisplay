--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 04/04/2017
function WorkArea:getTypedNetworkAreasArea(areaType)
    local area = 0;
    local typedWorkAreas = self:getTypedWorkAreas(areaType);
    for _, workArea in pairs(typedWorkAreas) do
        local x, _, z = getWorldTranslation(workArea.start);
        local x1, _, z1 = getWorldTranslation(workArea.width);
        local x2, _, z2 = getWorldTranslation(workArea.height);
        area = area + math.abs((z1 - z) * (x2 - x) - (x1 - x) * (z2 - z));
    end
    return area;
end
