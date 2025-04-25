//
//  FetchContactInfoModel.swift
//  PeraKing
//  
//  Created by wealon on 2025.
//  PeraKing.
//  
    

import Foundation
import SmartCodable
// MARK: - 主模型
@objc public class FetchContactInfoModel: BaseModel, SmartCodable {
    public var money: ContactGroupModel? // 联系人组
}

// MARK: - 联系人组模型
@objc public class ContactGroupModel: BaseModel, SmartCodable {
    public var takes: [ContactItemModel] = [] // 联系人数组，数量根据接口下发来
    public var halfway: String? // 其他附加字段（未明确用途，暂定为 String 类型）
   
}

// MARK: - 联系人项模型
@objc public class ContactItemModel: NSObject, SmartCodable {
    public var bastard: String = "" // 当前 item 选中的关系 key（回显的时候会用到）
    public var tens: String = "" // 当前 item 联系人的姓名（用于回显）
    public var objects: String = "" // 当前 item 联系人的电话（用于回显）
    public var carrying: String = "" // 当前 item 的标识 number（用于保存数据）
    public var men: String = "" // 当前 item 的标题 （用于显示）
    public var bush: String = "" // 选择关系的 title（图片或文案）（用于显示）
    public var hid: String = "" // 选择关系的提示 （用于显示）
    public var instinct: String = "" // 选择号码的 title（图片或文案）（用于显示）
    public var leaves: String = "" // 选择号码的提示（用于显示）
    public var rustling: [OptionModel] = [] // 关系选项的列表
   
    required public override init() {
    }
}
