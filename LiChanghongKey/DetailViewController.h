//
//  DetailViewController.h
//  LiChanghongKey
//
//  Created by lichanghong on 2016/11/15.
//  Copyright © 2016年 lichanghong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KeyEntity;
typedef enum : NSUInteger {
    DetailVC_Detail,
    DetailVC_Edit
} DetailVC_type;

@interface DetailViewController : UIViewController
@property (nonatomic,strong)KeyEntity *entity;
@property (nonatomic,assign)DetailVC_type pageType;

@end
