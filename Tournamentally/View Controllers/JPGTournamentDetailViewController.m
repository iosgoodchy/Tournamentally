//
//  JPGTournamentDetailViewController.m
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import "JPGTournamentDetailViewController.h"

@interface JPGTournamentDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *participationLabel;

@end

@implementation JPGTournamentDetailViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Populate the detail view participation label with the welcome message.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.participationLabel.text = self.tournament.tournamentMessage;
    });
}

@end
