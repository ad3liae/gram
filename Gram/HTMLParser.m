//
//  HTMLParser.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/28.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "HTMLParser.h"

@interface HTMLParser ()
{
    xmlParserCtxtPtr context;
    BOOL isItem;
    BOOL isBuffering;
    NSMutableData *characterBuffer;
}

@property BOOL isItem;
@property BOOL isBuffering;
@property (nonatomic, retain) NSMutableData *characterBuffer;

- (void)appendCharacters:(const char *)characters length:(NSInteger)length;
- (void)finishAppendCharacters:(NSString *)element;

@end

static void startElementSAX(void *context,
                            const xmlChar *localname,
                            const xmlChar *prefix,
                            const xmlChar *URI,
                            int nb_namespaces,
                            const xmlChar **namespaces,
                            int nb_attributes, int nb_defaulted,
                            const xmlChar **atrributes)
{
    HTMLParser *parser = (__bridge HTMLParser *)context;
    
    parser.isItem = YES;
    if (parser.isItem == YES)
    {
        if (strncmp((const char*)localname, "title", sizeof("title")) == 0)
        {
            parser.isBuffering = YES;
        }
        else if (strncmp((const char*)localname, "link", sizeof("link")) == 0)
        {
            parser.isBuffering = YES;
        }
        else if (strncmp((const char*)localname, "description", sizeof("description")) == 0)
        {
            //paserImporter.isBuffering = YES;
        }
        else if (strncmp((const char*)localname, "pubDate", sizeof("pubDate")) == 0)
        {
            parser.isBuffering = YES;
        }  
        
    }
    else
    {
        if (strncmp((const char*)localname, "item", sizeof("item")) == 0)
        {
            parser.isItem = YES;
        }
        else
        {
            //paser.isItem = NO;
        }
    }
}

static void endElementSAX(void *context,
                          const xmlChar *localname,
                          const xmlChar *prefix,
                          const xmlChar *URI)
{
    HTMLParser *parser = (__bridge HTMLParser *)context;
    
    if (parser.isBuffering == YES)
    {
        if (strncmp((const char*)localname, "title", sizeof("title")) == 0)
        {
            [parser finishAppendCharacters:@"title"];
        }
        else if (strncmp((const char*)localname, "link", sizeof("link")) == 0)
        {
            [parser finishAppendCharacters:@"link"];
        }
        else if (strncmp((const char*)localname, "description", sizeof("description")) == 0)
        {
            [parser finishAppendCharacters:@"description"];
        }
        else if (strncmp((const char*)localname, "pubDate", sizeof("pubDate")) == 0)
        {
            [parser finishAppendCharacters:@"pubDate"];
        }
    }
    parser.isBuffering = NO;
}

static void charactersFoundSAX(void *context,
                               const xmlChar *characters,
                               int length)
{
    HTMLParser *parser = (__bridge HTMLParser *)context;
    
    if (parser.isBuffering == YES)
    {
        NSLog(@"%s", (const char *)characters);
        [parser appendCharacters:(const char *)characters length:length];
    }
}

static xmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */  
    NULL,                       /* comment */  
    NULL,                       /* warning */  
    NULL,                       /* error */  
    NULL,                       /* fatalError //: unused error() get all the errors */  
    NULL,                       /* getParameterEntity */  
    NULL,                       /* cdataBlock */  
    NULL,                       /* externalSubset */  
    XML_SAX2_MAGIC,             //  
    NULL,  
    startElementSAX,            /* startElementNs */  
    endElementSAX,              /* endElementNs */  
    NULL,                       /* serror */  
};

@implementation HTMLParser
@synthesize isItem;
@synthesize isBuffering;
@synthesize characterBuffer;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.isBuffering = NO;
        self.characterBuffer = [NSMutableData data];
        
        if (!context)
        {
            context = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, (__bridge void *)(self), NULL, 0, NULL);
        }
        
        NSString *url = @"http://www.yahoo.co.jp/";
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (urlConnection == nil)
        {
            NSLog(@"error");
        }
    }
    
    return self;  
}

#pragma mark NSURLConnection Delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"receiving...");
    xmlParseChunk(context, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"didFinish");
    
    if (context) {
        xmlFreeParserCtxt(context);
        context = NULL;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error");
    
    if (context)
    {
        xmlFreeParserCtxt(context);  
        context = NULL;  
    }  
}

- (void)appendCharacters:(const char *)characters length:(NSInteger)length
{
    [characterBuffer appendBytes:characters length:length];
}

- (void)finishAppendCharacters:(NSString *)element
{
    NSString *currentString = [[NSString alloc] initWithData:self.characterBuffer encoding:NSUTF8StringEncoding];
    NSLog(@"#%@ : %@", element, currentString);
    [characterBuffer setLength:0];
}

@end
