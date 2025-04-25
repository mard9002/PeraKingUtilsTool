import Foundation
import UIKit
import SwiftUI

/// 通讯录工具类使用示例
public class ContactsExample {
    
    /// 选择单个联系人示例
    public static func selectContactExample(from viewController: UIViewController) {
        ContactsManager.shared.selectContact(
            from: viewController,
            success: { contact in
                print("选择联系人成功:")
                print("姓名: \(contact.name)")
                print("电话: \(contact.phones)")
                
                // 这里可以继续处理选择的联系人信息
                // 例如添加到联系人列表、发送消息等
            },
            error: { errorMessage in
                print("选择联系人失败: \(errorMessage)")
                
                // 可以显示错误提示或引导用户重新选择
                let alert = UIAlertController(
                    title: "选择联系人失败",
                    message: errorMessage,
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                viewController.present(alert, animated: true)
            }
        )
    }
    
    /// 获取所有联系人示例
    public static func getAllContactsExample(completion: @escaping ([ContactsManager.ContactInfo]) -> Void) {
        // 显示加载指示器
        let loadingVC = UIViewController.topMostViewController()
        let loadingAlert = UIAlertController(
            title: "加载中",
            message: "正在获取联系人...",
            preferredStyle: .alert
        )
        loadingVC?.present(loadingAlert, animated: true)
        
        // 异步获取所有联系人
        ContactsManager.shared.getAllContacts { contacts in
            // 关闭加载指示器
            loadingAlert.dismiss(animated: true) {
                // 回调联系人数组
                completion(contacts)
                
                // 打印联系人信息
                print("获取到 \(contacts.count) 个联系人")
                
                // 只打印前5个作为示例
                for (index, contact) in contacts.prefix(5).enumerated() {
                    print("联系人 \(index+1): \(contact.name), 电话: \(contact.phones)")
                }
            }
        }
    }
    
    /// 创建联系人选择视图
    public static func createContactsSelectionView() -> some View {
        return ContactsSelectionView()
    }
}

/// 获取最上层视图控制器的扩展
extension UIViewController {
    static func topMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

/// 联系人选择视图
struct ContactsSelectionView: View {
    @State private var selectedContact: ContactsManager.ContactInfo?
    @State private var allContacts: [ContactsManager.ContactInfo] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            // 标题
            Text("通讯录管理")
                .font(.largeTitle)
                .padding(.top, 20)
            
            // 选择的联系人信息
            if let contact = selectedContact {
                VStack(alignment: .leading, spacing: 8) {
                    Text("已选联系人:")
                        .font(.headline)
                    
                    HStack {
                        Text("姓名:")
                            .fontWeight(.semibold)
                        Text(contact.name)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("电话:")
                            .fontWeight(.semibold)
                        Text(contact.phones)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            // 选择联系人按钮
            Button(action: selectContact) {
                Text("选择联系人")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 获取所有联系人按钮
            Button(action: getAllContacts) {
                HStack {
                    Text("获取所有联系人")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.leading, 5)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .disabled(isLoading)
            
            // 联系人列表
            if !allContacts.isEmpty {
                Text("联系人列表 (\(allContacts.count)个)")
                    .font(.headline)
                    .padding(.top, 20)
                
                List {
                    ForEach(0..<min(allContacts.count, 10), id: \.self) { index in
                        let contact = allContacts[index]
                        HStack {
                            VStack(alignment: .leading) {
                                Text(contact.name)
                                    .fontWeight(.semibold)
                                Text(contact.phones)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if allContacts.count > 10 {
                        Text("... 还有 \(allContacts.count - 10) 个联系人")
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    }
                }
                .frame(height: 300)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.bottom, 20)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("错误"),
                message: Text(errorMessage ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
    }
    
    // 选择联系人
    private func selectContact() {
        // 确保获取到顶层视图控制器
        guard let topVC = UIViewController.topMostViewController() else {
            errorMessage = "无法获取当前视图控制器"
            showingAlert = true
            return
        }
        
        // 调用联系人选择器
        ContactsManager.shared.selectContact(
            from: topVC,
            success: { contact in
                self.selectedContact = contact
            },
            error: { error in
                self.errorMessage = error
                self.showingAlert = true
            }
        )
    }
    
    // 获取所有联系人
    private func getAllContacts() {
        isLoading = true
        
        ContactsManager.shared.getAllContacts { contacts in
            self.allContacts = contacts
            self.isLoading = false
        }
    }
} 