//
//  AbstractJSONModel.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "AbstractModel.h"

@interface AbstractJSONModel : AbstractModel
- (void)synchronizeSource;
- (void)synchronizeSourceWithKey:(NSString *)key;
@end