//
//  main.m
//  Salsa20-objc-sample
//
//  Created by Theodore Felix Leo on 1/6/15.
//  Copyright (c) 2015 Jyllandsgatan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Salsa20.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Byte key[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
        Byte nonce[] = { 0, 1, 2, 3, 4, 5, 6, 7 };
        Salsa20 *s = [[Salsa20 alloc] initWithKey:key nonce:nonce rounds:20];
        
        NSString *message = @"Secret salsa picante recipe";
        NSLog(@"Plain Message: %@", message);
        
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSInteger len = [messageData length]/sizeof(Byte);
        Byte messageByte[len];
        [messageData getBytes:messageByte length:len];
        Byte encrypted[len];
        Byte decrypted[len];
        
        // Encryption
        [s cryptInput:messageByte inOffset:0 output:encrypted outOffset:0 length:len];
        NSString *encryptedMessage = [[NSString alloc] initWithData:[NSData dataWithBytes:encrypted length:len] encoding:NSUTF8StringEncoding];
        NSLog(@"Encrypted Message: %@", encryptedMessage);
        
        // Reset position
        [s setPosition:0];
        
        // Decryption
        [s cryptInput:encrypted inOffset:0 output:decrypted outOffset:0 length:len];
        NSString *decryptedMessage = [[NSString alloc] initWithData:[NSData dataWithBytes:decrypted length:len] encoding:NSUTF8StringEncoding];
        NSLog(@"Decrypted Message: %@", decryptedMessage);
    }
    return 0;
}
