//
//  Salsa20.m
//  Salsa20-objc
//
//  Created by Theodore Felix Leo on 8/5/15.
//  Copyright (c) 2015 Jyllandsgatan. All rights reserved.
//

#import "Salsa20.h"

static const UInt32 tau[4] = {
    0x61707865, 0x3120646e, 0x79622d36, 0x6b206574,
};

UInt32 readInt32LE(Byte data[], NSInteger offset) {
    return (data[offset + 3] << 24) |
        ((data[offset + 2] & 0xff) << 16) |
        ((data[offset + 1] & 0xff) << 8) |
        (data[offset] & 0xff);
}

@interface Salsa20 () {
    UInt32 _input[16];
    Byte _output[64];
    UInt32 _tmp[16];
    
    NSInteger _doubleRounds;
    
    long _posBlock;
    NSInteger _posRemainder;
}

@end

@implementation Salsa20

- (instancetype)initWithKey:(Byte[])key nonce:(Byte[])nonce rounds:(NSInteger)rounds {
    self = [super init];
    if (self) {
        _doubleRounds = rounds >> 1;
        [self setupWithKey:key nonce:nonce];
    }
    return self;
}

- (void)setupWithKey:(Byte[])key nonce:(Byte[])nonce {
    _input[1] = readInt32LE(key, 0);
    _input[2] = readInt32LE(key, 4);
    _input[3] = readInt32LE(key, 8);
    _input[4] = readInt32LE(key, 12);
    
    _input[11] = readInt32LE(key, 0);
    _input[12] = readInt32LE(key, 4);
    _input[13] = readInt32LE(key, 8);
    _input[14] = readInt32LE(key, 12);
    
    _input[0] = tau[0];
    _input[5] = tau[1];
    _input[10] = tau[2];
    _input[15] = tau[3];
    
    _input[6] = readInt32LE(nonce, 0);
    _input[7] = readInt32LE(nonce, 4);
    _input[8] = 0;
    _input[9] = 0;
    
    [self calculateEncryptionOutputFromInput];
}

- (void)calculateEncryptionOutputFromInput {
    UInt32 x[16];
    memcpy(x, _tmp, sizeof(_tmp));
    
    UInt32 s;
    for (NSInteger i = _doubleRounds; i > 0; i--) {
        s = x[ 0] + x[12]; x[ 4] ^= (s <<  7) | (s >> (32 -  7));
        s = x[ 4] + x[ 0]; x[ 8] ^= (s <<  9) | (s >> (32 -  9));
        s = x[ 8] + x[ 4]; x[12] ^= (s << 13) | (s >> (32 - 13));
        s = x[12] + x[ 8]; x[ 0] ^= (s << 18) | (s >> (32 - 18));
        s = x[ 5] + x[ 1]; x[ 9] ^= (s <<  7) | (s >> (32 -  7));
        s = x[ 9] + x[ 5]; x[13] ^= (s <<  9) | (s >> (32 -  9));
        s = x[13] + x[ 9]; x[ 1] ^= (s << 13) | (s >> (32 - 13));
        s = x[ 1] + x[13]; x[ 5] ^= (s << 18) | (s >> (32 - 18));
        s = x[10] + x[ 6]; x[14] ^= (s <<  7) | (s >> (32 -  7));
        s = x[14] + x[10]; x[ 2] ^= (s <<  9) | (s >> (32 -  9));
        s = x[ 2] + x[14]; x[ 6] ^= (s << 13) | (s >> (32 - 13));
        s = x[ 6] + x[ 2]; x[10] ^= (s << 18) | (s >> (32 - 18));
        s = x[15] + x[11]; x[ 3] ^= (s <<  7) | (s >> (32 -  7));
        s = x[ 3] + x[15]; x[ 7] ^= (s <<  9) | (s >> (32 -  9));
        s = x[ 7] + x[ 3]; x[11] ^= (s << 13) | (s >> (32 - 13));
        s = x[11] + x[ 7]; x[15] ^= (s << 18) | (s >> (32 - 18));
        s = x[ 0] + x[ 3]; x[ 1] ^= (s <<  7) | (s >> (32 -  7));
        s = x[ 1] + x[ 0]; x[ 2] ^= (s <<  9) | (s >> (32 -  9));
        s = x[ 2] + x[ 1]; x[ 3] ^= (s << 13) | (s >> (32 - 13));
        s = x[ 3] + x[ 2]; x[ 0] ^= (s << 18) | (s >> (32 - 18));
        s = x[ 5] + x[ 4]; x[ 6] ^= (s <<  7) | (s >> (32 -  7));
        s = x[ 6] + x[ 5]; x[ 7] ^= (s <<  9) | (s >> (32 -  9));
        s = x[ 7] + x[ 6]; x[ 4] ^= (s << 13) | (s >> (32 - 13));
        s = x[ 4] + x[ 7]; x[ 5] ^= (s << 18) | (s >> (32 - 18));
        s = x[10] + x[ 9]; x[11] ^= (s <<  7) | (s >> (32 -  7));
        s = x[11] + x[10]; x[ 8] ^= (s <<  9) | (s >> (32 -  9));
        s = x[ 8] + x[11]; x[ 9] ^= (s << 13) | (s >> (32 - 13));
        s = x[ 9] + x[ 8]; x[10] ^= (s << 18) | (s >> (32 - 18));
        s = x[15] + x[14]; x[12] ^= (s <<  7) | (s >> (32 -  7));
        s = x[12] + x[15]; x[13] ^= (s <<  9) | (s >> (32 -  9));
        s = x[13] + x[12]; x[14] ^= (s << 13) | (s >> (32 - 13));
        s = x[14] + x[13]; x[15] ^= (s << 18) | (s >> (32 - 18));
    }
    
    for (NSInteger i = 0; i < 16; i++){
        NSInteger value = x[i] + _input[i];
        NSInteger nOfs = i << 2;
        _output[nOfs] = (Byte) (value);
        _output[nOfs + 1] = (Byte) (value >> 8);
        _output[nOfs + 2] = (Byte) (value >> 16);
        _output[nOfs + 3] = (Byte) (value >> 24);
    }
}

- (void)cryptInput:(Byte[])input inOffset:(NSInteger)inOffset output:(Byte[])output outOffset:(NSInteger)outOffset length:(NSInteger)length {
    for (NSInteger i = 0; i < length; i++) {
        output[outOffset++] = (Byte)(input[inOffset++] ^ _output[_posRemainder]);
        _posRemainder++;
        if (_posRemainder == 64) {
            _posRemainder = 0;
            [self increaseBlockPosition];
        }
    }
}

- (void)increaseBlockPosition {
    _posBlock++;
    long block = _posBlock;
    _input[8] = (UInt32)(block & 0x00000000ffffffff);
    _input[9] = (UInt32)(block >> 32);
    [self calculateEncryptionOutputFromInput];
}

- (void)setPosition:(long)position {
    [self setBlockPosition:(position >> 6)];
    _posRemainder = (UInt32)(position & 0x3f);
}

- (void)setBlockPosition:(long)block {
    if (_posBlock != block) {
        _posBlock = block;
        _input[8] = (UInt32)(block & 0x00000000ffffffff);
        _input[9] = (UInt32)(block >> 32);
        [self calculateEncryptionOutputFromInput];
    }
}

@end
