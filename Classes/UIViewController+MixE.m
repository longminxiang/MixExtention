//
//  UIViewController+MixE.m
//  MixExtention
//
//  Created by Eric Lung on 2019/2/14.
//  Copyright © 2019 Mix. All rights reserved.
//

#import "UIViewController+MixE.h"
#import "MixEHooker.h"

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

- (void)setViewState:(MixViewControllerState)viewState
{
    _viewState = viewState;
}

- (void)setDisableInteractivePopGesture:(BOOL)disableInteractivePopGesture
{
    _disableInteractivePopGesture = disableInteractivePopGesture;
    BOOL enabled = [self.vc.navigationController.viewControllers firstObject] != self.vc && !disableInteractivePopGesture;
    self.vc.navigationController.interactivePopGestureRecognizer.enabled = enabled;
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    _statusBarHidden = statusBarHidden;
    UIView *view = [[UIApplication sharedApplication] valueForKeyPath:@"statusBarWindow.statusBar"];
    [UIView animateWithDuration:0.25 animations:^{
        view.alpha = !statusBarHidden;
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
    self.navigationBarTitleTextAttributes = _navigationBarTitleTextAttributes;
    self.navigationBarTintColor = _navigationBarTintColor;
    self.navigationBarBarTintColor = _navigationBarBarTintColor;
    self.navigationBarBackgroundImage = _navigationBarBackgroundImage;
    self.navigationBarBackImage = _navigationBarBackImage;
}

- (void)setNavigationBarBottomLineHidden:(BOOL)navigationBarBottomLineHidden
{
    _navigationBarBottomLineHidden = navigationBarBottomLineHidden;
    [self navigationBarBottomLineView].hidden = navigationBarBottomLineHidden;
}

- (void)setNavigationBarTitleTextAttributes:(NSDictionary *)navigationBarTitleTextAttributes
{
    _navigationBarTitleTextAttributes = navigationBarTitleTextAttributes;
    if (self.navigationBarHidden) return;
    self.vc.navigationController.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes;
}

- (void)setNavigationBarTintColor:(UIColor *)navigationBarTintColor
{
    _navigationBarTintColor = navigationBarTintColor;
    if (self.navigationBarHidden) return;
    self.vc.navigationController.navigationBar.tintColor = navigationBarTintColor;
}

- (void)setNavigationBarBarTintColor:(UIColor *)navigationBarBarTintColor
{
    _navigationBarBarTintColor = navigationBarBarTintColor;
    if (self.navigationBarHidden) return;
    self.vc.navigationController.navigationBar.barTintColor = navigationBarBarTintColor;
}

- (void)setNavigationBarBackgroundImage:(UIImage *)navigationBarBackgroundImage
{
    _navigationBarBackgroundImage = navigationBarBackgroundImage;
    if (self.navigationBarHidden) return;
    [self.vc.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)setNavigationBarBackImage:(UIImage *)navigationBarBackImage
{
    _navigationBarBackImage = navigationBarBackImage;
    if (self.navigationBarHidden) return;
    self.vc.navigationController.navigationBar.backIndicatorImage = navigationBarBackImage;
    self.vc.navigationController.navigationBar.backIndicatorTransitionMaskImage = navigationBarBackImage;
}

- (void)setTabBarTintColor:(UIColor *)tabBarTintColor
{
    _tabBarTintColor = tabBarTintColor;
    [self tabBar].tintColor = tabBarTintColor;
}

- (void)setTabBarBarTintColor:(UIColor *)tabBarBarTintColor
{
    _tabBarBarTintColor = tabBarBarTintColor;
    [self tabBar].barTintColor = tabBarBarTintColor;
}

- (void)viewDidLoad
{
    self.viewState = MixViewControllerStateViewDidLoad;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.statusBarHidden = _statusBarHidden;
    self.statusBarStyle = _statusBarStyle;
    self.navigationBarHidden = _navigationBarHidden;
    self.tabBarTintColor = _tabBarTintColor;
    self.tabBarBarTintColor = _tabBarBarTintColor;
    self.navigationBarBottomLineHidden = _navigationBarBottomLineHidden;

    UINavigationController *nav = self.vc.navigationController;
    UINavigationBar *bar = nav.navigationBar;
    [self.vc.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        UIViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        BOOL isPop = ![nav.viewControllers containsObject:fromVC];
        if (isPop) {
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
        }
    } completion:nil];
    self.viewState = MixViewControllerStateViewWillAppear;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.disableInteractivePopGesture = _disableInteractivePopGesture;
    self.navigationBarBottomLineHidden = _navigationBarBottomLineHidden;
    self.viewState = MixViewControllerStateViewDidAppear;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.viewState = MixViewControllerStateViewWillDisappear;
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.viewState = MixViewControllerStateViewDidDisappear;
}

- (UIView *)navigationBarBottomLineView
{
    for (UIView *view in self.vc.navigationController.navigationBar.subviews) {
        if (![view isKindOfClass:[UIImageView class]] && ![view isKindOfClass:NSClassFromString(@"_UIBarBackground")]) continue;
        for (UIView *sview in view.subviews) {
            if (sview.frame.size.height > 1) continue;
            return sview;
        }
    }
    return nil;
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

@end

@interface UIViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, readonly) BOOL mix_hasExtention;

@end

@implementation UIViewController (MixExtention)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mixE_hook_class_swizzleMethodAndStore(self, @selector(viewDidLoad), @selector(_mix_extention_viewDidLoad));
        mixE_hook_class_swizzleMethodAndStore(self, @selector(viewWillAppear:), @selector(_mix_extention_viewWillAppear:));
        mixE_hook_class_swizzleMethodAndStore(self, @selector(viewWillDisappear:), @selector(_mix_extention_viewWillDisappear:));
        mixE_hook_class_swizzleMethodAndStore(self, @selector(viewDidAppear:), @selector(_mix_extention_viewDidAppear:));
        mixE_hook_class_swizzleMethodAndStore(self, @selector(viewDidDisappear:), @selector(_mix_extention_viewDidDisappear:));
        mixE_hook_class_swizzleMethodAndStore(self, @selector(preferredStatusBarStyle), @selector(_mix_extention_preferredStatusBarStyle));
    });
}

- (BOOL)mix_hasExtention
{
    return [self conformsToProtocol:@protocol(UIViewControllerMixExtention)];
}

- (UIViewControllerMixExtention *)mixE
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
    [self.mixE viewDidLoad];
}

- (UIStatusBarStyle)_mix_extention_preferredStatusBarStyle
{
    return self.mix_hasExtention ? self.mixE.statusBarStyle : [self _mix_extention_preferredStatusBarStyle];
}

- (void)_mix_extention_viewWillAppear:(BOOL)animated
{
    [self _mix_extention_viewWillAppear:animated];
    if (self.mix_hasExtention) [self.mixE viewWillAppear:animated];
}

- (void)_mix_extention_viewWillDisappear:(BOOL)animated
{
    [self _mix_extention_viewWillDisappear:animated];
    if (self.mix_hasExtention) [self.mixE viewWillDisappear:animated];
}

- (void)_mix_extention_viewDidAppear:(BOOL)animated
{
    [self _mix_extention_viewDidAppear:animated];
    if (self.mix_hasExtention) [self.mixE viewDidAppear:animated];
}

- (void)_mix_extention_viewDidDisappear:(BOOL)animated
{
    [self _mix_extention_viewDidDisappear:animated];
    if (self.mix_hasExtention) [self.mixE viewDidDisappear:animated];
}

@end