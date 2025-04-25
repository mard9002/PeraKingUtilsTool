import Foundation
import Moya

@available(iOS 13.0, *)
public extension NetworkService {
    
    /// 异步发送网络请求并解析返回的响应
    /// - Parameter target: API目标
    /// - Returns: 解析后的响应数据
//    func request<T: SmartCodable, U: TargetType>(_ target: U) async throws -> T {
//        return try await withCheckedThrowingContinuation { continuation in
//            request(target) { (result: Result<T, Error>) in
//                continuation.resume(with: result)
//            }
//        }
//    }
    
    /// 异步发送网络请求并返回原始数据
    /// - Parameter target: API目标
    /// - Returns: 原始响应数据
    func requestData<U: TargetType>(_ target: U) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            requestData(target) { result in
                continuation.resume(with: result)
            }
        }
    }
}

// MARK: - 结合响应式编程的异步扩展

#if canImport(Combine)
import Combine
import SmartCodable

@available(iOS 13.0, *)
public extension NetworkService {
    
    /// 使用Combine发送网络请求
    /// - Parameter target: API目标
    /// - Returns: 包含响应数据的Publisher
//    func requestPublisher<T: SmartCodable, U: TargetType>(_ target: U) -> AnyPublisher<T, Error> {
//        return Future<T, Error> { [weak self] promise in
//            guard let self = self else {
//                promise(.failure(NetworkError.cancelled))
//                return
//            }
//            
//            self.request(target) { (result: Result<T, Error>) in
//                promise(result)
//            }
//        }
//        .eraseToAnyPublisher()
//    }
    
    /// 使用Combine发送网络请求并返回原始数据
    /// - Parameter target: API目标
    /// - Returns: 包含原始数据的Publisher
    func requestDataPublisher<U: TargetType>(_ target: U) -> AnyPublisher<Data, Error> {
        return Future<Data, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NetworkError.cancelled))
                return
            }
            
            self.requestData(target) { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - 使用示例

/*
@available(iOS 13.0, *)
private func exampleAsyncUsage() async {
    do {
        // 使用async/await登录
        let loginResponse: BaseResponse<User> = try await NetworkService.shared.request(
            UserAPIService.login(email: "user@example.com", password: "password")
        )
        
        if let user = loginResponse.data {
            print("异步登录成功: \(user.name)")
            
            // 获取个人资料
            let profileResponse: BaseResponse<User> = try await NetworkService.shared.request(
                UserAPIService.getProfile
            )
            
            if let profile = profileResponse.data {
                print("异步获取个人资料成功: \(profile.name)")
            }
        }
    } catch {
        print("异步请求失败: \(error.localizedDescription)")
    }
}

#if canImport(Combine)
@available(iOS 13.0, *)
private func exampleCombineUsage() {
    var cancellables = Set<AnyCancellable>()
    
    // 使用Combine登录
    NetworkService.shared.requestPublisher(
        UserAPIService.login(email: "user@example.com", password: "password")
    )
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Combine登录失败: \(error.localizedDescription)")
            }
        },
        receiveValue: { (response: BaseResponse<User>) in
            if let user = response.data {
                print("Combine登录成功: \(user.name)")
            }
        }
    )
    .store(in: &cancellables)
}
#endif
*/ 
