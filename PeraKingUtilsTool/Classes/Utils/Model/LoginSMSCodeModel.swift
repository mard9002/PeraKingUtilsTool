//
//  LoginSMSCodeModel.swift
//  PeraKing
//  
//  Created by wealon on 2025.
//  PeraKing.
//  
    

import Foundation
import SmartCodable

@objc public class LoginSMSCodeModel: NSObject, SmartCodable {
    /// 手机号
    @objc public var brace: String = ""
    /// sessionId
    @objc public var subtly: String = ""
    required public override init() {}
}

