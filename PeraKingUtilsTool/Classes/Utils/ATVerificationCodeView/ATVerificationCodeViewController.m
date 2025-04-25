// ATVerificationCodeViewController.m
// PeraKing
//
// 创建于 2025-04-18

#import "ATVerificationCodeViewController.h"

@interface ATVerificationCodeViewController ()

@property (nonatomic, strong, readwrite) ATVerificationCodeView *verificationCodeView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *instructionLabel;
@property (nonatomic, strong) UIButton *verifyButton;
@property (nonatomic, strong) UIButton *resendButton;

@end

@implementation ATVerificationCodeViewController

#pragma mark - 初始化

- (instancetype)init {
    return [self initWithCodeLength:6];
}

- (instancetype)initWithCodeLength:(NSInteger)codeLength {
    self = [super init];
    if (self) {
        _codeLength = codeLength;
    }
    return self;
}

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 自动显示键盘
    [self.verificationCodeView becomeFirstResponder];
}

#pragma mark - UI设置

- (void)setupUI {
    // 标题标签
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"验证";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];
    
    // 说明标签
    self.instructionLabel = [[UILabel alloc] init];
    self.instructionLabel.text = @"请输入发送到您设备的验证码";
    self.instructionLabel.font = [UIFont systemFontOfSize:16.0];
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.numberOfLines = 0;
    self.instructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.instructionLabel];
    
    // 验证码视图
    self.verificationCodeView = [[ATVerificationCodeView alloc] initWithFrame:CGRectZero codeLength:self.codeLength];
    self.verificationCodeView.delegate = self;
    self.verificationCodeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.verificationCodeView];
    
    // 自定义外观
    self.verificationCodeView.cornerRadius = 8.0;
    self.verificationCodeView.borderColor = [UIColor lightGrayColor];
    self.verificationCodeView.focusedBorderColor = [UIColor blueColor];
    self.verificationCodeView.boxBackgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    self.verificationCodeView.textFont = [UIFont systemFontOfSize:24.0 weight:UIFontWeightMedium];
    
    // 验证按钮
    self.verifyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.verifyButton setTitle:@"验证" forState:UIControlStateNormal];
    self.verifyButton.backgroundColor = [UIColor systemBlueColor];
    [self.verifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.verifyButton.layer.cornerRadius = 8.0;
    self.verifyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.verifyButton addTarget:self action:@selector(verifyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.verifyButton];
    
    // 重新发送按钮
    self.resendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.resendButton setTitle:@"重新发送验证码" forState:UIControlStateNormal];
    self.resendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.resendButton addTarget:self action:@selector(resendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resendButton];
    
    // 布局约束
    [NSLayoutConstraint activateConstraints:@[
        // 标题标签
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:40.0],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        // 说明标签
        [self.instructionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:16.0],
        [self.instructionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.instructionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        
        // 验证码视图
        [self.verificationCodeView.topAnchor constraintEqualToAnchor:self.instructionLabel.bottomAnchor constant:40.0],
        [self.verificationCodeView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.verificationCodeView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        [self.verificationCodeView.heightAnchor constraintEqualToConstant:60.0],
        
        // 验证按钮
        [self.verifyButton.topAnchor constraintEqualToAnchor:self.verificationCodeView.bottomAnchor constant:40.0],
        [self.verifyButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.verifyButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        [self.verifyButton.heightAnchor constraintEqualToConstant:50.0],
        
        // 重新发送按钮
        [self.resendButton.topAnchor constraintEqualToAnchor:self.verifyButton.bottomAnchor constant:16.0],
        [self.resendButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];
}

#pragma mark - 按钮操作

- (void)verifyButtonTapped {
    [self verifyCode];
}

- (void)resendButtonTapped {
    // 显示加载指示器
    
    // 模拟网络请求延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 隐藏加载指示器
        
        // 清除当前验证码
        [self.verificationCodeView clearCode];
        
        // 显示成功消息
//        [self showAlertWithTitle:@"验证码已重新发送" message:@"新的验证码已发送到您的设备。"];
        
        // 使验证码视图再次成为第一响应者
        [self.verificationCodeView becomeFirstResponder];
    });
}

#pragma mark - 验证方法

- (void)verifyCode {
    // 确保验证码已完整输入
    if (self.verificationCodeView.code.length != self.codeLength) {
        [self showAlertWithTitle:@"验证码不完整" message:@"请输入完整的验证码。"];
        return;
    }
    
    
    // 模拟网络请求延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 演示目的，将"123456"视为有效验证码
        if ([self.verificationCodeView.code isEqualToString:@"123456"]) {
            [self verificationSuccessfulWithCode:self.verificationCodeView.code];
        } else {
            NSError *error = [NSError errorWithDomain:@"VerificationErrorDomain" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"验证码无效"}];
            [self verificationFailedWithError:error];
        }
    });
}

- (void)verificationSuccessfulWithCode:(NSString *)code {
    // 显示成功消息
    [self showAlertWithTitle:@"验证成功" message:@"您的验证码已成功验证。"];
    
    // 在实际应用中，通常会导航到下一个界面或完成某个流程
    // 此方法可以在子类中重写以实现自定义行为
}

- (void)verificationFailedWithError:(NSError *)error {
    // 显示错误消息
    [self showAlertWithTitle:@"验证失败" message:[NSString stringWithFormat:@"%@", error.localizedDescription]];
    
    // 清除验证码以重试
    [self.verificationCodeView clearCode];
    
    // 使验证码视图再次成为第一响应者
    [self.verificationCodeView becomeFirstResponder];
    
    // 此方法可以在子类中重写以实现自定义错误处理
}

#pragma mark - ATVerificationCodeViewDelegate

- (void)verificationCodeDidComplete:(NSString *)code {
    NSLog(@"验证码已完成输入: %@", code);
    // 验证码完成时自动验证
    [self verifyCode];
}

- (void)verificationCodeDidChange:(NSString *)code {
    NSLog(@"验证码已变更: %@", code);
    // 根据需要在验证码变化时更新UI或状态
}

#pragma mark - Alert Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    for (UIAlertAction *action in actions) {
        [alertController addAction:action];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
