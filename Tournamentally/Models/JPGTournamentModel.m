//
//  JPGTournamentModel.m
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import "JPGTournamentModel.h"

// Dictionary key constants.
static NSString * const kTournIdKey = @"id";
static NSString * const kTournTypeKey = @"type";
static NSString * const kTournLinksKey = @"links";
static NSString * const kTournEnterUrlKey = @"enter_tournament";
static NSString * const kTournUrlKey = @"self";
static NSString * const kTournAttrKey = @"attributes";
static NSString * const kTournNameKey = @"name";
static NSString * const kTournTimestampKey = @"created_at";
static NSString * const kTournMessageKey = @"entry_message";

@interface JPGTournamentModel ()

// Read-write counterparts to the public facing read-only properties.
@property (copy, nonatomic, readwrite) NSString *tournamentID;
@property (copy, nonatomic, readwrite) NSString *tournamentType;
@property (copy, nonatomic, readwrite) NSString *tournamentName;
@property (copy, nonatomic, readwrite) NSString *tournamentMessage;
@property (strong, nonatomic, readwrite) NSURL *tournamentParticipationURL;
@property (strong, nonatomic, readwrite) NSURL *tournamentURL;
@property (strong, nonatomic, readwrite) NSDate *tournamentCreationDate;

@end

@implementation JPGTournamentModel

#pragma mark - Public Methods

- (instancetype)initWithTournamentDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self parseTournamentDictionary:dict];
    }
    return self;
}

- (void)parseTournamentDictionary:(NSDictionary *)dict {
    if (dict != nil) {
        // Set the tournament ID.
        _tournamentID = dict[kTournIdKey];
        // Set the tournament type.
        _tournamentType = dict[kTournTypeKey];
        // Load the link data into a dictionary.
        NSDictionary *linkDict = dict[kTournLinksKey];
        if (linkDict != nil) {
            // Set the tournament participation URL.
            _tournamentParticipationURL = [NSURL URLWithString:(linkDict[kTournEnterUrlKey] ?: @"")];
            // Set the tournament URL.
            _tournamentURL = [NSURL URLWithString:(linkDict[kTournUrlKey] ?: @"")];
        }
        // Load the attribute data into a dictionary.
        NSDictionary *attrDict = dict[kTournAttrKey];
        if (attrDict != nil) {
            // Set the tournament name.
            _tournamentName = attrDict[kTournNameKey];
            // Get the tournament timestamp for date parsing.
            NSString *timestampString = attrDict[kTournTimestampKey];
            if (timestampString != nil) {
                // Convert ISO 8601 date format string to NSDate object.
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"]; // example: 2017-08-29T15:00:00.000Z
                NSDate *formattedDate = [formatter dateFromString:timestampString];
                // Set the tournament creation date.
                _tournamentCreationDate = formattedDate;
            }
            // Set the tournament welcome message.
            _tournamentMessage = attrDict[kTournMessageKey];
        }
    }
}

@end
