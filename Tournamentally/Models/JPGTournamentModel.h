//
//  JPGTournamentModel.h
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPGTournamentModel : NSObject

/**
 The unique identifier of the tournament (read-only).
 */
@property (copy, nonatomic, readonly) NSString *tournamentID;

/**
 The type of the tournament data (read-only).
 */
@property (copy, nonatomic, readonly) NSString *tournamentType;

/**
 The name of the tournament (read-only).
 */
@property (copy, nonatomic, readonly) NSString *tournamentName;

/**
 The tournament welcome message (read-only).
 */
@property (copy, nonatomic, readonly) NSString *tournamentMessage;

/**
 The URL used to participate in the tournament (read-only).
 */
@property (strong, nonatomic, readonly) NSURL *tournamentParticipationURL;

/**
 The URL of the tournament (read-only).
 */
@property (strong, nonatomic, readonly) NSURL *tournamentURL;

/**
 The tournament creation date (read-only).
 */
@property (strong, nonatomic, readonly) NSDate *tournamentCreationDate;


/**
 Initialization method of the JPGTournamentModel class.
 If you wish, you can choose to use init instead, but
 you will have to load the properties by calling the
 parseTournamentDictionary: method.

 @param dict A dictionary of tournament data to be parsed
 by the JPGTournamentModel class.
 @return A fully initialized JPGTournamentModel object populated
 with data from the dictionary parameter.
 */
- (instancetype)initWithTournamentDictionary:(NSDictionary *)dict;

/**
 Method used to populate and empty JPGTournamentModel object
 or to replace the existing property values.

 @param dict A dictionary of tournament data to be parsed
 by the JPGTournamentModel class.
 */
- (void)parseTournamentDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
