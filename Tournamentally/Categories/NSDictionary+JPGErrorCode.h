//
//  NSDictionary+JPGErrorCode.h
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSError+JPGError.h"

/**
 Category of NSDictionary to build JPGError user info dictionary data.
 */
@interface NSDictionary (JPGErrorCode)

/**
 Returns user info dictionary configured for the supplied error code

 @param errorCode JPGErrorCode to apply to the user info dictionary object.
 @param underlyingError Accompanying NSError (if required)
 @return A dictionary object containing user info.
 */
+ (NSDictionary * _Nullable)userInfoDictionaryForErrorCode:(JPGErrorCode)errorCode underlyingError:(NSError * _Nullable)underlyingError;

@end
