import Foundation
import Contacts
import ContactsUI
import UIKit

/// 通讯录管理工具类
public final class ContactsManager: NSObject {
    
    // MARK: - 公共类型
    
    /// 联系人信息结构
    public struct ContactInfo: Codable {
        /// 手机号，多个用逗号分割
        public var phones: String = ""
        /// 联系人姓名
        public var name: String = ""
        
        public init(name: String = "", phones: String = "") {
            self.name = name
            self.phones = phones
        }
    }
    
    /// 联系人选择成功回调类型
    public typealias ContactSelectedSuccessCallback = ((_ contact: ContactInfo) -> Void)
    
    /// 联系人选择错误回调类型
    public typealias ContactSelectedErrorCallback = ((_ errorMessage: String) -> Void)
    
    /// 获取所有联系人回调类型
    public typealias AllContactsCallback = ((_ contacts: [ContactInfo]) -> Void)
    
    // MARK: - 私有属性
    private let contactStore = CNContactStore()
    private var currentViewController: UIViewController?
    private var successCallback: ContactSelectedSuccessCallback?
    private var errorCallback: ContactSelectedErrorCallback?
    
    // MARK: - 共享实例
    public static let shared = ContactsManager()
    
    // MARK: - 初始化
    private override init() {
        super.init()
    }
    
    // MARK: - 公共方法
    
    /// 选择联系人
    /// - Parameters:
    ///   - viewController: 用于展示联系人选择器的视图控制器
    ///   - success: 选择成功回调（联系人有姓名和手机号）
    ///   - error: 选择错误回调（联系人缺少姓名或手机号）
    public func selectContact(
        from viewController: UIViewController,
        success: @escaping ContactSelectedSuccessCallback,
        error: @escaping ContactSelectedErrorCallback
    ) {
        // 保存回调和当前控制器
        self.currentViewController = viewController
        self.successCallback = success
        self.errorCallback = error
        
        // 检查通讯录权限
        checkContactsPermission { [weak self] granted in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if granted {
                    // 展示联系人选择器
                    self.showContactPicker()
                } else {
                    // 通知权限错误
                    error("未获得通讯录访问权限")
                }
            }
        }
    }
    
    /// 获取所有联系人信息
    /// - Parameter completion: 完成回调，返回所有联系人数组
    public func getAllContacts(completion: @escaping AllContactsCallback) {
        // 检查通讯录权限
        checkContactsPermission { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                // 在后台线程获取联系人
                DispatchQueue.global(qos: .userInitiated).async {
                    let contacts = self.fetchAllContacts()
                    
                    // 在主线程回调结果
                    DispatchQueue.main.async {
                        completion(contacts)
                    }
                }
            } else {
                // 权限被拒绝，返回空数组
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 检查通讯录访问权限
    public func checkContactsPermission(completion: @escaping (Bool) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .authorized:
            // 已有权限
            completion(true)
            
        case .notDetermined:
            // 请求权限
            contactStore.requestAccess(for: .contacts) { granted, error in
                if let error = error {
                    print("请求通讯录权限出错: \(error.localizedDescription)")
                }
                completion(granted)
            }
            
        case .restricted, .denied:
            // 权限被拒绝或受限
            completion(false)
            
        case .limited:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    /// 展示联系人选择器
    private func showContactPicker() {
        guard let viewController = currentViewController else { return }
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey]
        
        viewController.present(contactPicker, animated: true)
    }
    
    /// 获取所有联系人信息
    private func fetchAllContacts() -> [ContactInfo] {
        var results: [ContactInfo] = []
        
        // 需要获取的联系人属性
        let keys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey
        ]
        
        // 创建请求
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        // 执行请求
        do {
            try contactStore.enumerateContacts(with: request) { contact, _ in
                // 获取联系人信息
                if !contact.phoneNumbers.isEmpty {
                    let contactInfo = self.createContactInfo(from: contact)
                    if !contactInfo.phones.isEmpty {
                        results.append(contactInfo)
                    }
                }
            }
        } catch {
            print("获取联系人出错: \(error.localizedDescription)")
        }
        
        return results
    }
    
    /// 从CNContact创建ContactInfo
    private func createContactInfo(from contact: CNContact) -> ContactInfo {
        var contactInfo = ContactInfo()
        
        // 获取姓名
        let fullName = "\(contact.familyName)\(contact.givenName)"
        contactInfo.name = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 如果姓名为空，尝试使用公司名称
        if contactInfo.name.isEmpty, let organizationName = contact.organizationName as String?, !organizationName.isEmpty {
            contactInfo.name = organizationName
        }
        
        // 获取所有电话号码
        var phones: [String] = []
        for phoneNumber in contact.phoneNumbers {
            // 格式化电话号码（仅保留数字）
            let phoneValue = phoneNumber.value.stringValue
            let formattedPhone = phoneValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
            if !formattedPhone.isEmpty {
                phones.append(formattedPhone)
            }
        }
        
        // 合并电话号码
        contactInfo.phones = phones.joined(separator: ",")
        
        return contactInfo
    }
}

// MARK: - CNContactPickerDelegate
extension ContactsManager: CNContactPickerDelegate {
    
    public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        // 用户取消选择
        currentViewController = nil
    }
    
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // 用户选择了一个联系人
        defer {
            currentViewController = nil
        }
        
        // 解析联系人信息
        let contactInfo = createContactInfo(from: contact)
        
        // 检查是否有姓名和手机号
        if contactInfo.name.isEmpty {
            errorCallback?("The selected contact person has no name")
            return
        }
        
        if contactInfo.phones.isEmpty {
            errorCallback?("The selected contact person doesn't have a phone number")
            return
        }
        
        // 选择成功
        successCallback?(contactInfo)
    }
}

// MARK: - 示例代码
/*
使用示例:

// 1. 选择联系人
func selectContactExample() {
    guard let viewController = UIApplication.shared.windows.first?.rootViewController else { return }
    
    ContactsManager.shared.selectContact(
        from: viewController,
        success: { contact in
            print("选择联系人成功: \(contact.name), 电话: \(contact.phones)")
        },
        error: { errorMessage in
            print("选择联系人错误: \(errorMessage)")
        }
    )
}

// 2. 获取所有联系人
func getAllContactsExample() {
    print("正在获取所有联系人...")
    
    ContactsManager.shared.getAllContacts { contacts in
        print("获取到 \(contacts.count) 个联系人")
        
        for (index, contact) in contacts.enumerated() {
            if index < 5 { // 只打印前5个作为示例
                print("联系人 \(index+1): \(contact.name), 电话: \(contact.phones)")
            }
        }
    }
}
*/ 
