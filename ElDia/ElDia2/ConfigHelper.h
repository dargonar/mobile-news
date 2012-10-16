//
//  ConfigHelper.h
//  ElDia2
//
//  Created by Lion User on 03/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CFG_NOTICIA_FONTSIZE @"CFG_NOTICIA_FONTSIZE"
#define CFG_FIRSTTIME @"CFG_FIRSTTIME"

@interface ConfigHelper : NSObject

+(NSString *)getSettingValue:(NSString*)key;
+(void)setSettingValue:(NSString*)key value:(NSString*)value;

@end
