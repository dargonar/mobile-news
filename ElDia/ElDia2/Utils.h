//
//  Utils.h
//  ElDia
//
//  Created by Lion User on 26/10/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(NSString *)cleanUrl:(NSString*)url;
+(NSString *)getYoutubeId:(NSString*)url;
+(NSData*)sanitizeXML:(NSData*)xml_data;

@end
