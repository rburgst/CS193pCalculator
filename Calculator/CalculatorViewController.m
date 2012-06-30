//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Rainer Burgstaller on 30.06.12.
//  Copyright (c) 2012 RealNetworks. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

@property(nonatomic) BOOL userIsEnteringANumber;
@property(nonatomic, strong) CalculatorBrain* brain;

@end



@implementation CalculatorViewController

@synthesize display = _display;
@synthesize userIsEnteringANumber = _userIsEnteringANumber;
@synthesize brain = _brain;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setDisplay:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}




- (CalculatorBrain*) brain 
{
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    if (self.userIsEnteringANumber) {
        NSString *newText = [self.display.text stringByAppendingString:sender.currentTitle];
        self.display.text = newText;
    } else {
        self.display.text = sender.currentTitle;
        self.userIsEnteringANumber = YES;
    }
}

- (IBAction)operationPressed:(UIButton *)sender {
    // press enter for the user to help him save time
    if (self.userIsEnteringANumber) {
        [self enterPressed];
    }
    self.display.text = [NSString stringWithFormat:@"%g",[self.brain performOperation:sender.currentTitle]];
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsEnteringANumber = NO;
}

- (IBAction)invertSignPressed:(UIButton *)sender {
    if (self.userIsEnteringANumber) {
        // TODO for extra credit 3
    }
}

- (IBAction)commaPressed:(UIButton *)sender {
    if (self.userIsEnteringANumber && [self.display.text rangeOfString:@"."].location != NSNotFound) {
            // only allow 1 comma
        return;
    } else {
        // otherwise just handle it just like any other old digit.
        [self digitPressed:sender];
    }
}

- (IBAction)clearPressed:(UIButton *)sender {
    [self.brain clear];
    self.userIsEnteringANumber = NO;
    self.display.text = @"0";
}


@end
