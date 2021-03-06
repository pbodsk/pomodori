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
#import "PreferenceWindowController.h"

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
@property (nonatomic, strong) UserInformation *userInformation;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self customizeAppearance];
    [self initializeRemainingTime];
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
    self.pauseButton.hidden = YES;
    self.inPauseMode = NO;
    
    [self updateUserNameFromUserPreferences];
    
    self.networkController = [[NetworkController alloc]initWithDelegate:self];
    self.usersTable.delegate = self;
    self.usersTable.dataSource = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(preferencesWasUpdated) name:kPreferencesWasUpdatedNotification object:nil];
    
    
}

- (void)customizeAppearance {
    self.window.backgroundColor = [NSColor colorWithCalibratedRed:247.0/255.0 green:99.0/255.0 blue:92.0/255.0 alpha:1.0];
    NSColor *buttonColor = [NSColor colorWithCalibratedRed:185.0/255.0 green:217.0/255.0 blue:176.0/255.0 alpha:1.0];
    [self.startButton.cell setBackgroundColor:buttonColor];
    [self.resetButton.cell setBackgroundColor:buttonColor];
    [self.pauseButton.cell setBackgroundColor:buttonColor];
} 

- (void)initializeRemainingTime {
    NSString *minutesFromPreference = [[NSUserDefaults standardUserDefaults]objectForKey:PMDRPrefPomodorLengthKey];
    NSInteger remainingTime = [minutesFromPreference integerValue] * 60;
    self.remainingTime = remainingTime;
}

-(void) populateTimerLabelFromRemainingTime:(NSInteger)remainingTime {
    self.timerLabel.title = [self presentationStringFromRemainingTime:remainingTime];
}

-(NSString *)presentationStringFromRemainingTime:(NSInteger)remainingTime {
    NSInteger minutes = remainingTime / 60;
    NSInteger seconds = remainingTime - (minutes * 60);
    return [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
}

- (void)updateUserNameFromUserPreferences {
    self.userName = [[NSUserDefaults standardUserDefaults]objectForKey:PMDRPrefUserNameKey];
}

- (IBAction)startButtonTapped:(id)sender {
    [self initializeRemainingTime];
    self.userInformation = [[UserInformation alloc]initWithUserName:self.userName remainingTime:self.remainingTime];
    self.userInformation.pomodoroStatus = UserInformationPomodoroStatusActive;
    [self sendUserInformationToServer];
    [self startTimers];
    self.startButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

- (IBAction)resetButtonTapped:(id)sender {
    self.userInformation.pomodoroStatus = UserInformationPomodoroStatusDone;
    [self initializeRemainingTime];
    [self sendUserInformationToServer];
    [self invalidateTimers];
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
    self.pauseButton.hidden = YES;
    self.startButton.hidden = NO;
}

- (IBAction)pauseButtonTapped:(id)sender {
    if(! self.inPauseMode){
        self.inPauseMode = YES;
        [self.pauseButton setTitle:@"Resume"];
        self.userInformation.pomodoroStatus = UserInformationPomodoroStatusPaused;
        [self sendUserInformationToServer];
        [self invalidateTimers];
    } else {
        self.inPauseMode = NO;
        [self.pauseButton setTitle:@"Pause"];
        self.userInformation.pomodoroStatus = UserInformationPomodoroStatusActive;
        [self startTimers];
        [self sendUserInformationToServer];
    }
}

- (void)startTimers {
    self.pomodoroTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    self.networkTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(sendUserInformationToServer) userInfo:nil repeats:YES];
}

-(void)invalidateTimers {
    [self.pomodoroTimer invalidate];
    self.pomodoroTimer = nil;
    [self.networkTimer invalidate];
    self.networkTimer = nil;
}

-(void)updateTimer:(NSTimer *)timer {
    if(self.remainingTime > 0){
        self.remainingTime -= 1;
    } else {
        self.userInformation.pomodoroStatus = UserInformationPomodoroStatusDone;
        [self sendUserInformationToServer];
        [self invalidateTimers];
        [self postNotification];
    }
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
}

- (void)postNotification {
    NSUserNotification *pomodoroDoneNotification = [NSUserNotification new];
    pomodoroDoneNotification.title = @"Time's up";
    pomodoroDoneNotification.informativeText = @"Well done, your pomodoro session is done. Time for a quick break";
    pomodoroDoneNotification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:pomodoroDoneNotification];
}

- (void)sendUserInformationToServer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.userInformation.remainingTime = self.remainingTime;
    self.userInformation.userName = self.userName;
    [self.networkController sendUserInformation:self.userInformation];
}

- (void)preferencesWasUpdated {
    [self updateUserNameFromUserPreferences];
    [self initializeRemainingTime];
    [self populateTimerLabelFromRemainingTime:self.remainingTime];
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
    UserInformation *currentUser = [self.userInformationsFromServer objectAtIndex:row];
    if([tableColumn.identifier isEqualToString:@"userName"]){
        return [self.userNamesFromServer objectAtIndex:row];
    }
    
    if([tableColumn.identifier isEqualToString:@"remainingTime"]){
        return [self presentationStringFromRemainingTime:currentUser.remainingTime];
    }
    
    if([tableColumn.identifier isEqualToString:@"status"]) {
        return [currentUser presentationStringForPomodoroStatus:currentUser.pomodoroStatus];
    }
    return @"";
}

#pragma mark - NSTableViewDelegate methods

#pragma mark - All done
-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObject:self];
}

@end
