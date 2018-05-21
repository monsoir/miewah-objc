//
//  MiewahWord.h
//  miewah-objc
//
//  Created by Christopher on 2018/5/2.
//  Copyright © 2018 wenyongyang. All rights reserved.
//

#import "MiewahAsset.h"

@interface MiewahWord : MiewahAsset

@property (nonatomic, copy) NSString *word;

@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *sentences;
@property (nonatomic, copy) NSString *pronunciationVoice;

@end
