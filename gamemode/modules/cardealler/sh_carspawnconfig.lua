NextRP.CarDealer = NextRP.CarDealer or {}


function NextRP.CarDealer:GetVehicleCost(vehicleClass)
    -- 1. Проверяем в таблице VehicleCosts
    if self.VehicleCosts[vehicleClass] then
        return self.VehicleCosts[vehicleClass]
    end
    
    -- 2. Проверяем в NextRPCarList (cars.txt) - поле supplyPrice
    if NextRPCarList then
        for _, carData in pairs(NextRPCarList) do
            if carData.class == vehicleClass and carData.supplyPrice then
                return carData.supplyPrice
            end
        end
    end
    
    -- 3. Возвращаем стоимость по умолчанию
    return self.DefaultVehicleCost
end

-- Стоимость техники по умолчанию (если не указана в cars.txt)
NextRP.CarDealer.DefaultVehicleCost = 2000


NextRP.CarDealer.VehicleCosts = {
    -- Примеры (раскомментируй и настрой под свои классы):
    -- ["lvs_wheeldrive_dc15"] = 50,
    -- ["lvs_wheeldrive_tx130"] = 200,
    -- ["lvs_wheeldrive_atte"] = 500,
    -- ["lvs_repulsor_laat"] = 300,
}