//
//  JBMenuViewController.m
//  JoystickBall
//
//  Created by Christopher Laganiere on 2/9/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "JBMenuViewController.h"

@interface JBMenuViewController ()

@end

@implementation JBMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// This is lazy as hell
    self.view.backgroundColor = [UIColor colorWithRed:
                                 0.390625 green:0.83203125 blue:
                                 0.390625 alpha:1.0];
    
    CGFloat titleFontSize = isIpad ? 100.0f : 50.0f;
    CGFloat titlePosAdjustment = titleFontSize + 24.0f;
    CGRect titleFrame = self.view.frame;
    titleFrame.origin.y = (titleFrame.size.height - titlePosAdjustment - 60)/2.0f;
    titleFrame.size.height = 124.0f;
    UILabel *title = [[UILabel alloc] initWithFrame:titleFrame];
    
    title.font = [UIFont fontWithName:@"Imagine Font" size:titleFontSize];
    title.textColor = [UIColor whiteColor];
    title.text = @"Ulama II";
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
    
    CGRect subtitleFrame = self.view.frame;
    subtitleFrame.origin.y = (subtitleFrame.size.height + titlePosAdjustment - 60)/2.0f;
    subtitleFrame.size.height = 60.0f;
    UILabel *subtitle = [[UILabel alloc] initWithFrame:subtitleFrame];
    subtitle.font = [UIFont fontWithName:@"Imagine Font" size:25];
    subtitle.textColor = [UIColor whiteColor];
    subtitle.text = @"Tap to begin";
    subtitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:subtitle];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
