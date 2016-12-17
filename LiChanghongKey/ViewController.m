//
//  ViewController.m
//  LiChanghongKey
//
//  Created by lichanghong on 2016/11/14.
//  Copyright © 2016年 lichanghong. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "KeyEntity+CoreDataProperties.h"
#import <MagicalRecord/MagicalRecord.h>
#import "NSString+AES.h"
#import "UIView+Toast.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic,strong)NSMutableArray *entities;
@property (nonatomic,strong)UIView *emptyView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"LiChanghong"];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds  设置响应时间
    [_tableView addGestureRecognizer:lpgr]; //启用长按事件

    _entities = [[KeyEntity MR_findAllSortedBy:@"name" ascending:YES] mutableCopy];
    if (_entities) {
        if (_entities.count==0) {
            [self.searchBar setHidden:YES];
            [self.tableView addSubview: self.emptyView];
        }
        else
        for (int i=0; i<_entities.count; i++) {
            KeyEntity *entity = [_entities objectAtIndex:i];
            int64_t   mid     = entity.mid;
            NSString *name     = entity.name;
            NSString *pwd      = [entity.pwd aes256_decrypt];
            NSString *des      = [entity.des aes256_decrypt];
            NSString *title    = entity.title;
 
            NSLog(@"mid=%lld",mid);
            NSLog(@"username=%@",name);
            NSLog(@"pwd=%@",pwd);
            NSLog(@"des=%@",des);
            NSLog(@"title=%@",title);
        }
    }
   
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)resetEntities
{
    self.searchBar.text = @"";
    _entities = [[KeyEntity MR_findAllSortedBy:@"name" ascending:YES] mutableCopy];
    [self.tableView reloadData];
}

- (void)contains:(NSString *)str
{
    if (str.length<=0) {
        _entities = [[KeyEntity MR_findAllSortedBy:@"name" ascending:YES] mutableCopy];
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }
    else
    {
        NSMutableArray *marr = [NSMutableArray array];
        NSArray *arr2 = [KeyEntity MR_findAll];
        for (KeyEntity *a in arr2) {
            if (![marr containsObject:a]) {
                if ( [a.title containsString:str]) {
                    [marr addObject:a];
                }
                else if ([a.name containsString:str]) {
                    [marr addObject:a];
                }
            }
        }
        if (marr.count>0) {
            _entities =marr;
        }
    }
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_searchBar.text.length>0) {
        [self contains:_searchBar.text];
    }
    else
    {
        _entities = [[KeyEntity MR_findAllSortedBy:@"name" ascending:YES] mutableCopy];
        if (_entities) {
            if (_entities.count==0) {
                [self.searchBar setHidden:YES];
                [self.view addSubview: self.emptyView];
                [self.view bringSubviewToFront:self.emptyView];
            }
            else
            {
                if (_emptyView) {
                    [_emptyView removeFromSuperview];
                    _emptyView = nil;
                }
            }
        }
        
        [self.tableView reloadData];
    }
}

- (UIView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[UIView alloc]initWithFrame:KScreenRect];
        _emptyView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc]initWithFrame:_emptyView.frame];
        label.text = @"暂无内容";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        [_emptyView addSubview:label];
    }
    return _emptyView;
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    CGPoint p = [sender locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
    if (sender.state == UIGestureRecognizerStateBegan) {
        KeyEntity *entity = [_entities objectAtIndex:indexPath.row];
        NSString *pwd      = [entity.pwd aes256_decrypt];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = pwd;
        [self.view endEditing:YES];
        [self.view makeToast:@"密码已复制"];
    }
}

- (IBAction)handleAction:(id)sender {
    if (sender == _addBtn) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
            UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
            temporaryBarButtonItem.title = @"";
            self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
            detail.pageType = DetailVC_Edit;
            [self.navigationController showViewController:detail sender:nil];

        });
    }
    else if(sender == _settingBtn)
    {
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;

}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self contains:searchBar.text];
    [self.view makeToast:@"无搜索结果"];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self resetEntities];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self contains:searchText];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_entities) {
        return _entities.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"fjasklfjaksldfjaklsdfjlsda";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        UIColor *textColor = [UIColor colorWithRed:75/255.0 green:75/255.0 blue:75/255.0 alpha:1];
        cell.textLabel.textColor = textColor;
        cell.detailTextLabel.textColor = textColor;
    }
    KeyEntity *entity = [_entities objectAtIndex:indexPath.row];
    NSString *title     = entity.title;
//    NSString *pwd      = [entity.pwd aes256_decrypt];
    NSString *des      = @"******";//[entity.des aes256_decrypt];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = des;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
/*
    if (self.searchBar.showsCancelButton) {
        [self.view endEditing:YES];
        [self.searchBar setShowsCancelButton:NO];
        [self resetEntities];
        return;
    }
 */
    DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detail.entity = [_entities objectAtIndex:indexPath.row];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [self.navigationController showViewController:detail sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
