#define W [UIScreen mainScreen].bounds.size.width
#define H [UIScreen mainScreen].bounds.size.height

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.minazuki.powerdock.plist"

#import "libcolorpicker.h"
#include <libpowercontroller/powercontroller.h>

static UIWindow *dockButton = nil;

@interface SBHomeScreenViewController : UIViewController
-(void)Yes_Or_No_Alert:(NSString *)msg B_Name:(NSString *)btn B_Name2:(NSString *)btn2;
-(NSString *)kill_process:(BOOL)flg;
@end

@interface SBDockView : UIView
@end

@interface SBWallpaperEffectView : UIView
@end