//
//  LdTag.m
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

#import "LdTag.h"
#import "utilities.h"
#import "LDAlert.h"


@implementation LdTag

@synthesize ldMark = _ldMark;
@synthesize organizzazione = _organizzazione;
@synthesize luogo = _luogo;
@synthesize indirizzo = _indirizzo;
@synthesize citta = _citta;
@synthesize provincia = _provincia;
@synthesize sito = _sito;

#define TAGWIDTH    20
#define TAGHEIGHT   24

- (id)init: (GeoTag*) next: (NSMutableArray *) titles: (NSString*) record: (UIImage*) ldMark {
    self = [ super init: next : 0 : 0 : TAGWIDTH : TAGHEIGHT : TAGWIDTH/2 : TAGHEIGHT ];
    if (self) {
        NSMutableArray * fields = csvParser(record);
        _ldMark = ldMark;
        if ([ fields count ] > 6) {
            _organizzazione = (NSString *)[ fields objectAtIndex: 0];
            _luogo = (NSString *)[ fields objectAtIndex: 1];
            _indirizzo = (NSString *)[ fields objectAtIndex: 2];
            _citta = (NSString *)[ fields objectAtIndex: 3];
            _provincia = (NSString *)[ fields objectAtIndex: 4];
            _sito = (NSString *)[ fields objectAtIndex: 5];
            // GEOMETRYCOLLECTION(POINT(10.76773 45.13915))
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*POINT[ \t]*\\(([0-9.]*)&?[^0-9.]*([0-9.]*)&?\\).*" options:NSRegularExpressionCaseInsensitive error:NULL];
            NSString *coords = (NSString *)[ fields objectAtIndex: 6];


            NSTextCheckingResult *match = [regex firstMatchInString:coords options:0 range:NSMakeRange(0, [coords length])];
            // [match rangeAtIndex:1] gives the range of the group in parentheses
            NSString *Lat = [coords substringWithRange:[match rangeAtIndex:1]];
            NSString *Lon = [coords substringWithRange:[match rangeAtIndex:2]];
            [ self setCoords: [Lon doubleValue] :  [Lat floatValue] ];
        } else {
            self = nil;
        }
    }
    return self;
}

- (void) scaledPaint: (CGContextRef) context: (int) x: (int) y {
    CGRect imageRect = CGRectMake(x, y, TAGWIDTH, TAGHEIGHT);
    [_ldMark drawInRect:imageRect];
}

- (void) action: (CGSize) size // (Context context, Point p);
{
    printf ("Action %s\n", [ _organizzazione UTF8String ]);
    NSString * storyBoardName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyBoardName = @"MainStoryboard_iPad";
    } else {
        storyBoardName = @"MainStoryboard_iPhone";
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                storyBoardName  bundle:nil];
    LDAlert *alert = [storyboard instantiateViewControllerWithIdentifier: @"LDDialog"];
    [alert show: self ];
    [alert rotateAndResize: size ];
}

@end
