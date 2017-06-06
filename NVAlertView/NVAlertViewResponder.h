//
//  NVAlertViewResponder.h
//  NVAlertView
//
//  Created by Diogo Autilio on 9/26/14.
//  Copyright (c) 2014-2016 AnyKey Entertainment. All rights reserved.
//

#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif
#import "NVAlertView.h"

@interface NVAlertViewResponder : NSObject

/** TODO
 *
 * TODO
 */
- (instancetype)init:(NVAlertView *)alertview;

/** TODO
 *
 * TODO
 */
- (void)close;

@end
