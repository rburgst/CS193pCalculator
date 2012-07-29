//
//  GraphViewControllerViewController.m
//  Calculator
//
//  Created by Rainer Burgstaller on 14.07.12.
//  Copyright (c) 2012 RealNetworks. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"
#import "CalculatorProgramsTableViewController.h"

@interface GraphViewController ()<GraphDataSource, CalculatorProgramsTableViewControllerDelegate>


@property (nonatomic, weak) IBOutlet GraphView* graph;
@property (nonatomic, weak) IBOutlet UILabel* label;
@property (nonatomic, strong) UIPopoverController* lastPopoverController;

-(void)tapRecognized:(UITapGestureRecognizer*)gesture;
@end

@implementation GraphViewController

#define FAVORITES_KEY @"CalculatorGraphViewController.Favorites"


@synthesize graph = _graph;
@synthesize label = _label;
@synthesize toolbar = _toolbar;
@synthesize tabItem = _tabItem;
@synthesize dotsSwitch = _dotsSwitch;
@synthesize calculatorProgram = _calculatorProgram;
@synthesize lastPopoverController = _lastPopoverController;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.graph.datasource = self;
    [self refresh];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    recognizer.numberOfTapsRequired = 3;
    [self.graph addGestureRecognizer:recognizer];

    self.graph.defaultsPrefix = @"graph1";
    self.graph.useDots = YES;

}

-(void) setCalculatorProgram:(id)calculatorProgram {
    if (_calculatorProgram != calculatorProgram) {
        _calculatorProgram = calculatorProgram;
        [self refresh];
    }
}

-(void)tapRecognized:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [gesture locationInView:self.graph];
        self.graph.origin = location;
    }
}

- (IBAction)addToFavouritesPressed:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *programs = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!programs) programs = [NSMutableArray array];
    
    [programs addObject:self.calculatorProgram];
    [defaults setObject:programs forKey:FAVORITES_KEY];
    [defaults synchronize];
}

-(NSArray*)removeFavourite:(id)program
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *programs = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    
    [programs removeObject:program];
    
    [defaults setObject:programs forKey:FAVORITES_KEY];
    [defaults synchronize];
    return programs;
}


- (IBAction)dotsSwitchChanged:(UISwitch *)sender {
    self.graph.useDots = sender.on;
}

- (void)viewDidUnload
{
    [self setDotsSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)setTabItem:(UIBarButtonItem *)tabItem {
    if (tabItem != _tabItem) {
        NSMutableArray *newItems = [self.toolbar.items mutableCopy];
        if (_tabItem) [newItems removeObject:_tabItem];
        if (tabItem) [newItems insertObject:tabItem atIndex:0];
        _tabItem = tabItem;
        self.toolbar.items = newItems;
    }
}

-(void) refresh {
    self.label.text = [CalculatorBrain descriptionOfProgram:self.calculatorProgram];
    [self.graph setNeedsDisplay];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Favourite Graphs"]) {
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            // prevent multiple popovers on top of each other

            // first dismiss any previous popover
            [self.lastPopoverController dismissPopoverAnimated:YES];
            
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue*) segue;

            // remember the controller for later
            self.lastPopoverController = popoverSegue.popoverController;
        }
        
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
}

// ----------------- ui splitviewdelegate
#pragma mark UISplitViewDelegate

-(void)splitViewController:(UISplitViewController *)svc 
         popoverController:(UIPopoverController *)pc 
 willPresentViewController:(UIViewController *)aViewController {
    
}

-(void)splitViewController:(UISplitViewController *)svc 
    willHideViewController:(UIViewController *)aViewController 
         withBarButtonItem:(UIBarButtonItem *)barButtonItem 
      forPopoverController:(UIPopoverController *)pc {
    
    barButtonItem.title = @"Calculator";
    self.tabItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc 
    willShowViewController:(UIViewController *)aViewController 
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.tabItem = nil;
}

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation);
}

#pragma mark GraphDataSource

-(float) yValue:(GraphView *)view forX:(float)x {
    id program = self.calculatorProgram;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:x], @"x", nil];
    id result = [CalculatorBrain runProgram:program usingVariableValues:dict];
    if ([result isKindOfClass:[NSNumber class]]) {
        return [result doubleValue];
    }
    return 0;
}

-(NSString*) descriptionOfProgram {
    return [CalculatorBrain descriptionOfProgram:self.calculatorProgram];
}

#pragma mark - CalculatorProgramsTableViewControllerDelegate

-(void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender choseProgram:(id)program
{
    self.calculatorProgram = program;
}

-(void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender deletedProgram:(id)program
{
    sender.programs = [self removeFavourite:program];
}
@end
