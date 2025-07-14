//
//  UNMutableNotificationContent.h
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-30.
//


#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface UNMutableNotificationContent (NDPrivateAPIs)
@property BOOL hasDefaultAction;
@end

@interface NDNotificationCenterHackery : NSObject

+ (void)removeDefaultAction:(UNMutableNotificationContent*) content;

@end

NS_ASSUME_NONNULL_END