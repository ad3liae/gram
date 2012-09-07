//
//  HistoryMapViewController.h
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/22.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UITabBarWithAdDelegate.h"

@interface HistoryMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITabBarWithAdDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)tapChangeMode:(id)sender;

@end
