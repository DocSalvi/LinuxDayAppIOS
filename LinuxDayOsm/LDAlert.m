//
//  LDAlert.m
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

#import "LDAlert.h"
#import "UIView-LdAlertAnimations.h"
#import <QuartzCore/QuartzCore.h>

#define MY_TAG_VAL  999

@interface LDAlert()
- (void)alertDidFadeOut;
@end

@implementation LDAlert

@synthesize titolo = _titolo;
@synthesize luogo = _luogo;
@synthesize indirizzo = _indirizzo;
@synthesize citta = _citta;
@synthesize sito = _sito;

@synthesize delegate = _delegate;
@synthesize backgroundView = _backgroundView;
@synthesize alertView = _alertView;
@synthesize me = _me;
@synthesize goToButton = _goToButton;
@synthesize bkImage = _bkImage;
@synthesize data = _data;
@synthesize size = _size;
@synthesize okButton = _okButton;

#pragma mark -
#pragma mark IBActions

static id Dialog = nil;

- (IBAction)show: (LdTag *) ld
{
    // Retaining self is odd, but we do it to make this "fire and forget"
    _me = self; // To lock it into memory
    _data = ld;

    // We need to add it to the window, which we can get from the delegate
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:self.view];

    // Make sure the alert covers the whole window
    self.view.frame = window.frame;
    self.view.center = window.center;

    // "Pop in" animation for alert
    [alertView doPopInAnimationWithDelegate:self];

    // "Fade in" animation for background
    [backgroundView doFadeInAnimation];
}

- (IBAction)dismiss:(id)sender {
    //    [inputField resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    self.view.alpha = 0.0;
    [UIView commitAnimations];

    [self performSelector:@selector(alertDidFadeOut) withObject:nil afterDelay:0.5];

    printf ("Tag %d\n", [sender tag]);
    if ([sender tag] == MY_TAG_VAL) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_data.sito]];
    }
}

#pragma mark -

/* Lunghezza "massima" riga: 35 caratteri */
- (int) setText: (UILabel *) fld: (NSString *) text: (int) start {
    int lines = ([ text length ] + 34) / 35;
    int height = fld.frame.size.height * lines;
    printf ("Heght %d Righe %d Testo %s Lunghezza %d\n", height, ([ text length ] + 34) / 35, [ text UTF8String ], [ text length ]);
    fld.frame = CGRectMake(fld.frame.origin.x , start, fld.frame.size.width, height);
    fld.text = text;
    fld.numberOfLines = lines;
    return start + height;
}

- (void)viewDidLoad {
    // Fine gestione orientamento
    int offset = self.luogo.frame.origin.y - self.titolo.frame.origin.y - self.titolo.frame.size.height;
    printf ("Offset %d\n", offset);
    int start = self.titolo.frame.origin.y;
    start = [ self setText: self.titolo: _data.organizzazione: start ];
    start = [ self setText: self.luogo: _data.luogo: start + offset ];
    start = [ self setText: self.indirizzo: _data.indirizzo: start + offset ];
    start = [ self setText: self.citta: [ NSString stringWithFormat: @"%@ (%@)", _data.citta, _data.provincia ]: start + offset ];
    start = [ self setText: self.sito: _data.sito: start + offset ];
    self.goToButton.frame = CGRectMake(self.goToButton.frame.origin.x , start + offset, self.goToButton.frame.size.width, self.goToButton.frame.size.height);
    self.okButton.frame = CGRectMake(self.okButton.frame.origin.x , start + offset, self.okButton.frame.size.width, self.okButton.frame.size.height);
    self.alertView.frame = CGRectMake(self.alertView.frame.origin.x , self.alertView.frame.origin.y , self.alertView.frame.size.width, start + 3 * offset + self.goToButton.frame.size.height);
    self.bkImage.frame = CGRectMake(self.bkImage.frame.origin.x , self.bkImage.frame.origin.y , self.bkImage.frame.size.width, start + 3 * offset + self.goToButton.frame.size.height);
    Dialog = self;
}

- (void) rotateAndResize: (CGSize) size {
    _size = size;
    [ self didRotateFromInterfaceOrientation: self.interfaceOrientation ];
}

+ (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    printf ("didRotateFromInterfaceOrientation (%d)\n", (int)Dialog);
    if (Dialog) {
        printf ("didRotateFromInterfaceOrientation Invoco... (%d)\n", (int)Dialog);
        [ Dialog didRotateFromInterfaceOrientation: fromInterfaceOrientation ];
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    printf ("didRotateFromInterfaceOrientation Dialog (%d)\n", fromInterfaceOrientation);
    // Gestione orientamento
    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        float   angle = -M_PI/2;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        [ self.alertView setTransform:transform];
        self.backgroundView.frame = CGRectMake(0,10, self.backgroundView.frame.size.width+20, self.backgroundView.frame.size.height);
    } else if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        float   angle = M_PI/2;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        [ self.alertView setTransform:transform];
        self.backgroundView.frame = CGRectMake(0,10, self.backgroundView.frame.size.width+20, self.backgroundView.frame.size.height);
    } else if (fromInterfaceOrientation == UIDeviceOrientationPortrait) {
        float   angle = 0;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        [ self.alertView setTransform:transform];
        self.backgroundView.frame = CGRectMake(0,20, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
    }
}

- (void)viewDidUnload
{
    [self setGoToButton:nil];
    [self setOkButton:nil];
    [self setBkImage:nil];
    [super viewDidUnload];
    self.alertView = nil;
    self.backgroundView = nil;
    self.me = nil;
    Dialog = nil;
}

#pragma mark -
#pragma mark Private Methods
- (void)alertDidFadeOut
{
    [self.view removeFromSuperview];
}
#pragma mark -
#pragma mark CAAnimation Delegate Methods
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
