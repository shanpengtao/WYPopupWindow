//
//  ViewController.m
//  WYPopupWindow
//
//  Created by wayne on 2018/8/8.
//  Copyright © 2018年 58. All rights reserved.
//

#import "ViewController.h"
#import "WYPopupWindow.h"

//  随机颜色
#define   RandomColor   [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]
#define isIPhoneX \
([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
// 普通iPhone的navigationBar的高度
#define NormalNavigationBarHeight 64
// iPhoneX的navigationBar高度
#define XNavigationBarHeight 88
// 导航栏+状态栏高度
#define NavigationBarHeight  (isIPhoneX ? XNavigationBarHeight:NormalNavigationBarHeight)
// 屏幕的宽度
#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)
// 列表行高
#define CellHeight 50

#define SHOW_ALERT(text) \
UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"line:%d,method:%s",__LINE__, __func__] message:text preferredStyle:UIAlertControllerStyleAlert]; \
UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]; \
[alertController addAction:cancelAction]; \
UIWindow *window = [[UIApplication sharedApplication].delegate window]; \
[window.rootViewController presentViewController:alertController animated:YES completion:nil];

static NSArray *dataArray() {
    return @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
}

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

/** 列表 */
@property (nonatomic, strong) UITableView *tableView;

/** 开关 */
@property (nonatomic, strong) UISwitch *aSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"WYPopupWindow";
    self.view.backgroundColor = [UIColor colorWithRed:0xFA/255.0 green:0xFA/255.0 blue:0xFA/255.0 alpha:1];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(push)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.aSwitch];

    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showPopupWindow:(UIView *)touchView
{
    int width = 50 + (arc4random() % 101);
    int height = 50 + (arc4random() % 101);
    int x = 10 + (arc4random() % ((int)self.view.frame.size.width - 20 - width));
    int y = 10 + (arc4random() % ((int)CellHeight));

    NSLog(@"随机frame：(%d,%d),(%d,%d)", x, y, width, height);
    
    float animationAnchorPointX = ((double)arc4random() / 0x100000000);
    float animationAnchorPointY = ((double)arc4random() / 0x100000000);
    NSLog(@"随机动画起始点frame：(%f,%f)", animationAnchorPointX, animationAnchorPointY);

    UIView *parentView = touchView.superview;
    
    /****** 传入popupWindow要放到的父视图 及popupWindow的坐标（调起关键方法） ******/
    [[WYPopupWindow shareInstance] showPopWindowInView:parentView showAtLocation:CGRectMake(x, y, width, height)];
    
    // 记录展开视图的点击视图，用来解决重复点击该视图的问题
    [WYPopupWindow shareInstance].touchUpView = touchView;
    // 动画展开的起始点，默认是中心
    [WYPopupWindow shareInstance].animationAnchorPoint = CGPointMake(animationAnchorPointX, animationAnchorPointY);
    // popupWindow的背景颜色，默认是透明的
    [WYPopupWindow shareInstance].windowBackgoundColor = RandomColor;
    // 动画持续时间，默认0.2
    [WYPopupWindow shareInstance].animationDuration = 0.3;
    // 是否能响应内部点击事件，默认支持
    [WYPopupWindow shareInstance].touchable = YES;
    // 是否能响应外部点击事件，默认支持
    [WYPopupWindow shareInstance].outsideTouchable = YES;
    // 是否显示阴影，默认显示
//    [WYPopupWindow shareInstance].isShowShadow = YES;
    // 阴影颜色，默认显示grayColor
    [WYPopupWindow shareInstance].shadowColor = [UIColor redColor];
    // 圆角弧度，默认4
    [WYPopupWindow shareInstance].cornerRadius = 10;
    // popupWindow蒙版颜色，默认是透明的
    [WYPopupWindow shareInstance].maskColor = [UIColor colorWithWhite:0 alpha:0.1];
    
    /****** popupWindow上可以添加任何视图 ******/
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, width, height);
    [button setTitle:[dataArray() objectAtIndex:touchView.tag] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(touchButton) forControlEvents:UIControlEventTouchUpInside];
    [[WYPopupWindow shareInstance] addCustomView:button];
}

- (void)touchButton
{
    NSLog(@"点击了popupWindow上的按钮");
    
    // 关闭popupWindow
    [[WYPopupWindow shareInstance] closePopupWindow];
}

- (void)push
{
    [self.navigationController pushViewController:[UIViewController new] animated:YES];
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    NSLog(@"响应了单击手势");
}

- (void)changeSwitch
{
    NSLog(@"响应了UISwitch");
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataArray().count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentify = @"tableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    UIButton *button = self.button;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        cell.backgroundColor = [UIColor colorWithRed:0x9A/255.0 green:0xC0/255.0 blue:0xCD/255.0 alpha:1];
        [cell addSubview:button];
        [cell addSubview:self.label];
    }

    button.tag = indexPath.row;
    cell.textLabel.text = [dataArray() objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"响应了cell");
}

#pragma mark - Get

- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavigationBarHeight, ScreenWidth, ScreenHeight - NavigationBarHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor colorWithRed:0x9A/255.0 green:0xC0/255.0 blue:0xCD/255.0 alpha:1];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = [UIView new];
    }
    
    return _tableView;
}

- (UISwitch *)aSwitch
{
    if (!_aSwitch) {
        _aSwitch = [[UISwitch alloc] init];
        [_aSwitch addTarget:self action:@selector(changeSwitch) forControlEvents:UIControlEventValueChanged];
    }
    return _aSwitch;
    
}

- (UIButton *)button
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(ScreenWidth - 70, 10, 60, CellHeight - 20);
    button.backgroundColor = [UIColor blueColor];
    [button setTitle:@"show" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button addTarget:self action:@selector(showPopupWindow:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)label
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(ScreenWidth - 80 - 70, 10, 60, CellHeight - 20);
    label.backgroundColor = [UIColor yellowColor];
    label.text = @"tap";
    label.userInteractionEnabled = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [label addGestureRecognizer:tap];
    
    return label;
}

@end
