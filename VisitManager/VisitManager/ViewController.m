//
//  ViewController.m
//  VisitManager
//
//  Created by 李鹏跃 on 2022/4/16.
//

#import "ViewController.h"
#import "ProductListViewController.h"
@interface ViewController ()
@property (nonatomic,strong) UIButton *jumpToDemoButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.jumpToDemoButton];
    self.jumpToDemoButton.frame = CGRectMake(100, 100, 100, 100);
}

- (UIButton *) jumpToDemoButton {
    if (!_jumpToDemoButton) {
        _jumpToDemoButton = [[UIButton alloc]init];
        [_jumpToDemoButton setTitle:@"jumpToDemoButton" forState:UIControlStateNormal];
        _jumpToDemoButton.layer.borderColor = UIColor.redColor.CGColor;
        _jumpToDemoButton.layer.borderWidth = 1;
        _jumpToDemoButton.layer.cornerRadius = 2;
        [_jumpToDemoButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [_jumpToDemoButton addTarget:self action:@selector(click_jumpToDemoButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _jumpToDemoButton;
}
- (void)click_jumpToDemoButton {
    [self.navigationController pushViewController:[ProductListViewController new] animated:true];
}

@end
