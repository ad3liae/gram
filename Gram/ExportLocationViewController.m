//
//  ExportLocationViewController.m
//  Gram
//
//  Created by Yoshimura Kenya on 2012/08/31.
//  Copyright (c) 2012年 Yoshimura Kenya. All rights reserved.
//

#import "ExportLocationViewController.h"

#import "GramAnnotation.h"
#import "UITabBarWithAdController.h"

@interface ExportLocationViewController ()
{
    CLLocation *location;
    GramAnnotation *placeMark;
    CGRect frame;
}

@end

@implementation ExportLocationViewController
@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [mapView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    //UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    //tabBar.delegate = self;
    //frame = [mapView frame];
    
    location = nil;
    if ([CLLocationManager locationServicesEnabled])
    {
        if ([GramContext get]->location)
        {
            location = [GramContext get]->location;
        }
    }
    
    mapView.delegate = self;
    mapView.mapType = MKMapTypeStandard;
    MKCoordinateRegion region = mapView.region;
    region.center.latitude = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    [mapView setRegion:region animated:NO];
    
    self.title = @"座標を指定";
    
    /*
     if (tabBar.bannerIsVisible)
     {
     [self.mapView setFrame:CGRectMake(frame.origin.x,
     frame.origin.y,
     frame.size.width,
     frame.size.height - 93 -  49)];
     }
     else
     {
     [self.mapView setFrame:CGRectMake(frame.origin.x,
     frame.origin.y,
     frame.size.width,
     frame.size.height - 93)];
     }
     */
}

- (void)viewWillDisappear:(BOOL)animated
{
    //UITabBarWithAdController *tabBar = (UITabBarWithAdController *)self.tabBarController;
    //if (tabBar.delegate == self)
    //{
    //    tabBar.delegate = nil;
    //}
}

- (void)viewDidAppear:(BOOL)animated
{
    if (location != nil)
    {
        if (placeMark != nil)
        {
            
        }
        else
        {
            placeMark = [[GramAnnotation alloc] initWithCoordinate:location.coordinate];
            
            [mapView addAnnotation:placeMark];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(MKAnnotationView*)mapView:(MKMapView*)_mapView viewForAnnotation:(id)annotation {
    if (annotation == mapView.userLocation)
    {
        return nil;
    }
    
    MKPinAnnotationView *annotationView;
    NSString* identifier = @"Pin";
    annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    annotationView.animatesDrop = YES;
    annotationView.draggable = YES;
    return annotationView;
}

- (void) handleTapGesture:(UITapGestureRecognizer*)sender
{
    if (placeMark != nil)
    {
        [mapView removeAnnotation:placeMark];
    }
    
    CGPoint point = [sender locationInView:mapView];
    CLLocationCoordinate2D mapPoint = [ mapView convertPoint:point toCoordinateFromView:mapView];
    placeMark = [[GramAnnotation alloc] initWithCoordinate:mapPoint];
    [GramContext get]->locationFromMap = [[CLLocation alloc] initWithLatitude:mapPoint.latitude longitude:mapPoint.longitude];
    
    [mapView addAnnotation:placeMark];
}

#pragma  mark - custom delegate

- (void)bannerIsInvisible
{
    NSLog(@"delegate bannerIsInvisible");
    [UIView beginAnimations:@"ad" context:nil];
    [self.mapView setFrame:CGRectMake(frame.origin.x,
                                      frame.origin.y,
                                      frame.size.width,
                                      frame.size.height - 93)];
    [UIView commitAnimations];
}

- (void)bannerIsVisible
{
    NSLog(@"delegate bannerIsVisible");
    [UIView beginAnimations:@"ad" context:nil];
    [self.mapView setFrame:CGRectMake(frame.origin.x,
                                      frame.origin.y,
                                      frame.size.width,
                                      frame.size.height - 93 - 49)];
    [UIView commitAnimations];
}

@end
