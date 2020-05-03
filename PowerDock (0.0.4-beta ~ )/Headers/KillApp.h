//
//  KillProcess.h(SsS136)
//  PowerDock
//

@interface SBMediaController : NSObject

- (BOOL)isPlaying;
- (SBApplication*)nowPlayingApplication;

@end

@interface SBAppLayout : NSObject

@property(nonatomic, copy) NSDictionary *rolesToLayoutItemsMap;

@end

@interface SBFluidSwitcherItemContainerHeaderItem : NSObject

@property (nonatomic,copy) NSString *titleText;

@end

@interface SBFluidSwitcherItemContainer

-(void)setKillable:(BOOL)arg1;
- (BOOL)isKillable;
-(SBFluidSwitcherItemContainerHeaderItem*)headerItems;
- (void)layoutSubviews;

@end

@interface SBMainSwitcherViewController : UIViewController

+ (id)sharedInstance;
- (id)recentAppLayouts;
- (void)_deleteAppLayout:(id)arg1 forReason:(long long)arg2;

@end

@interface SBFluidSwitcherIconImageContainerView : UIView
@end