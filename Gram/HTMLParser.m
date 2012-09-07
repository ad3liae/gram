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

- (void)fromC;

- (void)appendCharacters:(const char *)characters length:(NSInteger)length;
- (void)finishAppendCharacters:(NSString *)element;

@end

static void startElementSAX(
                            void *context,
                            const xmlChar *localname,
                            const xmlChar *prefix,
                            const xmlChar *URI,
                            int nb_namespaces,
                            const xmlChar **namespaces,
                            int nb_attributes, int nb_defaulted,
                            const xmlChar **atrributes) {
    // void *context は Objective-C との橋渡し。
    // xmlCreatePushParserCtxt()の第2引数でselfとして渡されたのが、contextとして渡ってきた。
    // 型を合わせることで、Objective-Cのオブジェクトとして扱えるようにしている。
    HTMLParser *parser = (__bridge HTMLParser *)context;
    
    // タグの開始（要素の開始）を判断する。例えば<title>xxx</title>なら<title>を判断してくれる。
    // バッファし始めることをここで宣言(paserImporter.isBuffering=YES)する。
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
            //paserImporter.isBuffering = YES; // 今回はコメントにして記事本文は読み込まないようにしとく
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

static void endElementSAX(
                          void *context,
                          const xmlChar *localname,
                          const xmlChar *prefix,
                          const xmlChar *URI) {
    HTMLParser *parser = (__bridge HTMLParser *)context;
    
    // タグの終了（要素の終了）を判断する。例えば<title>xxx</title>なら</title>を判断してくれる。
    // バッファを終了する。
    // 例えば<title>あいうえお</title>なら、Objective-C側で溜めた文字列「あいうえお」
    // を確定させて次のバッファを溜められるようにしている。
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

static void charactersFoundSAX(
                               void *context,
                               const xmlChar *characters,
                               int length) {
    HTMLParser *parser = (__bridge HTMLParser *)context;
    
    // 通知で受け取る文字列は、一回だけじゃなくて連続してくる。（短ければ1回で受け取れる）
    // それらをその都度Objective-C側にバッファを溜めていく。
    // 例えば<title>あいうえお</title>なら、startElementSAXからendElementSAXの間
    // で断続して文字列「あいうえお」を取得することになる。
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
    // データ受信
    NSLog(@"受信中（データは分割されて受信される）");
    
    // これ追加
    // 受信したデータをパーサに渡している
    // NSDataはC言語では扱えないのでchar型にキャストして渡してる
    xmlParseChunk(context, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // 受信完了
    NSLog(@"受信完了");
    
    // ここを追加
    // パーサを解放
    if (context) {
        xmlFreeParserCtxt(context);
        context = NULL;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // 受信エラー
    NSLog(@"エラー");
    
    // ここを追加
    // パーサを解放
    if (context)
    {
        xmlFreeParserCtxt(context);  
        context = NULL;  
    }  
}

/**
 ここ追加
 パースされて送られてきた文字を、バッファに溜める。
 NSMutableDataなcharacterBufferに送られてきた文字をがんがん入れていく。
 Cの関数から呼ばれる不思議
 */
- (void)appendCharacters:(const char *)characters length:(NSInteger)length
{
    [characterBuffer appendBytes:characters length:length];
}

/**
 ここ追加
 溜めたバッファを NSString に変換する
 Cの関数から呼ばれる不思議
 */
- (void)finishAppendCharacters:(NSString *)element
{
    NSString *currentString = [[NSString alloc] initWithData:self.characterBuffer encoding:NSUTF8StringEncoding];
    NSLog(@"#%@ : %@", element, currentString);
    [characterBuffer setLength:0];
}

@end
