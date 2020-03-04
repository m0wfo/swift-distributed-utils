//
//  File.swift
//  
//
//  Created by Chris Mowforth on 15/02/2020.
//

import Foundation

public protocol ConfigProvider {

    func getStringValue(_ key: String) -> String?
}

final class EnvironmentConfigProvider : ConfigProvider {
    
    public func getStringValue(_ key: String) -> String? {
        return ProcessInfo.processInfo.environment[key]
    }
}

final class GithubConfigProvider : ConfigProvider {
    
    public func getStringValue(_ key: String) -> String? {
        return nil
    }
}
