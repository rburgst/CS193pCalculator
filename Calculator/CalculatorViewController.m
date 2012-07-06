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
@property(nonatomic, strong) NSString* historyString;
@property(nonatomic, strong) NSDictionary *variableDict;

@end



@implementation CalculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize variables = _variables;
@synthesize userIsEnteringANumber = _userIsEnteringANumber;
@synthesize brain = _brain;
@synthesize historyString = _historyString;
@synthesize variableDict = _variableDict;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setDisplay:nil];
    [self setHistory:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (NSString*)historyString {
    if (!_historyString) {
        _historyString = @"";
    }
    return _historyString;
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

- (void)updateDisplay {
    id program = self.brain.program;
    self.display.text = [NSString stringWithFormat:@"%g",[CalculatorBrain runProgram:program usingVariableValues:self.variableDict]];
//    self.historyString = [self.historyString stringByAppendingFormat:@"%@ ", operationString];
    self.history.text = [CalculatorBrain descriptionOfProgram:program];
}

- (IBAction)operationPressed:(UIButton *)sender {
    // press enter for the user to help him save time
    if (self.userIsEnteringANumber) {
        [self enterPressed];
    }
    NSString *operationString = sender.currentTitle;
    [self.brain performOperation:operationString];
    [self updateDisplay];
}

- (IBAction)enterPressed {
    double value = [self.display.text doubleValue];
    self.userIsEnteringANumber = NO;
    
    // and add it to the stack
    [self.brain pushOperand:value];
    [self updateDisplay];
}

- (IBAction)invertSignPressed:(UIButton *)sender {
    if (self.userIsEnteringANumber) {
        // TODO for extra credit 3
        NSString *currentText = self.display.text;
        if ([currentText rangeOfString:@"-"].location == 0) {
            self.display.text = [currentText substringFromIndex:1];   
        } else {
            self.display.text = [@"-" stringByAppendingString:currentText];            
        }
    } else {
        [self operationPressed:sender];
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
    self.history.text = @"";
    self.historyString = @"";
}

- (IBAction)backspacePressed:(UIButton *)sender {
    NSString *currentString = self.display.text;
    if ([currentString length] > 0 && ![currentString isEqualToString:@"0"]) {
        NSString *newText = [currentString substringToIndex:[currentString length] - 1];
        
        // prevent an empty string, show the 0 instead
        if ([newText length] == 0) {
            newText = @"0";
        }
        self.display.text = newText;
    }
}

- (IBAction)variablePressed:(UIButton *)sender {
    [self operationPressed:sender];
}

- (IBAction)undoPressed:(UIButton *)sender {
    [self updateDisplay];
}

- (IBAction)testPressed:(UIButton *)sender {
    int tag = sender.tag;
    
    switch (tag) {
        case 0:
            [self setupVariablesWithX:3.0 andA:5.0 andB:4.5];
            break;
        case 1:
            [self setupVariablesWithX:5.5 andA:10.0 andB:3.0];
            break;
        case 2:
            [self setupVariablesWithX:1 andA:2 andB:3];
            break;
    }
    [self updateDisplay];
}

- (void)setupVariablesWithX:(double) x andA:(double)a andB:(double) b {
    self.variableDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:x], @"x", [NSNumber numberWithDouble:a], @"a", [NSNumber numberWithDouble:b], @"b", nil];    
}


@end
