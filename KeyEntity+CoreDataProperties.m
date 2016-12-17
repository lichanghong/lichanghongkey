//
//  KeyEntity+CoreDataProperties.m
//  LiChanghongKey
//
//  Created by lichanghong on 12/17/16.
//  Copyright © 2016 lichanghong. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "KeyEntity+CoreDataProperties.h"

@implementation KeyEntity (CoreDataProperties)

+ (NSFetchRequest<KeyEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"KeyEntity"];
}

@dynamic des;
@dynamic name;
@dynamic pwd;
@dynamic title;
@dynamic mid;

@end
