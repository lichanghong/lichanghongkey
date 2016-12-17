//
//  NSString.h
//  LiChanghongKey
//
//  Created by lichanghong on 2016/11/21.
//  Copyright © 2016年 lichanghong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(AES)

-(NSString *) aes256_encrypt;
-(NSString *) aes256_decrypt;

- (NSString *)trim;

@end
