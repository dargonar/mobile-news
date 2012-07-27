//
//  SHA1Util.h
//  Massa
//
//  Created by Matias on 7/24/12.
//  Copyright (c) 2012 Diventi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CryptoUtil : NSObject

+ (NSString *) sha1:(NSString *) input;
+ (NSString *)  md5:(NSString *) input;
@end
