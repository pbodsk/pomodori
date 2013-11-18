//
//  AppDelegate.m
//  Tomapple
//
//  Created by Peter Bødskov on 10/11/13.
//  Copyright (c) 2013 Peter Bødskov. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkController.h"
#import "UserInformation.h"

#define kInitialValue 25 * 60

@interface AppDelegate(){
    
}
@property  (nonatomic )NSInteger remainingTime;
@property (nonatomic, strong) NSTimer *pomodoroTimer;
@property (nonatomic, strong) NSTimer *networkTimer;
@property (nonatomic) BOOL inPauseMode;
@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, strong) NSArray *userNamesFromServer;
@property (nonatomic, strong) NSArray *userInformationsFromServer;
@property (nonatomic, strong) NSString *userName;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.remainingTime = kInitialValue;
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
    self.pauseButton.hidden = YES;
    self.inPauseMode = NO;
    //TODO, skal udvides så man selv kan sende et navn ind.
    self.userName = [[NSHost currentHost]name];
    
    self.networkController = [[NetworkController alloc]initWithDelegate:self];
    self.usersTable.delegate = self;
    self.usersTable.dataSource = self;
}

-(void) populateTimerLabelFromRemainingTime:(NSInteger)remainingTime {
    self.timerLabel.title = [self presentationStringFromRemainingTime:remainingTime];
}

-(NSString *)presentationStringFromRemainingTime:(NSInteger)remainingTime {
    NSInteger minutes = remainingTime / 60;
    NSInteger seconds = remainingTime - (minutes * 60);
    return [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
}

- (IBAction)startButtonTapped:(id)sender {
    [self sendUserInformationToServer];
    self.pomodoroTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    self.networkTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(sendUserInformationToServer) userInfo:nil repeats:YES];
    self.startButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

- (IBAction)resetButtonTapped:(id)sender {
    [self invalidateTimer];
    self.remainingTime = kInitialValue;
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
    self.pauseButton.hidden = YES;
    self.startButton.hidden = NO;
}

- (IBAction)pauseButtonTapped:(id)sender {
    if(! self.inPauseMode){
        [self invalidateTimer];
        self.inPauseMode = YES;
    } else {
        self.pomodoroTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        self.inPauseMode = NO;
    }
}

-(void)invalidateTimer {
    [self.pomodoroTimer invalidate];
    self.pomodoroTimer = nil;
}

-(void)updateTimer:(NSTimer *)timer {
    if(self.remainingTime > 0){
        self.remainingTime -= 1;
    } else {
        [self.pomodoroTimer invalidate];
        self.pomodoroTimer = nil;
    }
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
}

- (void)sendUserInformationToServer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UserInformation *userInformation = [[UserInformation alloc]initWithUserName:self.userName remainingTime:self.remainingTime];
    [self.networkController sendUserInformation:userInformation];
}

#pragma mark - NetworkControllerDelegate methods
-(void)networkController:(NetworkController *)networkController didReceiveUserNames:(NSArray *)userNames andUserInformations:(NSArray *)userInformations {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.userNamesFromServer = userNames;
    self.userInformationsFromServer = userInformations;
    [self.usersTable reloadData];
}

#pragma mark - NSTableViewDataSource methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.userNamesFromServer.count;
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if([tableColumn.identifier isEqualToString:@"userName"]){
        return [self.userNamesFromServer objectAtIndex:row];
    } else {
        UserInformation *currentUser = [self.userInformationsFromServer objectAtIndex:row];
        return [self presentationStringFromRemainingTime:currentUser.remainingTime];
    }
}

#pragma mark - NSTableViewDelegate methods

@end
