//
//  YXMLReader.m
//
//  Created by Gérald HUARD on 07/02/12.
//  Copyright (c) 2012 __Yooneo__. All rights reserved.
//

#import "YXMLReader.h"
#import "NSDictionary+Path.h"


@implementation YXMLReader
@synthesize delegate=_delegate;
@synthesize url=_url;


-(id) initWithUrl:(NSURL*)url{
    self=[super init];
    if (self){        
        [self initVars];
        _url=url;
        _removeNameSpace=YES;
    }
    return self;
}


-(void) dealloc{
    [_url release];
    [_parser release];
    [_dict release];
    [_stack release];
    [_textInProgress release];
    
    [super dealloc];
}


-(void) parse{
    [self parse:NO];
}

-(void) parse:(BOOL)inParallel{
    if (inParallel)[NSThread detachNewThreadSelector:@selector(startParsing) toTarget:self withObject:nil];
    else [self startParsing];
}

-(void) startParsing{
    _parser=[[NSXMLParser alloc] initWithContentsOfURL:_url];
    _parser.delegate=self;
    [_parser parse];
    _dict=[[NSDictionary alloc ] initWithDictionary:[_stack objectAtIndex:0]] ;
    if (_delegate)[_delegate yXMLReaderDidFinishParsing:_dict];
}




-(NSDictionary*)dict{
    return _dict;
}

-(id)objectForXPath:(NSString*)xpath{    
    return [_dict objectForPath:xpath];
}




-(void) initVars{
    [_stack release];
    [_textInProgress release];

    _stack=[[NSMutableArray alloc] init];
    [_stack addObject:[NSMutableDictionary dictionary]];

    _dict=[[NSMutableDictionary alloc] init];
    _textInProgress=[[NSMutableString alloc] init];
    
}


-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{

    NSMutableDictionary *parentDict = [_stack lastObject];
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];

    
    if (_removeNameSpace){
        NSArray *parts=[elementName componentsSeparatedByString:@":"];
        elementName=[parts lastObject];        
        
        NSEnumerator *enumerator = [attributeDict keyEnumerator];
        id key = nil;
        NSMutableDictionary *dictAttr=[[NSMutableDictionary alloc] init];
        while ( (key = [enumerator nextObject]) != nil) {
            id value = [attributeDict objectForKey:key];
            
            if ([key isKindOfClass:[NSString class]]){
                parts=[key componentsSeparatedByString:@":"];
                key=[parts lastObject];
            }
            [dictAttr setValue:value forKey:key];
        }
        [childDict setValue:dictAttr forKey:kYXMLReaderAttributesKey];
    }else {
        [childDict setValue:attributeDict forKey:kYXMLReaderAttributesKey];
    }
    
    
    id existVal = [parentDict objectForKey:elementName];
    if (existVal){
        
        NSMutableArray *array = nil;
        if ([existVal isKindOfClass:[NSMutableArray class]])array = (NSMutableArray *) existVal;
        else{
            array = [NSMutableArray array];
            [array addObject:existVal];
            
            [parentDict setObject:array forKey:elementName];
        }
        [array addObject:childDict];
    }
    else [parentDict setObject:childDict forKey:elementName];
    
    [_stack addObject:childDict];
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    [self trimTextInProgress];    
    NSMutableDictionary *dictInProgress = [_stack lastObject];
    if ([_textInProgress length] > 0){
        [dictInProgress setObject:_textInProgress forKey:kYXMLReaderTextNodeKey];
        
        [_textInProgress release];
        _textInProgress = [[NSMutableString alloc] init];
    }
    [_stack removeLastObject];
}



-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [_textInProgress appendString:string];
}

-(void) trimTextInProgress{
    NSString *textInProgressWithoutWhite=[_textInProgress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [_textInProgress setString:textInProgressWithoutWhite];
}

@end


