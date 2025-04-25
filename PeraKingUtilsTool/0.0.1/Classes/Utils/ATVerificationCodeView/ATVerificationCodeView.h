// ATVerificationCodeView.h
// PeraKing
//
// 创建于 2025-04-18

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ATVerificationCodeViewDelegate <NSObject>

/**
 * 当验证码完全输入后调用
 * @param code 用户输入的完整验证码
 */
- (void)verificationCodeDidComplete:(NSString *)code;

@optional
/**
 * 当验证码发生变化时调用
 * @param code 当前的验证码
 */
- (void)verificationCodeDidChange:(NSString *)code;

@end

/**
 * 一个可自定义的验证码输入视图，为每个数字显示单独的方框。
 * 支持外观、长度和输入行为的自定义。
 */
@interface ATVerificationCodeView : UIView <UITextInputTraits>

/**
 * 接收验证码事件的代理
 */
@property(nonatomic, weak) id<ATVerificationCodeViewDelegate> delegate;

/**
 * 验证码中的数字位数（默认为6）
 */
@property(nonatomic, assign) NSInteger codeLength;

/**
 * 当前输入的验证码
 */
@property(nonatomic, copy, readonly) NSString *code;

/**
 * 各数字方框之间的间距（默认为8）
 */
@property(nonatomic, assign) CGFloat digitSpacing;

/**
 * 数字方框的圆角半径（默认为8）
 */
@property(nonatomic, assign) CGFloat cornerRadius;

/**
 * 数字方框的边框宽度（默认为1）
 */
@property(nonatomic, assign) CGFloat borderWidth;

/**
 * 未聚焦状态下数字方框的边框颜色（默认为浅灰色）
 */
@property(nonatomic, strong) UIColor *borderColor;

/**
 * 聚焦状态下数字方框的边框颜色（默认为黑色）
 */
@property(nonatomic, strong) UIColor *focusedBorderColor;

/**
 * 数字方框的背景颜色（默认为白色）
 */
@property(nonatomic, strong) UIColor *boxBackgroundColor;

/**
 * 验证码文本的颜色（默认为黑色）
 */
@property(nonatomic, strong) UIColor *textColor;

/**
 * 验证码文本的字体（默认为系统字体，20pt）
 */
@property(nonatomic, strong) UIFont *textFont;

/**
 * 键盘类型（默认为UIKeyboardTypeNumberPad）
 * 从UITextInputTraits协议继承
 */
@property(nonatomic, assign) UIKeyboardType keyboardType;

/**
 * 使用指定的frame和验证码长度初始化
 * @param frame 视图的frame
 * @param length 验证码中的数字位数
 * @return 已初始化的验证码视图
 */
- (instancetype)initWithFrame:(CGRect)frame codeLength:(NSInteger)length;

/**
 * 清除当前的验证码
 */
- (void)clearCode;

/**
 * 使视图成为第一响应者以显示键盘
 */
- (void)becomeFirstResponder;

/**
 * 设置键盘类型并在需要时更新键盘
 * @param keyboardType 要设置的键盘类型
 */
- (void)setCustomKeyboardType:(UIKeyboardType)keyboardType;

@end

NS_ASSUME_NONNULL_END
