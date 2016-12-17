//
//  DetailViewController.m
//  LiChanghongKey
//
//  Created by lichanghong on 2016/11/15.
//  Copyright © 2016年 lichanghong. All rights reserved.
//

#import "DetailViewController.h"
#import "NSString+AES.h"
#import "KeyEntity+CoreDataProperties.h"
#import <MagicalRecord/MagicalRecord.h>
#import "UIView+Toast.h"



@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UITextField *mtitle;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *pwd;

@property (weak, nonatomic) IBOutlet UITextView *desT;
@property (nonatomic) int64_t mid;

@property (weak, nonatomic) IBOutlet UIImageView *applogo;


@end

@implementation DetailViewController
{
    BOOL isEdit;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isEdit = NO;
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5; //seconds  设置响应时间
    [_applogo addGestureRecognizer:lpgr]; //启用长按事件

    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    NSString *title    = _entity.title;
    NSString *name     = _entity.name;
//    NSString *pwd      = [_entity.pwd aes256_decrypt];
    NSString *des      = [_entity.des aes256_decrypt];
    _mid                = _entity.mid;
    
    if (_pageType==DetailVC_Edit && name==nil && des==nil) {
        _mtitle.text = @"";
        _name.text = @"";
        _pwd.text  = @"";
        _desT.text  = @"";
        self.title = @"编辑";
    }
    else
    {
        _mtitle.text = title;
        _name.text = name;
        _pwd.text  = @"******";
        _desT.text  = des;
        self.title = @"详情";
    }
    self.pageType = _pageType;
    // Do any additional setup after loading the view.
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)longpress
{
    KeyEntity *entity = [KeyEntity MR_findFirstByAttribute:@"mid" withValue:@(_mid)];
    if([entity MR_deleteEntity])
    {
        [self.view makeToast:@"成功删除"];
        [self.navigationController popViewControllerAnimated:YES];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    else
    {
        [self.view makeToast:@"删除失败"];
    }
}
- (void)setupRightBarButton:(BOOL)isDone
{
    if (isDone) {
        _editButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleAction:)];
    }
    else
    {
        _editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(handleAction:)];
    }
    self.navigationItem.rightBarButtonItem = _editButton;
}
- (void)handleEdit
{
    self.title = @"编辑";
    self.pageType = DetailVC_Edit;
    [self setupRightBarButton:YES];
    isEdit = YES;
    
}
- (IBAction)handleAction:(id)sender {
    if (sender == _editButton) {
        if (self.pageType==DetailVC_Edit) {
            [self handleDone];
        }
        else
        {
            [self handleEdit];
        }
    }
}

- (void)handleDone
{
    NSString *title     = [_mtitle.text trim];
    NSString *name     = [_name.text trim];
    NSString *pwd      = [_pwd.text trim];
    NSString *des      = [_desT.text trim];
    if (name.length<3 || pwd.length<5 ) {
        [self.view makeToast:@"用户名或密码过于简单"];
        [self.view endEditing:YES];
        return;
    }
    pwd = [pwd aes256_encrypt];
    des = [des aes256_encrypt];
    //查看详情点击编辑不应该插入一条，而是改变一条
  
        // MagicalRecord保存的方法，不是主线程
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            // 首先，通过name查询，得到entity
            // 如果entity不存在，则创建
            // 赋值保存，注意这里的
            KeyEntity *entity = [KeyEntity MR_findFirstByAttribute:@"mid" withValue:@(_mid) inContext:localContext];
            if (!entity) {
                // 创建letter
                entity = [KeyEntity MR_createEntityInContext:localContext];
                entity.mid = [KeyEntity MR_findAll].count+100;
                entity.title = title;
                entity.name = name;
                entity.pwd  = pwd;
                entity.des  = des;
            }
            else
            {
                if([entity MR_deleteEntity])
                {
                    NSLog(@"suss");
                }
                entity = [KeyEntity MR_createEntityInContext:localContext];
                entity.mid = _mid;
                entity.title = title;
                entity.name = name;
                entity.pwd  = pwd;
                entity.des  = des;
                //[self.view makeToast:@"已经存在"];
            }
        } completion:^(BOOL contextDidSave, NSError *error) {
            NSLog(@"=-===%@  %@", (contextDidSave ? @"saveSuccessed" : @"saveFailure"),error);
            [self.view endEditing:YES];
            if (contextDidSave) {
                [self.view makeToast:@"保存成功"];
                self.pageType=DetailVC_Detail;
                [self setupRightBarButton:NO];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
}

- (void)setPageType:(DetailVC_type)pageType
{
    _pageType = pageType;
    if (pageType == DetailVC_Edit) {
        _mtitle.placeholder = @"edit title";
        _name.placeholder = @"edit name";
        _pwd.placeholder  = @"edit password";
        _mtitle.enabled = YES;
        _name.enabled = YES;
        _pwd.enabled  = YES;
        _desT.editable = YES;
        [self setupRightBarButton:YES];
    }
    else if(pageType == DetailVC_Detail)
    {
        _mtitle.placeholder = @"title";
        _name.placeholder = @"name";
        _pwd.placeholder  = @"password";
        _mtitle.enabled = NO;
        _name.enabled = NO;
        _pwd.enabled  = NO;
        _desT.editable = NO;
        [self setupRightBarButton:NO];

    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
