//
//  JBMenuViewController.m
//  JoystickBall
//
//  Created by Christopher Laganiere on 2/9/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "JBMenuViewController.h"

@interface JBMenuViewController ()

@property (nonatomic, weak) IBOutlet UILabel *title;

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
    CGRect titleFrame = CGRectMake(0, 300, 768, 124);
    UILabel *title = [[UILabel alloc] initWithFrame:titleFrame];
    title.font = [UIFont fontWithName:@"Imagine Font" size:100];
    title.textColor = [UIColor whiteColor];
    title.text = @"Ulama II";
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
