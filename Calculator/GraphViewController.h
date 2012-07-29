//
//  GraphViewControllerViewController.h
//  Calculator
//
//  Created by Rainer Burgstaller on 14.07.12.
//  Copyright (c) 2012 RealNetworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface GraphViewController : UIViewController<UISplitViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar* toolbar;
@property (nonatomic, strong) UIBarButtonItem* tabItem;
@property (weak, nonatomic) IBOutlet UISwitch *dotsSwitch;
@property (nonatomic, strong) id calculatorProgram;

-(void) refresh;

@end
