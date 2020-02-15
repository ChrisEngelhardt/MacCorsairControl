//
//  Helper.m
//  CorsairApi
//
//  Created by Chris Engelhardt on 25.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

#import <Foundation/Foundation.h>


char ** cArrayFromNSArray ( NSArray* array ){
   int i, count = array.count;
   char **cargs = (char**) malloc(sizeof(char*) * (count + 1));
   for(i = 0; i < count; i++) {        //cargs is a pointer to 4 pointers to char
      NSString *s      = array[i];     //get a NSString
      const char *cstr = s.UTF8String; //get cstring
      int          len = strlen(cstr); //get its length
      char  *cstr_copy = (char*) malloc(sizeof(char) * (len + 1));//allocate memory, + 1 for ending '\0'
      strcpy(cstr_copy, cstr);         //make a copy
       cstr_copy[len] = '\0';
      cargs[i] = cstr_copy;            //put the point in cargs
  }
  cargs[i] = NULL;
  return cargs;
}
