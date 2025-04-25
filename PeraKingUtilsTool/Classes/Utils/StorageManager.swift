import Foundation
import Security

/// 本地存储管理工具类
public final class StorageManager {
    
    // MARK: - UserDefaults
    
    /// UserDefaults管理
    public struct UserDefaultsManager {
        private static let prefix = Constants.Storage.userDefaultsPrefix
        private static let defaults = UserDefaults.standard
        
        /// 保存值到UserDefaults
        /// - Parameters:
        ///   - value: 要保存的值
        ///   - key: 键名
        public static func save<T>(_ value: T, forKey key: String) {
            defaults.set(value, forKey: prefix + key)
        }
        
        /// 从UserDefaults获取值
        /// - Parameter key: 键名
        /// - Returns: 存储的值
        public static func value<T>(forKey key: String) -> T? {
            return defaults.object(forKey: prefix + key) as? T
        }
        
        /// 保存对象到UserDefaults（需要遵循Codable协议）
        /// - Parameters:
        ///   - object: 要保存的对象
        ///   - key: 键名
        public static func saveObject<T: Encodable>(_ object: T, forKey key: String) {
            if let encoded = try? JSONEncoder().encode(object) {
                defaults.set(encoded, forKey: prefix + key)
            }
        }
        
        /// 从UserDefaults获取对象
        /// - Parameter key: 键名
        /// - Returns: 解码后的对象
        public static func object<T: Decodable>(forKey key: String) -> T? {
            if let data = defaults.data(forKey: prefix + key) {
                return try? JSONDecoder().decode(T.self, from: data)
            }
            return nil
        }
        
        /// 检查UserDefaults是否包含某个键
        /// - Parameter key: 键名
        /// - Returns: 是否包含
        public static func hasKey(_ key: String) -> Bool {
            return defaults.object(forKey: prefix + key) != nil
        }
        
        /// 从UserDefaults删除某个键
        /// - Parameter key: 键名
        public static func removeValue(forKey key: String) {
            defaults.removeObject(forKey: prefix + key)
        }
        
        /// 清除所有带有指定前缀的UserDefaults数据
        public static func clearAll() {
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                if key.hasPrefix(prefix) {
                    defaults.removeObject(forKey: key)
                }
            }
        }
    }
    
    // MARK: - KeyChain
    
    /// KeyChain管理
    public struct KeychainManager {
        private static let prefix = Constants.Storage.userDefaultsPrefix
        
        /// 保存字符串到KeyChain
        /// - Parameters:
        ///   - string: 要保存的字符串
        ///   - key: 键名
        /// - Returns: 操作是否成功
        @discardableResult
        public static func saveString(_ string: String, forKey key: String) -> Bool {
            guard let data = string.data(using: .utf8) else {
                return false
            }
            return saveData(data, forKey: key)
        }
        
        /// 从KeyChain获取字符串
        /// - Parameter key: 键名
        /// - Returns: 存储的字符串
        public static func string(forKey key: String) -> String? {
            guard let data = data(forKey: key) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }
        
        /// 保存数据到KeyChain
        /// - Parameters:
        ///   - data: 要保存的数据
        ///   - key: 键名
        /// - Returns: 操作是否成功
        @discardableResult
        public static func saveData(_ data: Data, forKey key: String) -> Bool {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: prefix + key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
            
            // 删除可能存在的旧数据
            SecItemDelete(query as CFDictionary)
            
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        }
        
        /// 从KeyChain获取数据
        /// - Parameter key: 键名
        /// - Returns: 存储的数据
        public static func data(forKey key: String) -> Data? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: prefix + key,
                kSecReturnData as String: kCFBooleanTrue as Any,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            if status == errSecSuccess {
                return result as? Data
            }
            return nil
        }
        
        /// 从KeyChain删除数据
        /// - Parameter key: 键名
        /// - Returns: 操作是否成功
        @discardableResult
        public static func removeData(forKey key: String) -> Bool {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: prefix + key
            ]
            
            let status = SecItemDelete(query as CFDictionary)
            return status == errSecSuccess || status == errSecItemNotFound
        }
        
        /// 清除所有KeyChain数据
        @discardableResult
        public static func clearAll() -> Bool {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword
            ]
            
            let status = SecItemDelete(query as CFDictionary)
            return status == errSecSuccess || status == errSecItemNotFound
        }
    }
    
    // MARK: - 文件存储
    
    /// 文件存储管理
    public struct FileManager {
        private static let fileManager = Foundation.FileManager.default
        
        /// 获取文档目录URL
        public static var documentsDirectoryURL: URL {
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
        
        /// 获取缓存目录URL
        public static var cachesDirectoryURL: URL {
            return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        }
        
        /// 获取临时目录URL
        public static var temporaryDirectoryURL: URL {
            return fileManager.temporaryDirectory
        }
        
        /// 在文档目录中创建子目录
        /// - Parameter directoryName: 目录名
        /// - Returns: 创建的目录URL
        @discardableResult
        public static func createDirectory(named directoryName: String, in directory: URL = documentsDirectoryURL) -> URL? {
            let directoryURL = directory.appendingPathComponent(directoryName)
            
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                return directoryURL
            } catch {
                print("创建目录失败: \(error.localizedDescription)")
                return nil
            }
        }
        
        /// 保存数据到文件
        /// - Parameters:
        ///   - data: 要保存的数据
        ///   - fileName: 文件名
        ///   - directory: 目录URL
        /// - Returns: 保存的文件URL
        @discardableResult
        public static func saveData(_ data: Data, toFileName fileName: String, in directory: URL = documentsDirectoryURL) -> URL? {
            let fileURL = directory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                return fileURL
            } catch {
                print("保存文件失败: \(error.localizedDescription)")
                return nil
            }
        }
        
        /// 从文件读取数据
        /// - Parameters:
        ///   - fileName: 文件名
        ///   - directory: 目录URL
        /// - Returns: 读取的数据
        public static func readData(fromFileName fileName: String, in directory: URL = documentsDirectoryURL) -> Data? {
            let fileURL = directory.appendingPathComponent(fileName)
            
            do {
                return try Data(contentsOf: fileURL)
            } catch {
                print("读取文件失败: \(error.localizedDescription)")
                return nil
            }
        }
        
        /// 删除文件
        /// - Parameters:
        ///   - fileName: 文件名
        ///   - directory: 目录URL
        /// - Returns: 操作是否成功
        @discardableResult
        public static func deleteFile(named fileName: String, in directory: URL = documentsDirectoryURL) -> Bool {
            let fileURL = directory.appendingPathComponent(fileName)
            
            do {
                try fileManager.removeItem(at: fileURL)
                return true
            } catch {
                print("删除文件失败: \(error.localizedDescription)")
                return false
            }
        }
        
        /// 检查文件是否存在
        /// - Parameters:
        ///   - fileName: 文件名
        ///   - directory: 目录URL
        /// - Returns: 文件是否存在
        public static func fileExists(named fileName: String, in directory: URL = documentsDirectoryURL) -> Bool {
            let fileURL = directory.appendingPathComponent(fileName)
            return fileManager.fileExists(atPath: fileURL.path)
        }
        
        /// 获取文件大小
        /// - Parameters:
        ///   - fileName: 文件名
        ///   - directory: 目录URL
        /// - Returns: 文件大小（字节）
        public static func fileSize(of fileName: String, in directory: URL = documentsDirectoryURL) -> Int64? {
            let fileURL = directory.appendingPathComponent(fileName)
            
            do {
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                return attributes[.size] as? Int64
            } catch {
                print("获取文件大小失败: \(error.localizedDescription)")
                return nil
            }
        }
        
        /// 列出目录中的所有文件
        /// - Parameter directory: 目录URL
        /// - Returns: 文件名数组
        public static func listFiles(in directory: URL = documentsDirectoryURL) -> [String]? {
            do {
                return try fileManager.contentsOfDirectory(atPath: directory.path)
            } catch {
                print("列出目录内容失败: \(error.localizedDescription)")
                return nil
            }
        }
        
        /// 清空目录
        /// - Parameter directory: 目录URL
        /// - Returns: 操作是否成功
        @discardableResult
        public static func clearDirectory(_ directory: URL = documentsDirectoryURL) -> Bool {
            guard let files = listFiles(in: directory) else {
                return false
            }
            
            var success = true
            
            for file in files {
                let fileURL = directory.appendingPathComponent(file)
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch {
                    print("删除文件失败: \(error.localizedDescription)")
                    success = false
                }
            }
            
            return success
        }
    }
} 