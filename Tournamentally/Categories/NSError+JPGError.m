//
//  NSError+JPGError.h
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import "NSError+JPGError.h"
#import "NSDictionary+JPGErrorCode.h"

// The Tournamentally error domain.
NSString * const kJPGErrorDomain = @"com.iosgoodch.TournamentallyErrorDomain";

@implementation NSError (JPGError)

+ (instancetype _Nullable)errorWithCode:(JPGErrorCode)code {
    return [NSError errorWithCode:code underlyingError:nil];
}

+ (instancetype)errorWithCode:(JPGErrorCode)code userInfo:(NSDictionary *)dict {
    return [NSError errorWithDomain:kJPGErrorDomain code:code userInfo:dict];
}

+ (instancetype)errorWithCode:(JPGErrorCode)code underlyingError:(NSError *)underlyingError {
    NSDictionary *userInfo = [NSDictionary userInfoDictionaryForErrorCode:code underlyingError:underlyingError];
    return [NSError errorWithCode:code userInfo:userInfo];
}

@end
