#
# Be sure to run `pod lib lint PeraKingUtilsTool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PeraKingUtilsTool'
  s.version          = '0.0.1'
  s.summary          = 'A short description of PeraKingUtilsTool.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/CareVoiceOS-SDK-Token/PeraKingUtilsTool'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'PeraKingUtilsTool' => 'mard9002' }
  s.source           = { :git => 'https://github.com/mard9002/PeraKingUtilsTool', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

 # 修改支持的 iOS 版本为 14.0 及以上
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'
  s.source_files = 'PeraKingUtils/Classes/**/*'
   # 编译选项（支持混合语言）
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '5.0', # 显式指定 Swift 版本
    'OTHER_LDFLAGS' => '$(inherited) -l"c++"' # 解决链接器问题
  }
  s.public_header_files = 'PeraKingUtils/Classes/**/*.h' # 包含公开的 Objective-C 头文件
  s.private_header_files = 'PeraKingUtils/Classes/**/Private/*.h' # 私有头文件（可选）
  s.prefix_header_file = false # 禁用默认前缀头文件

  # 添加依赖的系统框架 UIKit
  s.frameworks = 'UIKit'

  # 添加第三方依赖库
  s.dependency 'SVProgressHUD' # HUD 提示控件
  s.dependency 'SnapKit'     # 布局框架（推荐使用）
  s.dependency 'Moya'    # 网络请求库
  s.dependency 'SmartCodable' # 类型安全的 Codable 封装
  s.dependency 'Kingfisher'
end
