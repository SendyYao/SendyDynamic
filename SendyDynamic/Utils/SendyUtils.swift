//
//  SendyUtils.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/14.
//

import Foundation
import SystemConfiguration
import Network
import CoreLocation
import SystemConfiguration.CaptiveNetwork
import NetworkExtension

final class SendyUtils {
    
    static let shared = SendyUtils()
    
    private init() {}
    
    // MARK: - 网络连通性（WIFI / 蜂窝）
    func isNetworkReachable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { return false }
        
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(reachability, &flags) else { return false }
        
        return flags.contains(.reachable)
    }
    
    // MARK: Connet via WIFI
    func isReachableViaWiFi() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "apple.com"),
              SCNetworkReachabilityGetFlags(reachability, &flags) else { return false }
        
        return flags.contains(.reachable) && !flags.contains(.isWWAN)
    }
    
    // MARK: Judge LocalNetwork
    func canReachLocalAPI(urlString: String, timeout: TimeInterval = 1.5) async -> Bool {
        
        guard let url = URL(string: urlString) else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                return http.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
    
    // MARK: SSID & BSSID
    func getCurrentWiFiInfo() -> (ssid: String?, bssid: String?) {
        guard let interfaces = CNCopySupportedInterfaces() as? [String]
        else {
            return (nil, nil)
        }
        
        for interface in interfaces {
            print(interface)
            if let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] {
                let ssid = info[kCNNetworkInfoKeySSID as String] as? String
                let bssid = info[kCNNetworkInfoKeyBSSID as String] as? String
                
                return (ssid, bssid)
            }
        }
        return (nil, nil)
    }
}
