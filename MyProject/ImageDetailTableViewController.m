//
//  ImageDetailTableViewController.m
//  Application
//
//  Created by Vladyslav Kudelia on 17.09.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "ImageDetailTableViewController.h"

@interface ImageDetailTableViewController() <UITextFieldDelegate ,NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *downloadingNewImage;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadPregressView;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *downloadingButtonOutlet;

@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation ImageDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Image setting";
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table"]];
    
    _urlTextField.delegate = self;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.tableView.frame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_downloadPregressView setHidden:true];
    _downloadingNewImage.image = _car.image;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _car.image = _downloadingNewImage.image;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    
    CGSize keyboardSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:true];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(_scrollView.contentInset.top, 0, keyboardSize.height, 0);
    _scrollView.contentInset = insets;
    _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x, _scrollView.contentOffset.y + keyboardSize.height);
    _scrollView.scrollIndicatorInsets = insets;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:true];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(_scrollView.contentInset.top, 0, 0, 0);
    _scrollView.contentInset = insets;
    _scrollView.scrollIndicatorInsets = insets;
    
    [UIView commitAnimations];
}


- (IBAction)downloadButtonAction:(UIButton *)sender {
    _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:_sessionConfiguration delegate:self delegateQueue:nil];
    _downloadTask = [_session downloadTaskWithURL:[NSURL URLWithString:_urlTextField.text]];
    [_downloadTask resume];
    
    [_downloadPregressView setHidden:false];
    [_downloadingButtonOutlet setHidden:true];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_downloadPregressView setHidden:true];
        [_downloadingButtonOutlet setHidden:false];
        [_downloadingNewImage setImage:[UIImage imageWithData:data]];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_downloadPregressView setProgress:progress];
    });
}

@end
