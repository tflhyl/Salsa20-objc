//
//  Salsa20.h
//  Salsa20-objc
//
//  Created by Theodore Felix Leo on 8/5/15.
//  Copyright (c) 2015 Jyllandsgatan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Salsa20 : NSObject

- (instancetype)initWithKey:(Byte[])key nonce:(Byte[])nonce rounds:(NSInteger)rounds;

- (void)cryptInput:(Byte[])input inOffset:(NSInteger)inOffset output:(Byte[])output outOffset:(NSInteger)outOffset length:(NSInteger)length;

- (void)setPosition:(long)position;

@end
