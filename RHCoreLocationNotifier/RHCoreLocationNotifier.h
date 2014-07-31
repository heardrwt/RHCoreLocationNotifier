//
//  RHCoreLocationNotifier.h
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
//  RHCoreLocationNotifier works by injected a proxy class between
//  CLLocationManager and its delegate, invisibly forwarding all
//  delegate method calls onwards gracefully, while at the same
//  time siphoning any CLLocation objects from the wire as they
//  pass through.
//
//  RHCoreLocationNotifierLocationChangedNotifications are dispatched for
//  all initialised CLLocationManager instances automatically,
//  and there is no setup required.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 Notification dispatched on the default NSNotificationCenter every
 time a CLLocationManager updates its delegate with one or more new
 locations. The notification object is the relevant CLLocationManager
 instance. The userInfo dictionary also contains the relevant locations.
 
 @see RHCoreLocationNotifierNewLocationKey
 @see RHCoreLocationNotifierAllLocationsKey
 */
extern NSString * const RHCoreLocationNotifierLocationChangedNotification;


/** A CLLocation object representing the most recent location available. */
extern NSString * const RHCoreLocationNotifierNewLocationKey;

/** An NSArray object containing newly available location objects. */
extern NSString * const RHCoreLocationNotifierAllLocationsKey;


/** helper addition */
@interface CLLocationManager (RHCoreLocationNotifierAdditions)

/** The last location received. Will be nil until a location has been received. */
+ (CLLocation*)lastKnownLocation;

@end
