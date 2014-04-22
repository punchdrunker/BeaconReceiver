//
//  PDViewController.m
//  BeaconReceiver
//
//  Created by nanao on 2014/04/22.
//  Copyright (c) 2014年 punchdrunker. All rights reserved.
//

#import "PDViewController.h"


@interface PDViewController ()

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) CLProximity proximity;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _proximityUUID = [[NSUUID alloc] initWithUUIDString:@"772BAE40-C984-4D8A-B4C8-2BD2F3A3E6CB"];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_proximityUUID
                                                               identifier:@"org.punchdrunker.beacon"];
        [_locationManager startMonitoringForRegion:_beaconRegion];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Start Monitoring Region"];
    [_locationManager requestStateForRegion:_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Enter Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [_locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        
        NSString *rangeMessage;
        _proximity = nearestBeacon.proximity;
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate: ";
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near: ";
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far: ";
                break;
            default:
                rangeMessage = @"Range Unknown: ";
                break;
        }
        
        NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%d",
                             nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, nearestBeacon.rssi];
        [self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside: // リージョン内にいる
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            }
            break;
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
        default:
            break;
    }
}

#pragma mark - Private methods

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    NSString *string = [NSString stringWithFormat:@"%@\n%@", _textView.text, message];
    _textView.text = string;
    UIColor *color;
    switch (_proximity) {
        case CLProximityImmediate:
            color = [UIColor redColor];
            break;
        case CLProximityNear:
            color = [UIColor greenColor];
            break;
        case CLProximityFar:
            color = [UIColor blueColor];
            break;
        default:
            color = [UIColor whiteColor];
            break;
    }
    self.view.backgroundColor = color;
}

@end
