// ATVerificationCodeViewController.h
// PeraKing
//
// 创建于 2025-04-18

#import "ATVerificationCodeView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 一个示例视图控制器，演示如何使用ATVerificationCodeView。
 * 可以作为实现验证码功能的模板使用。
 */
@interface ATVerificationCodeViewController : UIViewController <ATVerificationCodeViewDelegate>

/**
 * 要输入的验证码长度（默认为6）。
 */
@property(nonatomic, assign) NSInteger codeLength;

/**
 * 验证码视图组件。
 */
@property(nonatomic, strong, readonly) ATVerificationCodeView *verificationCodeView;

/**
 * 使用特定验证码长度初始化。
 * @param codeLength 验证码中的数字位数
 * @return 初始化后的验证码视图控制器
 */
- (instancetype)initWithCodeLength:(NSInteger)codeLength;

/**
 * 当验证完成并且验证码已验证时调用的方法。
 * 在子类中重写此方法以处理成功验证的情况。
 * @param code 已验证的验证码
 */
- (void)verificationSuccessfulWithCode:(NSString *)code;

/**
 * 当验证失败时调用的方法。
 * 在子类中重写此方法以处理验证失败的情况。
 * @param error 验证过程中发生的错误
 */
- (void)verificationFailedWithError:(NSError *)error;

/**
 * 使用当前验证码开始验证过程。
 */
- (void)verifyCode;

@end

NS_ASSUME_NONNULL_END
