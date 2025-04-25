//
//  UserInfo.swift
//  PeraKing
//  
//  Created by wealon on 2025.
//  PeraKing.
//  
    

import Foundation

@objc public class UserInfo: NSObject {
    @objc public static var token: String  {
        set {
            StorageManager.UserDefaultsManager.save(newValue, forKey: "userToken")
        }
        get {
            let token: String? = StorageManager.UserDefaultsManager.value(forKey: "userToken")
            return token ?? ""
        }
    }
    @objc public static var phone: String  {
        set {
            StorageManager.UserDefaultsManager.save(newValue, forKey: "UserPhoneNum")
        }
        get {
            let phone: String? = StorageManager.UserDefaultsManager.value(forKey: "UserPhoneNum")
            return phone ?? ""
        }
    }
    
    @objc public static var one: Bool {
        set {
            StorageManager.UserDefaultsManager.save(newValue, forKey: "userOne")
        }
        get {
            let value: Bool? = StorageManager.UserDefaultsManager.value(forKey: "userOne")
            return value ?? false
        }
    }
    
    @objc public static var oneStartTime: String  {
        set {
            StorageManager.UserDefaultsManager.save(newValue, forKey: "oneStartTime")
        }
        get {
            let token: String? = StorageManager.UserDefaultsManager.value(forKey: "oneStartTime")
            return token ?? ""
        }
    }
    
    @objc public static var oneEndTime: String  {
        set {
            StorageManager.UserDefaultsManager.save(newValue, forKey: "oneEndTime")
        }
        get {
            let token: String? = StorageManager.UserDefaultsManager.value(forKey: "oneEndTime")
            return token ?? ""
        }
    }
    
    
    @objc public static var  cFBundleURLScheme: String {
        set {
            StorageManager.UserDefaultsManager.save(newValue, forKey: "cFBundleURLScheme")
        }
        get {
            let token: String? = StorageManager.UserDefaultsManager.value(forKey: "cFBundleURLScheme")
            return token ?? ""
        }
    }
    @objc public static var  facebookAppID: String {
        set {
            StorageManager.UserDefaultsManager.save(newValue, forKey: "facebookAppID")
        }
        get {
            let token: String? = StorageManager.UserDefaultsManager.value(forKey: "facebookAppID")
            return token ?? ""
        }
    }
    @objc public static var  facebookDisplayName: String {
        set {
            StorageManager.UserDefaultsManager.save(newValue, forKey: "facebookDisplayName")
        }
        get {
            let token: String? = StorageManager.UserDefaultsManager.value(forKey: "facebookDisplayName")
            return token ?? ""
        }
    }
    @objc public static var  facebookClientToke: String {
        set {
            StorageManager.UserDefaultsManager.save(newValue, forKey: "facebookClientToke")
        }
        get {
            let token: String? = StorageManager.UserDefaultsManager.value(forKey: "facebookClientToke")
            return token ?? ""
        }
    }
}
