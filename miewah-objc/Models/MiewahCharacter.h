//
//  MiewahCharacter.h
//  miewah-objc
//
//  Created by Christopher on 2018/5/1.
//  Copyright © 2018 wenyongyang. All rights reserved.
//

#import "MiewahModel.h"

@interface MiewahCharacter : MiewahModel

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, copy) NSString *character;
@property (nonatomic, copy) NSString *pronunciation;
@property (nonatomic, copy) NSString *meaning;

@property (nonatomic, copy) NSString *inputMethods;
@property (nonatomic, copy) NSString *sentences;
@property (nonatomic, copy) NSString *pronunciationVoice;

- (NSDictionary *)deSerializeInputMethods;
- (NSString *)prettifiedInputMethods;

@end
