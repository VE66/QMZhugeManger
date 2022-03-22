//
//  QMViewController.m
//  QMZhugeManger
//
//  Created by VE66 on 03/18/2022.
//  Copyright (c) 2022 VE66. All rights reserved.
//

#import "QMViewController.h"
#import <QMZhugeManger/QMZhugeManger.h>

@interface QMViewController ()

@end

@implementation QMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [QMZhugeManager setAccessid:@"ccdb6800-ff6d-11e9-8018-cbe6b3476ac1" userId:@"userID:1234567" userName:@"userName788" version:@"v4.1.0" sid:@""];
    [QMZhugeManager trackEvent:@"你好"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
