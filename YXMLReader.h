//
//  YXMLReader.h
//
//  Created by Gérald HUARD on 07/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kYXMLReaderAttributesKey @"@attr"
#define kYXMLReaderTextNodeKey @"@text"


@protocol YXMLReaderDelegate <NSObject>
- (void) yXMLReaderDidFinishParsing:(NSDictionary*)dict;
@end


@interface YXMLReader : NSObject <NSXMLParserDelegate>{
    
    NSURL                   *_url;
    NSXMLParser             *_parser;
    NSDictionary            *_dict;
    
    BOOL                    _removeNameSpace;

    id<YXMLReaderDelegate>  _delegate;
    
    
    NSMutableArray          *_stack;
    NSMutableString         *_textInProgress;

}

@property (nonatomic, assign) id<YXMLReaderDelegate> delegate;
@property (nonatomic, retain) NSURL *url;


-(id)   initWithUrl:(NSURL*)url;
-(void) initVars;
-(void) parse;
-(void) parse:(BOOL)inParallel;

-(void) trimTextInProgress;


-(NSDictionary*)dict;
-(id)objectForXPath:(NSString*)xpath;



@end


