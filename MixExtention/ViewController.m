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

    [self.mixE addObserver:self forKeyPath:@"disableInteractivePopGesture" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    [self.mixE addObserver:self forKeyPath:@"navigationBarHidden" options:NSKeyValueObservingOptionNew context:nil];
    self.mixE.navigationBarTintColor = [self randColor];
    self.mixE.navigationBarBackImage = [UIImage imageNamed:rand() % 2 ? @"icon_back" : @"nav_back"];
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

- (IBAction)disableInteractivePopGesture
{
    self.mixE.disableInteractivePopGesture = !self.mixE.disableInteractivePopGesture;
}

- (IBAction)handleStatusBarHiddenButton
{
    self.mixE.statusBarHidden = !self.mixE.statusBarHidden;
}

- (IBAction)handleStatusBarStyleSegmentedControl:(UISegmentedControl *)sender
{
    self.mixE.statusBarStyle = sender.selectedSegmentIndex;
}

- (IBAction)handleNavigationBarHidden
{
    self.mixE.navigationBarHidden = !self.mixE.navigationBarHidden;
}

- (IBAction)handleNavigationBarTintColor
{
    self.mixE.navigationBarTintColor = [self randColor];
}

- (IBAction)handleNavigationBarBarTintColor
{
    self.mixE.navigationBarBarTintColor = [self randColor];
}

- (IBAction)handleNavigationBarTitleColor
{
    NSDictionary *atts = @{NSForegroundColorAttributeName: [self randColor]};
    self.mixE.navigationBarTitleTextAttributes = atts;
}

- (IBAction)handleNavigationBarBottomLineHidden
{
    self.mixE.navigationBarBottomLineHidden = !self.mixE.navigationBarBottomLineHidden;
}

- (IBAction)handleTabBarTintColor
{
    self.mixE.tabBarTintColor = [self randColor];
}

- (IBAction)handleTabBarBarTintColor
{
    self.mixE.tabBarBarTintColor = [self randColor];
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
    if (object == self.mixE) {
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
    }
    else if (object == self.mixE) {
        if ([keyPath isEqualToString:@"disableInteractivePopGesture"]) {
            NSString *title = [NSString stringWithFormat:@"disableInteractivePopGesture: %@", self.mixE.disableInteractivePopGesture ? @"YES" : @"NO"];
            self.disableInteractivePopGestureButton.titleLabel.text = title;
            [self.disableInteractivePopGestureButton setTitle:title forState:UIControlStateNormal];
        }
        else if ([keyPath isEqualToString:@"navigationBarHidden"]) {
            NSString *title = [NSString stringWithFormat:@"statusBarHidden: %@", self.mixE.statusBarHidden ? @"YES" : @"NO"];
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
    [self.mixE removeObserver:self forKeyPath:@"viewState"];
    [self.mixE removeObserver:self forKeyPath:@"disableInteractivePopGesture"];
    [self.mixE removeObserver:self forKeyPath:@"navigationBarHidden"];
}

@end
