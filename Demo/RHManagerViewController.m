//
//  RHManagerViewController.m
//  RHCoreLocationNotifierDemo
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

#import "RHManagerViewController.h"


@implementation RHManagerViewController {
    BOOL _mapUpdating;
    bool _managerUpdating;
}


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = NSLocalizedString(@"Manager", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self _updateViews];
}

-(void)_updateViews{
    
    NSString *title = _managerUpdating ? NSLocalizedString(@"Stop Updating Location", nil) : NSLocalizedString(@"Start Updating Location", nil);
    [self.toggleManagerUpdatingButton setTitle:title forState:UIControlStateNormal];
    
    title = _mapUpdating ? NSLocalizedString(@"Hide User Location", nil) : NSLocalizedString(@"Show User Location", nil);
    [self.toggleMapUpdatingButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - actions
-(IBAction)toggleManagerUpdating:(id)sender{
    if (_managerUpdating) {
        [self.locationManager stopUpdatingLocation];
    } else {
        [self.locationManager startUpdatingLocation];
    }
    _managerUpdating = !_managerUpdating;
    [self _updateViews];
}

-(IBAction)toggleMapUpdating:(id)sender{
    _mapUpdating = !_mapUpdating;
    [self.mapView setShowsUserLocation:_mapUpdating];
    [self _updateViews];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocation *location = newLocation;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationLabel.text = [NSString stringWithFormat:@"%@", location];
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationLabel.text = [NSString stringWithFormat:@"%@", location];
    });
}



@end
