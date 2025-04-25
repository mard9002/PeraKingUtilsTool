//
//  RequestApplicationModel.swift
//  PeraKing
//  
//  Created by wealon on 2025.
//  PeraKing.
//  
    

import Foundation
import SmartCodable

@objc public class RequestApplicationModel: BaseModel, SmartCodable {
    /// 根据此连接跳转即可
    public var obscured: String?
}
