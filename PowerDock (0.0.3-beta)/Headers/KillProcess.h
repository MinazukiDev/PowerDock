//
//  KillProcess.xm (SsS136)
//  PowerDock
//
//  Created by Minazuki.
//  Special thanks SsS136.
//

#import "NSTask.h"
#import <spawn.h>
#import <Foundation/Foundation.h>
#include <stdlib.h>

NSString *proc;
NSString *proc2;
NSString *proc3;
NSRange range;
NSString *kill2;
NSString *kill3;
NSInteger abcc;
NSNumber *num1cc;
NSNumber *num2cc;
NSString *abccc;

@interface SBApplicationProcessState

@property(nonatomic, readonly) int pid;

@end

@interface SBApplicationController

-(NSArray *)runningApplications;

@end

SBApplicationController *runa;

@interface SBApplication : NSObject

@property(nonatomic, readonly) SBApplicationProcessState *processState;

- (void)setActivationSetting:(NSUInteger)fp8 flag:(BOOL)fp12;
- (void)setActivationSetting:(NSUInteger)fp8 value:(id)fp12;
- (void)setDeactivationSetting:(NSUInteger)fp8 flag:(BOOL)fp12;
- (id)bundleIdentifier;
- (NSString *)displayIdentifier;
- (BOOL)shouldLaunchPNGless;
- (BOOL)showsProgress;
- (BOOL)isRunning;

@end

@interface SBSyncController

-(void) _killApplicationsIfNecessary;

@end

SBSyncController *killa;

@interface SpringBoard : UIApplication

- (BOOL)isLocked;
- (NSArray *)_accessibilityRunningApplications;
- (SBApplication *)_accessibilityFrontMostApplication;

@end

SBApplication *sbApp;
int count;

@interface SBApplicationInfo

- (NSString*) displayName;

@end