//
//  SlangsViewModel.m
//  miewah-objc
//
//  Created by Christopher on 2018/5/4.
//  Copyright © 2018 wenyongyang. All rights reserved.
//

#import "SlangsViewModel.h"
#import "MiewahSlang.h"
#import "MiewahSlangRequesterManager.h"
#import "SlangListResponseObject.h"

@interface SlangsViewModel ()

@property (nonatomic, strong) id<MiewahListRequestProtocol> requester;

@end

@implementation SlangsViewModel

- (void)initializeObserverSignals {
    [super initializeObserverSignals];
    
    @weakify(self);
    self.requestSuccessHandler = ^(BaseResponseObject *payload) {
        @strongify(self);
        SlangListResponseObject *_payload = (SlangListResponseObject *)payload;
        
        // 最后一页
        self.noMoreData = [_payload.pages integerValue] == self.currentPage;
        
        [_payload.slangs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MiewahSlang *slang = [[MiewahSlang alloc] initWithDictionary:obj];
            [self.items addObject:slang];
        }];
        self.currentPage++;
        [self.loadedSuccess sendNext:nil];
    };
    
    [self resetFlags];
}

@synthesize requester = _requester;
- (id<MiewahListRequestProtocol>)requester {
    if (_requester == nil) {
        _requester = [[MiewahSlangRequesterManager alloc] init];
    }
    return _requester;
}

@end
