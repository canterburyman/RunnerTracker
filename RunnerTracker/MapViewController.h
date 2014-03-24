//
//  MapViewController.h
//  RunnerTracker
//
//  Created by Xinjun on 23/10/13.
//  Copyright (c) 2013 Xinjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) MKPolyline *objPolyline;
@property (nonatomic) CLLocationCoordinate2D lastLoc;
@end


@interface MyAnnotation : NSObject <MKAnnotation>

-(MyAnnotation *)initWithTitle:(NSString *)title subTitle:(NSString *) subTitle andCoordinate:(CLLocationCoordinate2D) location;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end