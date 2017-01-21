//
//  EditTableViewController.m
//  Application
//
//  Created by Vladyslav Kudelia on 14.09.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "EditTableViewController.h"
#import "ImageDetailTableViewController.h"

@interface EditTableViewController() <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *carImage;
@property (weak, nonatomic) IBOutlet UITextField *markTextField;
@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation EditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"Profile %@", _car.mark];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table"]];
    
    _markTextField.delegate = self;
    _modelTextField.delegate = self;
    _yearTextField.delegate = self;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.tableView.frame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.carImage.image = _car.image;
    self.markTextField.text = _car.mark;
    self.modelTextField.text = _car.model;
    self.yearTextField.text = [NSString stringWithFormat:@"%li", (long)_car.year];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _car.image = self.carImage.image;
    _car.mark = self.markTextField.text;
    _car.model = self.modelTextField.text;
    _car.year = [self.yearTextField.text integerValue];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
        
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:true completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    _car.image = image;
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToDetail"]) {
        ImageDetailTableViewController *vc = segue.destinationViewController;
        vc.car = _car;
    }
}


@end
