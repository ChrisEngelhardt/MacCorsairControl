//
//  main.c
//  Corsair
//
//  Created by Chris Engelhardt on 23.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

#include "device.h"
#include "driver.h"
#include "logic/options.h"
#include "logic/scan.h"
#include "print.h"

#include <errno.h>
#include <libusb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int
commanderpro_settings(
    struct corsair_device_scan scanned_device,
    struct option_flags flags,
    struct option_parse_return settings );

int
hydro_asetek_settings(
    struct corsair_device_scan scanned_device,
    struct option_flags flags,
    struct option_parse_return settings );

int
hydro_asetekpro_settings(
    struct corsair_device_scan scanned_device,
    struct option_flags flags,
    struct option_parse_return settings );

int
hydro_coolit_settings(
    struct corsair_device_scan scanned_device,
    struct option_flags flags,
    struct option_parse_return settings );

int
psu_settings(
    struct corsair_device_scan scanned_device,
    struct option_flags flags,
    struct option_parse_return settings );

int
main( int argc, char* argv[] )
{
    int rr; // result from libusb functions

    int8_t device_number = -1;

    int scanlist_count = 0;

    struct option_flags flags;
    struct option_parse_return settings;

    options_parse( argc, argv, &flags, &device_number, &settings );

    libusb_context* context = NULL;

    rr = libusb_init( &context );
    if ( rr < 0 )
    {
        msg_info( "Init Error %d\n", rr );
        return 1;
    }
    // rr = libusb_set_option( context, LIBUSB_OPTION_LOG_LEVEL, 2 );

    corsairlink_device_scanner( context, &scanlist_count );
    msg_debug( "DEBUG: scan done, start routines\n" );
    msg_debug( "DEBUG: selected device_number = %d\n", device_number );

    if ( device_number >= 0 )
    {
        if ( device_number >= scanlist_count )
        {
            msg_info(
                "Detected %d device(s), submitted device %d is out of range\n", scanlist_count,
                device_number );
        }
        else
        {
            if ( scanlist[device_number].device->driver == &corsairlink_driver_rmi )
            {
                psu_settings( scanlist[device_number], flags, settings );
            }
            else if ( scanlist[device_number].device->driver == &corsairlink_driver_commanderpro )
            {
                commanderpro_settings( scanlist[device_number], flags, settings );
            }
            else if ( scanlist[device_number].device->driver == &corsairlink_driver_asetek )
            {
                hydro_asetek_settings( scanlist[device_number], flags, settings );
            }
            else if ( scanlist[device_number].device->driver == &corsairlink_driver_asetekpro )
            {
                hydro_asetekpro_settings( scanlist[device_number], flags, settings );
            }
            else if ( scanlist[device_number].device->driver == &corsairlink_driver_coolit )
            {
                hydro_coolit_settings( scanlist[device_number], flags, settings );
            }
        }
    }

exit:
    corsairlink_close( context );
    return 0;
}

