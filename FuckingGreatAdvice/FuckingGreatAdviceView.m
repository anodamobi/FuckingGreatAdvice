//
//  FuckingGreatAdviceView.m
//  FuckingGreatAdvice
//
//  Created by Alex Zavrazhniy on 07.10.16.
//  Copyright (c) 2013 ANODA. All rights reserved.
//

#import "FuckingGreatAdviceView.h"
#import "GTMNSString+HTML.h"

@interface FuckingGreatAdviceView()

@property NSUserDefaults *defaults;

@end

NSString *kLastFetchedQuote = @"kLastFetchedQuote";

@implementation FuckingGreatAdviceView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self)
    {
        [self initialize];

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];

    CGRect newFrame = self.label.frame;
    CGFloat height = [_label.stringValue sizeWithAttributes:@{NSFontAttributeName: _label.font}].height;
    newFrame.size.height = height;
    newFrame.origin.y = (NSHeight(self.bounds) - height) / 2;
    _label.frame = newFrame;

    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
}

- (void)animateOneFrame
{
    [self fetchNextQuote];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet {
    return nil;
}

- (void) initialize {
    [self setAnimationTimeInterval:0.5];
    _defaults = [NSUserDefaults standardUserDefaults];
    [_defaults setValue:nil forKey:kLastFetchedQuote];
    [_defaults synchronize];

    [self configureLabel];
    [self restoreLastQuote];
    [self fetchNextQuote];
}

- (void)configureLabel {
    _label = [[NSTextField alloc] initWithFrame:self.bounds];
    _label.autoresizingMask = NSViewWidthSizable;
    _label.alignment = NSCenterTextAlignment;

    _label.stringValue = @"Ща, сек...";
    _label.textColor = [NSColor blackColor];
    _label.font = [NSFont fontWithName:@"Helvetica Bold" size:(self.preview ? 24.0 : 80.0)];

    _label.backgroundColor = [NSColor clearColor];
    [_label setEditable:NO];
    [_label setBezeled:NO];

    [self addSubview:_label];
}

- (void)restoreLastQuote {
    
    self.shouldFetchQuote = YES;
    NSString *lastQuote = [_defaults valueForKey:kLastFetchedQuote];
    [self setQuote: lastQuote];
}

- (void)scheduleNextFetch {
    double delayInSeconds = 10.0;
    dispatch_time_t fireTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(fireTime, dispatch_get_main_queue(), ^(void){
        self.shouldFetchQuote = YES;
    });
}

- (void)setQuote:(NSString *) quote {
    if (quote != nil) {
        _label.stringValue = quote;
        [_defaults setObject:quote forKey:kLastFetchedQuote];
        [_defaults synchronize];
        self.shouldFetchQuote = NO;
        [self setNeedsDisplay:YES];
    }

    [self scheduleNextFetch];
}


- (void) fetchNextQuote {
    @synchronized (self) {
        if (!self.shouldFetchQuote) {
            return;
        }
    }

    self.shouldFetchQuote = NO;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
        NSError *error;
        NSString *quote = @"Работай!";
            
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://fucking-great-advice.ru/api/random_by_tag/%D0%BA%D0%BE%D0%B4%D0%B5%D1%80%D1%83"]];
        if (data)
        {
            NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            quote = dictionary[@"text"];
            quote = [quote stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            quote = [quote gtm_stringByUnescapingFromHTML];
            quote = [NSString stringWithFormat:@"— %@", quote];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self scheduleNextFetch];
            [self setQuote: quote];
        });
    });
}

@end
