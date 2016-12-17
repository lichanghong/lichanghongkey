//
//  KeyEntity+CoreDataProperties.h
//  LiChanghongKey
//
//  Created by lichanghong on 12/17/16.
//  Copyright © 2016 lichanghong. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "KeyEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface KeyEntity (CoreDataProperties)

+ (NSFetchRequest<KeyEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *des;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *pwd;
@property (nullable, nonatomic, copy) NSString *title;
@property (nonatomic) int64_t mid;

@end

NS_ASSUME_NONNULL_END
