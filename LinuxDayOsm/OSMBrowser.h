//
//  OSMBrowser.h
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

#import <UIKit/UIKit.h>
#import "Dimension.h"
#import "LongPoint.h"
#import "GeoTag.h"
#import "TileArray.h"
#import "utilities.h"

#define tileSize 256

@class OSMBrowser;

@protocol OSMBrowserDelegate
- (void) OSMBrowser:(OSMBrowser *)OSMBrowser changeZoom: (int) newZoom;
@end

@interface OSMBrowser : UIView
@property (nonatomic, strong) GeoTag *tagList;

@property (assign) int oldZoom;
@property (assign) LongPoint oldTile;

@property (assign) int tileZoom;
@property (assign) LongPoint firstTile;
@property (assign) LongPoint screenCorner;
@property (assign) LongPoint absTopLeft;
@property (assign) LongPoint absBottomRight;

@property (assign) LongPoint startDrag;
@property (assign) LongPoint startAbsolutePixel;
@property (assign) bool zooming;
@property (assign) int startZoom;
@property (assign) int startDistance;

@property (assign) Dimension screenDim;
@property (nonatomic, strong) TileArray *tiles; // Rectangular array of *UIImage

// @property (assign) SeekBar mZoomBar;
@property (assign) CGSize minImageSize;
@property (assign) id <OSMBrowserDelegate> delegate;

@property (nonatomic, strong) UIImage *defaultImage;

@property (weak, nonatomic) IBOutlet UISlider *zoom;

@property (assign) bool updating;
@property (assign) bool reupdate;

@property (copy) NSString *docPath;

- (void) centerArea: (double) topLat: (double) leftLon: (double) bottomLat: (double) rightLon;
- (void) centerPoint: (double) lat: (double) lon: (int) zoom;

- (void) baseInit ;
- (void) setScreenCorner:(int) x: (int) y;
- (void) screenToAbsolutePixel: (LongPoint *) a: (int) x: (int) y;
- (void) setDefaultImage:(UIImage *)image;
- (void) adjustAndLoad;

- (void) zoomReposition;

- (void) onChngeZoom: (int) newZoom;
- (void) onStartZooming;
- (void) onEndZooming;

- (void) startPan;
- (void) continuePan: (int) deltaX: (int) deltaY;
- (void) endPan;

- (void) resize: (Dimension) size;

- (void)handleTtap:(CGPoint)touchLocation;

- (void) loadTileTask;

@end
