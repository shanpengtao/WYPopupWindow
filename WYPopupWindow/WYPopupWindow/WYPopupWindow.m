//
//  WYPopupWindow.m
//  WYPopupWindow
//
//  Created by wayne on 2018/6/15.
//  Copyright © 2018年 58. All rights reserved.
//

#import "WYPopupWindow.h"

@interface WYPopupWindow ()

/** 自定义视图所在的父视图 */
@property (nonatomic, strong) UIView *contentView;

/** 蒙版 */
@property (nonatomic, strong) UIView *maskView;

/** 缓存frame */
@property (nonatomic, assign) CGRect tmpFrame;

/** 是否处于展示中 */
@property (nonatomic, assign) BOOL _isDisplay;

/** 点击视图 */
@property (nonatomic, strong) UIButton *touchButton;

@end

@implementation WYPopupWindow

#pragma mark - ViewLife

+ (instancetype)shareInstance {
    
    static WYPopupWindow *popupWindow = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        popupWindow = [[WYPopupWindow alloc] init];
        [popupWindow initDefaultParams];
    });
    
    return popupWindow;
}

/**
 *  显示popupWindow
 */
- (void)showPopWindowInView:(UIView *)parentView showAtLocation:(CGRect)frame
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [self addSubview:self.contentView];
    
    CGRect rect = [[[UIApplication sharedApplication] keyWindow] convertRect:frame fromView:parentView];
    
    rect = [self adjustRect:rect];
    
    self.tmpFrame = rect;
    self.contentView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    [self showWindow:YES];
}

- (void)addCustomView:(UIView *)customView
{
    [self clearViewAndData];
    
    [self.contentView addSubview:customView];
}

// 调整坐标到window内部
- (CGRect)adjustRect:(CGRect)rect
{
    CGRect resultRect = CGRectZero;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    if (rect.origin.y + height > screenRect.size.height) {
        // 底部超出，往上移
        y = rect.origin.y - (rect.origin.y + height - screenRect.size.height);
    }
    else if (rect.origin.y < 0) {
        // 顶部超出，往下移
        y = 0;
    }
    else if (rect.origin.x + width > screenRect.size.width) {
        // 右侧超出，往左移
        x = rect.origin.x - (rect.origin.x + width - screenRect.size.width);
    }
    else if (rect.origin.x < 0) {
        // 左侧超出，往右移
        x = 0;
    }
    
    resultRect = CGRectMake(x, y, width, height);
    
    return resultRect;
}

// 赋值默认参数
- (void)initDefaultParams
{
    self.windowBackgoundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.animationAnchorPoint = CGPointMake(0.5, 0.5);
    self.animationDuration = 0.2;
    self.outsideTouchable = YES;
    self.touchable = YES;
    self.cornerRadius = 4;
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0;
    self.isShowShadow = YES;
}

// 清空视图和数据
- (void)clearViewAndData
{
    if (self.contentView.subviews) {
        for (id view in self.contentView.subviews) {
            if (view && [view isKindOfClass:[UIView class]]) {
                [view removeFromSuperview];
            }
        }
    }
}

/**
 *  关闭popupWindow
 */
- (void)closePopupWindow
{
    [_touchButton removeFromSuperview];
    _touchButton = nil;
    self.touchUpView = nil;
    
    [self showWindow:NO];
}

// 展示隐藏视图动画
- (void)showWindow:(BOOL)isShow
{
    __isDisplay = isShow;
    
    [self.layer removeAllAnimations];
    
    CAGradientLayer *contentLayer = (CAGradientLayer *)self.layer;
    contentLayer.anchorPoint = self.animationAnchorPoint;
    CGFloat kAnimationDuration = self.animationDuration;

    if (isShow) {
        
        self.maskView.hidden = NO;
        // 展开动画
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1)];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
        scaleAnimation.duration = kAnimationDuration;
        scaleAnimation.cumulative = NO;
        scaleAnimation.repeatCount = 1;
        [scaleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [contentLayer addAnimation: scaleAnimation forKey:@"popupWindowScaleEnlarge"];
        
        CABasicAnimation *showViewAnn = [CABasicAnimation animationWithKeyPath:@"opacity"];
        showViewAnn.fromValue = [NSNumber numberWithFloat:0.0];
        showViewAnn.toValue = [NSNumber numberWithFloat:1.0];
        showViewAnn.duration = kAnimationDuration;
        showViewAnn.fillMode = kCAFillModeForwards;
        showViewAnn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        showViewAnn.removedOnCompletion = YES;
        [contentLayer addAnimation:showViewAnn forKey:@"popupWindowShow"];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = kAnimationDuration;
        group.removedOnCompletion = YES;
        group.repeatCount = 1;
        group.fillMode = kCAFillModeForwards;
        [group setAnimations:@[scaleAnimation,showViewAnn]];
        [contentLayer addAnimation:group forKey:@"animationOpacity"];
        
        self.frame = self.tmpFrame;
        self.alpha = 1;
    }
    else {
        
        self.maskView.hidden = YES;
        // 隐藏动画
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1)];
        scaleAnimation.duration = kAnimationDuration;
        scaleAnimation.cumulative = NO;
        scaleAnimation.repeatCount = 1;
        [scaleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [contentLayer addAnimation: scaleAnimation forKey:@"popupWindowScaleNarrow"];
        
        CABasicAnimation *showViewAnn = [CABasicAnimation animationWithKeyPath:@"opacity"];
        showViewAnn.fromValue = [NSNumber numberWithFloat:1];
        showViewAnn.toValue = [NSNumber numberWithFloat:0];
        showViewAnn.duration = kAnimationDuration;
        showViewAnn.fillMode = kCAFillModeForwards;
        showViewAnn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        showViewAnn.removedOnCompletion = YES;
        [contentLayer addAnimation:showViewAnn forKey:@"popupWindowHide"];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = kAnimationDuration;
        group.removedOnCompletion = YES;
        group.repeatCount = 1;
        group.fillMode = kCAFillModeForwards;
        [group setAnimations:@[scaleAnimation,showViewAnn]];
        [contentLayer addAnimation:group forKey:@"animationOpacity"];
        self.alpha = 0;
        
        // 重置
        [self initDefaultParams];
    }
}

#pragma mark - 触摸点的所在位置

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // 将触摸点转到自己的身上的坐标
    CGPoint touchPoint = [self convertPoint:point toView:self.contentView];
    
    // 点在当前视图上，处理事件
    if ([self.contentView pointInside:touchPoint withEvent:event]) {
        return YES;
    }
    else {
        if (self.outsideTouchable) {
            [self closePopupWindow];
        }
        
        return [super pointInside:point withEvent:event];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // 将点转到window上的坐标
    CGPoint touchPoint = [[[UIApplication sharedApplication] keyWindow] convertPoint:point fromView:self];

    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(self.touchButton.frame), CGRectGetMinY(self.touchButton.frame), self.touchButton.bounds.size.width, self.touchButton.bounds.size.height), touchPoint)) {
        return self.touchButton;
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - Get

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _maskView.userInteractionEnabled = NO;
    }
    return _maskView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.masksToBounds = YES;
        _contentView.clipsToBounds = YES;
    }
    
    return _contentView;
}

- (UIButton *)touchButton
{
    if (!_touchButton) {
        _touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_touchButton addTarget:self action:@selector(closePopupWindow) forControlEvents:UIControlEventTouchUpInside];
    }
    return _touchButton;
}

- (BOOL)isDisplay
{
    return __isDisplay;
}

#pragma mark - Set

- (void)setTouchable:(BOOL)touchable
{
    self.userInteractionEnabled = touchable;
}

- (void)setOutsideTouchable:(BOOL)outsideTouchable
{
    _outsideTouchable = outsideTouchable;
    self.maskView.userInteractionEnabled = !outsideTouchable;
}

- (void)setMaskColor:(UIColor *)maskColor
{
    self.maskView.backgroundColor = maskColor;
}

- (void)setWindowBackgoundColor:(UIColor *)windowBackgoundColor
{
    self.contentView.backgroundColor = _windowBackgoundColor = windowBackgoundColor;
}

- (void)setIsShowShadow:(BOOL)isShowShadow
{
    _isShowShadow = isShowShadow;

    [self setNeedsDisplay];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.contentView.layer.cornerRadius = cornerRadius;
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    
    self.layer.shadowColor = shadowColor.CGColor;
}

- (void)setTouchUpView:(UIView *)touchUpView
{
    if (touchUpView) {
        // 将rect转到window上的坐标
        CGRect touchRect = [[[UIApplication sharedApplication] keyWindow] convertRect:touchUpView.frame fromView:touchUpView.superview];
        
        self.touchButton.frame = touchRect;
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.touchButton];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (_isShowShadow) {
        self.layer.shadowColor = _shadowColor ? _shadowColor.CGColor :[UIColor grayColor].CGColor;
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowRadius = 6;
        self.layer.shadowOffset = CGSizeZero;
    }
    else {
        self.layer.shadowOpacity = 0;
    }
    
    [super drawRect:rect];
}

@end
