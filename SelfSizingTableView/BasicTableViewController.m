//
//  BasicTableViewController.m
//  SelfSizingTableView
//

#import "BasicTableViewController.h"

#define kDefaultCellHeight 44
#define kLabelMarginHeight 21

#define kLabelMarginWidthWithAccessoryNone             (15 + 15)
#define kLabelMarginWidthWithAccessoryDisclosure       (15 + 35)
#define kLabelMarginWidthWithAccessoryDetailDisclosure (15 + 67)
#define kLabelMarginWidthWithAccessoryCheckmark        (15 + 39)
#define kLabelMarginWidthWithAccessoryDetail           (15 + 47)

@implementation BasicTableViewController

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
    cell.textLabel.text = [self textLabelTextAtIndexPath:indexPath];
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        // iOS 8.0 or later
        cell.textLabel.numberOfLines = 0;
    } else {
        // iOS 7.x or earlier
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    cell.accessoryType = (indexPath.row % 5);
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
        NSString *text = [self textLabelTextAtIndexPath:indexPath];
        CGFloat labelMarginWidth;
        switch (indexPath.row % 5) {
            case 0:
                labelMarginWidth = kLabelMarginWidthWithAccessoryNone;
                break;
            case 1:
                labelMarginWidth = kLabelMarginWidthWithAccessoryDisclosure;
                break;
            case 2:
                labelMarginWidth = kLabelMarginWidthWithAccessoryDetailDisclosure;
                break;
            case 3:
                labelMarginWidth = kLabelMarginWidthWithAccessoryCheckmark;
                break;
            case 4:
                labelMarginWidth = kLabelMarginWidthWithAccessoryDetail;
                break;
            default:
                NSAssert1(NO, @"*** %s: section index out of bounds", __PRETTY_FUNCTION__);
                labelMarginWidth = 0;
                break;
        }
        CGRect textRect = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(tableView.frame) - labelMarginWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil];
        CGFloat height = CGRectGetHeight(textRect) + kLabelMarginHeight;
        return MAX(ceil(height), kDefaultCellHeight);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Class extensions

- (NSString *)textLabelTextAtIndexPath:(NSIndexPath *)indexPath {
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
