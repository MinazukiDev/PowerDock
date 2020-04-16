#import "MTableCell.h"

@implementation MTableCell

- (void)layoutSubviews {
	[super layoutSubviews];
	self.textLabel.textColor = [UIColor colorWithRed:41.0/255.0 green:98.0/255.0 blue:255.0/255.0 alpha:255.0/255.0];
}

@end
