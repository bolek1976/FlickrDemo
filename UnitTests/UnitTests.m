//
//  UnitTests.m
//  UnitTests
//
//  Created by Boris Chirino on 04/02/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BCFlickrOperation.h"
#import "BCGlobalConfig.h"
#import "BCNetworkManager.h"
#import "Constants.h"


@interface UnitTests : XCTestCase
@property (nonatomic, strong) NSData *sizesJson;
@property BCFlickrOperation *flickrOperation;
@end

@interface BCFlickrOperation (BCFlickrOperationXCTest)
-(void)parseResponseFor:(JSONResourceResult)parseType;
@end

@implementation UnitTests

- (void)setUp {
    [super setUp];
    self.sizesJson = [self mockJsonForSizes];
    
    NSError *serializationError = nil;
    id result = [NSJSONSerialization JSONObjectWithData:self.sizesJson
                                                options:NSJSONReadingAllowFragments
                                                  error:&serializationError];
    XCTAssert(result);
    self.flickrOperation = [BCFlickrOperation new];
    
    self.flickrOperation.result = [NSDictionary dictionaryWithDictionary:result];
    
    self.flickrOperation.predicate = @"XCTest-ID1287878";
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 * ============================================ IMPORTANT =============================================================
 * ======================================== CHECK THIS OUT LATER ======================================================
 * Writing this test found :
 *
 *  This test show a weak implementation on the BCFlickrOperation class, because the <parseResponseFor:> method its
 *  should be decoupled, this method should be moved to another class for two main reason
 *
 *  - private methods must be only for use of the class it belong to and that method most of the time does not need testcase,
 *    doing this create fragile test wich may be break even the class is working perfectly.
 *
 *  - moving this method to a separate class, allow the reuse of the code, increase cohesion and facilitate unit testing.
 *
 */
-(void)testFlickrOperationParseResponseFor{
    
    [self.flickrOperation parseResponseFor:JSONResourceResultSizes];
    
    NSAssert(self.flickrOperation.result!=nil, @"Parse sizes json failed");
    
    NSAssert(![self.flickrOperation.result[@"original"] isEqualToString:@""], @"- original - key on result is empty");
    
    NSAssert(![self.flickrOperation.result[@"thumbnail"] isEqualToString:@""], @"- thumbnail - key on result is empty");
    
    NSAssert([self.flickrOperation.result[@"photo_id"] isEqualToString:@"1287878"], @"- photo_id - key on result parsed incorrectly");
    
}

-(void)testBCGlobalConfigSingleton{
    XCTAssertNotNil([BCGlobalConfig shared]);    
    NSURL *baseUrl = [NSURL URLWithString:@"https://api.flickr.com/services/rest/"];
    XCTAssertEqualObjects([[BCGlobalConfig shared] baseURL].absoluteString, baseUrl.absoluteString);
}

-(void)testNetWorkManagerSingleton{
    XCTAssertNotNil( [BCNetworkManager shared]);
}

-(void)testWebServiceUserOperation{
    XCTestExpectation *expectation = [self expectationWithDescription:@"flickr.people.findByUsername"];
    
    BCFlickrOperation *userNameOperation = [[BCFlickrOperation alloc]
                                            initWithResource:@"flickr.people.findByUsername"
                                            predicate:@"username=bolek1976"];
    
    userNameOperation.completion = ^(NSDictionary *response, NSError *error){
        
        XCTAssertNotNil(response, "data should not be nil");
        
        XCTAssertNil(error, "error should be nil");
        
        XCTAssertEqual(response.count, 1);
        
        NSString *userID = response[@"user_id"];
        
        XCTAssertEqualObjects(userID, @"37580922@N02");
        
        [expectation fulfill];
    };
    
    [[[BCNetworkManager shared] operationCoordinator] addOperation:userNameOperation];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        NSLog(@"i've waited a long time, username test failed");
    }];
}


-(void)testWebServicePublicPhotosperation{
    XCTestExpectation *expectation = [self expectationWithDescription:@"flickr.people.getPublicPhotos"];
    
    BCFlickrOperation *photosOperation = [[BCFlickrOperation alloc]
                                          initWithResource:@"flickr.people.getPublicPhotos"
                                          predicate:@"user_id=37580922@N02"];
    
    photosOperation.completion = ^(NSDictionary *response, NSError *error){
        
        XCTAssertNotNil(response, "data should not be nil");
        
        XCTAssertNil(error, "error should be nil");
        
        NSArray *dd = response[@"photo_ids"];
        
        XCTAssertEqual([dd count], 19);
        
        [expectation fulfill];
    };
    
    [[[BCNetworkManager shared] operationCoordinator] addOperation:photosOperation];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        NSLog(@"i've waited a long time, username test failed");
    }];
}



-(NSData*)mockJsonForSizes{
    NSURL *jsonUrl = [[NSBundle mainBundle] URLForResource:@"sizes" withExtension:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonUrl];
    return jsonData;
}


@end
