//
//  BCBaseOperation.m
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import "BCBaseOperation.h"
#import "BCGlobalConfig.h"


@interface BCBaseOperation ()


@end

@implementation BCBaseOperation

//abstract
- (instancetype)initWithResource:(NSString*)resource predicate:(NSString*)predicate
{
    return nil;
};

- (instancetype)init
{
    self = [super init];
    if (self) {
        _session = [[BCGlobalConfig shared] session];
        _isOperationExecuting = NO;
        _isOperationFinished = NO;
    }
    return self;
}

- (BOOL) isConcurrent {
    return YES;
}

- (void) start {
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        [self finish];
        return;
    }
    
    //DLog(@"opeartion started");
    [self willChangeValueForKey:@"isExecuting"];
    self.isOperationExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
}

- (void) finish {
    //DLog(@"Ending operation now");
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.isOperationExecuting = NO;
    self.isOperationFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished{
    return self.isOperationFinished ? YES : NO;
//    if (self.isOperationExecuting) {
//        return NO;
//    }else
//        return YES;
}

- (BOOL)isExecuting{
    
    return self.isOperationExecuting ? YES : NO;
}

- (void) cancel {
    [super cancel];
    if (self.isExecuting) {
        [self finish];
    }
}

- (NSString *)operationID{
    NSString *opID = nil;
    @synchronized(self) {
        opID = [self.predicate stringByReplacingCharactersInRange:NSMakeRange(0, 9) withString:@""];
    }
    return opID;
}

@end
