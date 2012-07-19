//
//  utilities.m
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

#import "utilities.h"

int long2absolutex(double lon)
{
    return (int)(floor((lon + 180.0) / 360.0 * (1<<26)));
}

int lat2absolutey(double lat)
{
    return (int)(floor((1.0 - log( tan(lat * M_PI/180.0) + 1.0 / cos(lat * M_PI/180.0)) / M_PI) / 2.0 * (1<<26)));
}

NSString *getTileURL(int xtile, int ytile, int zoom) {
    return [[NSString alloc] initWithFormat:@"http://c.tile.openstreetmap.org/%d/%d/%d.png", zoom, xtile, ytile, nil];
}

NSMutableArray *csvParser (NSString * csvString) {
    NSMutableArray *found =  [NSMutableArray arrayWithObjects: nil];
    char *csv = (char *) [ csvString UTF8String];
    int length = strlen (csv);
    int j=0;
    char *s = malloc(length+1);
    for (int i = 0; i < length; i++) {
        while (i<length && (csv[i]==' ' || csv[i]=='\t')) {
            i++;
        }
        if (csv[i]=='"') {  // Quoted string
            i++;
            while (i<length && csv[i]!='"') {
                if (csv[i]=='\\') {
                    i++;
                }
                if (i<length) {
                    s[j++] = csv[i++];
                }
            }
            if (i<length) {
                i++;
            }
            while (i<length && (csv[i]==' ' || csv[i]=='\t')) {
                i++;
            }
            if (i<length && csv[i]==',') {
                i--;
            }
        } else if (csv[i] == ',') { // Separator
            s[j] = 0;
            [ found addObject: (NSObject*) [ NSString stringWithUTF8String: s] ];
            j = 0;
        } else {
            while (i<length && csv[i]!=' ' && csv[i]!='\t' && csv[i]!=',') {
                s[j++] = csv[i++];
            }
            while (i<length && (csv[i]==' ' || csv[i]=='\t')) {
                i++;
            }
            if (i<length && csv[i]==',') {
                i--;
            }
        }
    }
    s[j] = 0;
    [ found addObject: (NSObject*) [ NSString stringWithUTF8String: s] ];
    j = 0;
    free (s);
    return found;
}
