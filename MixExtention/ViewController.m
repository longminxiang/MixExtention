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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = [NSString stringWithFormat:@"Test%d", rand() % 100];
        [self.mixE addObserver:self forKeyPath:@"viewState" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.mixE addObserver:self forKeyPath:@"item.disableInteractivePopGesture" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    [self.mixE addObserver:self forKeyPath:@"item.navigationBarHidden" options:NSKeyValueObservingOptionNew context:nil];
    self.mixE.item.navigationBarTintColor = [self randColor];
    self.mixE.item.navigationBarBackImage = [UIImage imageNamed:rand() % 2 ? @"icon_back" : @"nav_back"];
}

- (IBAction)push
{
    [self.navigationController.mixE pushViewController:[ViewController new] animated:YES completion:^{
        NSLog(@"push completed");
    }];
}

- (IBAction)pop
{
    [self.navigationController.mixE popViewControllerAnimated:YES completion:^{
        NSLog(@"pop completed");
    }];
}

- (IBAction)popToRoot
{
    [self.navigationController.mixE popToRootViewControllerAnimated:YES completion:^{
        NSLog(@"pop to root completed");
    }];
}

- (IBAction)present
{
    [self presentViewController:[ViewController new] animated:YES completion:^{
        NSLog(@"present completed");
    }];
}

- (IBAction)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismiss completed");
    }];
}

- (IBAction)disableInteractivePopGesture
{
    self.mixE.item.disableInteractivePopGesture = !self.mixE.item.disableInteractivePopGesture;
}

- (IBAction)handleStatusBarHiddenButton
{
    self.mixE.item.statusBarHidden = !self.mixE.item.statusBarHidden;
}

- (IBAction)handleStatusBarStyleSegmentedControl:(UISegmentedControl *)sender
{
    self.mixE.item.statusBarStyle = sender.selectedSegmentIndex;
}

- (IBAction)handleNavigationBarHidden
{
    self.mixE.item.navigationBarHidden = !self.mixE.item.navigationBarHidden;
}

- (IBAction)handleNavigationBarTintColor
{
    self.mixE.item.navigationBarTintColor = [self randColor];
}

- (IBAction)handleNavigationBarBarTintColor
{
    self.mixE.item.navigationBarBarTintColor = [self randColor];
}

- (IBAction)handleNavigationBarTitleColor
{
    NSDictionary *atts = @{NSForegroundColorAttributeName: [self randColor]};
    self.mixE.item.navigationBarTitleTextAttributes = atts;
}

- (IBAction)handleNavigationBarBottomLineHidden
{
    self.mixE.item.navigationBarBottomLineHidden = !self.mixE.item.navigationBarBottomLineHidden;
}

- (IBAction)handleTabBarTintColor
{
    self.mixE.item.tabBarTintColor = [self randColor];
}

- (IBAction)handleTabBarBarTintColor
{
    self.mixE.item.tabBarBarTintColor = [self randColor];
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
    if (object != self.mixE) return;

    if ([keyPath isEqualToString:@"viewState"]) {
        NSString *string = @"";
        switch (self.mixE.viewState) {
            case MixViewControllerStateViewDidLoad: string = @"view did load"; break;
            case MixViewControllerStateViewWillAppear: string = @"view will appear"; break;
            case MixViewControllerStateViewDidAppear: string = @"view did appear"; break;
            case MixViewControllerStateViewWillDisappear: string = @"view will disappear"; break;
            case MixViewControllerStateViewDidDisappear: string = @"view did disappear"; break;
            default: break;
        }
        NSLog(@"%@ %@", self.title, string);
    }
    else if ([keyPath isEqualToString:@"item.disableInteractivePopGesture"]) {
        NSString *title = [NSString stringWithFormat:@"disableInteractivePopGesture: %@", self.mixE.item.disableInteractivePopGesture ? @"YES" : @"NO"];
        self.disableInteractivePopGestureButton.titleLabel.text = title;
        [self.disableInteractivePopGestureButton setTitle:title forState:UIControlStateNormal];
    }
    else if ([keyPath isEqualToString:@"item.navigationBarHidden"]) {
        NSString *title = [NSString stringWithFormat:@"statusBarHidden: %@", self.mixE.item.statusBarHidden ? @"YES" : @"NO"];
        self.statusBarHiddenButton.titleLabel.text = title;
        [self.statusBarHiddenButton setTitle:title forState:UIControlStateNormal];
    }
}

- (BOOL)hidesBottomBarWhenPushed
{
    return self.navigationController.viewControllers.count > 1;
}

- (void)dealloc
{
    [self.mixE removeObserver:self forKeyPath:@"viewState"];
    [self.mixE removeObserver:self forKeyPath:@"item.disableInteractivePopGesture"];
    [self.mixE removeObserver:self forKeyPath:@"item.navigationBarHidden"];
}

@end
