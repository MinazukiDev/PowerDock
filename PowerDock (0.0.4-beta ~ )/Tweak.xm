//
//  Tweak.xm
//  PowerDock
//
//  Created by Minazuki.
//  Special thanks SsS136 & Dcsyhi.
//

#import "Tweak.h"
#import "Headers/KillProcess.h"
#import "Headers/KillApp.h"
#import "NSTask.h"

static BOOL enabled;
static BOOL hideDockBlur;
static float cornerRadius;
static float dockHeight;
static float titleAlpha;
static int fontSize;
static int powerOption = 1;

NSString *P_Title;
NSString *RP_Act;

static void loadPrefs(){

     NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];

     enabled = [[prefs objectForKey:@"enabled"] boolValue];
     hideDockBlur = [[prefs objectForKey:@"hideDockBlur"] boolValue];
     cornerRadius = [[prefs objectForKey:@"cornerRadius"] floatValue];
     dockHeight = [[prefs objectForKey:@"dockHeight"] floatValue];
     titleAlpha = [[prefs objectForKey:@"titleAlpha"] floatValue];
     fontSize = [[prefs objectForKey:@"fontSize"] intValue];
     powerOption = [[prefs objectForKey:@"powerOption"] intValue];

}

void updateSettings(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo) {
    loadPrefs();
}

%hook SBHomeScreenViewController
- (void)viewDidLoad{

        %orig;
        if (enabled) {
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
            [respButton addTarget:self action:@selector(powerDock:)  forControlEvents:UIControlEventTouchUpInside];
            respButton.tintColor = [UIColor whiteColor];
            [respButton.titleLabel setFont:[UIFont systemFontOfSize:24]];
            respButton.alpha = 0.7;
            [dockButton addSubview:respButton];

            [self.view addSubview:dockButton];
        }

}
%new    //プロレスをキル用 (Dcsyhi)
-(NSString *)kill_process:(BOOL)flg{
    SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
    SBApplication *SB_A = [springBoard _accessibilityRunningApplications];
    NSString *rtnStr = @"";

    for(NSString *s in (NSArray *)SB_A){
        SBApplicationProcessState *aa = [(SBApplication *)s processState];
        NSString *Num_pid = [NSString stringWithFormat:@"%d",aa.pid];
        
        if(flg){
            rtnStr = [rtnStr stringByAppendingString:[NSString stringWithFormat:@"%@ : %@ \n",[(SBApplication *)s displayName],Num_pid]];
        }else{
            NSTask *task  = [[NSTask alloc] init];
            NSPipe *pipe  = [[NSPipe alloc] init];
            [task setLaunchPath: @"/bin/sh"];
            [task setArguments: [NSArray arrayWithObjects: @"-c",[NSString stringWithFormat:@"kill %@",Num_pid], nil]];//pidkill
            [task setStandardOutput: pipe];
            [task launch];
            [task release];
        }
    }
    return flg ? rtnStr : nil;
}
%new    //アラート確認がいる箇所用関数 (Dcsyhi)
-(void)Yes_Or_No_Alert:(NSString *)msg B_Name:(NSString *)btn B_Name2:(NSString *)btn2{

    UIAlertView *alert2 = [[UIAlertView alloc] init];
    alert2.delegate = self;
    alert2.title = @"PowerDock";
    alert2.message = msg;
    [alert2 addButtonWithTitle:btn];
    [alert2 addButtonWithTitle:btn2];
    [alert2 show];
}
%new  //アラートボタンが押された時 (Dcsyhi)
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];

    if([buttonTitle isEqualToString:@"Respring"]) {
        notify_post("com.libpowercontroller.respring");
    }else if([buttonTitle isEqualToString:@"SafeMode"]) {
        notify_post("com.libpowercontroller.safemode");
   }else if([buttonTitle isEqualToString:@"Reboot"]){
        RP_Act = buttonTitle;
        [self Yes_Or_No_Alert:buttonTitle B_Name:@"Yes" B_Name2:@"No"];
   }else if([buttonTitle isEqualToString:@"UICache"]){
        notify_post("com.libpowercontroller.uicache");
   }else if([buttonTitle isEqualToString:@"Power down"]){
        RP_Act = buttonTitle;
        [self Yes_Or_No_Alert:buttonTitle B_Name:@"Yes" B_Name2:@"No"];
   }else if([buttonTitle isEqualToString:@"Kill All Apps"]){
        SBMainSwitcherViewController *mainSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
        NSArray *items = [mainSwitcher recentAppLayouts];
        
        SBMediaController *media = [%c(SBMediaController) sharedInstance];
        NSString *nowPlayingID = [[media nowPlayingApplication] bundleIdentifier];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for(SBAppLayout *item in items){
                if([media isPlaying] && [[[[item rolesToLayoutItemsMap] objectForKey: @1] bundleIdentifier] isEqualToString: nowPlayingID])
                    continue;
                [mainSwitcher _deleteAppLayout: item forReason: 1];
            }
        });
   }else if([buttonTitle isEqualToString:P_Title]){
        NSArray *applist = (NSArray*)[(SpringBoard *)[UIApplication sharedApplication] _accessibilityRunningApplications];

        NSString *P_Msg = [NSString stringWithFormat:@"If you want to Kill %@ Process?",[NSString stringWithFormat:@"%ld", applist.count]];
        if(applist.count > 0){
            [self Yes_Or_No_Alert:P_Msg B_Name:@"Kill" B_Name2:@"View Process"];
        }
   }else if([buttonTitle isEqualToString:@"Yes"]){
        NSString *act = [RP_Act stringByReplacingOccurrencesOfString:@" " withString:@""];
        act = [NSString stringWithFormat:@"com.libpowercontroller.%@",[act lowercaseString]];
                notify_post((char *) [act UTF8String]);
   }else if([buttonTitle isEqualToString:@"Kill"]){
       P_Title = [self kill_process:NO];
   }else if([buttonTitle isEqualToString:@"View Process"]){
       [self Yes_Or_No_Alert:[self kill_process:YES] B_Name:@"OK" B_Name2:@"Kill"];
   }else{// ok cansel no
       return;
   }
}
%new
-(void)powerDock:(UIButton*)btn{

    //(Dcsyhi)
    SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];

    NSArray *applist = (NSArray*)[springBoard _accessibilityRunningApplications];   //稼働中全プロセスを取得
    NSString *P_Cnt = [NSString stringWithFormat:@"%ld", applist.count];

    P_Title = [NSString stringWithFormat:@"Kill %@ Process",P_Cnt];

	NSArray *Actions = @[@"Respring",@"Reboot",@"SafeMode",@"Power down",@"UICache",@"Kill All Apps",P_Title];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    alert.title = @"PowerDock";
    alert.message = @"Choose a power option.";
    
    for(NSString *Act in Actions){
        [alert addButtonWithTitle:Act];
    }
    [alert addButtonWithTitle:@"Cancel"];
    alert.cancelButtonIndex = Actions.count;
    [alert show];
}
%end

// Dockの高さ
%hook SBDockView

// iOS13.3
- (CGFloat)dockHeight{
    if (enabled) {
        return %orig *dockHeight;
	} else {
		return %orig;
	} 
}

// iOS12~
+ (double)defaultHeight{
    if (enabled) {
        return %orig *dockHeight;
	} else {
		return %orig;
	} 
}
%end

// Dockのブラー
%hook SBDockView
- (void)setBackgroundAlpha:(double)arg1{
    if (enabled && hideDockBlur) {
        %orig;
        MSHookIvar<SBWallpaperEffectView *>(self,"_backgroundView").hidden = YES;
	} else {
		return %orig;
	} 
}
%end

%ctor {

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &updateSettings, CFSTR("com.minazuki.powerdock/reload"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    @autoreleasepool {
        loadPrefs();
        %init;
    }
}