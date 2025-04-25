import UIKit
import Photos
import AVFoundation

/// 媒体选择类型
public enum MediaPickerType {
    /// 相机拍照
    case camera
    /// 相册选择
    case photoLibrary
}

/// 相机位置选择
public enum CameraPosition {
    /// 后置摄像头
    case back
    /// 前置摄像头
    case front
}

/// 媒体选择管理器
public class MediaPickerManager: NSObject {
    
    // MARK: - 类型定义
    
    /// 媒体选择完成回调
    public typealias MediaPickerCompletion = (_ image: UIImage?, _ error: Error?) -> Void
    
    /// 相机权限回调
    public typealias CameraAuthorizationCompletion = (_ authorized: Bool) -> Void
    
    /// 相册权限回调
    public typealias PhotoLibraryAuthorizationCompletion = (_ authorized: Bool) -> Void
    
    // MARK: - 属性
    
    /// 单例实例
    public static let shared = MediaPickerManager()
    
    /// 图片压缩大小 (默认800KB)
    public var maxImageSizeKB: CGFloat = 800
    
    /// 是否隐藏相机切换按钮
    public var hideCameraToggleButton: Bool = false
    
    /// 相机位置
    public var cameraPosition: CameraPosition = .back
    
    /// 是否正在展示
    private var isPresenting: Bool = false
    
    /// 媒体选择控制器
    private var imagePickerController: UIImagePickerController?
    
    /// 选择完成回调
    private var completion: MediaPickerCompletion?
    
    /// 当前选择类型
    private var currentPickerType: MediaPickerType = .photoLibrary
    
    /// 用于持有管理器的引用
    private static var strongReference: MediaPickerManager?
    
    // MARK: - 初始化
    
    private override init() {
        super.init()
    }
    
    // MARK: - 公开方法
    
    /// 检查相机权限
    /// - Parameter completion: 权限状态回调
    public func checkCameraPermission(completion: @escaping CameraAuthorizationCompletion) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authStatus {
        case .authorized:
            // 已授权
            completion(true)
        case .denied, .restricted:
            // 被拒绝或受限
            completion(false)
        case .notDetermined:
            // 未确定状态，请求权限
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }
    
    /// 检查相册权限
    /// - Parameter completion: 权限状态回调
    public func checkPhotoLibraryPermission(completion: @escaping PhotoLibraryAuthorizationCompletion) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authStatus {
        case .authorized, .limited:
            // 已授权或限制访问
            completion(true)
        case .denied, .restricted:
            // 被拒绝或受限
            completion(false)
        case .notDetermined:
            // 未确定状态，请求权限
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized || status == .limited)
                }
            }
        @unknown default:
            completion(false)
        }
    }
    
    /// 从相册选择照片
    /// - Parameters:
    ///   - viewController: 用于展示选择器的视图控制器
    ///   - completion: 选择完成回调
    public func pickPhotoFromLibrary(from viewController: UIViewController, completion: @escaping MediaPickerCompletion) {
        guard !isPresenting else { return }
        
        currentPickerType = .photoLibrary
        self.completion = completion
        self.presentImagePicker(type: .photoLibrary, from: viewController)
    }
    
    /// 使用相机拍照
    /// - Parameters:
    ///   - viewController: 用于展示相机的视图控制器
    ///   - position: 相机位置（前置或后置）
    ///   - hideToggleButton: 是否隐藏切换相机按钮
    ///   - completion: 拍照完成回调
    public func takePhoto(from viewController: UIViewController, 
                         position: CameraPosition = .back,
                         hideToggleButton: Bool = false,
                         completion: @escaping MediaPickerCompletion) {
        guard !isPresenting else { return }
        
        currentPickerType = .camera
        self.completion = completion
        self.cameraPosition = position
        self.hideCameraToggleButton = hideToggleButton
        
        // 检查是否支持相机
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let error = NSError(domain: "com.peraKing.MediaPicker", code: 404, userInfo: [NSLocalizedDescriptionKey: "设备不支持相机"])
            completion(nil, error)
            return
        }
        
        checkCameraPermission { [weak self] authorized in
            guard let self = self else { return }
            
            if authorized {
                self.presentImagePicker(type: .camera, from: viewController)
            } else {
                self.showPermissionAlert(for: .camera, from: viewController)
                completion(nil, NSError(domain: "com.peraKing.MediaPicker", code: 403, userInfo: [NSLocalizedDescriptionKey: "相机访问权限被拒绝"]))
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 展示选择器
    private func presentImagePicker(type: MediaPickerType, from viewController: UIViewController) {
        imagePickerController = UIImagePickerController()
        guard let picker = imagePickerController else { return }
        
        picker.delegate = self
        picker.allowsEditing = false
        
        switch type {
        case .camera:
            picker.sourceType = .camera
            
            // 设置相机位置
            if cameraPosition == .front {
                picker.cameraDevice = .front
            } else {
                picker.cameraDevice = .rear
            }
            
            // 隐藏相机切换按钮
            if hideCameraToggleButton {
                picker.showsCameraControls = false
                
                // 创建自定义的相机控制视图
                let overlayView = createCustomCameraOverlay(for: picker)
                picker.cameraOverlayView = overlayView
            }
            
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        }
        
        isPresenting = true
        MediaPickerManager.strongReference = self
        
        viewController.present(picker, animated: true, completion: nil)
    }
    
    /// 创建自定义相机覆盖层
    private func createCustomCameraOverlay(for picker: UIImagePickerController) -> UIView {
        let screenBounds = UIScreen.main.bounds
        let overlayView = UIView(frame: screenBounds)
        overlayView.backgroundColor = .clear
        
        // 创建拍照按钮
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("Take photos", for: .normal)
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        captureButton.backgroundColor = .white
        captureButton.setTitleColor(.black, for: .normal)
        captureButton.layer.cornerRadius = 30
        captureButton.frame = CGRect(x: (screenBounds.width - 100) / 2, y: screenBounds.height - 100, width: 100, height: 60)
        
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        // 创建取消按钮
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.frame = CGRect(x: 20, y: 20, width: 60, height: 40)
        
        cancelButton.addTarget(self, action: #selector(cancelCapture), for: .touchUpInside)
        
        overlayView.addSubview(captureButton)
        overlayView.addSubview(cancelButton)
        
        return overlayView
    }
    
    /// 拍照操作
    @objc private func capturePhoto() {
        imagePickerController?.takePicture()
    }
    
    /// 取消捕获
    @objc private func cancelCapture() {
        imagePickerController?.dismiss(animated: true) { [weak self] in
            self?.isPresenting = false
            self?.completion?(nil, nil)
            MediaPickerManager.strongReference = nil
        }
    }
    
    /// 压缩图像到指定大小
    private func compressImage(_ image: UIImage) -> UIImage {
        let maxSize: CGFloat = maxImageSizeKB * 1024 // 转为字节
        
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var data = image.jpegData(compressionQuality: compression)!
        
        // 先尝试JPEG压缩
        while data.count > Int(maxSize) && compression > step {
            compression -= step
            data = image.jpegData(compressionQuality: compression)!
        }
        
        // 如果JPEG压缩不足，则尝试缩小尺寸
        if data.count > Int(maxSize) {
            var targetSize = image.size
            while data.count > Int(maxSize) {
                targetSize = CGSize(width: targetSize.width * 0.9, height: targetSize.height * 0.9)
                
                UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
                image.draw(in: CGRect(origin: .zero, size: targetSize))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                data = newImage.jpegData(compressionQuality: compression)!
            }
            
            return UIImage(data: data)!
        }
        
        return UIImage(data: data)!
    }
    
    /// 显示权限提示
    private func showPermissionAlert(for type: MediaPickerType, from viewController: UIViewController) {
        let title: String
        let message: String
        
        switch type {
        case .camera:
            title = "相机权限受限"
            message = "请在设备的\"设置-隐私-相机\"中允许访问相机。"
        case .photoLibrary:
            title = "相册权限受限"
            message = "请在设备的\"设置-隐私-照片\"中允许访问照片。"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension MediaPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        } else {
            image = nil
        }
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.isPresenting = false
            
            if let selectedImage = image {
                // 压缩图片
                let compressedImage = self.compressImage(selectedImage)
                self.completion?(compressedImage, nil)
            } else {
                let error = NSError(domain: "com.peraKing.MediaPicker", code: 500, userInfo: [NSLocalizedDescriptionKey: "未能获取所选图片"])
                self.completion?(nil, error)
            }
            
            MediaPickerManager.strongReference = nil
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.isPresenting = false
            self.completion?(nil, nil)
            MediaPickerManager.strongReference = nil
        }
    }
}

// MARK: - 使用示例

/*
// 示例1：从相册选择照片
MediaPickerManager.shared.pickPhotoFromLibrary(from: self) { [weak self] image, error in
    guard let self = self else { return }
    
    if let error = error {
        print("选择照片出错: \(error.localizedDescription)")
        return
    }
    
    if let selectedImage = image {
        // 使用所选图片
        self.imageView.image = selectedImage
        // 上传图片或其他操作...
    }
}

// 示例2：使用相机拍照（前置摄像头，隐藏切换按钮）
MediaPickerManager.shared.takePhoto(
    from: self,
    position: .front,
    hideToggleButton: true
) { [weak self] image, error in
    guard let self = self else { return }
    
    if let error = error {
        print("拍照出错: \(error.localizedDescription)")
        return
    }
    
    if let capturedImage = image {
        // 使用拍摄的照片
        self.imageView.image = capturedImage
        // 上传照片或其他操作...
    }
}

// 示例3：仅检查相机权限
MediaPickerManager.shared.checkCameraPermission { authorized in
    if authorized {
        print("相机权限已授权")
    } else {
        print("相机权限被拒绝")
    }
}
*/ 
