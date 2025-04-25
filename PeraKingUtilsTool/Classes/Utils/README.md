<!--
 * @Author       : 许七安
 * @Date         : 2025-04-17 09:46:34
 * @LastEditors  : hyman
 * @LastEditTime : 2025-04-17 09:57:33
 * @Description  : 请填写简介
-->
# UIKit 工具类

此目录包含 UIKit 应用开发所需的常用工具类：

- **UIExtensions**：UI组件扩展
- **DeviceHelper**：设备信息和环境
- **AnimationHelper**：辅助动画
- **StringFormatter**：字符串和数据格式化 
- **Constants**：常量管理类
- **StorageManager**：本地存储工具类

## UIKitSwiftUIBridge

A utility class that provides methods for converting between UIKit and SwiftUI components. This class facilitates the integration of SwiftUI views into UIKit-based applications and vice versa.

### Features:

- Convert SwiftUI views to UIViewController
- Convert SwiftUI views to UIView
- Embed SwiftUI views in UIKit view controllers
- Create SwiftUI wrappers for UIKit views and view controllers
- Convenience extensions for easier usage

### Example Usage:

```swift
// SwiftUI -> UIKit
let mySwiftUIView = MySwiftUIView()
let viewController = UIKitSwiftUIBridge.makeUIViewController(from: mySwiftUIView)
// or using the extension
let viewController = mySwiftUIView.toUIViewController()

// UIKit -> SwiftUI
let uiKitView = UIKitSwiftUIBridge.makeView {
    let label = UILabel()
    label.text = "Hello, World!"
    return label
}
```

## BaseViewController (Objective-C)

A base UIViewController class written in Objective-C that provides common functionality across all view controllers in the application.

### Features:

- Navigation bar setup with customizable title and back button
- Loading indicator with show/hide methods
- Alert presentation utilities
- Basic view controller lifecycle management

### Example Usage:

```objective-c
#import "BaseViewController.h"

@interface MyViewController : BaseViewController

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBarWithTitle:@"My Screen" showBackButton:YES];
    
    // Show loading while fetching data
    [self showLoading];
    
    // After data loads
    [self hideLoading];
    
    // Show an alert
    [self showAlertWithTitle:@"Success" message:@"Operation completed successfully"];
}

@end
```

## ATVerificationCodeView (Objective-C)

一个可自定义的验证码输入组件，以单独的方框显示每个数字，类似于短信或邮箱验证码输入框。

### 功能特点：

- 可配置的数字位数（默认为6位）
- 可自定义外观（颜色、间距、边框、字体）
- 自动处理键盘输入
- 提供验证码完成和变化的代理方法
- 当前输入位置的焦点指示
- 支持删除和仅数字输入

### 使用示例：

```objective-c
#import "ATVerificationCodeView.h"

@interface VerificationViewController : UIViewController <ATVerificationCodeViewDelegate>

@property (nonatomic, strong) ATVerificationCodeView *verificationCodeView;

@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化6位验证码
    self.verificationCodeView = [[ATVerificationCodeView alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 50) codeLength:6];
    self.verificationCodeView.delegate = self;
    
    // 根据需要自定义外观
    self.verificationCodeView.cornerRadius = 8.0;
    self.verificationCodeView.borderColor = [UIColor lightGrayColor];
    self.verificationCodeView.focusedBorderColor = [UIColor blueColor];
    
    [self.view addSubview:self.verificationCodeView];
    
    // 自动显示键盘
    [self.verificationCodeView becomeFirstResponder];
}

#pragma mark - ATVerificationCodeViewDelegate

- (void)verificationCodeDidComplete:(NSString *)code {
    NSLog(@"验证码已完成输入: %@", code);
    // 验证码与后端验证
}

- (void)verificationCodeDidChange:(NSString *)code {
    NSLog(@"验证码已变更: %@", code);
}

@end
```

## ATRetainPopupView (Objective-C)

一个全屏弹窗组件，用于显示保留信息提示，包含背景图、标题、描述文本、确认和取消按钮。

### 功能特点：

- 全屏显示的弹窗，带有半透明背景
- 可自定义标题和描述文本
- 自定义确认和取消按钮文字
- 右上角关闭按钮
- 带有动画效果的显示和隐藏
- 回调函数处理用户交互

### 使用示例：

```objective-c
#import "ATRetainPopupView.h"

@implementation YourViewController

- (void)showRetainPopup {
    [ATRetainPopupView showInView:self.view
                            title:@"请留步"
                      description:@"绑定信息可以帮助\n获取贷款更快\n您可以注册信息\n提高获取速度更快发展\n您的计划"
                      confirmText:@"确认"
                       cancelText:@"取消"
                     confirmBlock:^{
                         // 用户点击确认按钮后的处理
                         NSLog(@"用户确认留下");
                     }
                      cancelBlock:^{
                         // 用户点击取消按钮或关闭按钮后的处理
                         NSLog(@"用户选择离开");
                     }];
}

@end
```

## ATRetainPopupViewController (Objective-C)

ATRetainPopupView的视图控制器版本，适用于需要在导航控制器中使用的场景。与ATRetainPopupView提供相同的功能，但以视图控制器的形式呈现。

### 功能特点：

- 全屏模态呈现的弹窗视图控制器
- 可自定义标题和描述文本
- 自定义确认和取消按钮文字
- 右上角关闭按钮
- 带有动画效果的显示和隐藏
- 回调函数处理用户交互

### 使用示例：

```objective-c
#import "ATRetainPopupViewController.h"

@implementation YourViewController

- (void)showRetainPopupVC {
    ATRetainPopupViewController *popupVC = [ATRetainPopupViewController popupWithTitle:@"请留步"
                                                                          description:@"绑定信息可以帮助\n获取贷款更快\n您可以注册信息\n提高获取速度更快发展\n您的计划"
                                                                          confirmText:@"确认"
                                                                           cancelText:@"取消"
                                                                         confirmBlock:^{
                                                                             // 用户点击确认按钮后的处理
                                                                             NSLog(@"用户确认留下");
                                                                         }
                                                                          cancelBlock:^{
                                                                             // 用户点击取消按钮或关闭按钮后的处理
                                                                             NSLog(@"用户选择离开");
                                                                         }];
    
    popupVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:popupVC animated:YES completion:nil];
}

@end
```

## ATPopupManager (Objective-C)

弹窗管理器，用于统一管理各种弹窗的显示和隐藏。通过此管理器，开发者只需要关注弹窗内容的配置，而不必关心具体的显示逻辑和背景处理。

### 功能特点：

- 单例模式实现，全局统一管理弹窗
- 支持多种类型弹窗（保留用户、提示信息、自定义）
- 弹窗堆栈管理，支持多层弹窗的显示
- 支持自定义视图和视图控制器弹窗
- 背景点击自动关闭
- 动画显示和隐藏
- 统一的回调处理接口

### 使用示例：

```objective-c
#import "ATPopupManager.h"
#import "ATPopupConfigModel.h"

@implementation YourViewController

// 显示"请留步"类型弹窗
- (void)showRetainPopup {
    [[ATPopupManager sharedManager] showRetainPopupWithTitle:@"请留步"
                                                 description:@"绑定信息可以帮助\n获取贷款更快\n您可以注册信息\n提高获取速度更快发展\n您的计划"
                                                 confirmText:@"确认"
                                                  cancelText:@"取消"
                                                confirmBlock:^{
                                                    // 用户点击确认按钮后的处理
                                                    NSLog(@"用户确认留下");
                                                }
                                                 cancelBlock:^{
                                                    // 用户点击取消按钮或关闭按钮后的处理
                                                    NSLog(@"用户选择离开");
                                                }];
}

// 使用配置模型显示弹窗
- (void)showPopupWithConfig {
    // 创建配置模型
    ATPopupConfigModel *config = [ATPopupConfigModel retainPopupConfigWithTitle:@"请留步"
                                                                    description:@"绑定信息可以帮助\n获取贷款更快"
                                                                    confirmText:@"确认"
                                                                     cancelText:@"取消"];
    
    // 显示弹窗
    [[ATPopupManager sharedManager] showPopupWithConfig:config
                                          confirmBlock:^{
                                              NSLog(@"用户点击确认");
                                          }
                                           cancelBlock:^{
                                              NSLog(@"用户点击取消");
                                          }];
}

// 显示自定义按钮弹窗
- (void)showCustomButtonsPopup {
    ATPopupConfigModel *config = [ATPopupConfigModel customPopupConfigWithTitle:@"选择操作"
                                                                    description:@"请选择您要执行的操作"
                                                                   buttonTitles:@[@"确认", @"编辑", @"取消"]];
    
    [[ATPopupManager sharedManager] showPopupWithConfig:config
                                           actionBlock:^(NSInteger index) {
                                               switch (index) {
                                                   case 0:
                                                       NSLog(@"用户点击确认");
                                                       break;
                                                   case 1:
                                                       NSLog(@"用户点击编辑");
                                                       break;
                                                   case 2:
                                                       NSLog(@"用户点击取消");
                                                       break;
                                               }
                                           }];
}

@end