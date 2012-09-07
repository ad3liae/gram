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

#import "ZXAbstractExpandedDecoder.h"
#import "ZXBinaryUtil.h"
#import "ZXExpandedInformationDecoderTest.h"

@implementation ZXExpandedInformationDecoderTest

- (void)testNoAi {
  ZXBitArray* information = [ZXBinaryUtil buildBitArrayFromString:@" .......X ..XX..X. X.X....X .......X ...."];

  ZXAbstractExpandedDecoder* decoder = [ZXAbstractExpandedDecoder createDecoder:information];
  NSString* decoded = [decoder parseInformationWithError:nil];
  STAssertEqualObjects(decoded, @"(10)12A", @"Expected %@ to equal \"(10)12A\"");
}

@end
