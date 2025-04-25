# ATVerificationCodeView

`ATVerificationCodeView` 是一个用于验证码输入的自定义视图组件，它为每个数字或字符提供独立的方框，并支持多种自定义选项。

## 功能特点

- 支持自定义验证码长度
- 支持自定义键盘类型，适用于不同输入场景
- 提供完善的视觉样式自定义选项
- 实时输入反馈和完成回调
- 自动聚焦效果

## 属性和方法

### 主要属性

| 属性名 | 类型 | 描述 | 默认值 |
|-------|------|------|-------|
| `delegate` | `id<ATVerificationCodeViewDelegate>` | 处理验证码输入事件的代理 | `nil` |
| `codeLength` | `NSInteger` | 验证码的长度 | `6` |
| `code` | `NSString` (只读) | 当前输入的验证码 | `""` |
| `keyboardType` | `UIKeyboardType` | 输入键盘类型 | `UIKeyboardTypeNumberPad` |

### 样式属性

| 属性名 | 类型 | 描述 | 默认值 |
|-------|------|------|-------|
| `digitSpacing` | `CGFloat` | 数字方框之间的间距 | `8.0` |
| `cornerRadius` | `CGFloat` | 数字方框的圆角半径 | `8.0` |
| `borderWidth` | `CGFloat` | 数字方框的边框宽度 | `1.0` |
| `borderColor` | `UIColor` | 未聚焦状态的边框颜色 | `lightGrayColor` |
| `focusedBorderColor` | `UIColor` | 聚焦状态的边框颜色 | `blackColor` |
| `boxBackgroundColor` | `UIColor` | 数字方框的背景颜色 | `whiteColor` |
| `textColor` | `UIColor` | 验证码文本颜色 | `blackColor` |
| `textFont` | `UIFont` | 验证码文本字体 | `systemFont(20pt, medium)` |

### 方法

| 方法名 | 描述 |
|-------|------|
| `initWithFrame:codeLength:` | 使用指定的frame和验证码长度初始化 |
| `clearCode` | 清除当前已输入的验证码 |
| `becomeFirstResponder` | 使视图成为第一响应者，显示键盘 |
| `setCustomKeyboardType:` | 设置键盘类型并立即更新键盘（如果视图当前是第一响应者） |

### 代理方法

```objc
@protocol ATVerificationCodeViewDelegate <NSObject>

// 当验证码完全输入后调用
- (void)verificationCodeDidComplete:(NSString *)code;

@optional
// 当验证码发生变化时调用
- (void)verificationCodeDidChange:(NSString *)code;

@end
```

## 使用示例

### 基本用法

```objc
// 创建验证码视图
CGRect frame = CGRectMake(20, 100, self.view.bounds.size.width - 40, 50);
ATVerificationCodeView *codeView = [[ATVerificationCodeView alloc] initWithFrame:frame codeLength:6];
codeView.delegate = self;
[self.view addSubview:codeView];

// 使其成为第一响应者（显示键盘）
[codeView becomeFirstResponder];
```

### 设置键盘类型

可以使用两种方式设置键盘类型：

#### 方式一：初始化后直接设置属性（适用于显示键盘前设置）

```objc
// 创建验证码视图
ATVerificationCodeView *codeView = [[ATVerificationCodeView alloc] initWithFrame:frame codeLength:6];

// 设置为数字键盘（默认）
codeView.keyboardType = UIKeyboardTypeNumberPad;

// 设置为字母数字键盘
codeView.keyboardType = UIKeyboardTypeASCIICapable;

// 设置为电子邮件键盘
codeView.keyboardType = UIKeyboardTypeEmailAddress;
```

#### 方式二：使用方法动态改变键盘类型（适用于键盘已显示的情况）

```objc
// 设置为数字键盘并立即更新
[codeView setCustomKeyboardType:UIKeyboardTypeNumberPad];

// 设置为字母数字键盘并立即更新
[codeView setCustomKeyboardType:UIKeyboardTypeASCIICapable];

// 设置为URL键盘并立即更新
[codeView setCustomKeyboardType:UIKeyboardTypeURL];
```

### 实现代理方法

```objc
#pragma mark - ATVerificationCodeViewDelegate

// 验证码输入完成时调用
- (void)verificationCodeDidComplete:(NSString *)code {
    NSLog(@"验证码输入完成: %@", code);
    
    // 验证验证码
    [self verifyCode:code];
}

// 验证码变化时调用（可选实现）
- (void)verificationCodeDidChange:(NSString *)code {
    NSLog(@"当前验证码: %@", code);
}
```

### 自定义外观

```objc
// 设置自定义样式
codeView.digitSpacing = 12.0;
codeView.cornerRadius = 10.0;
codeView.borderWidth = 2.0;
codeView.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
codeView.focusedBorderColor = [UIColor blueColor];
codeView.boxBackgroundColor = [UIColor whiteColor];
codeView.textColor = [UIColor darkTextColor];
codeView.textFont = [UIFont systemFontOfSize:24.0 weight:UIFontWeightBold];
```

## 完整示例

```objc
@interface VerificationViewController () <ATVerificationCodeViewDelegate>

@property (nonatomic, strong) ATVerificationCodeView *codeView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UISegmentedControl *keyboardTypeControl;

@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建标题标签
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, self.view.bounds.size.width - 40, 30)];
    self.titleLabel.text = @"验证码";
    self.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    // 创建消息标签
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, self.view.bounds.size.width - 40, 20)];
    self.messageLabel.text = @"请输入发送到您手机的6位验证码";
    self.messageLabel.font = [UIFont systemFontOfSize:16];
    self.messageLabel.textColor = [UIColor darkGrayColor];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.messageLabel];
    
    // 创建验证码视图
    CGRect frame = CGRectMake(20, 180, self.view.bounds.size.width - 40, 50);
    self.codeView = [[ATVerificationCodeView alloc] initWithFrame:frame codeLength:6];
    self.codeView.delegate = self;
    
    // 自定义样式
    self.codeView.cornerRadius = 10.0;
    self.codeView.focusedBorderColor = [UIColor blueColor];
    self.codeView.textFont = [UIFont systemFontOfSize:22 weight:UIFontWeightMedium];
    
    // 默认使用数字键盘
    self.codeView.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.view addSubview:self.codeView];
    
    // 创建键盘类型选择器
    self.keyboardTypeControl = [[UISegmentedControl alloc] initWithItems:@[@"数字", @"字母", @"默认"]];
    self.keyboardTypeControl.frame = CGRectMake(20, 250, self.view.bounds.size.width - 40, 40);
    self.keyboardTypeControl.selectedSegmentIndex = 0;
    [self.keyboardTypeControl addTarget:self action:@selector(keyboardTypeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.keyboardTypeControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 自动显示键盘
    [self.codeView becomeFirstResponder];
}

- (void)keyboardTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            // 数字键盘
            [self.codeView setCustomKeyboardType:UIKeyboardTypeNumberPad];
            break;
        case 1:
            // 字母键盘
            [self.codeView setCustomKeyboardType:UIKeyboardTypeASCIICapable];
            break;
        case 2:
            // 默认键盘
            [self.codeView setCustomKeyboardType:UIKeyboardTypeDefault];
            break;
        default:
            break;
    }
    
    // 清除当前输入
    [self.codeView clearCode];
    
    // 确保键盘仍然显示
    [self.codeView becomeFirstResponder];
}

#pragma mark - ATVerificationCodeViewDelegate

- (void)verificationCodeDidComplete:(NSString *)code {
    NSLog(@"验证码输入完成: %@", code);
    
    // 模拟验证过程
    [self showLoading];
    
    // 模拟网络延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideLoading];
        
        // 模拟验证成功
        if (self.keyboardTypeControl.selectedSegmentIndex == 0 && [code isEqualToString:@"123456"]) {
            [self showSuccessMessage:@"验证成功"];
            [self proceedToNextScreen];
        } else if (self.keyboardTypeControl.selectedSegmentIndex == 1 && [code.uppercaseString isEqualToString:@"ABCDEF"]) {
            [self showSuccessMessage:@"字母验证码验证成功"];
            [self proceedToNextScreen];
        } else {
            [self showErrorMessage:@"验证码错误，请重试"];
            [self.codeView clearCode];
            [self.codeView becomeFirstResponder];
        }
    });
}

- (void)verificationCodeDidChange:(NSString *)code {
    NSLog(@"当前验证码: %@", code);
}

// 其他辅助方法...
@end
```

## 字母验证码示例

如果需要允许输入字母或字母数字组合的验证码：

```objc
// 创建字母验证码视图
CGRect frame = CGRectMake(20, 180, self.view.bounds.size.width - 40, 50);
ATVerificationCodeView *codeView = [[ATVerificationCodeView alloc] initWithFrame:frame codeLength:8];
codeView.delegate = self;

// 设置为ASCII键盘，允许输入字母和数字
codeView.keyboardType = UIKeyboardTypeASCIICapable;

[self.view addSubview:codeView];
```

## 注意事项

1. **键盘类型**：虽然可以设置任何键盘类型，但对于 `UIKeyboardTypeNumberPad` 类型，组件会自动过滤非数字输入。其他键盘类型则允许输入任何字符。

2. **自动验证**：当验证码输入完成时（达到设定的 `codeLength`），会自动调用 `verificationCodeDidComplete:` 代理方法。

3. **布局考虑**：确保为每个数字框分配足够的宽度，特别是当验证码长度较长时。

4. **键盘显示**：您需要手动调用 `becomeFirstResponder` 方法来显示键盘。通常在 `viewDidAppear:` 中调用。

5. **输入限制**：默认情况下，每个输入框只接受单个字符。

6. **更新键盘类型**：如果需要在键盘已显示的情况下切换键盘类型，请使用 `setCustomKeyboardType:` 方法而不是直接设置 `keyboardType` 属性。

7. **自定义验证逻辑**：如果需要更复杂的验证逻辑，可以继承此类并重写验证方法。 