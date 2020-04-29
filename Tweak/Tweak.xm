//
//  Tweak.xm
//  PowerDock
//
//  Created by Minazuki.
//  Special thanks SsS136.
//

#import "Tweak.h"
#import "Headers/KillProcess.h"
#import "Headers/KillApp.h"

static BOOL enabled;
static BOOL hideDockBlur;
//static BOOL buttonBlur;
static float cornerRadius;
static float dockHeight;
static float titleAlpha;
static int fontSize;
static int powerOption = 1;


static void loadPrefs()
{

     NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];

     enabled = [[prefs objectForKey:@"enabled"] boolValue];
     hideDockBlur = [[prefs objectForKey:@"hideDockBlur"] boolValue];
     //buttonBlur = [[prefs objectForKey:@"buttonBlur"] boolValue];
     cornerRadius = [[prefs objectForKey:@"cornerRadius"] floatValue];
     dockHeight = [[prefs objectForKey:@"dockHeight"] floatValue];
     titleAlpha = [[prefs objectForKey:@"titleAlpha"] floatValue];
     fontSize = [[prefs objectForKey:@"fontSize"] intValue];
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

        UIAlertController *alertController = 
        [UIAlertController alertControllerWithTitle:@"PowerDock"
                message:@"Reboot" 
                preferredStyle:UIAlertControllerStyleAlert];

        // Yes
        [alertController addAction:[UIAlertAction actionWithTitle:@"Yes"
                style:UIAlertActionStyleDestructive
                handler:^(UIAlertAction *action) {

                    notify_post("com.libpowercontroller.reboot");
        }]];

        // No
        [alertController addAction:[UIAlertAction actionWithTitle:@"No"
                style:UIAlertActionStyleDefault 
                handler:^(UIAlertAction *action) {

        }]];

    [view presentViewController:alertController animated:YES completion:nil];

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

        UIAlertController *alertController = 
        [UIAlertController alertControllerWithTitle:@"PowerDock"
                message:@"Power down" 
                preferredStyle:UIAlertControllerStyleAlert];

        // Yes
        [alertController addAction:[UIAlertAction actionWithTitle:@"Yes"
                style:UIAlertActionStyleDestructive
                handler:^(UIAlertAction *action) {

                    notify_post("com.libpowercontroller.powerdown");
        }]];

        // No
        [alertController addAction:[UIAlertAction actionWithTitle:@"No"
                style:UIAlertActionStyleDefault 
                handler:^(UIAlertAction *action) {

        }]];

    [view presentViewController:alertController animated:YES completion:nil];

    }]];

    // UICache
    [alertController addAction:[UIAlertAction actionWithTitle:@"UICache (Beta)"
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {

                notify_post("com.libpowercontroller.uicache");
    }]];

    // Kill All Apps (SsS136)
    [alertController addAction:[UIAlertAction actionWithTitle:@"Kill All Apps"
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {

			SBMainSwitcherViewController *mainSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
			NSArray *items = [mainSwitcher recentAppLayouts];

			SBMediaController *media = [%c(SBMediaController) sharedInstance];
			NSString *nowPlayingID = [[media nowPlayingApplication] bundleIdentifier];

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), 
			^{
				for(SBAppLayout *item in items)
				{
					if([media isPlaying] && [[[[item rolesToLayoutItemsMap] objectForKey: @1] bundleIdentifier] isEqualToString: nowPlayingID])
						continue;
					
					[mainSwitcher _deleteAppLayout: item forReason: 1];
				}
			});

    }]];

    // Kill Process (SsS136)

    SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
    NSArray *applist = [springBoard _accessibilityRunningApplications];
    NSString *strrz = [applist componentsJoinedByString:@""];
    proc = @"Kill ";
    proc2 = @" Process";
    NSInteger con = applist.count;
    NSNumber *num1 = [NSNumber numberWithInteger:con];
    NSNumber *num2 = [[NSNumber alloc] initWithInteger:con];
    NSString *abc = [num2 stringValue];
    NSLog(@"%@",num1);
    NSString *proc3 = [NSString stringWithFormat:@"%@%@%@", proc,abc,proc2];
    NSString *abc2 = @"If you want to ";
    NSString *abc3 = @"?";
    NSString *proc4 = [NSString stringWithFormat:@"%@%@%@%@%@",abc2,proc,abc,proc2,abc3];

    [alertController addAction:[UIAlertAction actionWithTitle:proc3
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {
                UIAlertController *alertController = 
                [UIAlertController alertControllerWithTitle:@"PowerDock"
                    message:proc4
                    preferredStyle:UIAlertControllerStyleAlert];

                    // Kill Process
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Kill"
                        style:UIAlertActionStyleDestructive
                        handler:^(UIAlertAction *action) {
                            for(int k=1000;k<100000;k++) {//pidsearch
                                kill2 = @"kill ";
                                abcc = k;
                                num1cc = [NSNumber numberWithInteger:abcc];
                                num2cc = [[NSNumber alloc] initWithInteger:abcc];
                                abccc = [num2cc stringValue];
range = [strrz rangeOfString:abccc];
                                if(range.location != NSNotFound) {
                                    kill3 = [NSString stringWithFormat:@"%@%@",kill2,abccc];
                                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                                    NSTask *task  = [[NSTask alloc] init];
                                    NSPipe *pipe  = [[NSPipe alloc] init];
                                    [task setLaunchPath: @"/bin/sh"];
                                    [task setArguments: [NSArray arrayWithObjects: @"-c",kill3, nil]];//pidkill
                                    [task setStandardOutput: pipe];
                                    [task launch];
                                    NSFileHandle *handle = [pipe fileHandleForReading];
                                    NSData *data = [handle  readDataToEndOfFile];
                                    NSString *result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                    NSLog(@"%@",result);
                                    [task release];
                                    [pipe release];
                                    [pool release];
                                }
                          }
                    }]]; // End Kill Process

                    // View Process
                    [alertController addAction:[UIAlertAction actionWithTitle:@"View Process"
                       style:UIAlertActionStyleDefault 
                       handler:^(UIAlertAction *action) {

                            UIAlertController *alertController = 
                            [UIAlertController alertControllerWithTitle:@"Process List"
                            message:strrz 
                            preferredStyle:UIAlertControllerStyleAlert];

                            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" 
                                style:UIAlertActionStyleDefault 
                                handler:^(UIAlertAction *action) {

                            }]]; // End View Process

                            // View Process > Kill Process
                            [alertController addAction:[UIAlertAction actionWithTitle:@"Kill" 
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    for(int k=1000;k<100000;k++) {//pidsearch
                                        kill2 = @"kill ";
                                        abcc = k;
                                        num1cc = [NSNumber numberWithInteger:abcc];
                                        num2cc = [[NSNumber alloc] initWithInteger:abcc];
                                        abccc = [num2cc stringValue];
range = [strrz rangeOfString:abccc];
                                        if(range.location != NSNotFound) {
                                            kill3 = [NSString stringWithFormat:@"%@%@",kill2,abccc];
                                            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                                            NSTask *task  = [[NSTask alloc] init];
                                            NSPipe *pipe  = [[NSPipe alloc] init];
                                            [task setLaunchPath: @"/bin/sh"];
                                            [task setArguments: [NSArray arrayWithObjects: @"-c",kill3, nil]];//pidkill
                                            [task setStandardOutput: pipe];
                                            [task launch];
                                            NSFileHandle *handle = [pipe fileHandleForReading];
                                            NSData *data = [handle  readDataToEndOfFile];
                                            NSString *result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                            NSLog(@"%@",result);
                                            [task release];
                                            [pipe release];
                                            [pool release];
                                         }
                                     }
                            }]]; // End View Process > Kill Process
                            [view presentViewController:alertController animated:YES completion:nil];
                    }]]; // End Kill or View Process
                    [view presentViewController:alertController animated:YES completion:nil];
    }]]; // End

    // Cancel
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
            style:UIAlertActionStyleCancel 
            handler:^(UIAlertAction *action) {

                // Cancel
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
+ (double)defaultHeight
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
- (void)setBackgroundAlpha:(double)arg1
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