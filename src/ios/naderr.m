/*
 Copyright 2013-2016 appPlant GmbH

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */
 
#import "naderr.h"
#import <Cordova/CDVAvailability.h>

@implementation naderr

#define KEY_RESULT                  @"Result"
#define KEY_METHOD                  @"Method"
#define PAGE_AREA_HEIGHT    500
#define PAGE_AREA_WIDTH     500
#define FONT_A_HEIGHT       24
#define FONT_A_WIDTH        12
#define BARCODE_HEIGHT_POS  70
#define BARCODE_WIDTH_POS   110

- (void)pluginInitialize{ }



- (void)printData:(CDVInvokedUrlCommand *)command{
    NSlog(@"this is working!");
    int result = EPOS2_SUCCESS;
    result = [printer connect:@"TCP:64:EB:8C:2C:2C:0B", timeout:EPOS2_PARAM_DEFAULT];
    result = [printer beginTransaction];
    result = [printer addTextAlign:EPOS2_ALIGN_CENTER];
    result = [printer addText:@"Hello World"];
    if (result != EPOS2_SUCCESS) {
        //Displays error messages
        NSlog(@"Eror while printing");
    } else {
        NSlog(@"printing");
    }

    //disconnect
    result = [printer endTransaction];
    result = [printer disconnect];


}

- (BOOL)runPrintReceiptSequence
{
    _textWarnings.text = @"";

    if (![self initializeObject]) {
        return NO;
    }

    if (![self createReceiptData]) {
        [self finalizeObject];
        return NO;
    }

    if (![self printData]) {
        [self finalizeObject];
        return NO;
    }

    return YES;
}


- (BOOL)runPrintCouponSequence
{
    _textWarnings.text = @"";

    if (![self initializeObject]) {
        return NO;
    }

    if (![self createCouponData]) {
        [self finalizeObject];
        return NO;
    }

    if (![self printData]) {
        [self finalizeObject];
        return NO;
    }

    return YES;
}

- (void)updateButtonState:(BOOL)state
{
    _buttonReceipt.enabled = state;
    _buttonCoupon.enabled = state;
}

- (BOOL)createReceiptData
{
    int result = EPOS2_SUCCESS;

    const int barcodeWidth = 2;
    const int barcodeHeight = 100;

    if (printer_ == nil) {
        return NO;
    }

    NSMutableString *textData = [[NSMutableString alloc] init];
    UIImage *logoData = [UIImage imageNamed:@"store.png"];

    if (textData == nil || logoData == nil) {
        return NO;
    }

    result = [printer_ addTextAlign:EPOS2_ALIGN_CENTER];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addTextAlign"];
        return NO;
    }

    result = [printer_ addImage:logoData x:0 y:0
              width:logoData.size.width
              height:logoData.size.height
              color:EPOS2_COLOR_1
              mode:EPOS2_MODE_MONO
              halftone:EPOS2_HALFTONE_DITHER
              brightness:EPOS2_PARAM_DEFAULT
              compress:EPOS2_COMPRESS_AUTO];

    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addImage"];
        return NO;
    }

    // Section 1 : Store infomation
    result = [printer_ addFeedLine:1];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }
    [textData appendString:@"THE STORE 123 (555) 555 – 5555\n"];
    [textData appendString:@"STORE DIRECTOR – John Smith\n"];
    [textData appendString:@"\n"];
    [textData appendString:@"7/01/07 16:58 6153 05 0191 134\n"];
    [textData appendString:@"ST# 21 OP# 001 TE# 01 TR# 747\n"];
    [textData appendString:@"------------------------------\n"];
    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    // Section 2 : Purchaced items
    [textData appendString:@"400 OHEIDA 3PK SPRINGF  9.99 R\n"];
    [textData appendString:@"410 3 CUP BLK TEAPOT    9.99 R\n"];
    [textData appendString:@"445 EMERIL GRIDDLE/PAN 17.99 R\n"];
    [textData appendString:@"438 CANDYMAKER ASSORT   4.99 R\n"];
    [textData appendString:@"474 TRIPOD              8.99 R\n"];
    [textData appendString:@"433 BLK LOGO PRNTED ZO  7.99 R\n"];
    [textData appendString:@"458 AQUA MICROTERRY SC  6.99 R\n"];
    [textData appendString:@"493 30L BLK FF DRESS   16.99 R\n"];
    [textData appendString:@"407 LEVITATING DESKTOP  7.99 R\n"];
    [textData appendString:@"441 **Blue Overprint P  2.99 R\n"];
    [textData appendString:@"476 REPOSE 4PCPM CHOC   5.49 R\n"];
    [textData appendString:@"461 WESTGATE BLACK 25  59.99 R\n"];
    [textData appendString:@"------------------------------\n"];

    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    // Section 3 : Payment infomation
    [textData appendString:@"SUBTOTAL                160.38\n"];
    [textData appendString:@"TAX                      14.43\n"];
    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    result = [printer_ addTextSize:2 height:2];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addTextSize"];
        return NO;
    }

    result = [printer_ addText:@"TOTAL    174.81\n"];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }

    result = [printer_ addTextSize:1 height:1];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addTextSize"];
        return NO;
    }

    result = [printer_ addFeedLine:1];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }

    [textData appendString:@"CASH                    200.00\n"];
    [textData appendString:@"CHANGE                   25.19\n"];
    [textData appendString:@"------------------------------\n"];
    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    // Section 4 : Advertisement
    [textData appendString:@"Purchased item total number\n"];
    [textData appendString:@"Sign Up and Save !\n"];
    [textData appendString:@"With Preferred Saving Card\n"];
    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    result = [printer_ addFeedLine:2];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }

    result = [printer_ addBarcode:@"01209457"
              type:EPOS2_BARCODE_CODE39
              hri:EPOS2_HRI_BELOW
              font:EPOS2_FONT_A
              width:barcodeWidth
              height:barcodeHeight];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addBarcode"];
        return NO;
    }

    result = [printer_ addCut:EPOS2_CUT_FEED];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addCut"];
        return NO;
    }

    return YES;
}

- (BOOL)createCouponData
{
    int result = EPOS2_SUCCESS;

    const int barcodeWidth = 2;
    const int barcodeHeight = 64;

    if (printer_ == nil) {
        return NO;
    }

    UIImage *coffeeData = [UIImage imageNamed:@"coffee.png"];
    UIImage *wmarkData = [UIImage imageNamed:@"wmark.png"];

    if (coffeeData == nil || wmarkData == nil) {
        return NO;
    }

    result = [printer_ addPageBegin];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addPageBegin"];
        return NO;
    }

    result = [printer_ addPageArea:0 y:0 width:PAGE_AREA_WIDTH height:PAGE_AREA_HEIGHT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addPageArea"];
        return NO;
    }

    result = [printer_ addPageDirection:EPOS2_DIRECTION_TOP_TO_BOTTOM];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addPageDirection"];
        return NO;
    }

    result = [printer_ addPagePosition:0 y:coffeeData.size.height];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addPagePosition"];
        return NO;
    }

    result = [printer_ addImage:coffeeData x:0 y:0
              width:coffeeData.size.width
              height:coffeeData.size.height
              color:EPOS2_PARAM_DEFAULT
              mode:EPOS2_PARAM_DEFAULT
              halftone:EPOS2_PARAM_DEFAULT
              brightness:3
              compress:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addImage"];
        return NO;
    }

    result = [printer_ addPagePosition:0 y:wmarkData.size.height];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addPagePosition"];
        return NO;
    }

    result = [printer_ addImage:wmarkData x:0 y:0
              width:wmarkData.size.width
              height:wmarkData.size.height
              color:EPOS2_PARAM_DEFAULT
              mode:EPOS2_PARAM_DEFAULT
              halftone:EPOS2_PARAM_DEFAULT
              brightness:EPOS2_PARAM_DEFAULT
              compress:EPOS2_PARAM_DEFAULT];

    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addImage"];
        return NO;
    }

    result = [printer_ addPagePosition:FONT_A_WIDTH * 4 y:(PAGE_AREA_HEIGHT / 2) - (FONT_A_HEIGHT * 2)];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addPagePosition"];
        return NO;
    }

    result = [printer_ addTextSize:3 height:3];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addTextSize"];
        return NO;
    }

    result = [printer_ addTextStyle:EPOS2_PARAM_DEFAULT ul:EPOS2_PARAM_DEFAULT em:EPOS2_TRUE color:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addTextStyle"];
        return NO;
    }

    result = [printer_ addTextSmooth:EPOS2_TRUE];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addTextSmooth"];
        return NO;
    }

    result = [printer_ addText:@"FREE Coffee\n"];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }

    result = [printer_ addPagePosition:(PAGE_AREA_WIDTH / barcodeWidth) - BARCODE_WIDTH_POS y:coffeeData.size.height + BARCODE_HEIGHT_POS];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addPagePosition"];
        return NO;
    }

    result = [printer_ addBarcode:@"01234567890" type:EPOS2_BARCODE_UPC_A hri:EPOS2_PARAM_DEFAULT font: EPOS2_PARAM_DEFAULT width:barcodeWidth height:barcodeHeight];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addBarocde"];
        return NO;
    }

    result = [printer_ addPageEnd];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addPageEnd"];
        return NO;
    }

    result = [printer_ addCut:EPOS2_CUT_FEED];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addCut"];
        return NO;
    }

    return YES;
}

- (BOOL)printData2
{
    int result = EPOS2_SUCCESS;

    Epos2PrinterStatusInfo *status = nil;

    if (printer_ == nil) {
        return NO;
    }

    if (![self connectPrinter]) {
        return NO;
    }

    status = [printer_ getStatus];
    [self dispPrinterWarnings:status];

    if (![self isPrintable:status]) {
        [ShowMsg show:[self makeErrorMessage:status]];
        [printer_ disconnect];
        return NO;
    }

    result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"sendData"];
        [printer_ disconnect];
        return NO;
    }

    return YES;
}

- (BOOL)initializeObject
{
    printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerSeries_ lang:lang_];

    if (printer_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
        return NO;
    }

    [printer_ setReceiveEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (printer_ == nil) {
        return;
    }

    [printer_ clearCommandBuffer];

    [printer_ setReceiveEventDelegate:nil];

    printer_ = nil;
}

-(BOOL)connectPrinter:(CDVInvokedUrlCommand *)command
{
    int result = EPOS2_SUCCESS;
    NSString* ipadress = [command.arguments objectAtIndex:0];
    NSlog(@"%@", ipadress);

    if (printer_ == nil) {
        return NO;
    }

    result = [printer_ connect:ipadress timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        return NO;
    }

    result = [printer_ beginTransaction];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"beginTransaction"];
        [printer_ disconnect];
        return NO;
    }

    return YES;
}

- (void)disconnectPrinter
{
    int result = EPOS2_SUCCESS;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    if (printer_ == nil) {
        return;
    }

    result = [printer_ endTransaction];
    if (result != EPOS2_SUCCESS) {
        [dict setObject:[NSNumber numberWithInt:result] forKey:KEY_RESULT];
        [dict setObject:@"endTransaction" forKey:KEY_METHOD];
        [self performSelectorOnMainThread:@selector(showEposErrorFromThread:) withObject:dict waitUntilDone:NO];
    }

    result = [printer_ disconnect];
    if (result != EPOS2_SUCCESS) {
        [dict setObject:[NSNumber numberWithInt:result] forKey:KEY_RESULT];
        [dict setObject:@"disconnect" forKey:KEY_METHOD];
        [self performSelectorOnMainThread:@selector(showEposErrorFromThread:) withObject:dict waitUntilDone:NO];
    }
    [self finalizeObject];
}

- (void)showEposErrorFromThread:(NSDictionary *)dict
{
    int result = EPOS2_SUCCESS;
    NSString *method = @"";
    result = [[dict valueForKey:KEY_RESULT] intValue];
    method = [dict valueForKey:KEY_METHOD];
    [ShowMsg showErrorEpos:result method:method];
}

- (BOOL)isPrintable:(Epos2PrinterStatusInfo *)status
{
    if (status == nil) {
        return NO;
    }

    if (status.connection == EPOS2_FALSE) {
        return NO;
    }
    else if (status.online == EPOS2_FALSE) {
        return NO;
    }
    else {
        ;//print available
    }

    return YES;
}

- (void) onPtrReceive:(Epos2Printer *)printerObj code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId
{
    [ShowMsg showResult:code errMsg:[self makeErrorMessage:status]];

    [self dispPrinterWarnings:status];
    [self updateButtonState:YES];

    [self performSelectorInBackground:@selector(disconnectPrinter) withObject:nil];
}

- (void)dispPrinterWarnings:(Epos2PrinterStatusInfo *)status
{
    NSMutableString *warningMsg = [[NSMutableString alloc] init];

    if (status == nil) {
        return;
    }

    _textWarnings.text = @"";

    if (status.paper == EPOS2_PAPER_NEAR_END) {
        [warningMsg appendString:NSLocalizedString(@"warn_receipt_near_end", @"")];
    }

    if (status.batteryLevel == EPOS2_BATTERY_LEVEL_1) {
        [warningMsg appendString:NSLocalizedString(@"warn_battery_near_end", @"")];
    }

    _textWarnings.text = warningMsg;
}

- (NSString *)makeErrorMessage:(Epos2PrinterStatusInfo *)status
{
    NSMutableString *errMsg = [[NSMutableString alloc] initWithString:@""];

    if (status.getOnline == EPOS2_FALSE) {
        [errMsg appendString:NSLocalizedString(@"err_offline", @"")];
    }
    if (status.getConnection == EPOS2_FALSE) {
        [errMsg appendString:NSLocalizedString(@"err_no_response", @"")];
    }
    if (status.getCoverOpen == EPOS2_TRUE) {
        [errMsg appendString:NSLocalizedString(@"err_cover_open", @"")];
    }
    if (status.getPaper == EPOS2_PAPER_EMPTY) {
        [errMsg appendString:NSLocalizedString(@"err_receipt_end", @"")];
    }
    if (status.getPaperFeed == EPOS2_TRUE || status.getPanelSwitch == EPOS2_SWITCH_ON) {
        [errMsg appendString:NSLocalizedString(@"err_paper_feed", @"")];
    }
    if (status.getErrorStatus == EPOS2_MECHANICAL_ERR || status.getErrorStatus == EPOS2_AUTOCUTTER_ERR) {
        [errMsg appendString:NSLocalizedString(@"err_autocutter", @"")];
        [errMsg appendString:NSLocalizedString(@"err_need_recover", @"")];
    }
    if (status.getErrorStatus == EPOS2_UNRECOVER_ERR) {
        [errMsg appendString:NSLocalizedString(@"err_unrecover", @"")];
    }

    if (status.getErrorStatus == EPOS2_AUTORECOVER_ERR) {
        if (status.getAutoRecoverError == EPOS2_HEAD_OVERHEAT) {
            [errMsg appendString:NSLocalizedString(@"err_overheat", @"")];
            [errMsg appendString:NSLocalizedString(@"err_head", @"")];
        }
        if (status.getAutoRecoverError == EPOS2_MOTOR_OVERHEAT) {
            [errMsg appendString:NSLocalizedString(@"err_overheat", @"")];
            [errMsg appendString:NSLocalizedString(@"err_motor", @"")];
        }
        if (status.getAutoRecoverError == EPOS2_BATTERY_OVERHEAT) {
            [errMsg appendString:NSLocalizedString(@"err_overheat", @"")];
            [errMsg appendString:NSLocalizedString(@"err_battery", @"")];
        }
        if (status.getAutoRecoverError == EPOS2_WRONG_PAPER) {
            [errMsg appendString:NSLocalizedString(@"err_wrong_paper", @"")];
        }
    }
    if (status.getBatteryLevel == EPOS2_BATTERY_LEVEL_0) {
        [errMsg appendString:NSLocalizedString(@"err_battery_real_end", @"")];
    }

    return errMsg;
}

- (void)onSelectPrinter:(NSString *)target
{
    _textTarget.text = "TCP:192.168.100.22";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *view = nil;

    if ([segue.identifier isEqualToString:@"DiscoveryView"]) {

        view = (DiscoveryViewController *)[segue destinationViewController];

        ((DiscoveryViewController *)view).delegate = self;
    }
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == printerList_) {
        [_buttonPrinter setTitle:[printerList_ getItem:position] forState:UIControlStateNormal];
        printerSeries_ = (int)printerList_.selectIndex;
    }
    else if (obj == langList_) {
        [_buttonLang setTitle:[langList_ getItem:position] forState:UIControlStateNormal];
        lang_ = (int)langList_.selectIndex;

    }
    else {
        ; //do nothing
    }
}
@end
