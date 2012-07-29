//
//  CalculatorView.h
//  Calculator
//
//  Created by Rainer Burgstaller on 14.07.12.
//  Copyright (c) 2012 RealNetworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphDataSource

-(float) yValue:(GraphView*)view forX:(float)x;
-(NSString*) descriptionOfProgram;

@end

@interface GraphView : UIView

@property(nonatomic)float scale;
@property(nonatomic) CGPoint origin;
@property(nonatomic,weak) id<GraphDataSource> datasource;
@property(nonatomic,copy) NSString* defaultsPrefix;
@property(nonatomic) BOOL useDots;


@end
