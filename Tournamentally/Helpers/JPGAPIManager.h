//
//  JPGAPIManager.h
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPGTournamentModel.h"

/**
 Tournament list request callback block.

 @param tournaments An array of JPGTournamentModel objects.
 @param error If an error occurred, the cause of the failure.
 */
typedef void(^TournamentListBlock)(NSArray<JPGTournamentModel *> * _Nullable tournaments, NSError * _Nullable error);

/**
 Tournament participation request callback block

 @param tournament The JPGTournamentModel object representing the tournament being joined.
 @param error If an error occurred, the cause of the failure.
 */
typedef void(^TournamentParticipationBlock)(JPGTournamentModel * _Nullable tournament, NSError * _Nullable error);

/**
 Main class for handling API calls.
 */
@interface JPGAPIManager : NSObject

/**
 Class method that returns a shared instance of the JPGAPIManager class.
 
 @return The shared instance of the JPGAPIManager singleton.
 */
+ (JPGAPIManager * _Nonnull)sharedInstance;

/**
 The init method should not be called directly. Use [JPGAPIManager sharedInstance] to access the singleton.
 */
- (instancetype _Nonnull)init __attribute__((unavailable("Do not initialilze the JPGAPIManager directly. Use [JPGAPIManager sharedInstance] to access the singleton.")));

/**
 Method used to get a list of available tournaments that a player can enter.

 @param completion The TournamentListBlock callback block to be invoked when the request is complete.
 */
- (void)getTournamentList:(TournamentListBlock _Nonnull)completion;

/**
 Method used to participate in a specific tournament.

 @param url The URL of the tournament to participate in.
 @param completion The TournamentParticipationBlock callback block to be invoked when the request is complete.
 */
- (void)participateInTournamentWithURL:(NSURL * _Nonnull)url completion:(TournamentParticipationBlock _Nonnull)completion;

@end
