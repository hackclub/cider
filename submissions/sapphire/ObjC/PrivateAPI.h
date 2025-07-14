//
//  PrivateAPI.h
//  DynamicNotch
//

#ifndef PrivateAPI_h
#define PrivateAPI_h

#import <CoreGraphics/CoreGraphics.h>
#import <IOKit/hidsystem/IOHIDEventSystemClient.h>

// This is the private function to disable the native macOS bezel HUDs
// for volume, brightness, etc.
void CGSSetBezelHUDEnabled(bool enabled);

// These are private functions for getting and setting the keyboard backlight brightness.
void HIDPostRequest(uint32_t a, uint32_t b, uint32_t c);
uint32_t HIDGetRequest(uint32_t a, uint32_t b);

#endif /* PrivateAPI_h */
