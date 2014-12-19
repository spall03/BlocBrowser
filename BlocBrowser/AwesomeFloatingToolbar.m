//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Stephen Palley on 12/17/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"



@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UILabel *currentButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end


@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
//            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex]; //assign titles and colors to buttons
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:colorForThisButton];
            
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton]; //add label views to main view
        }
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
        
        
    }
    
    return self;
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self]; //resets translation calc
    }
}


- (void) tapFired:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.buttons containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)tappedView).titleLabel.description];
            }
        }
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint pinch = [recognizer locationInView:self];
        CGFloat scale = [recognizer scale];
        NSLog(@"New pinch: %@", NSStringFromCGPoint(pinch));
        NSLog(@"New scale: %lf", scale);
        UIView *tappedView = [self hitTest:pinch withEvent:nil];
        
        if ([tappedView isEqual:self]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchToolbar:)]) {
                [self.delegate floatingToolbar:self didPinchToolbar:scale];
                
            }
        }
        
        
    
    
    
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"gesture is over, %@", NSStringFromCGRect(self.frame));
    }
    
}

- (void) longPressFired:(UILongPressGestureRecognizer *) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [recognizer locationInView:self];
        NSLog(@"New long press: %@", NSStringFromCGPoint(location));
        [self randomizeColors];
    }
    
}

- (void) randomizeColors {
    
    for (UILabel *thisButton in self.buttons)
    {

        CGFloat randomRedValue = (20 + (arc4random() % 200))/255.0; //pick colors such that text is still readable
        CGFloat randomGreenValue = (20 + (arc4random() % 200))/255.0;
        CGFloat randomBlueValue = (20 + (arc4random() % 200))/255.0;
        
        UIColor *newColor = [UIColor colorWithRed:randomRedValue green:randomGreenValue blue:randomBlueValue alpha:1]; //create new random color
        
        [thisButton setBackgroundColor:newColor];
        
    }
    
    
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // set the frames for the 4 labels
        
        for (UIButton *thisButton in self.buttons) {
            NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
            
            CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2; //split view up 2x2
            CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
            CGFloat buttonX = 0;
            CGFloat buttonY = 0;
            
            // adjust labelX and labelY for each label
            if (currentButtonIndex < 2) {
                // 0 or 1, so on top
                buttonY = 0;
            } else {
                // 2 or 3, so on bottom
                buttonY = CGRectGetHeight(self.bounds) / 2;
            }
            
            if (currentButtonIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
                // 0 or 2, so on the left
                buttonX = 0;
            } else {
                // 1 or 3, so on the right
                buttonX = CGRectGetWidth(self.bounds) / 2;
            }
            
            [thisButton setFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
        }
    });

    
}

#pragma mark - Touch Handling

- (UIButton *) buttonFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject]; //grab a touch from set of touches
    CGPoint location = [touch locationInView:self]; //where was it?
    UIView *subview = [self hitTest:location withEvent:event]; //which label subview did it hit?
    return (UIButton *)subview;
}




#pragma mark - Button Enabling

//figure out which label got touched
- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.buttons objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}

@end
