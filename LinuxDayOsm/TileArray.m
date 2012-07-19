//
//  TileArray.m
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

#import "TileArray.h"

@implementation TileArray

@synthesize tiles = _tiles;
@synthesize tilesSize = _tilesSize;
@synthesize defaultImage = _defaultImage;

- (id) initWithDim: (Dimension) d: (int) tileSize {
    if (self = [ super init ]) {
        _tilesSize.width = (d.width + tileSize - 1) / tileSize + 2;
        _tilesSize.height = (d.height + tileSize - 1) / tileSize + 2;
        printf ("%dx%d %dx%d\n", d.width, d.height, _tilesSize.width, _tilesSize.height);
        _tiles = nil;
        _defaultImage = nil;
    }
    return self;
}

- (void) setDefaultImage:(UIImage *)image {
    int i;

    _defaultImage = image;
    NSMutableArray *myTiles = [NSMutableArray arrayWithObjects: nil];
    for (i = 0; i < _tilesSize.width * _tilesSize.height; i++) {
        [ myTiles addObject: image ];
    }
    _tiles = myTiles;
}

- (UIImage*) getTile: (int) x: (int) y {
    if (_tilesSize.width && _tilesSize.height && _tiles && x >= 0 && y >= 0 &&  x < _tilesSize.width && y < _tilesSize.height) {
        return (UIImage*)[ _tiles objectAtIndex:(y*_tilesSize.width+ x) ];
    }
    return _defaultImage;
}

- (void) setTile: (UIImage*) tile: (int) x: (int) y {
    if (_tiles && tile) {
        [ _tiles replaceObjectAtIndex: (y * _tilesSize.width + x) withObject: tile];
    }
}

- (void) resize: (Dimension) d: (int) tileSize {
    int i;
    _tilesSize.width = (d.width + tileSize - 1) / tileSize + 2;
    _tilesSize.height = (d.height + tileSize - 1) / tileSize + 2;
    NSMutableArray *myTiles = [NSMutableArray arrayWithObjects: nil];
    for (i = 0; i < _tilesSize.width * _tilesSize.height; i++) {
        [ myTiles addObject: _defaultImage ];
    }
    _tiles = myTiles;
    printf ("%dx%d %dx%d\n", d.width, d.height, _tilesSize.width, _tilesSize.height);
}

@end
