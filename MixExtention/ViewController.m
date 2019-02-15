//
//  ViewController.m
//  MixExtention
//
//  Created by Eric Lung on 2019/2/14.
//  Copyright © 2019 Mix. All rights reserved.
//

#import "ViewController.h"
#import "MixExtention.h"

@interface ViewController ()<UIViewControllerMixExtention>

@property (nonatomic, weak) IBOutlet UIButton *disableInteractivePopGestureButton;
@property (nonatomic, weak) IBOutlet UIButton *statusBarHiddenButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = [NSString stringWithFormat:@"Test%d", rand() % 100];

    [self.mix_extention addObserver:self forKeyPath:@"viewWillAppear" options:NSKeyValueObservingOptionNew context:nil];
    [self.mix_extention addObserver:self forKeyPath:@"viewDidAppear" options:NSKeyValueObservingOptionNew context:nil];
    [self.mix_extention addObserver:self forKeyPath:@"disableInteractivePopGesture" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    [self.mix_extention addObserver:self forKeyPath:@"statusBarHidden" options:NSKeyValueObservingOptionNew context:nil];

    self.mix_extention.navigationBarTintColor = [self randColor];
    self.mix_extention.navigationBarBackImage = [UIImage imageNamed:rand() % 2 ? @"icon_back" : @"nav_back"];
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

- (IBAction)disableInteractivePopGesture
{
    self.mix_extention.disableInteractivePopGesture = !self.mix_extention.disableInteractivePopGesture;
}

- (IBAction)handleStatusBarHiddenButton
{
    self.mix_extention.statusBarHidden = !self.mix_extention.statusBarHidden;
}

- (IBAction)handleStatusBarStyleSegmentedControl:(UISegmentedControl *)sender
{
    self.mix_extention.statusBarStyle = sender.selectedSegmentIndex;
}

- (IBAction)handleNavigationBarHidden
{
    self.mix_extention.navigationBarHidden = !self.mix_extention.navigationBarHidden;
}

- (IBAction)handleNavigationBarTintColor
{
    self.mix_extention.navigationBarTintColor = [self randColor];
}

- (IBAction)handleNavigationBarBarTintColor
{
    self.mix_extention.navigationBarBarTintColor = [self randColor];
}

- (IBAction)handleNavigationBarTitleColor
{
    NSDictionary *atts = @{NSForegroundColorAttributeName: [self randColor]};
    self.mix_extention.navigationBarTitleTextAttributes = atts;
}

- (IBAction)handleTabBarTintColor
{
    self.mix_extention.tabBarTintColor = [self randColor];
}

- (IBAction)handleTabBarBarTintColor
{
    self.mix_extention.tabBarBarTintColor = [self randColor];
}

- (IBAction)handleFindTopViewController
{
    UIViewController *topVC = [UIViewControllerMixExtention topViewController];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Top ViewController is:" message:topVC.title preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:vc animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [vc dismissViewControllerAnimated:YES completion:nil];
    });
}

- (UIColor *)randColor
{
    return [UIColor colorWithRed:(float)(rand() % 10) / 10 green:(float)(rand() % 10) / 10 blue:(float)(rand() % 10) / 10 alpha:1];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.mix_extention) {
        if ([keyPath isEqualToString:@"viewWillAppear"]) {
            NSLog(@"%@ Will %@", self.title, self.mix_extention.viewWillAppear ? @"Appear" : @"Disappear");
        }
        else if ([keyPath isEqualToString:@"viewDidAppear"]) {
            NSLog(@"%@ Did %@", self.title, self.mix_extention.viewWillAppear ? @"Appear" : @"Disappear");
        }
        else if ([keyPath isEqualToString:@"disableInteractivePopGesture"]) {
            NSString *title = [NSString stringWithFormat:@"disableInteractivePopGesture: %@", self.mix_extention.disableInteractivePopGesture ? @"YES" : @"NO"];
            self.disableInteractivePopGestureButton.titleLabel.text = title;
            [self.disableInteractivePopGestureButton setTitle:title forState:UIControlStateNormal];
        }
        else if ([keyPath isEqualToString:@"statusBarHidden"]) {
            NSString *title = [NSString stringWithFormat:@"statusBarHidden: %@", self.mix_extention.statusBarHidden ? @"YES" : @"NO"];
            self.statusBarHiddenButton.titleLabel.text = title;
            [self.statusBarHiddenButton setTitle:title forState:UIControlStateNormal];
        }
    }
}

- (BOOL)hidesBottomBarWhenPushed
{
    return self.navigationController.viewControllers.count > 1;
}

- (void)dealloc
{
    [self.mix_extention removeObserver:self forKeyPath:@"viewWillAppear"];
    [self.mix_extention removeObserver:self forKeyPath:@"viewDidAppear"];
    [self.mix_extention removeObserver:self forKeyPath:@"disableInteractivePopGesture"];
    [self.mix_extention removeObserver:self forKeyPath:@"statusBarHidden"];
}

@end