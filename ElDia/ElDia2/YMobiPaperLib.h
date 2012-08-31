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
#import "SqliteCache.h"

#define MAIN_XSL_PATH @"1_main_list"
#define NEWS_XSL_PATH @"2_new_open"

typedef enum {
  YMobiNavigationTypeMain = 0,          //Listado principal
  YMobiNavigationTypeNews = 1,          //Noticia abierta
  YMobiNavigationTypeSections = 2,      //Secciones
  YMobiNavigationTypeSectionNews = 3,   //Noticias de seccion
  YMobiNavigationTypeOther = 4          // verga tiesa
} YMobiNavigationType;


@interface YMobiPaperLib : NSObject{
NSArray									*urls;
}

@property (retain) NSArray									*urls;

- (id)init;
-(void)loadHtml:(YMobiNavigationType *)item queryString:(NSString *)queryString xsl:(NSString *)xsl  _webView:(UIWebView *) _webView ;
-(void)loadHtml:(NSString *)path xsl:(NSString *)xsl  _webView:(UIWebView *) _webView;
-(NSString *)getHtml:(NSString *)path xsl:(NSString *)xsl;
-(NSString *)getUrl:(YMobiNavigationType *)item queryString:(NSString *)queryString;
@end
