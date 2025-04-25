//
//  MarkUploadModel.swift
//  PeraKing
//  
//  Created by wealon on 2025.
//  PeraKing.
//  
    

import Foundation
import SmartCodable

@objc public class MarkUploadModel: BaseModel, SmartCodable {
    public var facebook: FacebookModel?
}


@objc public class FacebookModel: BaseModel, SmartCodable {
    public  var cFBundleURLScheme: String = ""
    public var facebookAppID: String = ""
    public var facebookDisplayName: String = ""
    public var facebookClientToke: String = ""
}
