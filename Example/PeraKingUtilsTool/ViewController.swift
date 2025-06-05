//
//  ViewController.swift
//  PeraKingUtilsTool
//
//  Created by CareVoiceOS-SDK-Token on 04/25/2025.
//  Copyright (c) 2025 CareVoiceOS-SDK-Token. All rights reserved.
//

import UIKit
import PeraKingUtilsTool

class ViewController: UIViewController {
    
    // 添加图片视图来显示选择的图片
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // 添加相机按钮
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("拍照", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    // 添加相册按钮
    private let photoLibraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("从相册选择", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // 设置UI布局
    private func setupUI() {
        view.backgroundColor = .white
        title = "媒体选择示例"
        
        // 添加图片视图
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        // 添加相机按钮
        view.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            cameraButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            cameraButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 添加相册按钮
        view.addSubview(photoLibraryButton)
        photoLibraryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoLibraryButton.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 20),
            photoLibraryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            photoLibraryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            photoLibraryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // 设置按钮事件
    private func setupActions() {
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        photoLibraryButton.addTarget(self, action: #selector(photoLibraryButtonTapped), for: .touchUpInside)
    }
    
    // 相机按钮点击事件
    @objc private func cameraButtonTapped() {
        // 使用相机拍照（启用拍照后确认功能）
        MediaPickerManager.shared.takePhoto(
            from: self,
            position: .back,
            hideToggleButton: true  // 设置为true以启用自定义UI和拍照后确认功能
        ) { [weak self] image, error in
            guard let self = self else { return }
            
            if let error = error {
                print("拍照出错: \(error.localizedDescription)")
                self.showAlert(title: "错误", message: error.localizedDescription)
                return
            }
            
            if let capturedImage = image {
                // 使用拍摄并确认的照片
                self.imageView.image = capturedImage
                print("成功获取照片，尺寸: \(capturedImage.size)")
            }
        }
    }
    
    // 相册按钮点击事件
    @objc private func photoLibraryButtonTapped() {
        // 从相册选择照片
        MediaPickerManager.shared.pickPhotoFromLibrary(from: self) { [weak self] image, error in
            guard let self = self else { return }
            
            if let error = error {
                print("选择照片出错: \(error.localizedDescription)")
                self.showAlert(title: "错误", message: error.localizedDescription)
                return
            }
            
            if let selectedImage = image {
                // 使用所选图片
                self.imageView.image = selectedImage
                print("成功选择照片，尺寸: \(selectedImage.size)")
            }
        }
    }
    
    // 显示提示框
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

