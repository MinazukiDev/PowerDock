#include "PDListController.h"

@implementation PDListController
@synthesize respringButton;

- (instancetype)init {
    self = [super init];

    if (self) {
        self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" 
                                    style:UIBarButtonItemStylePlain
                                    target:self 
                                    action:@selector(respring:)];
        self.navigationItem.rightBarButtonItem = self.respringButton;

    }

    return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UISwitch appearance] setOnTintColor:[UIColor blueColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UISwitch appearance] setOnTintColor:nil];
}

- (void)myInfo {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Minazuki's Info" 
        message:@"Twitter\n Discord\n Donate" 
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction 
        actionWithTitle:@"Twitter"
        style:UIAlertActionStyleDefault 
        handler:^(UIAlertAction *action) {
            	UIApplication *app = [UIApplication sharedApplication];
	if ([app canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=Minazuki_dev"]]) {
		[app openURL:[NSURL URLWithString:@"twitter://user?screen_name=Minazuki_dev"]];
	} else if ([app canOpenURL:[NSURL URLWithString:@"tweetbot:///user_profile/Minazuki_dev"]]) {
		[app openURL:[NSURL URLWithString:@"tweetbot:///user_profile/Minazuki_dev"]];		
	} else {
		[app openURL:[NSURL URLWithString:@"https://mobile.twitter.com/Minazuki_dev"]];
        }
                }]];

    [alert addAction:[UIAlertAction 
        actionWithTitle:@"Discord"
        style:UIAlertActionStyleDefault 
        handler:^(UIAlertAction *action) {
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://discord.gg/dEYpUwv"]];

                }]];

    [alert addAction:[UIAlertAction 
        actionWithTitle:@"Donate"
        style:UIAlertActionStyleDefault 
        handler:^(UIAlertAction *action) {
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://donorbox.org/donate-for-minazuki"]];

                }]];

    [alert addAction:[UIAlertAction 
        actionWithTitle:@"Cancel"
        style:UIAlertActionStyleCancel 
        handler:^(UIAlertAction *action) {
            // Cancel
                }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)respring:(id)sender {

    UIViewController *view = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (view.presentedViewController != nil && !view.presentedViewController.isBeingDismissed) {
                view = view.presentedViewController;
        }

    UIAlertController *alertController = 
    [UIAlertController alertControllerWithTitle:@"Confirmation"
            message:@"Do you want to respring?" 
            preferredStyle:UIAlertControllerStyleAlert];

    // Respring
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" 
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {

                notify_post("com.libpowercontroller.respring");
    }]];

    // Cancel
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" 
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {

                // Cancel
    }]];

    [view presentViewController:alertController animated:YES completion:nil];

}

- (void)source {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/MinazukiDev/PowerDock"]];
}

@end
