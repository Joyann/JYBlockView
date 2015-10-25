//
//  ViewController.m
//  JYBlockView
//
//  Created by joyann on 15/10/24.
//  Copyright © 2015年 Joyann. All rights reserved.
//

#import "ViewController.h"
#import "JYBlockView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"Home_refresh_bg"];
    [self.view addSubview:imageView];
    
    JYBlockView *blockView = [[JYBlockView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    blockView.center = self.view.center;
    [self.view addSubview:blockView];
    
//    self.view.layer.contents = (id)([UIImage imageNamed:@"Home_refresh_bg"].CGImage);
}


@end
