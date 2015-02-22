//
//  CustomTableViewController.m
//  SelfSizingTableView
//

#import "CustomTableViewController.h"

#define kDefaultCellHeight 44
#define kCellSeparatorWidth 1

#define kCellLayoutMarginTop    8
#define kCellLayoutMarginLeft  15
#define kCellLayoutMarginBottom 8
#define kCellLayoutMarginRight 15

#define kAccessoryDisclosureWidth       33
#define kAccessoryDetailDisclosureWidth 67
#define kAccessoryCheckmarkWidth        39
#define kAccessoryDetailWidth           47

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleLabelLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleLabelBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleLabelRightConstraint;

@end

@implementation CustomTableViewCell

- (void)updateConstraints {
    [super updateConstraints];
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        // iOS 8.0 or later
        UIEdgeInsets layoutMargins = self.layoutMargins;
        self.titleLabelTopConstraint.constant = layoutMargins.top;
        UIImage *image = self.imageView.image;
        if (!image) {
            self.titleLabelLeftConstraint.constant = layoutMargins.left;
        } else {
            self.titleLabelLeftConstraint.constant = layoutMargins.left + image.size.width + kCellLayoutMarginLeft;
        }
        self.titleLabelBottomConstraint.constant = layoutMargins.bottom;
        if ((self.accessoryType == UITableViewCellAccessoryNone) &&
            !self.accessoryView) {
            self.titleLabelRightConstraint.constant = layoutMargins.right;
        } else {
            self.titleLabelRightConstraint.constant = 0;
        }
    } else {
        // iOS 7.x or earlier
        self.titleLabelTopConstraint.constant = kCellLayoutMarginTop;
        UIImage *image = self.imageView.image;
        if (!image) {
            self.titleLabelLeftConstraint.constant = kCellLayoutMarginLeft;
        } else {
            self.titleLabelLeftConstraint.constant = kCellLayoutMarginLeft + image.size.width + kCellLayoutMarginLeft;
        }
        self.titleLabelBottomConstraint.constant = kCellLayoutMarginBottom;
        if ((self.accessoryType == UITableViewCellAccessoryNone) &&
            !self.accessoryView) {
            self.titleLabelRightConstraint.constant = kCellLayoutMarginRight;
        } else {
            self.titleLabelRightConstraint.constant = 0;
        }
    }
}

@end

@implementation CustomTableViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        // iOS 8.0 or later
        self.tableView.estimatedRowHeight = 44;
    } else {
        // iOS 7.x or earlier
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        // iOS 8.0 or later
        // XXX: Auto Layout doesn't work correctly without cell's superview
        if (!cell.superview) {
            [NSObject cancelPreviousPerformRequestsWithTarget:tableView selector:@selector(reloadData) object:nil];
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
        }
    }
    if (indexPath.row < 5) {
        cell.imageView.image = [UIImage imageNamed:@"AirDrop-Settings"];
    } else {
        cell.imageView.image = nil;
    }
    cell.titleLabel.text = [self titleLabelTextAtIndexPath:indexPath];
    cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.accessoryType = (indexPath.row % 5);
    [cell setNeedsUpdateConstraints];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        // iOS 8.0 or later
        return UITableViewAutomaticDimension;
    } else {
        // iOS 7.x or earlier
        NSString *text = [self titleLabelTextAtIndexPath:indexPath];
        CGFloat leftMarginWidth, rightMarginWidth;
        if (indexPath.row < 5) {
            UIImage *image = [UIImage imageNamed:@"AirDrop-Settings"];
            leftMarginWidth = kCellLayoutMarginLeft + image.size.width + kCellLayoutMarginLeft;
        } else {
            leftMarginWidth = kCellLayoutMarginLeft;
        }
        switch (indexPath.row % 5) {
            case 0:
                rightMarginWidth = kCellLayoutMarginRight;
                break;
            case 1:
                rightMarginWidth = kAccessoryDisclosureWidth;
                break;
            case 2:
                rightMarginWidth = kAccessoryDetailDisclosureWidth;
                break;
            case 3:
                rightMarginWidth = kAccessoryCheckmarkWidth;
                break;
            case 4:
                rightMarginWidth = kAccessoryDetailWidth;
                break;
            default:
                NSAssert1(NO, @"*** %s: section index out of bounds", __PRETTY_FUNCTION__);
                rightMarginWidth = 0;
                break;
        }
        CGRect textRect = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(tableView.frame) - leftMarginWidth - rightMarginWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil];
        CGFloat height = kCellLayoutMarginTop + CGRectGetHeight(textRect) + kCellLayoutMarginBottom + kCellSeparatorWidth;
        return MAX(ceil(height), kDefaultCellHeight);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Class extensions

- (NSString *)titleLabelTextAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = @"The quick brown fox jumps over the lazy dog.";
    NSMutableArray *texts = [NSMutableArray array];
    for (NSUInteger i = 0; i < indexPath.row; i++) {
        [texts addObject:text];
    }
    return [texts componentsJoinedByString:@" "];
}

- (void)contentSizeCategoryDidChange:(NSNotification *)notification {
    UITableView *tableView = self.tableView;
    [tableView invalidateIntrinsicContentSize];
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        // iOS 8 or later
        [tableView setNeedsLayout];
    } else {
        // iOS 7.x or earlier
        [tableView reloadData];
    }
}

@end
