//
//  WYPopupWindow.h
//  WYPopupWindow
//
//  Created by wayne on 2018/6/15.
//  Copyright © 2018年 58. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYPopupWindow : UIView

/** 展开视图的按钮，控制展开视图过程中点击按钮的事件 */
@property (nonatomic, weak) UIView *touchUpView;

/** PopupWindow背景蒙版颜色，默认透明 */
@property (nonatomic, strong) UIColor *maskColor;

/** PopupWindow背景颜色，默认透明 */
@property (nonatomic, strong) UIColor *windowBackgoundColor;

/** 动画锚点，默认中间点(0.5, 0.5) */
@property (nonatomic, assign) CGPoint animationAnchorPoint;

/** 动画持续时间，默认0.2 */
@property (nonatomic, assign) CGFloat animationDuration;

/** 是否能响应内部点击事件，默认支持 */
@property (nonatomic, assign) BOOL touchable;

/** 是否能响应外部点击事件，默认支持 */
@property (nonatomic, assign) BOOL outsideTouchable;

/** 是否显示阴影，默认显示 */
@property (nonatomic, assign) BOOL isShowShadow;

/** 阴影颜色，默认显示grayColor */
@property (nonatomic, strong) UIColor *shadowColor;

/** 圆角弧度，默认4 */
@property (nonatomic, assign) CGFloat cornerRadius;

/** 是否处于展示中，只读 */
@property (nonatomic, assign, readonly) BOOL isDisplay;

/**
 *  单例实例
 */
+ (instancetype)shareInstance;

/**
 *  显示popupWindow
 *
 *  @param parentView   父视图
 *  @param frame        父视图的位置大小
 */
- (void)showPopWindowInView:(UIView *)parentView showAtLocation:(CGRect)frame;

/**
 *  添加自定义视图
 *
 *  @param customView   自定义视图
 */
- (void)addCustomView:(UIView *)customView;

/**
 *  关闭当前popupWindow
 */
- (void)closePopupWindow;

@end
