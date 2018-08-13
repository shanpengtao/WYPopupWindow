# WYPopupWindow
仿安卓popupWindow，显示popupWindow中不影响页面上的其他任何交互，支持扩展添加任何视图

# 接入说明：
    pod WYPopupWindow 或 导入WYPopupWindow.(h,m)
    
# 使用说明：
    /****** 传入popupWindow要放到的父视图 及popupWindow的坐标（调起关键方法） ******/
    [[WYPopupWindow shareInstance] showPopWindowInView:parentView showAtLocation:CGRectMake(x, y, width, height)];
    
    // 记录展开视图的点击视图，用来解决重复点击该视图的问题
    [WYPopupWindow shareInstance].touchUpView = touchView;
    // 动画展开的起始点，默认是中心
    [WYPopupWindow shareInstance].animationAnchorPoint = CGPointMake(animationAnchorPointX, animationAnchorPointY);
    // popupWindow的背景颜色，默认是透明的
    [WYPopupWindow shareInstance].windowBackgoundColor = RandomColor;
    // 动画持续时间，默认0.2
    [WYPopupWindow shareInstance].animationDuration = 0.5;
    // 是否能响应内部点击事件，默认支持
    [WYPopupWindow shareInstance].touchable = YES;
    // 是否能响应外部点击事件，默认支持
    [WYPopupWindow shareInstance].outsideTouchable = YES;
    // 是否显示阴影，默认显示
    [WYPopupWindow shareInstance].isShowShadow = YES;
    // 阴影颜色，默认显示grayColor
    [WYPopupWindow shareInstance].shadowColor = [UIColor redColor];
    // 圆角弧度，默认4
    [WYPopupWindow shareInstance].cornerRadius = 10;
    // popupWindow蒙版颜色，默认是透明的
    [WYPopupWindow shareInstance].maskColor = [UIColor colorWithWhite:0 alpha:0.1];
    // 关闭popupWindow
    // [[WYPopupWindow shareInstance] closePopupWindow];
    
    /****** popupWindow上可以添加任何视图 ******/
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    label.text = [dataArray() objectAtIndex:touchView.tag];
    label.textAlignment = NSTextAlignmentCenter;
    [[WYPopupWindow shareInstance] addCustomView:button];
