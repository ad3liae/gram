/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXBitSourceBuilder.h"

@interface ZXBitSourceBuilder ()

@property (nonatomic, assign) int bitsLeftInNextByte;
@property (nonatomic, assign) int nextByte;
@property (nonatomic, retain) NSMutableData* output;

@end


/**
 * Class that lets one easily build an array of bytes by appending bits at a time.
 */
@implementation ZXBitSourceBuilder

@synthesize bitsLeftInNextByte;
@synthesize nextByte;
@synthesize output;

- (id)init {
  if(self = [super init]) {
    self.bitsLeftInNextByte = 8;
    self.nextByte = 0;
    self.output = [NSMutableData data];
  }

  return self;
}

- (void)write:(int)value numBits:(int)numBits {
  if (numBits <= self.bitsLeftInNextByte) {
    self.nextByte <<= numBits;
    self.nextByte |= value;
    self.bitsLeftInNextByte -= numBits;
    if (self.bitsLeftInNextByte == 0) {
      [self.output appendBytes:&nextByte length:1];
      self.nextByte = 0;
      self.bitsLeftInNextByte = 8;
    }
  } else {
    int bitsToWriteNow = self.bitsLeftInNextByte;
    int numRestOfBits = numBits - bitsToWriteNow;
    int mask = 0xFF >> (8 - bitsToWriteNow);
    int valueToWriteNow = (int)(((unsigned int)value) >> numRestOfBits) & mask;
    [self write:valueToWriteNow numBits:bitsToWriteNow];
    [self write:value numBits:numRestOfBits];
  }
}

- (unsigned char*)toByteArray {
  if (self.bitsLeftInNextByte < 8) {
    [self write:0 numBits:self.bitsLeftInNextByte];
  }
  return (unsigned char*)[self.output bytes];
}

- (int)byteArrayLength {
  return [self.output length];
}

@end
