//
//  JPGAPIManager.m
//  Tournamentally
//
//  Created by John Goodchild on 11/18/17.
//  Copyright © 2017 John Goodchild. All rights reserved.
//

#import "JPGAPIManager.h"
#import "Reachability.h"
#import "NSError+JPGError.h"

typedef void(^AuthTokenBlock)(NSString *token, NSError *error);

static NSString * const kTournamentAuthTokenKey = @"X-Acme-Authentication-Token";
static NSString * const kTournamentAPIBaseURL = @"https://damp-chamber-22487.herokuapp.com/api/v1";
static NSString * const kTokenEndpoint = @"/authentications/tokens";
static NSString * const kTournamentsEndpoint = @"/tournaments";
static NSString * const kTournamentDataKey = @"data";

@interface JPGAPIManager ()

@property (strong, nonatomic) Reachability *reachability;
@property (copy, nonatomic) NSString *authToken;

@end

@implementation JPGAPIManager

#pragma mark - Public Methods

+ (JPGAPIManager *)sharedInstance {
    static JPGAPIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)participateInTournamentWithURL:(NSURL *)url completion:(TournamentParticipationBlock)completion {
    if (url == nil) {
        // The URL was nil. Return an error.
        completion(nil, [NSError errorWithCode:JPGErrorCodeTournamentParticipartionError]);
        return;
    }
    // Each request requires an auth token so we wrap the requests in a
    // call to get either a new token or the cached one.
    // The getAuthToken: method also checks the network state.
    [self getAuthToken:^(NSString *token, NSError *error) {
        if (error != nil) {
            // An error occurred while getting the auth token. Return the error.
            completion(nil, error);
            return;
        }
        
        // Configure the post request for tournament participation.
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // Define the request headers.
        NSDictionary *headers = @{kTournamentAuthTokenKey   : token,
                                  @"Content-Type"           : @"application/vnd.api+json"};
        configuration.HTTPAdditionalHeaders = headers;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:60.0];
        [request setHTTPMethod:@"POST"];
        
        // Define the session task and callback block.
        NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *postError) {
            if (postError != nil) {
                // There was an error with the request. Return the error.
                completion(nil, [NSError errorWithCode:JPGErrorCodeTournamentParticipartionError underlyingError:postError]);
                return;
            }
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger statusCode = httpResponse.statusCode;
            
            if (statusCode == 201 && data != nil) {
                // A success response was received. Decode the response data.
                NSError *decodeError = nil;
                NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&decodeError];
                if (decodeError != nil) {
                    // There was an error decoding the response data. Return the error.
                    completion(nil, [NSError errorWithCode:JPGErrorCodeTournamentParticipartionError underlyingError:decodeError]);
                    return;
                }
                if (parsedData == nil) {
                    completion(nil, [NSError errorWithCode:JPGErrorCodeTournamentParticipartionError]);
                    return;
                }
                
                // Load the tournament data into a dictionary.
                NSDictionary *parsedDict = parsedData[kTournamentDataKey];
                if (parsedDict == nil) {
                    // No data existed for the specified key. Return an error.
                    completion(nil, [NSError errorWithCode:JPGErrorCodeTournamentParticipartionError]);
                    return;
                }
                
                // Convert the dictionary into a JPGTournamentModel object.
                JPGTournamentModel *tournament = [[JPGTournamentModel alloc] initWithTournamentDictionary:parsedDict];
                // Invoke the callback with the tournament object.
                completion(tournament, nil);
                
            } else if (statusCode == 401) {
                // The authentication token was missing or invalid.
                // Clear the cached token so the next attempt can get a new one.
                self.authToken = nil;
                completion(nil, [NSError errorWithCode:JPGErrorCodeAuthTokenError]);
                return;
            } else {
                // Either the response data was missing or there was another error.
                completion(nil, [NSError errorWithCode:JPGErrorCodeUnknown]);
                return;
            }
            
        }];
        
        // Execute the session task.
        [postDataTask resume];
    }];
}

- (void)getTournamentList:(TournamentListBlock)completion {
    // Each request requires an auth token so we wrap the requests in a
    // call to get either a new token or the cached one.
    // The getAuthToken: method also checks the network state.
    [self getAuthToken:^(NSString *token, NSError *error) {
        if (error != nil) {
            // An error occurred while getting the auth token. Return the error.
            completion(nil, error);
            return;
        }
        
        // Configure the get request for getting the tournament list.
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // Define the request headers.
        NSDictionary *headers = @{kTournamentAuthTokenKey   : token,
                                  @"Content-Type"           : @"application/vnd.api+json"};
        configuration.HTTPAdditionalHeaders = headers;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        // Construct the URL.
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kTournamentAPIBaseURL, kTournamentsEndpoint]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:60.0];
        [request setHTTPMethod:@"GET"];
        
        // Define the session task and callback block.
        NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *getError) {
            if (getError != nil) {
                // There was an error with the request. Return the error.
                completion(nil, [NSError errorWithCode:JPGErrorCodeTournamentListError underlyingError:getError]);
                return;
            }
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger statusCode = httpResponse.statusCode;
            
            if (statusCode == 200 && data != nil) {
                // A success response was received. Decode the response data.
                NSError *decodeError = nil;
                NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&decodeError];
                if (decodeError != nil) {
                    // There was an error decoding the response data. Return the error.
                    completion(nil, [NSError errorWithCode:JPGErrorCodeTournamentListError underlyingError:decodeError]);
                    return;
                }
                if (parsedData == nil) {
                    // Decoding the tournament data yielded no result. Return an error.
                    completion(nil, [NSError errorWithCode:JPGErrorCodeTournamentListError]);
                    return;
                }
                
                // Load the tournament data into an array.
                NSArray *parsedArray = parsedData[kTournamentDataKey];
                if (parsedArray == nil) {
                    // No data existed for the specified key. Return an error.
                    completion(nil, [NSError errorWithCode:JPGErrorCodeTournamentListError]);
                    return;
                }
                
                NSMutableArray *tournaments = [NSMutableArray array];
                // Enumerate through the array of tournament dictionary objects and
                // convert them into JPGTournamentModel objects.
                [parsedArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull tournDict, NSUInteger idx, BOOL * _Nonnull stop) {
                    JPGTournamentModel *tournament = [[JPGTournamentModel alloc] initWithTournamentDictionary:tournDict];
                    [tournaments addObject:tournament];
                    tournament = nil;
                }];
                
                // Invoke the callback with the tournament array.
                completion(tournaments, nil);
                
            } else if (statusCode == 401) {
                // The authentication token was missing or invalid.
                // Clear the cached token so the next attempt can get a new one.
                self.authToken = nil;
                completion(nil, [NSError errorWithCode:JPGErrorCodeAuthTokenError]);
                return;
            } else {
                // Either the response data was missing or there was another error.
                completion(nil, [NSError errorWithCode:JPGErrorCodeUnknown]);
                return;
            }
            
        }];
        
        // Execute the session task.
        [getDataTask resume];
    }];
}

#pragma mark - Private Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set the host name to be used for network access checks.
        _reachability = [Reachability reachabilityWithHostName:@"damp-chamber-22487.herokuapp.com"];
        // Set the cached auth token to nil.
        _authToken = nil;
    }
    return self;
}

/**
 Helper method to determine the current network state.

 @return A boolean value represening whether or not the network is accessible.
 */
- (BOOL)networkIsReachable {
    return (self.reachability.currentReachabilityStatus != NotReachable);
}

/**
 Method used to get the auth token.

 @param completion The AuthTokenBlock callback block to be invoked when the request is complete.
 */
- (void)getAuthToken:(AuthTokenBlock)completion {
    // Check for network access.
    if (![[JPGAPIManager sharedInstance] networkIsReachable]) {
        // Network is unavailable. Return an error.
        completion(nil, [NSError errorWithCode:JPGErrorCodeNetworkUnavailable]);
        return;
    }
    
    // Check for cached auth token.
    if (self.authToken != nil) {
        // We have a cached auth token. Return it.
        completion(self.authToken, nil);
        return;
    }
    
    // Configure the post request for getting the authentication token.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kTournamentAPIBaseURL, kTokenEndpoint]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    // Define the session task and callback block.
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *postError) {
        if (postError != nil) {
            // There was an error with the request. Return the error.
            completion(nil, [NSError errorWithCode:JPGErrorCodeAuthTokenError underlyingError:postError]);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpResponse.statusCode;
        
        if (statusCode == 201 && data != nil) {
            // A success response was received. Decode the token data and cache it.
            self.authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            // Return the new auth token.
            completion(self.authToken, nil);
            return;
            
        } else {
            // Either the response data was missing or there was another error.
            completion(nil, [NSError errorWithCode:JPGErrorCodeAuthTokenError]);
            return;
        }
        
    }];
    
    // Execute the session task.
    [postDataTask resume];
}

@end
