//
//  OSMBrowser.m
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

#import "OSMBrowser.h"
#import "LinuxDayOSMViewController.h"

@implementation OSMBrowser

@synthesize tagList = _tagList;

@synthesize oldZoom = _oldZoom;
@synthesize oldTile = _oldTile;

@synthesize tileZoom = _tileZoom;
@synthesize firstTile = _firstTile;
@synthesize screenCorner = _screenCorner;
@synthesize absTopLeft = _absTopLeft;
@synthesize absBottomRight = _absBottomRight;

@synthesize startDrag = _startDrag;
@synthesize startAbsolutePixel = _startAbsolutePixel;
@synthesize zooming = _zooming;
@synthesize startZoom = _startZoom;
@synthesize startDistance = _startDistance;

@synthesize screenDim = _screenDim;
@synthesize tiles = _tiles;

// @synthesize mZoomBar = _mZoomBar;
@synthesize minImageSize = _minImageSize;
@synthesize delegate = _delegate;

@synthesize defaultImage = _defaultImage;

@synthesize zoom = _zoom;

@synthesize updating =_updating;
@synthesize reupdate = _reupdate;

@synthesize docPath = _docPath;

#define kDataKey        @"Data"
#define kDataFile       @"data.plist"

- (void)baseInit {
    _screenDim.width = self.frame.size.width;
    _screenDim.height = self.frame.size.height;
    _tiles = [ [ TileArray alloc ] initWithDim: _screenDim : tileSize ];
    _tileZoom = 2;
    _oldZoom = 0;
    _firstTile.x = 0 ;
    _firstTile.y = 0;
    [ self setScreenCorner: tileSize: tileSize ];
    [ self loadTiles ];

    _minImageSize = CGSizeMake(5, 5);
    _delegate = nil;
}


- (void)setDefaultImage:(UIImage *)image {
    _defaultImage = image;
    [ _tiles setDefaultImage: image ];
    [ self loadTiles ];
}

- (void) screenToAbsolutePixel: (LongPoint *) a: (int) x: (int) y
{
    int mult = 1 << (18 - _tileZoom);
    a->x = (_firstTile.x * tileSize + x + _screenCorner.x) * mult + mult / 2;
    a->y = (_firstTile.y * tileSize + y + _screenCorner.y) * mult + mult / 2;
}

- (void) setScreenCorner:(int) x: (int) y
{
    _screenCorner.x = x;
    _screenCorner.y = y;
    [ self screenToAbsolutePixel: &_absTopLeft : 0 : 0 ];
    [ self screenToAbsolutePixel: &_absBottomRight : _screenDim.width: _screenDim.height ];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    char buf [80];
    int x = 0;
    int y = 0;
    CGFloat black[4] = {0.0f, 0.0f, 0.0f, 1.0f};

    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0f, -1.0f));
    CGContextSelectFont(context, "Arial", 18, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    // CGContextSaveGState(context);

    for (y = (_screenCorner.y-tileSize+1)/tileSize; (y * tileSize - _screenCorner.y - 10) < _screenDim.height; y++) {
        for (x = (_screenCorner.x-tileSize+1)/tileSize; (x * tileSize - _screenCorner.x - 10) < _screenDim.width; x++) {
            // printf ("(%d-%d,%d,%d) %d,%d  [%d,%d %dx%d]\n", x * tileSize - _screenCorner.y - 1, y * tileSize - _screenCorner.x - 1, (x+1) * tileSize - _screenCorner.y - 1, (y+1) * tileSize - _screenCorner.x - 1, _screenDim.width, _screenDim.height, x, y, _tiles.tilesSize.width, _tiles.tilesSize.height);
            CGPoint imagePoint = CGPointMake (x * tileSize - _screenCorner.x, y * tileSize - _screenCorner.y);
            [ [ _tiles getTile: x:y ] drawAtPoint: imagePoint];
        }
    }

    int scale = 1 << (18 - _tileZoom);
    for (GeoTag *t = _tagList; t != nil; t = [ t getNext ] ) {
        [ t paint: context : _absTopLeft : _absBottomRight : scale ];
    }

    // CGContextRestoreGState(context);
    CGContextSetFillColor(context, black);
    sprintf(buf,"Zoom : %d", _tileZoom);
    CGContextShowTextAtPoint(context, 10, 20, buf, strlen(buf));
    // sprintf(buf,"Coordinate tile : %d,%d", _firstTile.x, _firstTile.y);
    // CGContextShowTextAtPoint(context, 10, 36, buf, strlen(buf));
    // sprintf(buf,"Dimensione array : %dx%d",_tiles.tilesSize.width, _tiles.tilesSize.height);
    // CGContextShowTextAtPoint(context, 10, 52, buf, strlen(buf));
    // sprintf(buf,"Offset Schermo : %d,%d", _screenCorner.x, _screenCorner.y);
    // CGContextShowTextAtPoint(context, 10, 68, buf, strlen(buf));
    // sprintf(buf,"Dimensione Schermo : %dx%d", _screenDim.width, _screenDim.height);
    // CGContextShowTextAtPoint(context, 10, 84, buf, strlen(buf));
    // sprintf(buf,"Ultima tessera : %d,%d", x, y);
    // CGContextShowTextAtPoint(context, 10, 100, buf, strlen(buf));
}

- (void) centerPoint: (double) lat: (double) lon: (int) zoom {
    _tileZoom = zoom;
    int ratio = 1 << (18 - _tileZoom);
    int left = long2absolutex (lon)/ratio - (_screenDim.width/2);
    int top = lat2absolutey (lat)/ratio - (_screenDim.height/2);
    if (left < 0) {
        left = 0;
    }
    if (top < 0) {
        top = 0;
    }
    _firstTile.x = (left - tileSize/2)/tileSize;
    if ((left%tileSize) == 0) {
        _firstTile.x --;
    }
    _firstTile.y = (top - tileSize/2)/tileSize;
    if ((top%tileSize) == 0) {
        _firstTile.y --;
    }
    [ self setScreenCorner: (left - (_firstTile.x * tileSize)): (top - (_firstTile.y * tileSize)) ];
    _oldZoom = 0;
    if (_zoom != nil) {
        [ _zoom setValue: (float)(_tileZoom-2) ];
    }
}

- (void) centerArea: (double) topLat: (double) leftLon: (double) bottomLat: (double) rightLon {
    int left = long2absolutex (leftLon);
    int top = lat2absolutey (topLat);
    int right = long2absolutex (rightLon);
    int bottom = lat2absolutey (bottomLat);
    double scaleX = (double) (right - left)/_screenDim.width;
    double scaleY = (double) (bottom - top)/_screenDim.height;
    double scale = (scaleX > scaleY) ? scaleX : scaleY;
    _tileZoom = 18 - (int)ceil(log((double)scale) / log(2.0));
    int ratio = 1 << (18 - _tileZoom);
    left /= ratio;
    top /= ratio;
    right /= ratio;
    bottom /= ratio;
    left -= (_screenDim.width - right + left) / 2;
    top -= (_screenDim.height - bottom + top) / 2;
    _firstTile.x = (left - tileSize/2)/tileSize;
    _firstTile.y = (top - tileSize/2)/tileSize;
    [ self setScreenCorner: (left - (_firstTile.x * tileSize)): (top - (_firstTile.y * tileSize)) ];
    _oldZoom = 0;
    if (_zoom != nil) {
        [ _zoom setValue: (float)(_tileZoom-2) ];
    }
    [ self adjustAndLoad ];
}


- (void) adjustAndLoad {
    if (_screenCorner.x < tileSize/2) {
        _screenCorner.x += tileSize;
        _firstTile.x --;
    }
    if (_screenCorner.y < tileSize/2) {
        _screenCorner.y += tileSize;
        _firstTile.y --;
    }
    [ self loadTiles ];
}

-(int) long2tilex: (double) lon
{
    return (int)(floor((lon + 180.0) / 360.0 * (1<<_tileZoom)));
}

-(int) lat2tiley: (double) lat
{
    return (int)(floor((1.0 - log( tan(lat * M_PI/180.0) + 1.0 / cos(lat * M_PI/180.0)) / M_PI) / 2.0 * (1<<_tileZoom)));
}

-(double) tilex2long: (double) x
{
    return x / (double)(1<<_tileZoom) * 360.0 - 180;
}

-(double) tiley2lat: (double) y
{
    double n = M_PI - 2.0 * M_PI * y / (double)(1<<_tileZoom);
    return 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)));
}

- (void) loadTiles {
    if (_updating) {
        _reupdate = true;
    } else {
        _updating = true;
        [self performSelectorInBackground:@selector(loadTileTask) withObject:nil];
    }

}

- (NSString*)createDataPath: (int) zoom {

    if (_docPath == nil) {
        self.docPath = [ LinuxDayOSMViewController getPrivateDocsDir];
    }

    NSError *error;
    NSString * currentPath = [ _docPath  stringByAppendingPathComponent: [NSString stringWithFormat:@"%d", zoom ] ];
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath: currentPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    // return success;
    return currentPath;
}

- (UIImage*) loadTile: (int) x: (int) y: (int) zoom: (int) maxTiles {
    if (x >= 0 && y >= 0 && x < maxTiles && y < maxTiles) {
        NSString * tilePath = [[ self createDataPath: zoom] stringByAppendingPathComponent: [NSString stringWithFormat:@"%d_%d.png", x, y ]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tilePath]) {
            return [ UIImage imageWithContentsOfFile: tilePath ];
        } else {
            @try {
                NSURL* aURL = [NSURL URLWithString:getTileURL(x, y, _tileZoom)];
                NSData* data = [[NSData alloc] initWithContentsOfURL:aURL];
                [ data writeToFile: tilePath atomically: TRUE ];
                return [UIImage imageWithData:data];
            }
            @catch (NSException *exception) {
                return nil;
            }
        }
    }
    return nil;
}

- (void) loadTileTask {
    while (_tiles != nil) {
        printf ("Inizio ricaricamento Tiles\n");
        _reupdate = false;
        int maxTiles = 1 << _tileZoom;
        int startx;
        int endx;
        int stepx;
        int starty;
        int endy;
        int stepy;
        int firstx = _firstTile.x;
        int firsty = _firstTile.y;
        int oldx = _oldTile.x;
        int oldy = _oldTile.y;
        /* valuta la dirzione della copia in X */
        if (firstx > oldx) {
            startx = 0;
            endx = _tiles.tilesSize.width;
            stepx = 1;
        } else {
            startx = _tiles.tilesSize.width - 1;
            endx = -1;
            stepx = -1;
        }
        /* Valuta la direzione della copia in y */
        if (firsty > oldy) {
            starty = 0;
            endy = _tiles.tilesSize.height;
            stepy = 1;
        } else {
            starty = _tiles.tilesSize.height - 1;
            endy = -1;
            stepy = -1;
        }
        /* Se ci sono sovrapposizioni, sposta, se no annulla */
        for (int y = starty; y != endy; y+=stepy) {
            for (int x = startx; x != endx; x+= stepx) {
                // if (_oldZoom == _tileZoom && (x + firstx) >= oldx && (x + firstx) < (oldx + _tiles.tilesSize.width) &&
                //    (y + firsty) >= oldy && (y + firsty) < (oldy + _tiles.tilesSize.height)) {
                //    [ _tiles setTile: [ _tiles getTile: (x + firstx - oldx): (y + firsty - oldy) ]: x: y];
                //} else {
                    [ _tiles setTile: _defaultImage: x: y ];
                //}
            }
        }
        /* Carica le tessere vuote */
        for (int y = 0; y < _tiles.tilesSize.height; y++) {
            for (int x = 0; x < _tiles.tilesSize.width; x++) {
                if ( [ _tiles getTile: x: y] == _defaultImage) {
                    UIImage * i = [ self loadTile: firstx + x: firsty + y: _tileZoom: maxTiles ];
                    if (i != nil) {
                        [ _tiles setTile: i: x: y ];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setNeedsDisplay];
                        });
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
        _oldZoom = _tileZoom;
        _oldTile.x = firstx;
        _oldTile.y = firsty;
        if (!_reupdate) {
            break;
        }
    }
    printf ("Termine thread ricaricamento Tiles\n");
    _updating = false;
}

- (void) changeZoom: (int) newZoom {
    [ self setTileZoom: newZoom + 2 ];
    [ self loadTiles ];
    printf ("Cambiato zoom - ridimensiono\n");
}

- (void)handleTtap:(CGPoint)touchLocation {
    LongPoint abs;
    GeoTag *clicked = nil;
    [ self screenToAbsolutePixel: &abs : touchLocation.x : touchLocation.y ];
    int scale = 1 << (18 - _tileZoom);
    for (GeoTag *current=_tagList; current!=nil; current = [ current getNext ]) {
        if ( [ current isHit: abs : scale ]) {
            clicked = current;
        }
    }
    if (clicked != nil) {
        [ clicked action: self.frame.size ]; //(getContext(), p);
    }
}

- (void) startPan {
    _startDrag.x = _screenCorner.x;
    _startDrag.y = _screenCorner.y;
}

- (void) continuePan: (int) deltaX: (int) deltaY {
    [ self setScreenCorner : _startDrag.x - deltaX : _startDrag.y - deltaY ];
    [ self setNeedsDisplay ];
}

- (void) endPan {
    _firstTile.y += _screenCorner.y / tileSize;
    _firstTile.x += _screenCorner.x / tileSize;
    [ self setScreenCorner: _screenCorner.x % tileSize : _screenCorner.y % tileSize ];
    [ self adjustAndLoad ];

}

// Inizio gestione Scroll Bar Zoom
- (void) onChngeZoom: (int) newZoom {
    if (newZoom != _tileZoom) {
        _tileZoom = newZoom;
        int mult = 1 << (18 - _tileZoom);
        int scaledX = (_startAbsolutePixel.x / mult) - _startDrag.x;
        int scaledY = (_startAbsolutePixel.y / mult) - _startDrag.y;
        [ self setScreenCorner : scaledX - (_firstTile.x * tileSize) : scaledY - (_firstTile.y * tileSize) ];
        // [ self setNeedsDisplay ];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    }
}

- (void) onStartZooming {
    _startDrag.x = _screenDim.width/2;
    _startDrag.y = _screenDim.height/2;
    [ self screenToAbsolutePixel: &_startAbsolutePixel : _startDrag.x : _startDrag.y ];
}

- (void) onEndZooming {
    [ self zoomReposition ];
}
// Fine gestione Scroll Bar Zoom

- (void) zoomReposition {
    int mult = 1 << (18 - _tileZoom);
    int scaledX = (_startAbsolutePixel.x / mult) - _startDrag.x;
    int scaledY = (_startAbsolutePixel.y / mult) - _startDrag.y;
    _firstTile.x = (scaledX - tileSize/2)/tileSize;
    _firstTile.y = (scaledY - tileSize/2)/tileSize;
    [ self setScreenCorner : scaledX - (_firstTile.x * tileSize) : scaledY - (_firstTile.y * tileSize) ];
    [ self adjustAndLoad ];
}

- (void) resize: (Dimension) size {
    self.frame = CGRectMake(0,0, size.width, size.height);
    _screenDim.width = self.frame.size.width;
    _screenDim.height = self.frame.size.height;
    // Riposizione la scroll bar
    if (_zoom.frame.origin.y < 100) { // I-PAD - Scroll bar in alto
        _zoom.frame = CGRectMake(self.frame.size.width - 265,_zoom.frame.origin.y, _zoom.frame.size.width, _zoom.frame.size.height);
    } else { // I-PHONE - Scroll Bar in basso
        _zoom.frame = CGRectMake(_zoom.frame.origin.x, self.frame.size.height - 62, _zoom.frame.size.width, _zoom.frame.size.height);
    }
    [ _tiles resize: _screenDim : tileSize ];
    [ self loadTiles ];
}

@end
