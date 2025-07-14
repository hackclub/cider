//
//  WeatherIconMapper.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-30.
//

import Foundation


struct WeatherIconMapper {

    
    
    
    static func map(from code: Int) -> String {
        switch code {
        
        case 0: return "tornado" 
        case 1: return "tropicalstorm" 
        case 2: return "hurricane" 
        case 3: return "cloud.bolt.rain.fill" 
        case 4: return "cloud.bolt.rain.fill" 
        
        
        case 5: return "cloud.sleet.fill" 
        case 6: return "cloud.sleet.fill" 
        case 7: return "cloud.sleet.fill" 
        case 8: return "cloud.hail.fill" 
        case 10: return "thermometer.snowflake" 

        
        case 9: return "cloud.drizzle.fill" 
        case 11: return "cloud.rain.fill" 
        case 12: return "cloud.heavyrain.fill" 
        case 40: return "cloud.heavyrain.fill" 
        case 35: return "cloud.hail.fill" 

        
        case 13: return "cloud.snow.fill" 
        case 14: return "cloud.snow.fill" 
        case 15: return "wind.snow" 
        case 16: return "snowflake" 
        case 42: return "cloud.snow.fill" 
        case 43: return "snowflake" 

        
        case 17: return "cloud.hail.fill" 
        case 18: return "cloud.sleet.fill" 

        
        case 19: return "wind" 
        case 20: return "cloud.fog.fill" 
        case 21: return "sun.haze.fill" 
        case 22: return "smoke.fill" 
            
        
        case 23: return "wind" 
        case 24: return "wind" 
            
        
        case 25: return "thermometer.snowflake" 

        
        case 26: return "cloud.fill" 

        
        case 27: return "cloud.moon.fill" 
        case 29: return "cloud.moon.fill" 
        case 31: return "moon.stars.fill" 
        case 33: return "moon.fill" 

        
        case 28: return "cloud.sun.fill" 
        case 30: return "cloud.sun.fill" 
        case 32: return "sun.max.fill" 
        case 34: return "sun.min.fill" 

        
        case 37: return "cloud.sun.bolt.fill" 
        case 38: return "cloud.sun.rain.fill" 
        case 39: return "cloud.sun.rain.fill" 
        case 41: return "cloud.sun.rain.fill" 

        
        case 45: return "cloud.moon.rain.fill" 
        case 46: return "cloud.moon.rain.fill" 
        case 47: return "cloud.moon.bolt.fill" 
            
        
        case 36: return "sun.max.trianglebadge.exclamationmark" 

        
        case 44: return "questionmark.circle" 

        default:
            return "questionmark.circle" 
        }
    }
}
