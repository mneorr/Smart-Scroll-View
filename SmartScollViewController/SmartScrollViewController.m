//
//  SmartScrollViewController.m
//
//  Created by Marin Usalj on 9/1/11.
//  Copyright (c) 2011 http://mneorr.com. All rights reserved.
//

#import "SmartScrollViewController.h"


@implementation SmartScrollViewController
@synthesize scrollView;

#pragma mark - Private

- (void)setUpScrollViewScrollingContent {
    scrollView.contentSize = scrollView.frame.size;
    scrollView.frame = self.view.bounds;
}

- (void)setUpScrollViewAutoresizingMask {
    scrollView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
}

- (void)listenToKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppeared:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDissapeared:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)listenToPickerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerAppeared:) name:@"UIPickerViewDidShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerDissapeared:) name:@"UIPickerViewDidHideNotification" object:nil];
}

- (void)stopListeningToAllNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGFloat)keyboardHeight:(NSNotification *) notification {
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        return [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    else return [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
}

- (CGFloat)keyboardAnimationDuration:(NSNotification *)notification {
    return [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
}

- (void)reduceScrollViewFrameByKeyboardHeight:(CGFloat) keyboardHeight {
    CGRect scrollViewFrame = scrollView.frame;
    scrollViewFrame.size.height -= keyboardHeight;
    scrollView.frame = scrollViewFrame;
}

- (void)restoreScrollViewFrameByKeyboardHeight:(CGFloat) keyboardHeight {
    CGRect scrollViewFrame = scrollView.frame;
    scrollViewFrame.size.height += keyboardHeight;
    scrollView.frame = scrollViewFrame;
}

- (void)animateWithDuration:(CGFloat)duration block:(void(^)(void))block {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    
    block();
    
    [UIView commitAnimations];
}



- (void)keyboardAppeared:(NSNotification *) notification {
    [self animateWithDuration:[self keyboardAnimationDuration:notification] block:^{
        [self reduceScrollViewFrameByKeyboardHeight:[self keyboardHeight:notification]];
        [scrollView scrollRectToVisible:[scrollView findFirstResponder].frame animated:NO];   
    }];
}

- (void)keyboardDissapeared:(NSNotification *) notification {
    [self animateWithDuration:[self keyboardAnimationDuration:notification] block:^{
        [self restoreScrollViewFrameByKeyboardHeight:[self keyboardHeight:notification]];
        [scrollView scrollRectToVisible:[scrollView findFirstResponder].frame animated:NO]; 
    }];
}

- (void)pickerAppeared: (NSNotification *) notification {
    [scrollView scrollRectToVisible:CGRectMake(0, 500, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
}

- (void)pickerDissapeared: (NSNotification *) notification {
    
}

- (void)adjustScrollViewFrameToViewFrameWithDuration:(CGFloat)duration {
    [self animateWithDuration:duration block:^{
        scrollView.frame = self.view.bounds;
        scrollView.bounds = self.view.bounds;
    }];
}

- (void)releaseScrollViewIfNotArc {
#ifdef OBJC_ARC_UNAVAILABLE
    [self setScrollView:nil];
#endif
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.scrollView];
    [self setUpScrollViewScrollingContent];    
    [self setUpScrollViewAutoresizingMask];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self listenToKeyboardNotifications];
    [self listenToPickerNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self stopListeningToAllNotifications];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [self releaseScrollViewIfNotArc];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self adjustScrollViewFrameToViewFrameWithDuration:duration];
}


#pragma mark - UITextField delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
