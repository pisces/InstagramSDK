//
//  InstagramSDKMacros.h
//  InstagramSDK
//
//  Created by pisces on 2015. 5. 14..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#ifndef InstagramSDK_InstagramSDKMacros_h
#define InstagramSDK_InstagramSDKMacros_h

#ifdef __cplusplus
#define IGSDK_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define IGSDK_EXTERN extern __attribute__((visibility ("default")))
#endif

#endif
