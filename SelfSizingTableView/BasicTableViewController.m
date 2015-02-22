//
//  BasicTableViewController.m
//  SelfSizingTableView
//

#import "BasicTableViewController.h"

#define kDefaultCellHeight 44

#define kCellLayoutMarginLeft   15
#define kCellLayoutMarginRight  15
#define kCellLayoutMarginHeight 21

#define kAccessoryDisclosureWidth       33
#define kAccessoryDetailDisclosureWidth 67
#define kAccessoryCheckmarkWidth        39
#define kAccessoryDetailWidth           47

@implementation BasicTableViewController

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
        CGFloat leftMarginWidth, rightMarginWidth;
        switch (indexPath.row % 5) {
            case 0:
                leftMarginWidth = kCellLayoutMarginLeft;
                rightMarginWidth = kCellLayoutMarginRight;
                break;
            case 1:
                leftMarginWidth = kCellLayoutMarginLeft;
                rightMarginWidth = kAccessoryDisclosureWidth;
                break;
            case 2:
                leftMarginWidth = kCellLayoutMarginLeft;
                rightMarginWidth = kAccessoryDetailDisclosureWidth;
                break;
            case 3:
                leftMarginWidth = kCellLayoutMarginLeft;
                rightMarginWidth = kAccessoryCheckmarkWidth;
                break;
            case 4:
                leftMarginWidth = kCellLayoutMarginLeft;
                rightMarginWidth = kAccessoryDetailWidth;
                break;
            default:
                NSAssert1(NO, @"*** %s: section index out of bounds", __PRETTY_FUNCTION__);
                leftMarginWidth = 0;
                rightMarginWidth = 0;
                break;
        }
        CGRect textRect = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(tableView.frame) - leftMarginWidth - rightMarginWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil];
        CGFloat height = CGRectGetHeight(textRect) + kCellLayoutMarginHeight;
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
