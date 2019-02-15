//
//  UIViewController+MixExtention.m
//  MixExtention
//
//  Created by Eric Lung on 2019/2/14.
//  Copyright © 2019 Mix. All rights reserved.
//

#import "UIViewController+MixExtention.h"
#import "MixExtentionHooker.h"

@interface UIViewControllerMixExtention ()

@property (nonatomic, weak) UIViewController *vc;

@end

@implementation UIViewControllerMixExtention

- (instancetype)initWithViewController:(UIViewController *)vc
{
    if (self = [super init]) {
        self.vc = vc;
    }
    return self;
}

+ (UIViewController *)topViewController
{
    UIViewController *avc = [UIApplication sharedApplication].delegate.window.rootViewController;
    return [self findTopViewController:avc];
}

+ (UIViewController *)findTopViewController:(UIViewController *)vc
{
    UIViewController *avc;
    if (vc.presentedViewController) {
        avc = [self findTopViewController:vc.presentedViewController];
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        avc = [self findTopViewController:nav.topViewController];
    }
    else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tvc = (UITabBarController *)vc;
        avc = [self findTopViewController:tvc.viewControllers[tvc.selectedIndex]];
    }
    else if ([vc isKindOfClass:[UIViewController class]] && ![vc isKindOfClass:[UIAlertController class]]) {
        avc = vc;
    }
    return avc;
}

- (void)setViewWillAppear:(BOOL)viewWillAppear
{
    _viewWillAppear = viewWillAppear;
}

- (void)setViewDidAppear:(BOOL)viewDidAppear
{
    _viewDidAppear = viewDidAppear;
}

- (void)setDisableInteractivePopGesture:(BOOL)disableInteractivePopGesture
{
    BOOL isRoot = [self.vc.navigationController.viewControllers firstObject] == self.vc;
    _disableInteractivePopGesture = isRoot ? YES : disableInteractivePopGesture;
    self.vc.navigationController.interactivePopGestureRecognizer.enabled = !_disableInteractivePopGesture;
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    _statusBarHidden = statusBarHidden;
    UIView *view = [[UIApplication sharedApplication] valueForKeyPath:@"statusBarWindow.statusBar"];
    [UIView animateWithDuration:0.25 animations:^{
        view.alpha = !self.statusBarHidden;
    }];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    _statusBarStyle = statusBarStyle;
    [self.vc setNeedsStatusBarAppearanceUpdate];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    _navigationBarHidden = navigationBarHidden;
    [self.vc.navigationController setNavigationBarHidden:navigationBarHidden animated:YES];
    if (!navigationBarHidden) {
        if (self.navigationBarTitleTextAttributes) self.navigationBarTitleTextAttributes = _navigationBarTitleTextAttributes;
        if (self.navigationBarTintColor) self.navigationBarTintColor = _navigationBarTintColor;
        if (self.navigationBarBackgroundImage) self.navigationBarBackgroundImage = _navigationBarBackgroundImage;
        if (self.navigationBarBackImage) self.navigationBarBackImage = _navigationBarBackImage;
    }
}

- (void)setNavigationBarTitleTextAttributes:(NSDictionary *)navigationBarTitleTextAttributes
{
    _navigationBarTitleTextAttributes = navigationBarTitleTextAttributes;
    if (!self.navigationBarHidden) {
        self.vc.navigationController.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes;
    }
}

- (void)setNavigationBarTintColor:(UIColor *)navigationBarTintColor
{
    _navigationBarTintColor = [navigationBarTintColor copy];
    if (!self.navigationBarHidden) {
        self.vc.navigationController.navigationBar.tintColor = navigationBarTintColor;
    }
}

- (void)setNavigationBarBarTintColor:(UIColor *)navigationBarBarTintColor
{
    _navigationBarBarTintColor = [navigationBarBarTintColor copy];
    if (!self.navigationBarHidden) {
        self.vc.navigationController.navigationBar.barTintColor = navigationBarBarTintColor;
    }
}

- (void)setNavigationBarBackgroundImage:(UIImage *)navigationBarBackgroundImage
{
    _navigationBarBackgroundImage = navigationBarBackgroundImage;
    if (!self.navigationBarHidden) {
        [self.vc.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)setNavigationBarBackImage:(UIImage *)navigationBarBackImage
{
    _navigationBarBackImage = navigationBarBackImage;
    if (!self.navigationBarHidden) {
        self.vc.navigationController.navigationBar.backIndicatorImage = navigationBarBackImage;
        self.vc.navigationController.navigationBar.backIndicatorTransitionMaskImage = navigationBarBackImage;
    }
}

- (void)setTabBarTintColor:(UIColor *)tabBarTintColor
{
    _tabBarTintColor = [tabBarTintColor copy];
    [self tabBar].tintColor = tabBarTintColor;
}

- (void)setTabBarBarTintColor:(UIColor *)tabBarBarTintColor
{
    _tabBarBarTintColor = [tabBarBarTintColor copy];
    [self tabBar].barTintColor = tabBarBarTintColor;
}

- (UITabBar *)tabBar
{
    NSArray *vcs = self.vc.tabBarController.viewControllers;
    UINavigationController *nav = self.vc.navigationController;
    if (([nav.viewControllers firstObject] == self.vc || [vcs containsObject:self.vc]) && ![self.vc isKindOfClass:[UITabBarController class]]) {
        UITabBar *tabBar = self.vc.tabBarController.tabBar;
        if (!tabBar && [self.vc isKindOfClass:[UITabBarController class]]) {
            tabBar = ((UITabBarController *)self.vc).tabBar;
        }
        return tabBar;
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    UINavigationController *nav = self.vc.navigationController;
    UINavigationBar *bar = nav.navigationBar;

    self.statusBarHidden = _statusBarHidden;
    self.statusBarStyle = _statusBarStyle;
    self.navigationBarHidden = _navigationBarHidden;
    self.navigationBarTitleTextAttributes = _navigationBarTitleTextAttributes;
    self.navigationBarTintColor = _navigationBarTintColor;
    self.navigationBarBarTintColor = _navigationBarBarTintColor;
    if (!self.navigationBarBackgroundImage) {
        self.navigationBarBackgroundImage = [bar backgroundImageForBarMetrics:UIBarMetricsDefault];
    }
    if (self.navigationBarBackImage) {
        self.navigationBarBackImage = _navigationBarBackImage;
    }
    self.tabBarTintColor = _tabBarTintColor;
    self.tabBarBarTintColor = _tabBarBarTintColor;

    [self.vc.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        UIViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        BOOL isPop = ![nav.viewControllers containsObject:fromVC];
        if (!isPop) return ;

        for (UIView *view in [bar subviews]) {
            if ([view isKindOfClass:NSClassFromString(@"_UINavigationBarContentView")]) {
                for (UILabel *label in [view subviews]) {
                    if (![label isKindOfClass:[UILabel class]] || self.navigationBarHidden) continue;
                    label.attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:self.navigationBarTitleTextAttributes];
                    break;
                }
            }
            else if ([view isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
                for (UIView *sview in [view subviews]) {
                    if (![sview isKindOfClass:[UIVisualEffectView class]]) continue;
                    for (UIView *ssview in [sview subviews]) {
                        if (ssview.alpha < 0.86 && !self.navigationBarHidden) {
                            ssview.backgroundColor = self.navigationBarTintColor;
                            break;
                        }
                    }
                }
            }
        }
    } completion:nil];
    self.viewWillAppear = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.disableInteractivePopGesture = _disableInteractivePopGesture;
    self.viewDidAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.viewWillAppear = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.viewDidAppear = NO;
}

@end

@interface UIViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, readonly) BOOL mix_hasExtention;

@end

@implementation UIViewController (MixExtention)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mix_extention_hook_class_swizzleMethodAndStore(self, @selector(viewDidLoad), @selector(_mix_extention_viewDidLoad));
        mix_extention_hook_class_swizzleMethodAndStore(self, @selector(viewWillAppear:), @selector(_mix_extention_viewWillAppear:));
        mix_extention_hook_class_swizzleMethodAndStore(self, @selector(viewWillDisappear:), @selector(_mix_extention_viewWillDisappear:));
        mix_extention_hook_class_swizzleMethodAndStore(self, @selector(viewDidAppear:), @selector(_mix_extention_viewDidAppear:));
        mix_extention_hook_class_swizzleMethodAndStore(self, @selector(viewDidDisappear:), @selector(_mix_extention_viewDidDisappear:));
        mix_extention_hook_class_swizzleMethodAndStore(self, @selector(preferredStatusBarStyle), @selector(_mix_extention_preferredStatusBarStyle));
    });
}

- (BOOL)mix_hasExtention
{
    return [self conformsToProtocol:@protocol(UIViewControllerMixExtention)];
}

- (UIViewControllerMixExtention *)mix_extention
{
    if (!self.mix_hasExtention) return nil;
    id obj = objc_getAssociatedObject(self, _cmd);
    if (!obj) {
        obj = [[UIViewControllerMixExtention alloc] initWithViewController:self];
        objc_setAssociatedObject(self, _cmd, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obj;
}

- (void)_mix_extention_viewDidLoad
{
    [self _mix_extention_viewDidLoad];
    if (!self.mix_hasExtention) return;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (UIStatusBarStyle)_mix_extention_preferredStatusBarStyle
{
    return self.mix_hasExtention ? self.mix_extention.statusBarStyle : [self _mix_extention_preferredStatusBarStyle];
}

- (void)_mix_extention_viewWillAppear:(BOOL)animated
{
    [self _mix_extention_viewWillAppear:animated];
    if (self.mix_hasExtention) [self.mix_extention viewWillAppear:animated];
}

- (void)_mix_extention_viewWillDisappear:(BOOL)animated
{
    [self _mix_extention_viewWillDisappear:animated];
    if (self.mix_hasExtention) [self.mix_extention viewWillDisappear:animated];
}

- (void)_mix_extention_viewDidAppear:(BOOL)animated
{
    [self _mix_extention_viewDidAppear:animated];
    if (self.mix_hasExtention) [self.mix_extention viewDidAppear:animated];
}

- (void)_mix_extention_viewDidDisappear:(BOOL)animated
{
    [self _mix_extention_viewDidDisappear:animated];
    if (self.mix_hasExtention) [self.mix_extention viewDidDisappear:animated];
}

@end
