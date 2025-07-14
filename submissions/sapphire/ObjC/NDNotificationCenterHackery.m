//
//  NDNotificationCenterHackery.m
//  Sapphire
//
//  Created by Shariq Charolia on 2025-06-30.
//


#import <UserNotifications/UserNotifications.h>
#import "NDNotificationCenterHackery.h"

@implementation NDNotificationCenterHackery

+ (void)removeDefaultAction:(UNMutableNotificationContent*) content{
	content.hasDefaultAction = NO;
}

@end