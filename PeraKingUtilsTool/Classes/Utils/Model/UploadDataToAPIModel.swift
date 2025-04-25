//
//  UploadDataToAPIModel.swift
//  PeraKing
//
//  Created by wealon on 2025.
//  PeraKing.
//


import Foundation
import SmartCodable

@objc public class UploadDataToAPIModel: BaseModel, SmartCodable {
    public var tens: String? // 姓名
    public var cost: String? // 证件号（用全键盘编辑）
    public var peeling: String? // 性别
    public var imported: String? // 出生日期（日-月-年，编辑时带入识别出的日期）
    public var obscured: String? // 图片地址
    public var canon: String? // 出生年份
    public var helpful: String? // 出生月份
    public var taller: String? // 出生日期
}
