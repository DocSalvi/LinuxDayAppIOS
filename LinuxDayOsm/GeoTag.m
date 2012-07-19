//
//  GeoTag.m
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

#import "GeoTag.h"
#import "OSMBrowser.h"
#import "utilities.h"

@implementation GeoTag

@synthesize next = _next;
@synthesize coords = _coords;
@synthesize absolutePos = _absolutePos;
@synthesize size = _size;
@synthesize refPoint = _refPoint;

- (id)init: (GeoTag*) next:  (double) lat: (double) lon: (int) sizeW: (int) sizeH: (int) refPointX: (int) refPointY {
    if (self) {
        _next = next;
        _size.width = sizeW;
        _size.height = sizeH;
        _refPoint.h = refPointX;
        _refPoint.v = refPointY;
        _coords.lon = lon;
        _coords.lat = lat;
        _absolutePos.x = long2absolutex(lon),
        _absolutePos.y = lat2absolutey(lat);
    }
    return self;
}

- (bool) isHit: (LongPoint) absolute: (int) scale {
    return absolute.x >= (_absolutePos.x - _refPoint.h * scale) && absolute.x < (_absolutePos.x + (_size.width - _refPoint.h) * scale) &&
    absolute.y >= (_absolutePos.y - _refPoint.v * scale) && absolute.y < (_absolutePos.y + (_size.height - _refPoint.v) * scale);
}

- (GeoTag *) getNext {
    return _next;
}

- (void) setNext: (GeoTag *) next {
    _next = next;
}

- (void) setCoords: (double) lat: (double) lon {
    _coords.lon = lon;
    _coords.lat = lat;
    _absolutePos.x = long2absolutex(lon),
    _absolutePos.y = lat2absolutey(lat);
}

- (Boolean) isInto: (LongPoint) absTopLeft: (LongPoint) absBottomRight: (int) scale {
    return _absolutePos.x >= absTopLeft.x && _absolutePos.x < absBottomRight.x && _absolutePos.y >= absTopLeft.y && _absolutePos.y < absBottomRight.y;
}

- (void) paint: (CGContextRef) context: (LongPoint) absTopLeft: (LongPoint) absBottomRight: (int) scale {
    if ([ self isInto: absTopLeft: absBottomRight : scale ]) {
        [ self scaledPaint: context : (_absolutePos.x - absTopLeft.x) / scale - _refPoint.h : (_absolutePos.y - absTopLeft.y) / scale - _refPoint.v ];
    }
}

// abstract
- (void) scaledPaint: (CGContextRef) context: (int) x: (int) y {
}

// abstract
- (void) action: (CGSize) size // (Context context, Point p);
{
}

@end
