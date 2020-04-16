//
//  Tweak.xm
//  PowerDock
//
//  Created by Minazuki.
//

#import "Tweak.h"

static BOOL enabled;
static BOOL hideDockBlur;
static float cornerRadius;
static float dockHeight;
static int powerOption = 1;

static void loadPrefs()
{

     NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];

     enabled = [[prefs objectForKey:@"enabled"] boolValue];
     hideDockBlur = [[prefs objectForKey:@"hideDockBlur"] boolValue];
     cornerRadius = [[prefs objectForKey:@"cornerRadius"] floatValue];
     dockHeight = [[prefs objectForKey:@"dockHeight"] floatValue];
     powerOption = [[prefs objectForKey:@"powerOption"] intValue];

}

void updateSettings(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    loadPrefs();
}

%hook SBHomeScreenViewController
- (void)viewDidLoad
{
        if (enabled) {
            %orig;

            // Dockのボタン
            dockButton = [[UIWindow alloc] initWithFrame:CGRectMake(W/2-125, H/1.12, 250, 60)];
            dockButton.hidden = NO;
            dockButton.layer.masksToBounds = YES;
            dockButton.layer.cornerRadius = cornerRadius;

            // Dockのブラー
            UIBlurEffect *dockBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurView = [[UIVisualEffectView alloc]initWithEffect:dockBlur];
            blurView.frame = dockButton.bounds;
            [dockButton addSubview:blurView];

            // Respringボタン
            UIButton *respButton = [UIButton buttonWithType:UIButtonTypeCustom];
            respButton.frame = CGRectMake(56, 10, 135, 35);
            respButton.hidden = NO;
            [respButton setTitle:@"PowerDock" forState:UIControlStateNormal];
            [respButton addTarget:self action:@selector(powerDock)  forControlEvents:UIControlEventTouchUpInside];
            respButton.tintColor = [UIColor whiteColor];
            [respButton.titleLabel setFont:[UIFont systemFontOfSize:24]];
            respButton.alpha = 0.7;
            [dockButton addSubview:respButton];

	} else {
		return %orig;
	} 
}

%new
- (void)powerDock
{
    UIViewController *view = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (view.presentedViewController != nil && !view.presentedViewController.isBeingDismissed) {
                view = view.presentedViewController;
        }

    UIAlertController *alertController = 
    [UIAlertController alertControllerWithTitle:@"PowerDock"
            message:@"Choose a power option." 
            preferredStyle:UIAlertControllerStyleAlert];

    // Respring
    [alertController addAction:[UIAlertAction actionWithTitle:@"Respring" 
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {

                notify_post("com.libpowercontroller.respring");
    }]];

    // Reboot
    [alertController addAction:[UIAlertAction actionWithTitle:@"Reboot"
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {

                notify_post("com.libpowercontroller.reboot");
    }]];

    // Safe Mode
    [alertController addAction:[UIAlertAction actionWithTitle:@"Safe Mode"
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {

                notify_post("com.libpowercontroller.safemode");
    }]];

    // Power down
    [alertController addAction:[UIAlertAction actionWithTitle:@"Power down"
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {

                notify_post("com.libpowercontroller.powerdown");
    }]];

    // Cancel
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {

                // Camcel
    }]];

    [view presentViewController:alertController animated:YES completion:nil];

}

%end

// Dockの高さ
%hook SBDockView

// iOS13.3
- (CGFloat)dockHeight
{
        if (enabled) {
            return %orig *dockHeight;
	} else {
		return %orig;
	} 
}

// iOS12~
+(double)defaultHeight
{
        if (enabled) {
            return %orig *dockHeight;
	} else {
		return %orig;
	} 
}
%end

// Dockのブラー
%hook SBDockView
-(void)layoutSubviews
{
        if (enabled && hideDockBlur) {
            %orig;
            MSHookIvar<SBWallpaperEffectView *>(self,"_backgroundView").hidden = YES;
	} else {
		return %orig;
	} 
}
%end

%ctor 
{

CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
        NULL, &updateSettings, 
        CFSTR("com.minazuki.powerdock/reload"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    @autoreleasepool {
        loadPrefs();
        %init;
    }
}