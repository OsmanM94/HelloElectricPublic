//
//  EVDatabase.swift
//  Clin
//
//  Created by asia on 13/09/2024.
//

import Foundation

// MARK: - EVDatabase
struct EVDatabase: Codable, Identifiable, Hashable {
    let availability,
        availableSince,
        rangeCityCold,
        rangeHighwayCold: String?
    
    let rangeCombinedCold,
        rangeCityMild,
        rangeHighwayMild,
        rangeCombinedMild: String?
    
    let performanceAcceleration0_62_Mph,
        performanceTopSpeed,
        electricRange,
        totalPower: String?
    
    let drive,
        batteryNominalCapacity,
        batteryType,
        numberOfCells: String?
    
    let batteryArchitecture,
        batteryWarranty,
        warrantyMileage,
        batteryUseableCapacity: String?
    
    let batteryCathodeMaterial,
        batteryPackConfiguration,
        batteryNominalVoltage,
        batteryFormFactor: String?
    
    let batteryName,
        chargingHomePort,
        chargingHomePortLocation,
        chargingHomeChargePower: String?
    
    let chargingHomeChargeTime,
        chargingHomeChargeSpeed,
        chargingHomeChargePowerMax,
        chargingHomeAutochargeSupported: String?
    
    let chargingRapidPort,
        chargingRapidPortLocation,
        chargingRapidChargeSpeed,
        chargingRapidAutochargeSupported: String?
    
    let efficiencyRealRangeConsumption,
        efficiencyFuelEquivalent,
        dimensionsAndWeightLenght,
        dimensionsAndWeightWidth: String?
    
    let dimensionsAndWeightWidthMirrors,
        dimensionsAndWeightWheelbase,
        dimensionsAndWeightWeightUnladen,
        dimensionsGrossWeight: String?
    
    let dimensionsPayload,
        dimensionsCargoVolume,
        dimensionsCargoVolumeMax,
        dimensionsRoofLoad: String?
    
    let dimensionsTow,
        dimensionsTowingUnbraked,
        dimensionsTowingBraked,
        miscellaneousSeats: String?
    
    let miscellaneousTurningCircle,
        miscellaneousPlatform,
        miscellaneousBody,
        miscellaneousSegment: String?
    
    let miscellaneousRoofRails,
        miscellaneousHeatPump,
        miscellaneousHPStandardEquipment: String?
    
    let image1: [String]?
    
    let availableOrderFrom,
        firstDeliveryExpected,
        performanceTorque,
        carName: String?
    
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case availability
        case availableSince = "available_since"
        case rangeCityCold = "range_city_cold"
        case rangeHighwayCold = "range_highway_cold"
        case rangeCombinedCold = "range_combined_cold"
        case rangeCityMild = "range_city_mild"
        case rangeHighwayMild = "range_highway_mild"
        case rangeCombinedMild = "range_combined_mild"
        case performanceAcceleration0_62_Mph = "performance_acceleration_0_62_mph"
        case performanceTopSpeed = "performance_top_speed"
        case electricRange = "electric_range"
        case totalPower = "total_power"
        case drive
        case batteryNominalCapacity = "battery_nominal_capacity"
        case batteryType = "battery_type"
        case numberOfCells = "number_of_cells"
        case batteryArchitecture = "battery_architecture"
        case batteryWarranty = "battery_warranty"
        case warrantyMileage = "warranty_mileage"
        case batteryUseableCapacity = "battery_useable_capacity"
        case batteryCathodeMaterial = "battery_cathode_material"
        case batteryPackConfiguration = "battery_pack_configuration"
        case batteryNominalVoltage = "battery_nominal_voltage"
        case batteryFormFactor = "battery_form_factor"
        case batteryName = "battery_name"
        case chargingHomePort = "charging_home_port"
        case chargingHomePortLocation = "charging_home_port_location"
        case chargingHomeChargePower = "charging_home_charge_power"
        case chargingHomeChargeTime = "charging_home_charge_time"
        case chargingHomeChargeSpeed = "charging_home_charge_speed"
        case chargingHomeChargePowerMax = "charging_home_charge_power_max"
        case chargingHomeAutochargeSupported = "charging_home_autocharge_supported"
        case chargingRapidPort = "charging_rapid_port"
        case chargingRapidPortLocation = "charging_rapid_port_location"
        case chargingRapidChargeSpeed = "charging_rapid_charge_speed"
        case chargingRapidAutochargeSupported = "charging_rapid_autocharge_supported"
        case efficiencyRealRangeConsumption = "efficiency_real_range_consumption"
        case efficiencyFuelEquivalent = "efficiency_fuel_equivalent"
        case dimensionsAndWeightLenght = "dimensions_and_weight_lenght"
        case dimensionsAndWeightWidth = "dimensions_and_weight_width"
        case dimensionsAndWeightWidthMirrors = "dimensions_and_weight_width_mirrors"
        case dimensionsAndWeightWheelbase = "dimensions_and_weight_wheelbase"
        case dimensionsAndWeightWeightUnladen = "dimensions_and_weight_weight_unladen"
        case dimensionsGrossWeight = "dimensions_gross_weight"
        case dimensionsPayload = "dimensions_payload"
        case dimensionsCargoVolume = "dimensions_cargo_volume"
        case dimensionsCargoVolumeMax = "dimensions_cargo_volume_max"
        case dimensionsRoofLoad = "dimensions_roof_load"
        case dimensionsTow = "dimensions_tow"
        case dimensionsTowingUnbraked = "dimensions_towing_unbraked"
        case dimensionsTowingBraked = "dimensions_towing_braked"
        case miscellaneousSeats = "miscellaneous_seats"
        case miscellaneousTurningCircle = "miscellaneous_turning_circle"
        case miscellaneousPlatform = "miscellaneous_platform"
        case miscellaneousBody = "miscellaneous_body"
        case miscellaneousSegment = "miscellaneous_segment"
        case miscellaneousRoofRails = "miscellaneous_roof_rails"
        case miscellaneousHeatPump = "miscellaneous_heat_pump"
        case miscellaneousHPStandardEquipment = "miscellaneous_hp_standard_equipment"
        case image1 = "image_1"
        case availableOrderFrom = "available_order_from"
        case firstDeliveryExpected = "first_delivery_expected"
        case performanceTorque = "performance_torque"
        case carName = "car_name"
        case id
    }
}

extension EVDatabase {
    static let sampleData: EVDatabase = EVDatabase(
        availability: "Available",
        availableSince: "2024",
        rangeCityCold: "300 km",
        rangeHighwayCold: "250 km",
        rangeCombinedCold: "275 km",
        rangeCityMild: "350 km",
        rangeHighwayMild: "300 km",
        rangeCombinedMild: "325 km",
        performanceAcceleration0_62_Mph: "7.5 sec",
        performanceTopSpeed: "180 km/h",
        electricRange: "510 km",
        totalPower: "150 kW",
        drive: "Rear Wheel Drive",
        batteryNominalCapacity: "77 kWh",
        batteryType: "Lithium-ion",
        numberOfCells: "288",
        batteryArchitecture: "Pouch",
        batteryWarranty: "8 years",
        warrantyMileage: "160,000 km",
        batteryUseableCapacity: "82 kWh",
        batteryCathodeMaterial: "NMC 811",
        batteryPackConfiguration: "12 modules, 24 cells each",
        batteryNominalVoltage: "352 V",
        batteryFormFactor: "Pouch",
        batteryName: "ID.4 Pro Battery",
        chargingHomePort: "Type 2",
        chargingHomePortLocation: "Right rear",
        chargingHomeChargePower: "11 kW AC",
        chargingHomeChargeTime: "7h 30min",
        chargingHomeChargeSpeed: "50 km/h",
        chargingHomeChargePowerMax: "11 kW",
        chargingHomeAutochargeSupported: "Yes",
        chargingRapidPort: "CCS",
        chargingRapidPortLocation: "Right rear",
        chargingRapidChargeSpeed: "550 km/h",
        chargingRapidAutochargeSupported: "Yes",
        efficiencyRealRangeConsumption: "18 kWh/100km",
        efficiencyFuelEquivalent: "2.0 L/100km",
        dimensionsAndWeightLenght: "4.58 m",
        dimensionsAndWeightWidth: "1.85 m",
        dimensionsAndWeightWidthMirrors: "2.11 m",
        dimensionsAndWeightWheelbase: "2.77 m",
        dimensionsAndWeightWeightUnladen: "2,124 kg",
        dimensionsGrossWeight: "2,660 kg",
        dimensionsPayload: "536 kg",
        dimensionsCargoVolume: "543 L",
        dimensionsCargoVolumeMax: "1,575 L",
        dimensionsRoofLoad: "75 kg",
        dimensionsTow: "Yes",
        dimensionsTowingUnbraked: "750 kg",
        dimensionsTowingBraked: "1,000 kg",
        miscellaneousSeats: "5",
        miscellaneousTurningCircle: "10.2 m",
        miscellaneousPlatform: "MEB",
        miscellaneousBody: "SUV",
        miscellaneousSegment: "D",
        miscellaneousRoofRails: "Optional",
        miscellaneousHeatPump: "Optional",
        miscellaneousHPStandardEquipment: "No",
        image1: [
            "https://ev-database.org/img/auto/Volkswagen_ID4_2024/Volkswagen_ID4_2024-01@2x.jpg",
            "https://ev-database.org/img/auto/Volkswagen_ID4_2024/Volkswagen_ID4_2024-02@2x.jpg"
        ],
        availableOrderFrom: "Now",
        firstDeliveryExpected: "Q1 2024",
        performanceTorque: "310 Nm",
        carName: "Volkswagen ID.4 (2024)",
        id: 1
    )
}
