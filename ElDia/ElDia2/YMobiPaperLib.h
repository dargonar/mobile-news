//
//  YMobiPaperLib.h
//  ElDia2
//
//  Created by Lion User on 28/08/2012.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLGenerator.h"
#import "CryptoUtil.h"
#import "Reachability.h"

#define XSL_PATH_MAIN_LIST @"1_main_list"
#define XSL_PATH_SECTION_LIST @"2_section_list"
#define XSL_PATH_NEWS @"3_new"
#define XSL_PATH_SECTIONS @"4_menu"
#define XSL_NOTICIAS_IDS @"_noticias_id_array"
#define XSL_NOTICIA_METADATA @"_noticia_metadata"

#define SCHEMA_NOTICIA @"noticia"
#define SCHEMA_VIDEO @"video"
#define SCHEMA_AUDIO @"audio"
#define SCHEMA_GALERIA @"galeria"
#define SCHEMA_SECTION @"seccion"

#define MSG_UPD_MAIN @"update_main_list"
#define MSG_GET_MAIN @"get_main_list"
#define MSG_GET_NEW @"get_new"
#define MSG_GET_SECTIONS @"get_sections"
#define MSG_GET_SECTION_LIST @"get_section_list"
#define MSG_UPD_SECTION_LIST @"update_section_list"


typedef enum {
  YMobiNavigationTypeMain = 0,          //Listado principal
  YMobiNavigationTypeNews = 1,          //Noticia abierta
  YMobiNavigationTypeSections = 2,      //Secciones
  YMobiNavigationTypeSectionNews = 3,   //Noticias de seccion
  YMobiNavigationTypeOther = 4          // verga tiesa
} YMobiNavigationType;

@protocol YMobiPaperLibDelegate <NSObject>
@required
- (void) requestSuccessful:(id)data message:(NSString*)message;
- (void) requestFailed:(id)error message:(NSString*)message;
@end

@interface YMobiPaperLib : NSObject<NSURLConnectionDataDelegate>{
  NSArray									*urls;
  NSMutableDictionary     *messages;
  NSMutableDictionary     *requestsMetadata;
  __unsafe_unretained id <YMobiPaperLibDelegate> delegate;

  NSString *metadata;
}

@property (retain) NSString *metadata; // Usado para info de la noticia, en NoticiaViewController.
@property (retain) NSMutableDictionary *requestsMetadata;
@property (retain) NSArray						 *urls;
@property (retain) NSMutableDictionary *messages;
// Delegate
@property (nonatomic, assign) id <YMobiPaperLibDelegate> delegate;

- (id)init;

-(NSData*)getHtml:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl;
-(NSData*)getHtml:(NSString *)path xsl:(NSString *)xsl;
-(NSString*)getHtmlPath:(NSString*)path;

-(NSString *)loadURL:(NSString *)path;
-(NSString *)buildHtml:(NSString *)xml xsl:(NSString *)xsl;

-(NSString *)getUrl:(YMobiNavigationType)item queryString:(NSString *)queryString;

-(NSData*) getHtmlAndConfigure:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl tag:(NSString*)tag force_load:(BOOL)force_load;
-(void)configureXSL:(NSString*)xsl xml:(NSString*)xml;

//-(NSData*) getChachedData:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl tag:(NSString*)tag fire_event:(BOOL)fire_event;
-(NSData*) getChachedData:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl tag:(NSString*)tag fire_event:(BOOL)fire_event is_html:(BOOL)is_html;
-(NSData*) getChachedData:(NSString*)path tag:(NSString*)tag fire_event:(BOOL)fire_event;
-(NSData*) getChachedDataAndConfigure:(YMobiNavigationType)item queryString:(NSString *)queryString xsl:(NSString *)xsl tag:(NSString*)tag fire_event:(BOOL)fire_event;

-(void)cleanCache;
-(bool)mustReloadPath:(YMobiNavigationType)item queryString:(NSString *)queryString;

+(void)setIds:(NSString*)text;
+(NSString*)getNextNoticiaId:(NSString*)_noticia_id;
+(NSString*)getPrevNoticiaId:(NSString*)_noticia_id;

-(BOOL)areWeConnectedToInternet;
-(NSError*)getLasError;
-(void)setLasError:(NSError*)error;
-(void)setLasErrorDesc:(NSString*)error;
@end
