//
//  FetchUserAuthenticationInfoModel.swift
//  PeraKing
//  
//  Created by wealon on 2025.
//  PeraKing.
//  
    

import Foundation
import SmartCodable

@objc public class FetchUserAuthenticationInfoModel: BaseModel, SmartCodable {
    public var gang: [GangItemModel] = [] // 动态表单数组，真实数据根据接口下发
}
// MARK: - 表单项模型
@objc public class GangItemModel: BaseModel, SmartCodable {
    public var shield: Int? // 表单项的唯一 ID
    public var connect: String = "" // 表单项的标题，如 "Education"
    public var gen: String = "" // 表单项的提示文本，如 "Please select education"
    public var downwards: String = "" // 表单项的唯一标识，用于保存时作为 key
    public var obviously: String = "" // 表单项的类型，如 "stepped"（单选框）、"onto"（输入框）
    public var paid: Int = 0 // 键盘类型，0 为全键盘，1 为数字键盘
    public var upwards: [OptionModel] = [] // 单选框的选项数组
    public var hawk: Int? // 其他附加字段（未明确用途，暂定为 Int 类型）
    public var grandpa: Int = 0 // 表单项的完成状态（0 未完成，1 已完成）
    public var arrive: String = "" // 表单项的状态描述，如 "Certified"
    public var box: Bool = false // 表单项是否出错（true 出错，false 正常）
    public var beneath: String = "" // 表单项的值，用于展示或回显
    public var escape: String = "" // 表单项的 key，用于保存时传参
    public var sniffed: Int? // 其他附加字段（未明确用途，暂定为 Int 类型）
}

// MARK: - 单选框选项模型
@objc public class OptionModel: BaseModel, SmartCodable {
    public var tens: String = "" // 单选框的值，用于显示和回显
    public var escape: String = "" // 单选框的 key，用于保存时传参
}
