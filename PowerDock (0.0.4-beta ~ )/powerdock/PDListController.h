#import <Preferences/PSListController.h>
#include <libpowercontroller/powercontroller.h>

@interface PDListController : PSListController
    @property (nonatomic, retain) UIBarButtonItem *respringButton;
     - (void)respring:(id)sender;
@end
