//
//  SqliteCache.h
//  Massa
//
//  Created by Matias on 7/25/12.
//  Copyright (c) 2012 Diventi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface SqliteCache : NSObject {
  sqlite3 *db;
}

+ (SqliteCache *) defaultCache;
- (NSData *) get   : (NSString*)key;
- (void)     set   : (NSString*)key data:(NSData*)data;
- (void)     clean : (int)hours;
@end
