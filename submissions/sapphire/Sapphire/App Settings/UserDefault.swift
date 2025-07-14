//
//  UserDefault.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI
import Combine


private let appGroupSuite = UserDefaults(suiteName: "group.com.shariq.sapphire")

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            
            guard let data = appGroupSuite?.data(forKey: key) else {
                return defaultValue
            }
            do {
                let value = try JSONDecoder().decode(Value.self, from: data)
                return value
            } catch {
                if let encodedDefault = try? JSONEncoder().encode(defaultValue) {
                    appGroupSuite?.set(encodedDefault, forKey: key)
                }
                return defaultValue
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                
                appGroupSuite?.set(data, forKey: key)
            } catch {
            }
        }
    }
}
