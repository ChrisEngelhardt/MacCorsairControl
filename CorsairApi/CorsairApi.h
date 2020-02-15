//
//  CorsairApi.h
//  CorsairApi
//
//  Created by Chris Engelhardt on 23.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "device.h"
#include "driver.h"
#include "logic/options.h"
#include "logic/scan.h"
#include "print.h"
#include "protocol/asetek.h"
#include "protocol/asetekpro.h"


#include "Helper.h"
@interface CorsairApi : NSObject{
    libusb_context* context;
    NSOperationQueue *lusbQueue;
    struct corsair_device_info* device;
    struct libusb_device_handle* handle;
}


+ (CorsairApi*)sharedInstance;
@property (nonatomic, readonly) int numberOfValidDevices;

- (void) close;

- (void) setup :(void (^)(void)) success  failed : (void (^)(NSString*))failed;
- (void) setDevice : (int) deviceNumber success : (void (^)(void))success failed : (void (^)(NSString*))failed;
- (void) getDeviceNameAt : (void (^)(NSString*))success;
- (void) getVendorNameAt : (void (^)(NSString*))success;
- (void) getFirmwareNameAt : (void (^)(NSString*))success;
- (void) getTemperatureSensorsCount : (void (^)(int))success;
- (void) getDeviceTemperature : (void (^)(NSArray*))success;
- (void) getFansInfo : (void (^)(NSDictionary*))success;

- (void) setLightMode : (int8_t) argc : (NSArray*) argv  success:(void (^)(void))success failed:(void (^)(void))failed;
- (void) setStaticLight :(int8_t) channel : (NSString*) color success:(void (^)(void))success failed:(void (^)(void))failed;
- (void) setFanMode : (int8_t) argc : (NSArray*) argv  success:(void (^)(void))success failed:(void (^)(void))failed;
- (void) setPumpMode : (int8_t) argc : (NSArray*) argv  success:(void (^)(void))success failed:(void (^)(void))failed;


@end
