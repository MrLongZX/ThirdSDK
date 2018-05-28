//
//  ViewController.m
//  WeiXin
//
//  Created by guimi on 2018/5/25.
//  Copyright © 2018年 guimi. All rights reserved.
//

#import "ViewController.h"
#import "WXApiManager.h"

@interface ViewController ()<WXAuthDelegate>

@property (nonatomic, strong) UIButton *authBtn;

@end

@implementation ViewController

- (UIButton *)authBtn
{
    if (!_authBtn) {
        _authBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _authBtn.frame = CGRectMake(50, self.view.frame.size.height/2 - 25, self.view.frame.size.width - 100, 50);
        [_authBtn setBackgroundColor:[UIColor lightGrayColor]];
        [_authBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_authBtn setTitle:@"微信授权" forState:UIControlStateNormal];
        [_authBtn addTarget:self action:@selector(showLogin) forControlEvents:UIControlEventTouchUpInside];
    }
    return _authBtn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.authBtn];
}

- (void)showLogin
{
    [[WXApiManager sharedManager] sendAuthRequestWithController:self
                                                       delegate:self];
}

#pragma mark - WXAuthDelegate
// 授权成功
- (void)wxAuthSucceed:(NSString*)code
{
    NSLog(@"授权成功 code: %@",code);
    [self getAccessTokeActionWith:code];
}

// 授权失败
- (void)wxAuthDenied
{
    NSLog(@"denied");
}

// 用户点击取消并返回
- (void)wxAuthCancel
{
    NSLog(@"cancel");
}


// 根据codeh获取access_token
- (void)getAccessTokeActionWith:(NSString *)code
{
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",@"wx49fc99c349383712",@"893dbbab16d6601326468ace4e531078",code];
    
    __weak __typeof(self)weakSelf = self;
    [self getSessionRequestWithURL:urlStr withReslut:^(NSDictionary *dic) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"access_token相关信息：%@",dic);
        [strongSelf getUserInfoWithAccessToken:dic[@"access_token"] withOpenId:dic[@"openid"]];
        
    }];
}

// 获取微信用户信息
- (void)getUserInfoWithAccessToken:(NSString *)token withOpenId:(NSString *)openid
{
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,openid];
    
    [self getSessionRequestWithURL:urlStr withReslut:^(NSDictionary *dic) {
        NSLog(@"个人信息：%@",dic);
    }];
}

// 发送网络请求
- (void)getSessionRequestWithURL:(NSString *)url withReslut:(void (^)(NSDictionary *dic))completionHandler
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *urlString = [NSURL URLWithString:url];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:urlString completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        completionHandler(dic);
        
    }];
    
    [task resume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
