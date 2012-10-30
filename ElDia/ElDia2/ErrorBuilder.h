//
//  ErrorBuilder.h
//  ElDia
//
//  Created by Matias on 10/25/12.
//  Copyright (c) 2012 Lion User. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ERR_REQUEST_NULL              0x1001   //SERVER : el resultado de un request es nulo
#define ERR_INVALID_XML               0x1002   //SERVER : el xml es invalido (mal formado o un caracter puto)

#define ERR_SERIALIZING_MI            0x2001   //LOCAL  : no podemos serializar los mobi images
#define ERR_CACHING_MI                0x2002   //LOCAL  : no podemos cachear los mobi images
#define ERR_CACHING_HTML              0x2003   //LOCAL  : no podemos cachear el html generado
#define ERR_INVALID_XLS               0x2004   //LOCAL  : el xslt es invalido
#define ERR_INVALID_XSL_PARAM         0x2005   //LOCAL  : el parametro de xsl es invalido
#define ERR_XSL_TANSFORM              0x2006   //LOCAL  : la transformacion xml+xsl fallo
#define ERR_GENERATED_HTML            0x2007   //LOCAL  : el html generado es invalido (zero size o null)
#define ERR_GENERATED_XML             0x2008   //LOCAL  : el xml generado con las url locales es invalido
#define ERR_DESERIALIZING_MI          0x2009   //LOCAL  : no podemos de serializar los mobi images

#define ERR_NO_INTERNET_CONNECTION    0x3001   //INTERNET  : no no hay conexion a internet

@interface ErrorBuilder : NSObject
  +(id) build:(NSError **)error desc:(NSString *)desc code:(NSInteger)code;
@end
