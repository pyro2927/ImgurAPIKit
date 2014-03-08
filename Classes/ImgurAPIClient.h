//
//  ImgurAPIClient.h
//  Orangered
//
//  Created by Joseph Pintozzi on 11/2/13.
//  Copyright (c) 2013 Joseph Pintozzi. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

typedef void (^IAKUploadCompletionBlock)(BOOL success, NSDictionary *result, NSError *error);
typedef void (^IAKResponseCompletionBlock)(id responseObject, NSError *error);
typedef void (^IAKCompletionBlock)(NSError *error);

@interface ImgurAPIClient : AFHTTPRequestOperationManager

@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSTimer *refreshTimer;

- (id)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

//login
- (NSURL *)oauthURLWithRedirectURI:(NSString *)redirectURI;
- (AFHTTPRequestOperation *)refreshAccessToken:(NSString*)refreshToken completion:(IAKResponseCompletionBlock)completion;

// configure with response returned when requestion token type authentication
- (void)configureWithResponseDictionary:(NSDictionary*)responseDictionary;

//Upload files
- (void)uploadImageWithFileString:(NSString*)filePath completionBlock:(IAKUploadCompletionBlock)completionBlock;
- (void)uploadImageWithImageData:(NSData*)imageData completionBlock:(IAKUploadCompletionBlock)completionBlock;

@end