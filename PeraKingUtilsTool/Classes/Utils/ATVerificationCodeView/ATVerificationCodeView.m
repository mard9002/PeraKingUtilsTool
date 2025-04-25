// ATVerificationCodeView.m
// PeraKing
//
// 创建于 2025-04-18

#import "ATVerificationCodeView.h"

@interface ATVerificationCodeView () <UIKeyInput>

@property (nonatomic, strong) NSMutableArray<UIView *> *digitBoxes;
@property (nonatomic, strong) NSMutableArray<UILabel *> *digitLabels;
@property (nonatomic, strong) NSMutableString *codeString;
@property (nonatomic, assign) NSInteger currentIndex;

// 私有属性存储键盘类型
@property (nonatomic, assign) UIKeyboardType keyboardTypeValue;

@end

@implementation ATVerificationCodeView

@synthesize autocapitalizationType;
@synthesize autocorrectionType;
@synthesize spellCheckingType;
@synthesize enablesReturnKeyAutomatically;
@synthesize keyboardAppearance;
@synthesize returnKeyType;
@synthesize secureTextEntry;
@synthesize textContentType;
@synthesize passwordRules;

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame codeLength:6];
}

- (instancetype)initWithFrame:(CGRect)frame codeLength:(NSInteger)length {
    self = [super initWithFrame:frame];
    if (self) {
        _codeLength = length;
        [self setupDefaults];
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _codeLength = 6; // 默认验证码长度
        [self setupDefaults];
        [self setupViews];
    }
    return self;
}

- (void)setupDefaults {
    _digitSpacing = 8.0;
    _cornerRadius = 8.0;
    _borderWidth = 1.0;
    _borderColor = [UIColor lightGrayColor];
    _focusedBorderColor = [UIColor blackColor];
    _boxBackgroundColor = [UIColor whiteColor];
    _textColor = [UIColor blackColor];
    _textFont = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    _codeString = [NSMutableString string];
    _currentIndex = 0;
    _digitBoxes = [NSMutableArray array];
    _digitLabels = [NSMutableArray array];
    _keyboardTypeValue = UIKeyboardTypeNumberPad; // 设置默认键盘类型为数字键盘
}

#pragma mark - 视图设置

- (void)setupViews {
    // 清除现有视图（如果有）
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    [self.digitBoxes removeAllObjects];
    [self.digitLabels removeAllObjects];
    
    // 创建数字方框和标签
    CGFloat boxWidth = (CGRectGetWidth(self.bounds) - (self.digitSpacing * (self.codeLength - 1))) / self.codeLength;
    CGFloat boxHeight = CGRectGetHeight(self.bounds);
    
    for (NSInteger i = 0; i < self.codeLength; i++) {
        CGFloat xPosition = i * (boxWidth + self.digitSpacing);
        
        // 创建方框
        UIView *digitBox = [[UIView alloc] initWithFrame:CGRectMake(xPosition, 0, boxWidth, boxHeight)];
        digitBox.backgroundColor = self.boxBackgroundColor;
        digitBox.layer.cornerRadius = self.cornerRadius;
        digitBox.layer.borderWidth = self.borderWidth;
        digitBox.layer.borderColor = self.borderColor.CGColor;
        [self addSubview:digitBox];
        [self.digitBoxes addObject:digitBox];
        
        // 创建标签
        UILabel *digitLabel = [[UILabel alloc] initWithFrame:digitBox.bounds];
        digitLabel.textAlignment = NSTextAlignmentCenter;
        digitLabel.font = self.textFont;
        digitLabel.textColor = self.textColor;
        [digitBox addSubview:digitLabel];
        [self.digitLabels addObject:digitLabel];
    }
    
    // 更新第一个方框显示聚焦状态
    [self updateFocus];
    
    // 添加点击手势以显示键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat boxWidth = (CGRectGetWidth(self.bounds) - (self.digitSpacing * (self.codeLength - 1))) / self.codeLength;
    CGFloat boxHeight = CGRectGetHeight(self.bounds);
    
    for (NSInteger i = 0; i < self.digitBoxes.count; i++) {
        CGFloat xPosition = i * (boxWidth + self.digitSpacing);
        UIView *digitBox = self.digitBoxes[i];
        digitBox.frame = CGRectMake(xPosition, 0, boxWidth, boxHeight);
        
        UILabel *digitLabel = self.digitLabels[i];
        digitLabel.frame = digitBox.bounds;
    }
}

#pragma mark - 属性设置

- (void)setCodeLength:(NSInteger)codeLength {
    if (_codeLength != codeLength) {
        _codeLength = codeLength;
        [self clearCode];
        [self setupViews];
    }
}

- (void)setDigitSpacing:(CGFloat)digitSpacing {
    if (_digitSpacing != digitSpacing) {
        _digitSpacing = digitSpacing;
        [self setNeedsLayout];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius != cornerRadius) {
        _cornerRadius = cornerRadius;
        for (UIView *box in self.digitBoxes) {
            box.layer.cornerRadius = cornerRadius;
        }
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (_borderWidth != borderWidth) {
        _borderWidth = borderWidth;
        for (UIView *box in self.digitBoxes) {
            box.layer.borderWidth = borderWidth;
        }
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (_borderColor != borderColor) {
        _borderColor = borderColor;
        [self updateFocus];
    }
}

- (void)setFocusedBorderColor:(UIColor *)focusedBorderColor {
    if (_focusedBorderColor != focusedBorderColor) {
        _focusedBorderColor = focusedBorderColor;
        [self updateFocus];
    }
}

- (void)setBoxBackgroundColor:(UIColor *)boxBackgroundColor {
    if (_boxBackgroundColor != boxBackgroundColor) {
        _boxBackgroundColor = boxBackgroundColor;
        for (UIView *box in self.digitBoxes) {
            box.backgroundColor = boxBackgroundColor;
        }
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;
        for (UILabel *label in self.digitLabels) {
            label.textColor = textColor;
        }
    }
}

- (void)setTextFont:(UIFont *)textFont {
    if (_textFont != textFont) {
        _textFont = textFont;
        for (UILabel *label in self.digitLabels) {
            label.font = textFont;
        }
    }
}

#pragma mark - 键盘类型相关方法

- (UIKeyboardType)keyboardType {
    return self.keyboardTypeValue;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    self.keyboardTypeValue = keyboardType;
}

- (void)setCustomKeyboardType:(UIKeyboardType)keyboardType {
    // 更新键盘类型
    self.keyboardTypeValue = keyboardType;
    
    // 如果当前是第一响应者，需要先取消再重新成为第一响应者以更新键盘类型
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
        [self becomeFirstResponder];
    }
}

#pragma mark - 公共方法

- (NSString *)code {
    return [self.codeString copy];
}

- (void)clearCode {
    self.codeString = [NSMutableString string];
    self.currentIndex = 0;
    
    for (UILabel *label in self.digitLabels) {
        label.text = @"";
    }
    
    [self updateFocus];
    
    if ([self.delegate respondsToSelector:@selector(verificationCodeDidChange:)]) {
        [self.delegate verificationCodeDidChange:self.code];
    }
}

- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - 辅助方法

- (void)updateFocus {
    for (NSInteger i = 0; i < self.digitBoxes.count; i++) {
        UIView *box = self.digitBoxes[i];
        if (i == self.currentIndex) {
            box.layer.borderColor = self.focusedBorderColor.CGColor;
        } else {
            box.layer.borderColor = self.borderColor.CGColor;
        }
    }
}

- (void)viewTapped:(UITapGestureRecognizer *)sender {
    [self becomeFirstResponder];
}

#pragma mark - UIKeyInput 协议

- (BOOL)hasText {
    return self.codeString.length > 0;
}

- (void)insertText:(NSString *)text {
    // 仅当键盘类型为数字键盘时进行数字验证
    if (self.keyboardTypeValue == UIKeyboardTypeNumberPad && ![self validateNumberInput:text]) {
        return;
    }
    
    // 检查是否已达到最大长度
    if (self.currentIndex >= self.codeLength) {
        return;
    }
    
    // 对于所有键盘类型，验证输入是否为单个字符
    if (text.length != 1) {
        return;
    }
    
    // 添加输入字符
    [self.codeString appendString:text];
    self.digitLabels[self.currentIndex].text = text;
    self.currentIndex++;
    
    // 更新UI
    [self updateFocus];
    
    // 通知代理变化
    if ([self.delegate respondsToSelector:@selector(verificationCodeDidChange:)]) {
        [self.delegate verificationCodeDidChange:self.code];
    }
    
    // 检查验证码是否完成
    if (self.currentIndex == self.codeLength) {
        if ([self.delegate respondsToSelector:@selector(verificationCodeDidComplete:)]) {
            [self.delegate verificationCodeDidComplete:self.code];
        }
    }
}

- (void)deleteBackward {
    if (self.currentIndex > 0) {
        self.currentIndex--;
        self.digitLabels[self.currentIndex].text = @"";
        
        // 从字符串中删除最后一个字符
        if (self.codeString.length > 0) {
            [self.codeString deleteCharactersInRange:NSMakeRange(self.codeString.length - 1, 1)];
        }
        
        // 更新UI
        [self updateFocus];
        
        // 通知代理变化
        if ([self.delegate respondsToSelector:@selector(verificationCodeDidChange:)]) {
            [self.delegate verificationCodeDidChange:self.code];
        }
    }
}

// 验证数字输入
- (BOOL)validateNumberInput:(NSString *)input {
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [input rangeOfCharacterFromSet:nonDigits].location == NSNotFound && input.length == 1;
}

@end 
