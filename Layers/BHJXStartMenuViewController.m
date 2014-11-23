//
//  BHJXStartMenuViewController.m
//  Layers
//
//  Created by Jun Hong Park on 10/21/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXStartMenuViewController.h"

@interface BHJXStartMenuViewController ()

@end

@implementation BHJXStartMenuViewController

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
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Startmenubackground.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
