//
//  MyUtils.m
//  NewXLPrep
//
//  Created by Matu on 12-02-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "MyUtils.h"
BOOL isPad() {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

NSString *stripPadSuffixOnPhone(NSString *name)
{
    if( !isPad() )
        return [name substringToIndex:[name length]-5];
    
    return name;
}
