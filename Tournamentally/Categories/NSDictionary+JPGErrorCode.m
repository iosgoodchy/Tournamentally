//
//  NSDictionary+JPGErrorCode.h
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import "NSDictionary+JPGErrorCode.h"

static NSString * const kJPGDefaultRecoverySuggestion = @"Please try again.";
static NSString * const kJPGErrorCodeNetworkUnavailableText = @"Unable to reach the network.";
static NSString * const kJPGErrorCodeNetworkUnavailableRecoverySuggestion = @"Please connect to a network and try again";

@implementation NSDictionary (JPGErrorCode)

+ (NSDictionary *)userInfoDictionaryForErrorCode:(JPGErrorCode)errorCode underlyingError:(NSError *)underlyingError {
    NSDictionary *userInfo = nil;
    switch (errorCode) {
        case JPGErrorCodeUnknown:
            break;
        case JPGErrorCodeAuthTokenError:
        case JPGErrorCodeTournamentListError:
        case JPGErrorCodeTournamentParticipartionError:
            userInfo = [NSDictionary userInfoDictionaryForUnderlyringError:underlyingError];
            break;
        case JPGErrorCodeNetworkUnavailable:
            userInfo = [NSDictionary userInfoDictionaryForLocalizedDescription:kJPGErrorCodeNetworkUnavailableText
                                                   localizedRecoverySuggestion:kJPGErrorCodeNetworkUnavailableRecoverySuggestion];
            break;
        default:
            break;
    }
    return userInfo;
}

/**
 Builds a user info dictionary containing a localized description and a localized recovery suggestion.
 */
+ (NSDictionary *)userInfoDictionaryForLocalizedDescription:(NSString *)localizedDescription
                                localizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion {
    return @{NSLocalizedDescriptionKey : localizedDescription, NSLocalizedRecoverySuggestionErrorKey : localizedRecoverySuggestion};
}

/**
 Builds a user info dictionary containing an underlying error, if provided.
 */
+ (NSDictionary *)userInfoDictionaryForUnderlyringError:(NSError *)error {
    if (error == nil) {
        return nil;
    }
    return @{NSUnderlyingErrorKey : error};
}

@end
