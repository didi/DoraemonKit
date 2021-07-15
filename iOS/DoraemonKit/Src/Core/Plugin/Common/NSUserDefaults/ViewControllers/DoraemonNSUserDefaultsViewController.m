//
//  DoraemonNSUserDefaultsViewController.m
//  DoraemonKit
//
//  Created by 0xd-cc on 2019/11/26.
//

#import "DoraemonNSUserDefaultsViewController.h"
#import "DoraemonDefine.h"
#import "DoraemonNSUserDefaultsModel.h"
#import "DoraemonNSUserDefaultsEditViewController.h"

@interface DoraemonNSUserDefaultsViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray<DoraemonNSUserDefaultsModel *> *modelList;
@property (nonatomic, strong) NSMutableArray<DoraemonNSUserDefaultsModel *> *searchList;
@property (nonatomic, strong, readonly) NSMutableArray<DoraemonNSUserDefaultsModel *> *dataArray;

@property (nonatomic, assign) BOOL isSearch;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UITextField *searchTextField;

@property (nonatomic, strong) UIBarButtonItem *clearAllItem;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@end

@implementation DoraemonNSUserDefaultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isSearch = NO;
    
    [self buildSearchUI];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IPHONE_NAVIGATIONBAR_HEIGHT, self.view.doraemon_width, self.view.doraemon_height - IPHONE_NAVIGATIONBAR_HEIGHT) style:UITableViewStylePlain];
    if (@available(iOS 13.0, *)) {
        self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    // 该方式退出键盘（系统键盘）时会在底部卡顿一下
    //self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)buildSearchUI {
    
    CGFloat searchTextFieldWidth = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, searchTextFieldWidth, 30.0)];
    searchTextField.placeholder = @"Search Key";
    searchTextField.layer.cornerRadius = 15.0;
    if (@available(iOS 13.0, *)) {
        searchTextField.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        searchTextField.backgroundColor = [UIColor whiteColor];
    }
    searchTextField.delegate = self;
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchTextField.returnKeyType = UIReturnKeySearch;
    self.navigationItem.titleView = searchTextField;
    _searchTextField = searchTextField;
    
    searchTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 36.0)];
    searchTextField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 36.0)];
    
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    searchTextField.rightViewMode = UITextFieldViewModeUnlessEditing;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reload];
}

- (void)reload {
    NSDictionary<NSString *, id> *dic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    self.modelList = [NSMutableArray array];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        DoraemonNSUserDefaultsModel *model = [[DoraemonNSUserDefaultsModel alloc] init];
        model.key = key;
        model.value = obj;
        [self.modelList addObject:model];
    }];
    [self.modelList sortUsingComparator:^NSComparisonResult(DoraemonNSUserDefaultsModel * _Nonnull obj1, DoraemonNSUserDefaultsModel *  _Nonnull obj2) {
        return [obj1.key.lowercaseString compare:obj2.key.lowercaseString];
    }];
    
    if (self.isSearch) {
        
        [self searchWithKeyword:self.searchTextField.text];
        
        return;
    }
    
    [self.tableView reloadData];
}

- (void)clearUserDefaults {
    
    if ([self.searchTextField isFirstResponder]) {
        
        [self.searchTextField resignFirstResponder];
    }
    
    [DoraemonAlertUtil handleAlertActionWithVC:self text:@"clear all data?" okBlock:^{
        
        self.isSearch = NO;
        
        NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
        
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:bundleIdentifier];
        
        [self reload];
        
    } cancleBlock:^{
    
    }];
}

#pragma mark
#pragma mark - Private Method

- (void)setIsSearch:(BOOL)isSearch {
    _isSearch = isSearch;
    
    self.navigationItem.rightBarButtonItems = isSearch ? @[self.cancelItem] : @[self.clearAllItem];
}

- (void)cancelSearch {
    
    self.isSearch = NO;
    
    self.searchTextField.text = nil;
    
    if ([self.searchTextField isFirstResponder]) {
        
        [self.searchTextField resignFirstResponder];
    }
    
    [_searchList removeAllObjects];
    
    [self.tableView reloadData];
}

- (void)searchWithKeyword:(NSString *)keyword {
    
    NSString *checkKeyWord = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([checkKeyWord length] <= 0) { return; }
    
    checkKeyWord = [checkKeyWord lowercaseString];
    
    self.searchTextField.text = checkKeyWord;
    
    [_searchList removeAllObjects];
    
    for (DoraemonNSUserDefaultsModel *model in self.modelList) {
        
        if ([[model.key lowercaseString] containsString:checkKeyWord]) {
            
            [self.searchList addObject:model];
        }
    }
    
    self.isSearch = YES;
    
    [self.tableView reloadData];
}

#pragma mark
#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifer = @"DoraemonNSUserDefaultsViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
    }
    DoraemonNSUserDefaultsModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.key;
    cell.detailTextLabel.text = [model.value description];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DoraemonNSUserDefaultsModel *model = self.dataArray[indexPath.row];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:model.key];
        [self reload];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DoraemonNSUserDefaultsModel *model = self.dataArray[indexPath.row];
    DoraemonNSUserDefaultsEditViewController *vc = [[DoraemonNSUserDefaultsEditViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.searchTextField resignFirstResponder];
}

#pragma mark
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (![textField hasText]) {
        
        [self cancelSearch];
        
        return YES;
    }
    
    [textField resignFirstResponder];
    
    [self searchWithKeyword:textField.text];
    
    return YES;
}

#pragma mark
#pragma mark - Property

- (NSMutableArray<DoraemonNSUserDefaultsModel *> *)dataArray {
    
    return self.isSearch ? self.searchList : self.modelList;
}

- (NSMutableArray<DoraemonNSUserDefaultsModel *> *)searchList {
    if (!_searchList) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}

- (UIBarButtonItem *)clearAllItem {
    if (!_clearAllItem) {
        _clearAllItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearUserDefaults)];
    }
    return _clearAllItem;
}

- (UIBarButtonItem *)cancelItem {
    if (!_cancelItem) {
        _cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSearch)];
    }
    return _cancelItem;
}
@end
