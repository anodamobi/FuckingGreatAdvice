//
//  FuckingGreatAdviceView.h
//  FuckingGreatAdvice
//
//  Created by Alex Zavrazhniy on 07.10.16.
//  Copyright (c) 2016 ANODA. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface FuckingGreatAdviceView : ScreenSaverView

@property (strong) NSTextField *label;
@property (assign) BOOL shouldFetchQuote;

@end
