//
//  CorsairApi.m
//  CorsairApi
//
//  Created by Chris Engelhardt on 23.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

#import "CorsairApi.h"
#include "device.h"

#include "driver.h"

#include <libusb.h>



@implementation CorsairApi

@synthesize numberOfValidDevices;

+ (CorsairApi*)sharedInstance{
    static CorsairApi *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CorsairApi alloc] init];
    });
    return sharedInstance;
}


-(id)init{
    self = [super init];
    lusbQueue = [[NSOperationQueue alloc] init];
    [lusbQueue setMaxConcurrentOperationCount:1];
    [lusbQueue setQualityOfService: NSQualityOfServiceUserInteractive];
    return self;
}


- (void) setup :(void (^)(void)) success  failed : (void (^)(NSString*))failed{
    [lusbQueue addOperationWithBlock:^{
        [self close];
        self->device = nil;
        self->handle = nil;
        self->context = nil;
        int libUsbInit = libusb_init( &self->context );
        if ( libUsbInit < 0 ){
            failed(@"Failed to initialize libusb");
            msg_debug( "Init Error %d\n", libUsbInit );
            return;
        }
        self->numberOfValidDevices = 0;
        //scan for devices
        int state = corsairlink_device_scanner( self->context, &self->numberOfValidDevices );
        if(self->numberOfValidDevices < 1 || state != 0){
            failed(@"No Device found");
            return;
        }
        success();
    }];
}

- (void) setDevice : (int) deviceNumber success : (void (^)(void))success failed : (void (^)(NSString*))failed{
    [lusbQueue addOperationWithBlock:^{
        
        if(deviceNumber > self->numberOfValidDevices && self->context != nil){
            failed(@"Device out of range");
            return;
        }
        
        self->device = scanlist[deviceNumber].device;
        self->handle = scanlist[deviceNumber].handle;
        self->device->driver->init( self->handle, self->device->write_endpoint );
        msg_debug( "DEBUG: init done\n" );
        
        char name[32];
        name[sizeof( name ) - 1] = 0;
        
        if (self->device->driver->fw_version( self->device, self->handle, name, sizeof( name ) ) == 0){
            success();
        }else{
            failed(@"Nop");
        }
        
    }];
    
}


-(void) close {
    if( device != nil && handle != nil){
        corsairlink_close( self->context );
        device = nil;
        handle = nil;
        context = nil;
    }
}


- (void) getVendorNameAt :(void (^)(NSString*))success{
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){ return; }
        
        char name[32];
        name[sizeof( name ) - 1] = 0;
        
        /* fetch device name, vendor name, product name */
        self->device->driver->vendor( self->device, self->handle, name, sizeof( name ) );
        success([[NSString alloc] initWithUTF8String:name]);
        
    }];
}


- (void) getFirmwareNameAt : (void (^)(NSString*))success{
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){ return; }
        
        char name[32];
        name[sizeof( name ) - 1] = 0;
        
        self->device->driver->fw_version( self->device, self->handle, name, sizeof( name ) );
        success([[NSString alloc] initWithUTF8String:name]);
    }];
}

- (void) getDeviceNameAt : (void (^)(NSString*))success{
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){ return; }
        success([[NSString alloc]initWithUTF8String:self->device->name]);
    }];
}




-(void) getTemperatureSensorsCount : (void (^)(int))success {
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){
            success(nil);
            return; }
        uint8_t sensorsCount = 0;
        self->device->driver->temperature.count( self->device, self->handle, &sensorsCount);
        success(sensorsCount);
    }];
}


- ( void ) getDeviceTemperature : (void (^)(NSArray*))success{
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){ return; }
        
        uint8_t sensorsCount = 0;
        self->device->driver->temperature.count( self->device, self->handle, &sensorsCount );
       
        char name[32];
        name[sizeof( name ) - 1] = 0;
        double temperature = 0.0;
        
        NSMutableArray* temps = [[NSMutableArray alloc]initWithCapacity:sensorsCount];
        /* fetch temperatures */
        for ( int i = 0; i < sensorsCount; i++ ){
            int i = self->device->driver->temperature.read( self->device, self->handle, 0, &temperature );
            if (i != 0){
                success(nil);
            }
            [temps addObject:[NSNumber numberWithDouble:temperature]];
        }
        success(temps);
    }];
}

- (void) getFansInfo : (void (^)(NSDictionary*))success {
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){ return; }
        struct corsair_device_info* device = self->device;
        struct libusb_device_handle* handle = self->handle;
        
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        struct option_parse_return readings;
        device->driver->fan.count( device, handle, &readings.fan_ctrl );
        
        for ( int ii = 0; ii < readings.fan_ctrl.fan_count; ii++ ){
            readings.fan_ctrl.channel = ii;
            device->driver->fan.profile.read_profile( device, handle, &readings.fan_ctrl );
            device->driver->fan.print_mode(
                                           readings.fan_ctrl.mode, readings.fan_ctrl.data, readings.fan_ctrl.mode_string,
                                           sizeof( readings.fan_ctrl.mode_string ) );
            device->driver->fan.speed( device, handle, &readings.fan_ctrl );
            
            NSMutableDictionary* fan = [[NSMutableDictionary alloc] init];
            [fan setObject: [NSNumber numberWithInt: readings.fan_ctrl.speed_rpm] forKey:@"speed"];
            [fan setObject: [NSNumber numberWithInt: readings.fan_ctrl.max_speed] forKey:@"maxSpeed"];
            [fan setObject: [[NSString alloc]initWithUTF8String:readings.fan_ctrl.mode_string] forKey:@"mode"];
            
            [dict setObject:fan forKey:[[NSString alloc]initWithFormat:@"%d",ii]];
        }
        
        success(dict);
        
    }];
}


- (void) getPumpInfo : (void (^)(NSDictionary*))success {
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){ return; }
        struct option_parse_return readings;
        struct corsair_device_info* device = self->device;
        struct libusb_device_handle* handle = self->handle;
        
        
        device->driver->pump.profile.read_profile( device, handle, &readings.pump_ctrl );
        device->driver->pump.speed( device, handle, &readings.pump_ctrl );
        
        NSMutableDictionary* pump = [[NSMutableDictionary alloc] init];
        [pump setObject: [NSNumber numberWithInt: readings.pump_ctrl.max_speed] forKey:@"maxSpeed"];
        [pump setObject: [NSNumber numberWithInt: readings.pump_ctrl.speed_rpm] forKey:@"speed"];
        [pump setObject: [[NSString alloc]initWithUTF8String: AsetekProPumpModes_String[readings.pump_ctrl.mode] ] forKey:@"mode"];
        
        success(pump);
        
    }];
}


- (void) setLightMode : (int8_t) argc : (NSArray*) argv  success:(void (^)(void))success failed:(void (^)(void))failed;{
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){
            failed();
            return;
        }
        
        struct option_flags flags;
        struct option_parse_return settings;
        struct corsair_device_info* device = self->device;
        struct libusb_device_handle* handle = self->handle;
        char** a = cArrayFromNSArray(argv);
        int8_t unused = 0;
        options_parse( argc, a, &flags, &unused, &settings );
        
        msg_debug( "Setting LED Flag found\n" );
        switch ( settings.led_ctrl.mode ){
            case BLINK:
                msg_debug( "Setting LED to BLINK\n" );
                device->driver->led.blink( device, handle, &settings.led_ctrl );
                break;
            case PULSE:
                msg_debug( "Setting LED to PULSE\n" );
                device->driver->led.color_pulse( device, handle, &settings.led_ctrl );
                break;
            case SHIFT:
                msg_debug( "Setting LED to SHIFT\n" );
                device->driver->led.color_shift( device, handle, &settings.led_ctrl );
                break;
            case RAINBOW:
                msg_debug( "Setting LED to RAINBOW\n" );
                device->driver->led.rainbow( device, handle, &settings.led_ctrl );
                break;
            case TEMPERATURE:
                msg_debug( "Setting LED to TEMPERATURE\n" );
                device->driver->led.temperature( device, handle, &settings.led_ctrl );
                break;
            case STATIC:
            default:
                msg_debug( "Setting LED STATIC\n" );
                device->driver->led.static_color( device, handle, &settings.led_ctrl );
                break;
        }
        
        success();
    }];
    
}

- (void) setStaticLight : (int8_t) channel : (NSString*) color success:(void (^)(void))success failed:(void (^)(void))failed;{
    [lusbQueue addOperationWithBlock:^{
        
        if(self->device == nil || self->handle == nil){
            failed();
            return;
        }
        
        struct corsair_device_info* device = self->device;
        struct libusb_device_handle* handle = self->handle;
        struct led_control led_ctrl;
        
        //basics set everytime
        led_ctrl.count = 7;
        led_ctrl.speed = 3;
        led_ctrl.temperatures[0] = 35;
        led_ctrl.temperatures[1] = 45;
        led_ctrl.temperatures[2] = 55;
        
        led_ctrl.channel = channel;
        led_ctrl.mode = 0;
        sscanf( [color UTF8String], "%02hhX%02hhX%02hhX,", &led_ctrl.led_colors[0].red, &led_ctrl.led_colors[0].green, &led_ctrl.led_colors[0].blue );
        device->driver->led.static_color( device, handle, &led_ctrl );
        
        success();
    }];
    
}


- (void) setFanMode : (int8_t) argc : (NSArray*) argv  success:(void (^)(void))success failed:(void (^)(void))failed;{
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){
            failed();
            return;
        }
        struct option_flags flags;
        struct option_parse_return settings;
        struct corsair_device_info* device = self->device;
        struct libusb_device_handle* handle = self->handle;
        char** a = cArrayFromNSArray(argv);
        int8_t unused = 0;
        options_parse( argc, a, &flags, &unused, &settings );
        
        msg_info( "Setting pump to mode: %u\n", settings.pump_ctrl.mode );
        settings.pump_ctrl.channel = device->pump_index;
        msg_info( "Setting fan to mode: %u\n", settings.fan_ctrl.mode );
        switch ( settings.fan_ctrl.mode ){
            case PWM:
                device->driver->fan.profile.write_pwm( device, handle, &settings.fan_ctrl );
                break;
            case RPM:
                device->driver->fan.profile.write_rpm( device, handle, &settings.fan_ctrl );
                break;
            case QUIET:
                device->driver->fan.profile.write_profile_quiet( device, handle, &settings.fan_ctrl );
                break;
            case DEFAULT:
            case BALANCED:
                device->driver->fan.profile.write_profile_balanced( device, handle, &settings.fan_ctrl );
                break;
            case PERFORMANCE:
                device->driver->fan.profile.write_profile_performance( device, handle, &settings.fan_ctrl );
                break;
            case CUSTOM:
                device->driver->fan.profile.write_custom_curve( device, handle, &settings.fan_ctrl );
                break;
            default:
                msg_info( "Unsupported AsetekPro Fan Mode\n" );
                break;
        }
        success();
    }];
}

- (void) setPumpMode : (int8_t) argc : (NSArray*) argv  success:(void (^)(void))success failed:(void (^)(void))failed;{
    [lusbQueue addOperationWithBlock:^{
        if(self->device == nil || self->handle == nil){
            failed();
            return;
        }
        
        struct option_flags flags;
        struct option_parse_return settings;
        struct corsair_device_info* device = self->device;
        struct libusb_device_handle* handle = self->handle;
        char** a = cArrayFromNSArray(argv);
        int8_t unused = 0;
        options_parse( argc, a, &flags, &unused, &settings );
        
        msg_info( "Setting pump to mode: %u\n", settings.pump_ctrl.mode );
        settings.pump_ctrl.channel = device->pump_index;
        switch ( settings.pump_ctrl.mode ){
            case QUIET:
                ASETEK_FAN_TABLE_QUIET( settings.pump_ctrl.table );
                device->driver->pump.profile.write_profile_quiet( device, handle, &settings.pump_ctrl );
                break;
            case BALANCED:
                ASETEK_FAN_TABLE_BALANCED( settings.pump_ctrl.table );
                device->driver->pump.profile.write_profile_balanced( device, handle, &settings.pump_ctrl );
                break;
            case PERFORMANCE:
                ASETEK_FAN_TABLE_EXTREME( settings.pump_ctrl.table );
                device->driver->pump.profile.write_profile_performance( device, handle, &settings.pump_ctrl );
                break;
            case CUSTOM:
            default:
                device->driver->pump.profile.write_custom_curve( device, handle, &settings.pump_ctrl );
                break;
        }
        success();
    }];
}
@end
