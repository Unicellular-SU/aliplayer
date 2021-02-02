//
//  AliyunPlayer.h
//  Pods
//
//  Created by 苏紫成 on 2020/10/10.
//

#import <Foundation/Foundation.h>
#import "Flutter/Flutter.h"
#import "AliyunPlayer/AVPDelegate.h"
#import <AliyunPlayer/CicadaRenderDelegate.h>

@interface AliyunPlayer : NSObject<FlutterStreamHandler,FlutterStreamHandler,FlutterTexture,AVPDelegate, CicadaRenderDelegate>

@property NSNumber *textureId;

- (instancetype)initWithRegistrar:(id<FlutterPluginRegistrar>)registrar;
- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

- (void)shutdown;
@end
