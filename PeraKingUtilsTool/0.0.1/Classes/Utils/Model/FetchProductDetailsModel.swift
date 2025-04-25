//
//  FetchProductDetailsModel.swift
//  PeraKing
//  
//  Created by wealon on 2025.
//  PeraKing.
//  
    

import Foundation
import SmartCodable

@objc public class FetchProductDetailsModel: BaseModel, SmartCodable {
    public var belt: Int? // 先判断这个字段，如果不等于200，取url(混淆前)字段拼上公参跳转，等于200正常显示以下数据
    public var frequently: ProductInfo? // 产品信息
    public var heaviest: [CertificationItem] = [] // 认证项列表（注意：认证项可能下发 4 项或 5 项，不要写死数量）
    public var steal: NextStep? // 下一步信息
}

// MARK: - 产品信息模型
@objc public class ProductInfo: BaseModel, SmartCodable {
    public var shield: String = "" // 产品 ID << 从这里取产品 ID >>
    public var steered: String = "" // 产品名称
    public var gym: String = ""// 订单号
    public var lu: String? // 订单 ID
    public var women: String = ""// 金额
    public var bedding: String? // 金额描述文案（该字段下发数据为空时用 UI 上给的写死即可）
    public var spend: String = "" // 期限
    public var sarcastically: String? // 期限描述文案（该字段下发数据为空时用 UI 上给的写死即可）
    public var observing: String = ""// 利率
    public  var tall: String? // 利率描述文案（该字段下发数据为空时用 UI 上给的写死即可）
}

// MARK: - 认证项模型
@objc public class CertificationItem: BaseModel, SmartCodable {
    public var connect: String = ""// 标题
    public var gen: String = ""// 副标题
    public var escape: String? // 标识
    public var obscured: String? // 跳转地址
    public var grandpa: Int = 0 // 是否已完成认证（0 否，1 是）
    public var arrive: String = ""// 认证类型
    public var cliff: String = ""// 认证项类型
    public var beak: String? // 标识
    public var hawk: String? // 标识
    public var destination: String? // 标识
    public var battalion: String = ""// 提示文案
    public var classified: String = "" // 认证项 Logo
}

// MARK: - 下一步模型
@objc public class NextStep: BaseModel, SmartCodable {
    public var cliff: String? // 判断此字段，如果为空说明认证项已全部认证成功，如果有值就跳转到对应认证项
    public var obscured: String? // 跳转地址
    public var escape: String? // 标识
    public var connect: String = "" // 下一步的标题
}
