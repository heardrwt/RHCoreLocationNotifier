//
//  RHCoreLocationNotifier.m
//  RHCoreLocationNotifier
//
//  Created by Richard Heard on 17/05/2014.
//  Copyright (c) 2014 Richard Heard. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "RHCoreLocationNotifier.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

NSString * const RHCoreLocationNotifierLocationChangedNotification = @"RHCoreLocationNotifierLocationChangedNotification";
NSString * const RHCoreLocationNotifierNewLocationKey = @"RHCoreLocationNotifierNewLocationKey";
NSString * const RHCoreLocationNotifierAllLocationsKey = @"RHCoreLocationNotifierAllLocationsKey";

extern BOOL RHCLNCallStackCurrentlyInsideCoreLocation();

static __strong CLLocation *_notifierLastKnownLocation;

@interface RHCoreLocationNotifierDelegateProxy : NSObject <CLLocationManagerDelegate>
- (instancetype)initWithOriginalDelegate:(id)originalDelegate;

@property (nonatomic, weak) id <CLLocationManagerDelegate> originalDelegate;

@end

@implementation RHCoreLocationNotifierDelegateProxy

#pragma mark - setup our swizzles
+ (void)load {
    Class locationManagerClass = NSClassFromString(@"CLLocationManager");
    if (!locationManagerClass) return;
    
    // add our new methods to the class
    class_addMethod(locationManagerClass, @selector(rhcl_setDelegate:), (IMP)rhcl_setDelegate, "v@:@");
    class_addMethod(locationManagerClass, @selector(rhcl_delegate), (IMP)rhcl_delegate, "@@:");
    
    // swizzle setDelegate:
    Method originalMethod = class_getInstanceMethod(locationManagerClass, @selector(setDelegate:));
    Method newMethod = class_getInstanceMethod(locationManagerClass, @selector(rhcl_setDelegate:));
    method_exchangeImplementations(originalMethod, newMethod);
    
    // swizzle delegate
    originalMethod = class_getInstanceMethod(locationManagerClass, @selector(delegate));
    newMethod = class_getInstanceMethod(locationManagerClass, @selector(rhcl_delegate));
    method_exchangeImplementations(originalMethod, newMethod);
    
}


#pragma mark - replacement methods
// due to swizzling, the rhcl_ methods are the original implementations on CLLocationManager
static void rhcl_setDelegate(id self, SEL _cmd, id delegate) {
    RHCoreLocationNotifierDelegateProxy *proxy = delegate ? [[RHCoreLocationNotifierDelegateProxy alloc] initWithOriginalDelegate:delegate] : nil;
    [self performSelector:@selector(rhcl_setDelegate:) withObject:proxy];
    
    // associate ourselves so that we are not dealloc'd when assigned to the weak delegate property
    objc_setAssociatedObject(self, "RHCoreLocationNotifierDelegateProxy", proxy, OBJC_ASSOCIATION_RETAIN);
}

static id rhcl_delegate(id self, SEL _cmd) {
    // we check to see who is calling and return the proxy object to CLLocation, while everyone else gets the original delegate
    RHCoreLocationNotifierDelegateProxy *proxy = [self performSelector:@selector(rhcl_delegate)];
    return RHCLNCallStackCurrentlyInsideCoreLocation() ? proxy : [proxy originalDelegate];
}


#pragma mark - init
- (instancetype)initWithOriginalDelegate:(id)originalDelegate {
    self = [super init];
    if (self) {
        self.originalDelegate = originalDelegate;
    }
    return self;
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if ([self.originalDelegate respondsToSelector:_cmd]){
        [self.originalDelegate locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
    }
    
    [self _dispatchLocations:[[[NSArray array] arrayByAddingObject:oldLocation] arrayByAddingObject:newLocation] fromManager:manager];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([self.originalDelegate respondsToSelector:_cmd]){
        [self.originalDelegate locationManager:manager didUpdateLocations:locations];
    }
    
    [self _dispatchLocations:locations fromManager:manager];
}


#pragma mark - generic forwarding
// allow forwarding of all methods
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.originalDelegate ? : [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    // fwd if we have an original delegate
    return self.originalDelegate ? [self.originalDelegate respondsToSelector:aSelector] : [self.class instancesRespondToSelector:aSelector];
}


#pragma mark - notification dispatch

- (void)_dispatchLocations:(NSArray *)locations fromManager:(CLLocationManager *)manager {
    if (locations.count < 1) return;
    
    _notifierLastKnownLocation = [locations lastObject];
    
    NSDictionary *userInfo = @{RHCoreLocationNotifierAllLocationsKey: locations, RHCoreLocationNotifierNewLocationKey:[locations lastObject]};
    [[NSNotificationCenter defaultCenter] postNotificationName:RHCoreLocationNotifierLocationChangedNotification object:manager userInfo:userInfo];
}

@end

#pragma mark - Misc
BOOL RHCLNCallStackCurrentlyInsideCoreLocation() {
    NSArray *stack = [NSThread callStackSymbols];
    // if CLLocation == YES && RHCoreLocation == NO
    
    BOOL matchedCLLocation = NO;
    BOOL matchedRHCoreLocation = NO;
    
    for (NSString *entry in stack) {
        if ([entry rangeOfString:@" CoreLocation "].length != 0) matchedCLLocation = YES;
        if ([entry rangeOfString:@"RHCoreLocationNotifierDelegateProxy"].length != 0) matchedRHCoreLocation = YES;
    }
    
    return matchedCLLocation && !matchedRHCoreLocation;
}

#pragma clang diagnostic pop


#pragma mark - RHCoreLocationNotifierAdditions

@implementation CLLocationManager (RHCoreLocationNotifierAdditions)

/** The last location received. Will be nil until a location has been received. */
+ (CLLocation*)lastKnownLocation {
    return _notifierLastKnownLocation;
}

@end

