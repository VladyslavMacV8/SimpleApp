//
//  ChatViewController.m
//  MyProject
//
//  Created by Vladyslav Kudelia on 15.10.16.
//  Copyright © 2016 Vladyslav Kudelia. All rights reserved.
//

#import "ChatViewController.h"
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "JSQMessagesCollectionViewFlowLayout.h"
#import "JSQMessages.h"
#import "JSQPhotoMediaItem.h"
#import "JSQLocationMediaItem.h"
#import "JSQVideoMediaItem.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesAvatarImageFactory.h"
#import <JSQMessagesBubbleImage.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <FirebaseStorage/FirebaseStorage.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import "zoomPopup.h"

@interface ChatViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageView;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageView;
@property (strong, nonatomic) FIRDatabaseReference *databaseReference;
@property (strong, nonatomic) NSString *convoId;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.senderDisplayName;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundChat"]];
    imageView.alpha = 0.5;
    
    self.collectionView.backgroundView = imageView;
    
    _messages = [NSMutableArray new];
    _databaseReference = [[FIRDatabase database] reference];
    
    [self setupBubbles];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    NSString *receiverId = [_receiverData objectForKey:@"uId"];
    NSString *receiverIdFive = [receiverId substringToIndex:5];
    
    NSString *senderIdFive = [self.senderId substringToIndex:5];
    
    if (senderIdFive > receiverIdFive) {
        _convoId = [NSString stringWithFormat:@"%@%@", senderIdFive, receiverIdFive];
    } else {
        _convoId = [NSString stringWithFormat:@"%@%@", receiverIdFive, senderIdFive];
    }

    [self observeMessages];
    
    
}

- (IBAction)backButtonAction:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *viewiewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeView"];
    [self presentViewController:viewiewController animated:true completion:nil];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _messages[indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _messages.count;
}

- (void)setupBubbles {
    JSQMessagesBubbleImageFactory *factory = [JSQMessagesBubbleImageFactory new];
    _outgoingBubbleImageView = [factory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    _incomingBubbleImageView = [factory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = _messages[indexPath.item];
    if (message.senderId == self.senderId) {
        return _outgoingBubbleImageView;
    } else {
        return _incomingBubbleImageView;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *message = _messages[indexPath.item];
    if (message.senderId == self.senderId) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = _messages[indexPath.row];
    id<JSQMessageMediaData> mediaItem = message.media;
    
    if ([mediaItem isKindOfClass:[JSQVideoMediaItem class]]) {
        JSQVideoMediaItem *mediaVideoItem = (JSQVideoMediaItem *)message.media;
        if (mediaVideoItem != nil) {
            AVPlayer *player = [AVPlayer playerWithURL:mediaVideoItem.fileURL];
            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
            playerViewController.player = player;
            [self presentViewController:playerViewController animated:true completion:nil];
        }
    } else if ([mediaItem isKindOfClass:[JSQPhotoMediaItem class]]) {
        JSQPhotoMediaItem *mediaPhotoItem = (JSQPhotoMediaItem *)message.media;
        if (mediaPhotoItem != nil) {
            UIImageView *image = [[UIImageView alloc] initWithImage:mediaPhotoItem.image];
            image.bounds = CGRectMake(0, 0, self.view.frame.size.width / 1.5, self.view.frame.size.height / 1.5);
            zoomPopup *popup = [[zoomPopup alloc] initWithMainview:self.view andStartRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0)];
            [popup showPopup:image];
        }
    }
}


- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    FIRDatabaseReference *itemReference = [[[_databaseReference child:@"message"] child:[NSString stringWithFormat:@"%@", _convoId]] childByAutoId];
    
    NSDictionary *messageItem = @{@"text":text, @"senderId":senderId, @"mediaType":@"TEXT"};
    [itemReference setValue:messageItem];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:true];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Send file" message:@"Appearance media files in messages depend of your internet speed" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *image = [UIAlertAction actionWithTitle:@"Image Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getMediaFrom:kUTTypeImage];
    }];
    UIAlertAction *video = [UIAlertAction actionWithTitle:@"Video Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getMediaFrom:kUTTypeMovie];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [sheet addAction:image];
    [sheet addAction:video];
    [sheet addAction:cancel];
    
    sheet.popoverPresentationController.sourceView = self.view;
    sheet.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMinX(self.view.frame), CGRectGetMaxY(self.view.frame), sheet.accessibilityFrame.size.width, sheet.accessibilityFrame.size.height);
    
    [self presentViewController:sheet animated:true completion:nil];
}

- (void)getMediaFrom:(CFStringRef)type {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.mediaTypes = @[(__bridge NSString *)type];
    [self presentViewController:picker animated:true completion:nil];
}

-(void)imageToFullScreen{
    
}

- (void)observeMessages {
    FIRDatabaseQuery *messagesQuery = [[_databaseReference child:[NSString stringWithFormat:@"message/%@", _convoId]] queryLimitedToLast:25];
    [messagesQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value[@"senderId"] != nil) {
            NSString *ID = snapshot.value[@"senderId"];
            NSString *mediaType = snapshot.value[@"mediaType"];
            
            if ([mediaType isEqual:@"TEXT"]) {
                NSString *text = snapshot.value[@"text"];
                [_messages addObject:[JSQMessage messageWithSenderId:ID displayName:@"" text:text]];
            } else if ([mediaType isEqual:@"PHOTO"]) {
                NSString *image = snapshot.value[@"fileUrl"];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:image]];
                JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:data]];
                [_messages addObject:[JSQMessage messageWithSenderId:ID displayName:@"" media:photoItem]];
            } else if ([mediaType isEqual:@"VIDEO"]) {
                NSString *video = snapshot.value[@"fileUrl"];
                JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:video] isReadyToPlay:true];
                [_messages addObject:[JSQMessage messageWithSenderId:ID displayName:@"" media:videoItem]];
            }
            
            [self finishReceivingMessageAnimated:true];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSURL *video = info[UIImagePickerControllerMediaURL];
    if (image != nil) {
        [self sendMedia:image and:nil];
    } else if (video != nil) {
        [self sendMedia:nil and:video];
    }
    [picker dismissViewControllerAnimated:true completion:nil];
    [self.collectionView reloadData];
}

- (void)sendMedia:(UIImage *)image and:(NSURL *)video {
    if (image != nil) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%f", [FIRAuth auth].currentUser, [NSDate date].timeIntervalSinceReferenceDate];
        NSData *data = UIImageJPEGRepresentation(image, 0.3);
        FIRStorageMetadata *metadata = [FIRStorageMetadata new];
        metadata.contentType = @"image/jpg";
        [[[[FIRStorage storage] reference] child:filePath] putData:data metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"%@", error.localizedDescription);
                return;
            }
            
            NSString *fileURL = [metadata downloadURLs][0].absoluteString;
            FIRDatabaseReference *newMessage = [[_databaseReference child:[NSString stringWithFormat:@"message/%@", _convoId]] childByAutoId];
            NSDictionary *messageItem = @{@"fileUrl":fileURL, @"senderId":self.senderId, @"mediaType":@"PHOTO"};
            [newMessage setValue:messageItem];
        }];
    } else if (video != nil) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%f", [FIRAuth auth].currentUser, [NSDate date].timeIntervalSinceReferenceDate];
        NSData *data = [NSData dataWithContentsOfURL:video];
        FIRStorageMetadata *metadata = [FIRStorageMetadata new];
        metadata.contentType = @"video/mp4";
        [[[[FIRStorage storage] reference] child:filePath] putData:data metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"%@", error.localizedDescription);
                return;
            }
            
            NSString *fileURL = [metadata downloadURLs][0].absoluteString;
            FIRDatabaseReference *newMessage = [[_databaseReference child:[NSString stringWithFormat:@"message/%@", _convoId]] childByAutoId];
            NSDictionary *messageItem = @{@"fileUrl":fileURL, @"senderId":self.senderId, @"mediaType":@"VIDEO"};
            [newMessage setValue:messageItem];
        }];
    }
}


@end
