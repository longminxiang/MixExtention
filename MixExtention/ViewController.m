//
//  ViewController.m
//  MixExtention
//
//  Created by Eric Lung on 2019/2/14.
//  Copyright © 2019 Mix. All rights reserved.
//

#import "ViewController.h"
#import "UINavigationController+MixExtention.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = [NSString stringWithFormat:@"Test%d", rand() % 100];
}

- (IBAction)push
{
    [self.navigationController.mix_extention pushViewController:[ViewController new] animated:YES completion:^{
        NSLog(@"push completed");
    }];
}

- (IBAction)pop
{
    [self.navigationController.mix_extention popViewControllerAnimated:YES completion:^{
        NSLog(@"pop completed");
    }];
}

- (IBAction)popToRoot
{
    [self.navigationController.mix_extention popToRootViewControllerAnimated:YES completion:^{
        NSLog(@"pop to root completed");
    }];
}

@end
