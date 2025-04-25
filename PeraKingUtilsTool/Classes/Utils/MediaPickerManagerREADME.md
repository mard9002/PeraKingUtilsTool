# MediaPickerManager

`MediaPickerManager` 是一个用于处理相机拍照和相册选择的工具类，提供了简单易用的接口来处理权限检查、媒体选择和图片压缩等功能。

## 功能特点

- 检查和请求相机、相册权限
- 从相册选择照片
- 使用相机拍照（支持前后摄像头切换）
- 可选隐藏相机切换按钮
- 自动压缩图片到指定大小（默认 800KB）
- 统一的错误处理和回调机制

## 使用方法

### 相机权限检查

```swift
// 检查相机权限
MediaPickerManager.shared.checkCameraPermission { authorized in
    if authorized {
        print("相机权限已授权")
        // 执行需要相机权限的操作
    } else {
        print("相机权限被拒绝")
        // 提示用户开启权限
    }
}
```

### 相册权限检查

```swift
// 检查相册权限
MediaPickerManager.shared.checkPhotoLibraryPermission { authorized in
    if authorized {
        print("相册权限已授权")
        // 执行需要相册权限的操作
    } else {
        print("相册权限被拒绝")
        // 提示用户开启权限
    }
}
```

### 从相册选择照片

```swift
// 从相册选择照片
MediaPickerManager.shared.pickPhotoFromLibrary(from: self) { [weak self] image, error in
    guard let self = self else { return }
    
    if let error = error {
        print("选择照片出错: \(error.localizedDescription)")
        return
    }
    
    if let selectedImage = image {
        // 使用所选图片（已自动压缩到800KB以下）
        self.imageView.image = selectedImage
        
        // 上传图片
        self.uploadImage(selectedImage)
    }
}
```

### 使用相机拍照

#### 基本用法

```swift
// 默认使用后置摄像头，显示切换按钮
MediaPickerManager.shared.takePhoto(from: self) { [weak self] image, error in
    guard let self = self else { return }
    
    if let error = error {
        print("拍照出错: \(error.localizedDescription)")
        return
    }
    
    if let capturedImage = image {
        // 使用拍摄的照片（已自动压缩到800KB以下）
        self.imageView.image = capturedImage
        
        // 处理图片
        self.processImage(capturedImage)
    }
}
```

#### 自定义拍照选项

```swift
// 使用前置摄像头，并隐藏切换按钮
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
        self.avatarImageView.image = capturedImage
        
        // 更新用户头像
        self.updateUserAvatar(capturedImage)
    }
}
```

### 调整图片压缩大小

默认情况下，`MediaPickerManager` 会将图片压缩到 800KB 以下，但您可以根据需要调整这个值：

```swift
// 设置图片压缩大小为500KB
MediaPickerManager.shared.maxImageSizeKB = 500

// 然后正常使用
MediaPickerManager.shared.pickPhotoFromLibrary(from: self) { image, error in
    // 处理结果
}
```

## 完整示例：个人资料头像更新

```swift
class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvatarView()
    }
    
    private func setupAvatarView() {
        // 设置头像为圆形
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeAvatar))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func changeAvatar() {
        let alert = UIAlertController(title: "更换头像", message: nil, preferredStyle: .actionSheet)
        
        // 相机选项
        alert.addAction(UIAlertAction(title: "拍照", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.takePhoto()
        })
        
        // 相册选项
        alert.addAction(UIAlertAction(title: "从相册选择", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.selectFromPhotoLibrary()
        })
        
        // 取消选项
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func takePhoto() {
        MediaPickerManager.shared.takePhoto(from: self, position: .front) { [weak self] image, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showErrorAlert(message: "拍照失败: \(error.localizedDescription)")
                return
            }
            
            if let newImage = image {
                self.avatarImageView.image = newImage
                self.uploadAvatar(newImage)
            }
        }
    }
    
    private func selectFromPhotoLibrary() {
        MediaPickerManager.shared.pickPhotoFromLibrary(from: self) { [weak self] image, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showErrorAlert(message: "选择照片失败: \(error.localizedDescription)")
                return
            }
            
            if let newImage = image {
                self.avatarImageView.image = newImage
                self.uploadAvatar(newImage)
            }
        }
    }
    
    private func uploadAvatar(_ image: UIImage) {
        // 在这里实现头像上传逻辑
        showLoadingIndicator()
        
        // 模拟上传操作
        DispatchQueue.global().async {
            // 上传图片的代码...
            
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                self.showSuccessMessage("头像更新成功")
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showSuccessMessage(_ message: String) {
        // 显示成功提示
    }
    
    private func showLoadingIndicator() {
        // 显示加载指示器
    }
    
    private func hideLoadingIndicator() {
        // 隐藏加载指示器
    }
}
```

## 注意事项

1. **权限处理**：确保在 Info.plist 中添加了相应的权限描述：
   - 相机权限：`NSCameraUsageDescription`
   - 相册权限：`NSPhotoLibraryUsageDescription`

2. **内存管理**：`MediaPickerManager` 使用了强引用机制（`strongReference`）确保在回调完成前不会被释放，您不需要额外持有它的引用。

3. **图片压缩**：默认压缩到 800KB，如需更高质量的图片，可以增加 `maxImageSizeKB` 的值，但要注意内存和网络带宽消耗。

4. **设备兼容性**：在使用相机功能前，代码会自动检查设备是否支持相机功能，如果不支持会通过错误回调通知调用者。

5. **自定义相机界面**：如果设置 `hideToggleButton` 为 true，会提供一个简单的自定义相机界面。如果需要更复杂的自定义相机界面，建议使用 `AVFoundation` 框架自己实现相机功能。

6. **iOS 版本兼容**：该类支持 iOS 10 及以上系统，较低版本的 iOS 可能需要额外的适配工作。

7. **主线程回调**：所有的回调都保证在主线程中执行，您可以直接在回调中更新 UI，无需额外切换线程。

8. **错误处理**：所有可能的错误都会通过回调的 `error` 参数返回，建议始终检查 `error` 参数并做相应处理。 