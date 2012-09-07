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

#import "ZXEmailAddressParsedResult.h"
#import "ZXEmailAddressResultParser.h"
#import "ZXEmailDoCoMoResultParser.h"
#import "ZXResult.h"

@implementation ZXEmailAddressResultParser

- (ZXParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [result text];
  NSString * emailAddress;
  if ([rawText hasPrefix:@"mailto:"] || [rawText hasPrefix:@"MAILTO:"]) {
    emailAddress = [rawText substringFromIndex:7];
    int queryStart = [emailAddress rangeOfString:@"?"].location;
    if (queryStart != NSNotFound) {
      emailAddress = [emailAddress substringToIndex:queryStart];
    }
    NSMutableDictionary * nameValues = [self parseNameValuePairs:rawText];
    NSString * subject = nil;
    NSString * body = nil;
    if (nameValues != nil) {
      if ([emailAddress length] == 0) {
        emailAddress = [nameValues objectForKey:@"to"];
      }
      subject = [nameValues objectForKey:@"subject"];
      body = [nameValues objectForKey:@"body"];
    }
    return [ZXEmailAddressParsedResult emailAddressParsedResultWithEmailAddress:emailAddress
                                                                        subject:subject
                                                                           body:body
                                                                      mailtoURI:rawText];
  } else {
    if (![ZXEmailDoCoMoResultParser isBasicallyValidEmailAddress:rawText]) {
      return nil;
    }
    emailAddress = rawText;
    return [ZXEmailAddressParsedResult emailAddressParsedResultWithEmailAddress:emailAddress
                                                                        subject:nil
                                                                           body:nil
                                                                      mailtoURI:[@"mailto:" stringByAppendingString:emailAddress]];
  }
}

@end
