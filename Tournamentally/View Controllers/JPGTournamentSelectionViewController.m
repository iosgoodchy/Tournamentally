//
//  JPGTournamentSelectionViewController.m
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import "JPGTournamentSelectionViewController.h"
#import "JPGTournamentDetailViewController.h"
#import "JPGAPIManager.h"
#import "JPGTournamentModel.h"

static NSString * const kShowTournamentDetailSegueIdentifier = @"showDetail";

@interface JPGTournamentSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loadTournamentsButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (copy, nonatomic) NSArray *tournaments;

@end

@implementation JPGTournamentSelectionViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set the table view footer view to an empty view to hide empty cells.
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set the appropriate load/refresh button title.
    [self updateLoadButtonTitle];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowTournamentDetailSegueIdentifier]) {
        // Get the segue destination view controller.
        JPGTournamentDetailViewController *detailViewController = segue.destinationViewController;
        NSDictionary *segueDict = (NSDictionary *)sender;
        // Set the detail view tournament object.
        detailViewController.tournament = segueDict[@"tournament"];
        // Set the detail view title to the tournament name.
        detailViewController.navigationItem.title = segueDict[@"title"];
        // Override the back button title of the detail view.
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
        backButton.title = @"Back";
        self.navigationItem.backBarButtonItem = backButton;
    }
}

#pragma mark - Button Actions

- (IBAction)loadTournaments:(id)sender {
    if (self.tournaments.count > 0) {
        // Clear the old data and refresh the table view.
        // Shows the user visually that someting happened.
        self.tournaments = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // Disable the load/refresh button.
        self.loadTournamentsButton.enabled = NO;
        // Start animating the loading indicator.
        [self.loadingIndicator startAnimating];
    });
    
    // Invoke an API call to get a list or tournament objects.
    [[JPGAPIManager sharedInstance] getTournamentList:^(NSArray<JPGTournamentModel *> * _Nullable tournaments, NSError * _Nullable error) {
        if (error != nil) {
            // An error occurred. Display an alert.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:[NSString stringWithFormat:@"Could not load tournaments.\n\nError: %@", (error.localizedDescription ?: error)] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) { /* no action */ }]];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Stop animating the loading indicator.
                [self.loadingIndicator stopAnimating];
                // Enable the load/refresh button.
                self.loadTournamentsButton.enabled = YES;
                [self presentViewController:alert animated:YES completion:nil];
            });
            // Set the appropriate load/refresh button title.
            [self updateLoadButtonTitle];
            return;
        }
        // Cache the tournament data and refresh the table view.
        self.tournaments = tournaments;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            // Stop animating the loading indicator.
            [self.loadingIndicator stopAnimating];
            // Enable the load/refresh button.
            self.loadTournamentsButton.enabled = YES;
        });
        // Set the appropriate load/refresh button title.
        [self updateLoadButtonTitle];
    }];
}

#pragma mark - UI Helpers

/**
 Convenience method to update the load/refresh button title based on
 the existence of tournament data.
 */
- (void)updateLoadButtonTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadTournamentsButton.title = (self.tournaments.count > 0 ? @"Refresh" : @"Load");
    });
}

#pragma mark - Table View Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Lock down the table view selections to prevent multiple taps.
    tableView.allowsSelection = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        // Start animating the loading indicator.
        [self.loadingIndicator startAnimating];
    });
    // Get the appropriate tournament object.
    __block JPGTournamentModel *selectedTournament = self.tournaments[indexPath.row];
    // Invoke an API call to participate in the selected tournament.
    [[JPGAPIManager sharedInstance] participateInTournamentWithURL:selectedTournament.tournamentParticipationURL completion:^(JPGTournamentModel * _Nullable tournament, NSError * _Nullable error) {
        if (error == nil && tournament != nil) {
            // Invoke a segue to show details of the resulting tournament.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:kShowTournamentDetailSegueIdentifier sender:@{@"tournament" : tournament, @"title" : selectedTournament.tournamentName}];
            });
        } else {
            // An error occurred. Display an alert to the user.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:[NSString stringWithFormat:@"Could not participate in tournament.\n\nError: %@", (error.localizedDescription ?: error)] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) { /* no action */ }]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // Re-enable table view selections and deselect the row.
            tableView.allowsSelection = YES;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            // Stop animating the loading indicator.
            [self.loadingIndicator stopAnimating];
        });
    }];
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tournaments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellID = @"TournamentCellID";
    
    // Dequeue a table view cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    // Get the appropriate tournament object.
    JPGTournamentModel *tournament = self.tournaments[indexPath.row];
    // Populate the cell text label with the tournament name.
    cell.textLabel.text = [NSString stringWithFormat:@"Name: %@", tournament.tournamentName];
    
    // Convert the tournament creation date into a short date string.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.dateFormat = @"MM-dd-yyyy";
    NSString *dateString = [formatter stringFromDate:tournament.tournamentCreationDate];
    // Populate the cell detail label with the tournament creation date.
    cell.detailTextLabel.text = dateString;
    
    return cell;
}

@end
