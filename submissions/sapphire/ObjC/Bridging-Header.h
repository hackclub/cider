//
//  Bridging-Header.h
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-02.
//

#import "NDNotificationCenterHackery.h"
#import <CoreGraphics/CoreGraphics.h>
int DisplayServicesGetBrightness(CGDirectDisplayID display, float *brightness);
int DisplayServicesSetBrightness(CGDirectDisplayID display, float brightness);
