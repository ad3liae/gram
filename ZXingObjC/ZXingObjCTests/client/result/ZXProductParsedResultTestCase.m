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

#import "ZXProductParsedResult.h"
#import "ZXProductParsedResultTestCase.h"
#import "ZXResultParser.h"

@interface ZXProductParsedResultTestCase ()

- (void)doTestWithContents:(NSString*)contents
                normalized:(NSString*)normalized
                    format:(ZXBarcodeFormat)format;

@end

@implementation ZXProductParsedResultTestCase

- (void)testProduct {
  [self doTestWithContents:@"123456789012" normalized:@"123456789012" format:kBarcodeFormatUPCA];
  [self doTestWithContents:@"00393157" normalized:@"00393157" format:kBarcodeFormatEan8];
  [self doTestWithContents:@"5051140178499" normalized:@"5051140178499" format:kBarcodeFormatEan13];
  [self doTestWithContents:@"01234565" normalized:@"012345000065" format:kBarcodeFormatUPCE];
}

- (void)doTestWithContents:(NSString*)contents
                normalized:(NSString*)normalized
                    format:(ZXBarcodeFormat)format {
  ZXResult* fakeResult = [ZXResult resultWithText:contents rawBytes:NULL length:0 resultPoints:nil format:format];
  ZXParsedResult* result = [ZXResultParser parseResult:fakeResult];
  STAssertEquals(result.type, kParsedResultTypeProduct, @"Types don't match");
  ZXProductParsedResult* productResult = (ZXProductParsedResult*)result;
  STAssertEqualObjects(productResult.productID, contents, @"Contents don't match");
  STAssertEqualObjects(productResult.normalizedProductID, normalized, @"Normalized doesn't match");
}

@end
