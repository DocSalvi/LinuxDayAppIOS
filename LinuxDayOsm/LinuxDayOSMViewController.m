//
//  LinuxDayOSMViewController.m
//  LinuxDayOsm
//  Copyright (C) Stefano Salvi 2012 <stefano@salvi.mn.it>
/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0
 * Stefano Salvi licenses LinuxDatOSM under the Mozilla Public Licence v 2.0 (MPL 2.0) or
 * GNU General Public License version 2 (GPL2), both of which
 * are identified below. You may choose either license to govern
 * your use of LinuxDatOSM only upon the condition that you
 * accept all of the terms of either the MPL 2.0 or GPL2. Read
 * the terms carefully. If you are not willing to be bound by
 * these terms, do not download or use LinuxDatOSM.
 *
 * MPL 2.0
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * GPL 2.0:
 *  LinuxDayOsm is free software: you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the
 *  Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  LinuxDayOsm is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program.  If not, see <http://www.gnu.org/licenses/>.
 * ***** END LICENSE BLOCK ***** */

#import "LinuxDayOSMViewController.h"
#import "HereTag.h"
#import "LdTag.h"
#import "utilities.h"
#import "LDAlert.h"

#define topLatItaly     46.920255315374526
#define leftLonItaly    5.80078125
#define bottomLatItaly  36.527294814546245
#define righrLonItaly   19.16015625

#define fermiLat        45.14161339283485
#define fermiLon        10.767443776130676

#define baseZoom        12

#define CSVTitles       @"\"Organizzatore\",\"Luogo\",\"Indirizzo\",\"Città\",\"Provincia\",\"Sito Web\",\"Longitudine\",\"Latitudine\""
#define LugManCSV       @"\"Associazione Culturale LugMAN (Linux Users Group MANtova)\",\"Istituto Superiore E. Fermi\",\"Strada Spolverina, 5\",\"Mantova\",\"MN\",\"http://www.lugman.net/mediawiki/index.php?title=Linux_day\",\"GEOMETRYCOLLECTION(POINT(10.76773 45.13915))\""

@interface LinuxDayOSMViewController ()

@end

@implementation LinuxDayOSMViewController
@synthesize zoom;
@synthesize osmBrowser;
@synthesize CLController;
@synthesize here = _here;
@synthesize homeLatitude = _homeLatitude;
@synthesize homeLongitude = _homeLongitude;

- (void) OSMBrowser:(OSMBrowser *)OSMBrowser changeZoom: (int) newZoom {
    printf ("Delegate changeZoom %d\n", newZoom);
    [ self.osmBrowser setTileZoom: newZoom ];
    printf ("Delegate setTileZoom %d\n", newZoom);
    [ self.osmBrowser setNeedsDisplay ];
    // [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO ];
    printf ("Delegate setNeedsDisplay\n");
}

- (void) loadTagList {
    NSStringEncoding encoding;
    NSError *error;
    GeoTag *taglist = NULL;
    UIImage *tagImage = [UIImage imageNamed:@"ld_mark.png"];
    NSString *table = [ [NSString alloc ] initWithContentsOfURL: [NSURL URLWithString:@"http://www.linuxday.it/2011/data/"] usedEncoding:&encoding error:&error];
    NSArray *lines = [ table componentsSeparatedByString: @"\n"];
    // printf ("File letto (%d linee): %s\n", [lines count ], [ table UTF8String ]);
    NSMutableArray *titles = csvParser ((NSString*) [ lines objectAtIndex: 0 ]);
    for (int i=2; i < [ lines count ]; i++) {
        LdTag *t = [[LdTag alloc] init: taglist : titles : [ lines objectAtIndex: i ] : tagImage ];
        if (t) {
            taglist = t;
        }
    }
    self.osmBrowser.tagList = taglist;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.osmBrowser setNeedsDisplay];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
    self.osmBrowser.defaultImage = [UIImage imageNamed:@"ld_osm_i_pad.png"];
    self.osmBrowser.zoom = self.zoom;
    self.osmBrowser.delegate = self;
    [ osmBrowser centerArea: topLatItaly :  leftLonItaly :  bottomLatItaly :  righrLonItaly ];

    [self performSelectorInBackground:@selector(loadTagList) withObject:nil];

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGesture:)];
    [pinch setDelegate:self];
    [pinch setDelaysTouchesBegan:YES];
    [self.osmBrowser addGestureRecognizer:pinch];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [pan setDelegate:self];
    [pan setDelaysTouchesBegan:YES];
    [self.osmBrowser addGestureRecognizer:pan];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    [tap setDelegate:self];
    [self.osmBrowser addGestureRecognizer:tap];

    CLController = [[LocationDelegate alloc] init];
  CLController.delegate = self;
  [CLController.locMgr startUpdatingLocation];
}

- (void)locationUpdate:(CLLocation *)location {
    if (self.osmBrowser.tagList) {
        _homeLongitude = [location coordinate].longitude;
        _homeLatitude = [location coordinate].latitude;

        if (!_here) {
            GeoTag *t = self.osmBrowser.tagList;
            int currZoom = baseZoom;
            _here = [[HereTag alloc] init: nil: _homeLatitude: _homeLongitude ];
            while (t.next) {
                t = t.next;
            }
            [ t setNext: _here ];
            // printf ("longitudine %f (%f), latitudine %f (%f)\n", [location coordinate].longitude, fermiLon, [location coordinate].latitude, fermiLat);
            do {
                [ self.osmBrowser centerPoint: _homeLatitude : _homeLongitude : currZoom ];
                printf ("top %d left %d bottom %d right %d Zoom %d\n", self.osmBrowser.absTopLeft.y, self.osmBrowser.absTopLeft.x, self.osmBrowser.absBottomRight.y, self.osmBrowser.absBottomRight.x,currZoom);
                int scale = 1 << (18 - currZoom);
                for (t = self.osmBrowser.tagList; t; t = t.next) {
                    if (t != _here && [ t isInto: self.osmBrowser.absTopLeft : self.osmBrowser.absBottomRight : scale]) {
                        printf ("%s %d %d\n", [ t.description UTF8String ], t.absolutePos.x, t.absolutePos.y);
                        break;
                    }
                }
                if (currZoom < 3) {
                    printf ("currZoom < 3\n");
                    break;
                }
                if (t == nil) {
                    currZoom --;
                    printf ("Nuovo currZoom %d\n", currZoom);
                }
            } while (t == nil);
            [ osmBrowser adjustAndLoad ];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.osmBrowser setNeedsDisplay];
            });
        } else {
            [ _here setCoords: _homeLatitude: _homeLongitude ];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.osmBrowser setNeedsDisplay];
            });
        }

    }
  // printf ("%s\n", [[location description] UTF8String ]);
}

- (void)locationError:(NSError *)error {
  // printf ("%s\n", [[error description] UTF8String ]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
// Rotation mamagement



-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    Dimension d;
    d.width = self.view.bounds.size.width;
    d.height = self.view.bounds.size.height;
    [ self.osmBrowser resize: d ];
    [ LDAlert didRotateFromInterfaceOrientation: self.interfaceOrientation ];
}
// End Rotation Management

#define SCALEMULT       4
// Recognizers
- (IBAction)handlePinchGesture:(UIGestureRecognizer *)sender {
    static int basezoom;
    if (sender.state == UIGestureRecognizerStateBegan) {
        basezoom = self.osmBrowser.tileZoom;
        [ self.osmBrowser onStartZooming ];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [ self.osmBrowser onEndZooming ];
    } else {
        double scale = [(UIPinchGestureRecognizer *)sender scale];
        if (scale > 1) {
          scale -= 1;
        } else {
          scale = 1-(1/scale);
        }
        printf ("Scale %f ", scale);
        // if (scale > SCALEMULT) {
        //     scale /= SCALEMULT;
        // } else if (scale < 1/SCALEMULT) {
        //     scale *= SCALEMULT;
        // }
        // int newZoom = basezoom * scale;
        int newZoom = basezoom + scale;
        if (newZoom < 2) {
            newZoom=2;
        } else if (newZoom > 18) {
            newZoom = 18;
        }
        [ self.osmBrowser onChngeZoom: newZoom ];
    }
}



- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {

    CGPoint translate = [sender translationInView:self.view];

    if (sender.state == UIGestureRecognizerStateBegan) {
        [ self.osmBrowser startPan];
    }

    [ self.osmBrowser continuePan: (int) translate.x: (int) translate.y ];

    if (sender.state == UIGestureRecognizerStateEnded) {
        [ self.osmBrowser endPan ];
    }
}



- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender {

    CGPoint tapPoint = [sender locationInView:sender.view.superview];

    printf ("handleSingleTap %f,%f Ended\n", tapPoint.x, tapPoint.y);

    [ self.osmBrowser handleTtap: tapPoint ];
    /* [UIView beginAnimations:nil context:NULL];

    sender.view.center = tapPoint;

    [UIView commitAnimations]; */

}
// End Recognizers

- (void)viewDidUnload
{
    [self setZoom:nil];
    [self setOsmBrowser:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction) sliderValueChanged:(UISlider *)sender {
    [ self.osmBrowser onChngeZoom: [sender value] + 2 ];
}

- (IBAction) changeButtonPressed:(id)sender {
    [ self.osmBrowser onStartZooming ];
}

- (IBAction) changeButtonReleased:(id)sender {
    [ self.osmBrowser onEndZooming ];
}

- (IBAction)goToCurrentLocation:(id)sender {
    [ self.osmBrowser centerPoint: _homeLatitude : _homeLongitude : self.osmBrowser.tileZoom ];
    [ osmBrowser adjustAndLoad ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.osmBrowser setNeedsDisplay];
    });
}

- (IBAction)resetView:(id)sender {
    [ osmBrowser centerArea: topLatItaly :  leftLonItaly :  bottomLatItaly :  righrLonItaly ];
}

+ (NSString *)getPrivateDocsDir {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];

    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];

    return documentsDirectory;

}

@end
