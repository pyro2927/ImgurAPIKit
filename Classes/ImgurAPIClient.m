//
//  ImgurAPIClient.m
//  Orangered
//
//  Created by Joseph Pintozzi on 11/2/13.
//  Copyright (c) 2013 Joseph Pintozzi. All rights reserved.
//

#import "ImgurAPIClient.h"

@implementation ImgurAPIClient

- (id)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret{
    return [super initWithBaseURL:[NSURL URLWithString:@"https://api.imgur.com/"]];
}

- (id)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret mashapeKey:(NSString*)mashapeKey{
    if (self = [self initWithBaseURL:[NSURL URLWithString:@"https://imgur-apiv3.p.mashape.com/"] clientId:clientId clientSecret:clientSecret])
	{
        [self.requestSerializer setValue:mashapeKey forHTTPHeaderField:@"X-Mashape-Authorization"];
	}
    return self;
}

- (id)initWithBaseURL:(NSURL *)url clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestSerializer setValue:[@"Client-ID " stringByAppendingString:clientId] forHTTPHeaderField:@"Authorization"];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.clientId = clientId;
    self.clientSecret = clientSecret;
    return self;
}

#pragma mark IAKLogin

- (NSURL *)oauthURLWithRedirectURI:(NSString *)redirectURI{
    NSParameterAssert(redirectURI);
    NSAssert(_clientId != nil, @"You must first set a clientId");
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.imgur.com/oauth2/authorize?response_type=token&client_id=%@", _clientId]];
}

- (AFHTTPRequestOperation *)refreshAccessToken:(NSString*)refreshToken completion:(IAKResponseCompletionBlock)completion{
    
    return [self POST:@"https://api.imgur.com/oauth2/token" parameters:@{@"refresh_token": refreshToken, @"client_id": _clientId, @"client_secret": _clientSecret, @"grant_type": @"refresh_token"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)refreshAccessToken{
    [self refreshAccessToken:_refreshToken completion:^(id responseObject, NSError *error) {
        if (error) {
//            TODO: handle failed reponse
            NSLog(@"Error refreshing access token: %@", error.localizedDescription);
        } else {
            [self configureWithResponseDictionary:responseObject];
        }
    }];
}

- (void)configureWithResponseDictionary:(NSDictionary*)responseDictionary{
    NSParameterAssert(responseDictionary);
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        _refreshTimer = nil;
    }
    int expiresIn = [responseDictionary[@"expires_in"] intValue];
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:expiresIn - 20 target:self selector:@selector(refreshAccessToken) userInfo:Nil repeats:YES];
    _accessToken = responseDictionary[@"access_token"];
    _username = responseDictionary[@"account_username"];
    _refreshToken = responseDictionary[@"refresh_token"];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];
}

#pragma mark IAK File Uploads

/*
 Sample response
 
 {
 data =     {
 animated = 0;
 bandwidth = 0;
 datetime = 1383429956;
 deletehash = 0n3SWOXM9mLlZHT;
 description = "<null>";
 favorite = 0;
 height = 503;
 id = lScQoHg;
 link = "http://i.imgur.com/lScQoHg.jpg";
 nsfw = "<null>";
 section = "<null>";
 size = 56873;
 title = "<null>";
 type = "image/jpeg";
 views = 0;
 width = 1240;
 };
 status = 200;
 success = 1;
 }
 */

- (void)uploadImageWithFileUrl:(NSURL*)fileUrl completionBlock:(IAKUploadCompletionBlock)completionBlock{
    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
    NSString *filePath = [fileUrl absoluteString];
    NSString *fileName = [[filePath componentsSeparatedByString:@"/"] lastObject];
    NSString *mimeType = [@"image/" stringByAppendingString:[[filePath componentsSeparatedByString:@"."] lastObject]];
    [self uploadImageWithData:fileData fileName:fileName mimeType:mimeType completionBlock:completionBlock];
}

- (void)uploadImageWithImageData:(NSData*)imageData completionBlock:(IAKUploadCompletionBlock)completionBlock{
    [self uploadImageWithData:imageData fileName:@"image.jpg" mimeType:@"image/jpg" completionBlock:completionBlock];
}

- (void)uploadImageWithData:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType completionBlock:(IAKUploadCompletionBlock)completionBlock{
    [self POST:@"/3/upload.json" parameters:@{@"type": @"file"} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"image" fileName:fileName mimeType:mimeType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Image uploaded!");
        completionBlock(YES, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed image upload :(");
        completionBlock(NO, nil, error);
    }];
}

@end
