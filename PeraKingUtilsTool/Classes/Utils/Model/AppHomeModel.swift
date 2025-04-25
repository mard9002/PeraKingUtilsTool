//
//  ResponseModel.swift
//  PeraKing
//
//  Created by wealon on 2025.
//  PeraKing.
//


import Foundation
import SmartCodable


@objc public class AppHomeModel: NSObject, SmartCodable {
    public var guns: Guns? // 大卡位或小卡位，必有，重点
    public var dirt: Dirt? // 逾期提醒模块，首页2才展示，可能有多条，做成轮播样式
    public var creatures: Creatures? // 产品列表模块（也叫极速列表），首页2才有
    public var jaws: Int? // 强制定位字段：1强制，0不强制
    public var hidden: Int? // 首页差异化模块显示状态：1表示显示，0表示不显示
    public var fangs: String? // 选用文案1，有需求才用
    public var exposing: String? // 选用文案2，有需求才用
    public var skillfully: String? // 选用文案3，有需求才用
    public var extorted: Extorted? // 联系我们模块，根据UI来，有则显示，没有不显示
    public var zaocys: Answerive? // Banner模块，取下发的，没有则不用管
    
    required public override init() {}
}

// MARK: - 大卡位或小卡位模型
@objc public class Guns: NSObject, SmartCodable {
    public var escape: String = "" // 判断是大卡位（首页1）还是小卡位（首页2），返回的是混淆后的数据
    public var  safer: [Safer] = [] // 产品列表
    
    required public override init() {}
}
// MARK: - 产品详细信息模型
@objc public class Safer: NSObject, SmartCodable {
    public var shield: Int? // 产品ID
    public var steered: String = "" // 产品名称
    public var remained: String = ""// 产品Logo
    public var replied: String = ""// 按钮文案（大卡位按钮的文案）
    public var pistol: String = "" // 贷款金额
    public var security: String = "" // 贷款金额的描述文案
    public var topclass: String = "" // 贷款期限
    public var working: String = ""// 贷款期限单位
    public var experience: String = "" // 贷款期限的描述文案
    public var tighten: String = ""// 贷款利率
    public var caused: String = "" // 贷款利率的描述文案
    
    required public override init() {}
}

// MARK: - 逾期提醒模块模型
@objc public class Dirt: NSObject, SmartCodable {
    public var escape: String = ""// 模块标识
    public var safer: [RepayHisence] = []// 逾期提醒列表
    
    required public override init() {}
}
// MARK: - 逾期提醒详细信息模型
@objc public class RepayHisence: NSObject, SmartCodable {
    public var panic: String = "" // 显示文案，直接展示
    public var obscured: String? // 跳转地址，一般是个H5的地址，直接跳转就行
    
    required public override init() {}
}

// MARK: - 产品列表模块模型
@objc public class Creatures: NSObject, SmartCodable {
    public var escape: String = "" // 模块标识
    public var safer: [ProductHisence] = [] // 产品列表
    
    required public override init() {}
}

// MARK: - 产品列表详细信息模型
@objc public class ProductHisence: NSObject, SmartCodable {
    public var shield: Int? // 产品ID
    public var steered: String = "" // 产品名称
    public var remained: String = "" // 产品Logo
    public var replied: String = "" // 按钮文案
    public var facial: String? // 贷款金额
    public var security: String = "" // 贷款金额的描述文案
    public var observing: String = "" // 贷款利率
    public var caused: String = "" // 贷款利率的描述文案
    public var quietly: String = "" // 贷款期限
    public var buckle: String = "" // 贷款期限的描述文案
    
    // 以下字段基本用不到，看需求
    public var pistol: String? // 贷款额度范围
    public var real: String? // 产品标签
    public var playing: String? // 产品描述
    public var cking: String? // 产品编码
    public var toy: String? // 颜色
    public var witness: String? // 按钮状态
    public var obscured: String? // 产品地址
    public var topclass: String?
    public var medicine: String? // 描述文案
    public var traditional: String?
    public var tighten: String?
    public var valuable: String?
    public var venoms: String?
    
    required public override init() {}
}

// MARK: - 联系我们模块模型
@objc public class Extorted: NSObject, SmartCodable {
    public var bitten: String = "" // 显示的图片的URL
    public var venomous: String = "" // 跳转的URL
    
    required public override init() {}
}
// MARK: - Banner模块模型
@objc public class Answerive: NSObject, SmartCodable {
    public  var escape: String = "" // 模块标识
    public var safer: [SaferModel] = [] // Banner列表
    required public override init() {}
}
// MARK: - Banner详细信息模型
@objc public class SaferModel: BaseModel, SmartCodable {
    public var obscured: String? // 跳转的URL，不为空时点击跳转即可
    public var lightly: String = "" // 显示的图片的URL
}
