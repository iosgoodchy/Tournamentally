//
//  NSError+JPGError.h
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const kJPGErrorDomain;

/**
 Enumerated list of error code types.
 */
typedef NS_ENUM(NSUInteger, JPGErrorCode) {
    // The error is unknown.
    JPGErrorCodeUnknown,
    // There was an error with the auth token.
    JPGErrorCodeAuthTokenError,
    // There was an error getting the tournament list.
    JPGErrorCodeTournamentListError,
    // There was an error participating in a tournament.
    JPGErrorCodeTournamentParticipartionError,
    // The network is unavailable.
    JPGErrorCodeNetworkUnavailable,
};

/**
 Category of NSError for JPGError types.
 */
@interface NSError (JPGError)

/**
 Returns an error object for the supplied error code.

 @param code JPGErrorCode to apply to the NSError object.
 @return Custom NSError object.
 */
+ (instancetype _Nullable)errorWithCode:(JPGErrorCode)code;

/**
 Returns an error object for the supplied error code with optional userInfo.

 @param code JPGErrorCode to apply to the NSError object.
 @param dict Dictionary of user info (if required).
 @return Custom NSError object.
 */
+ (instancetype _Nullable)errorWithCode:(JPGErrorCode)code userInfo:(NSDictionary * _Nullable)dict;

/**
 Returns an error object with a user dictionary configured for the supplied error code.

 @param code JPGErrorCode to apply to the NSError object.
 @param underlyingError Accompanying NSError (if required).
 @return Custom NSError object.
 */
+ (instancetype _Nullable)errorWithCode:(JPGErrorCode)code underlyingError:(NSError * _Nullable)underlyingError;

@end
