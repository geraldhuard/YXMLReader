//
//  NSDictionary+Path.m
//  MazAudio
//
//  Created by Gérald HUARD on 04/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Path.h"

@implementation NSDictionary (Path)



-(id)objectForPath:(NSString*)path{
    NSDictionary *dictProgress=[self copy];
    NSArray *strings = [path componentsSeparatedByString:@"/"];
    NSString *lastkey=[strings lastObject];    
    
    
    for (int i=0;i<[strings count]-1;i++){        
        NSString *pth=[strings objectAtIndex:i]; 
        if ([pth length]>0){
            if ([dictProgress isKindOfClass:[NSDictionary class]])dictProgress=[dictProgress objectForKey:pth];
            else {
                @throw [NSException exceptionWithName:NSInvalidArchiveOperationException
                                               reason:@"NSDictionnary::Path incorrect"
                                             userInfo:nil];
                return nil;
            }
        }
    }
    return [dictProgress objectForKey:lastkey];
}

@end
