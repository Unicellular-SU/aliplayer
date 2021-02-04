//
//  AliyunPlayer.m
//  aliplayer
//
//  Created by 苏紫成 on 2020/10/10.
//

#import "AliyunPlayer.h"
#import "AliyunPlayer/AliPlayer.h"
#import <libkern/OSAtomic.h>
#import <stdatomic.h>
#import "AliyunPlayer/VidPlayerConfigGen.h"


@implementation AliyunPlayer  {
    FlutterEventChannel *eventChannel;
    FlutterEventSink eventSink;
    id<FlutterPluginRegistrar> _registrar;
    id<FlutterTextureRegistry> _textureRegistry;
    
    AliPlayer *_aliPlayer;
    
    CVPixelBufferRef volatile _latestPixelBuffer;
    CVPixelBufferRef _lastBuffer;
    
    int64_t _tid;
    
    UIView *playerView;
}




- (instancetype)initWithRegistrar:(id<FlutterPluginRegistrar>)registrar {
    self = [super self];
    if (self) {
        _registrar = registrar;
        _tid = -1;
        _latestPixelBuffer = nil;
        _lastBuffer = nil;
        
        [self setupSurface];
        
        _textureId = @(_tid);
        
        ///初始化view
        _aliPlayer = [[AliPlayer alloc] init];
        _aliPlayer.autoPlay = YES;
        playerView = [[UIView alloc] init];
//        playerView.frame = CGRectMake(0, 0, 414, 300);
        _aliPlayer.playerView = playerView;
        _aliPlayer.delegate = self;
        _aliPlayer.renderDelegate = self;
        _aliPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFILL;
        _aliPlayer.enableHardwareDecoder = YES;
        
        [self messenger:[registrar messenger]];
    }
    
    return self;
}

- (void)messenger:(NSObject <FlutterBinaryMessenger> *)messenger {
    
    eventChannel = [FlutterEventChannel
                    eventChannelWithName:[NSString stringWithFormat:@"aliplayer/videoEvents%lld",_tid]
                    binaryMessenger:messenger];
    
    [eventChannel setStreamHandler:self];
}

- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"call method:%@", call.method);
    if ([call.method isEqualToString:@"player_prepare"]) {
        [_aliPlayer prepare];
        result(nil);
    }else if ([call.method isEqualToString:@"player_start"]) {
        [_aliPlayer start];
        result(nil);
    } else if ([call.method isEqualToString:@"player_pause"]) {
        [_aliPlayer pause];
        result(nil);
    } else if ([call.method isEqualToString:@"player_get_track"]) {
        AVPMediaInfo* info = [_aliPlayer getMediaInfo];
        NSArray<AVPTrackInfo*>* tracks = info.tracks;
        NSMutableArray *array = [NSMutableArray array];
        for(AVPTrackInfo* obj in tracks){
            [array addObject:obj.trackDefinition];
        }
        NSArray *myArray = [array copy];
        result(myArray);
    } else if ([call.method isEqualToString:@"player_set_track"]) {
        int index = (int) [call.arguments[@"index"] intValue];
        [_aliPlayer selectTrack:index];
        result(nil);
    } else if ([call.method isEqualToString:@"player_seek_to"]) {
        int64_t time = (int64_t) [call.arguments[@"position"] intValue];
        [_aliPlayer seekToTime:time seekMode:AVP_SEEKMODE_INACCURATE];
        result(nil);
    }  else if ([call.method isEqualToString:@"player_set_speed"]){
        float speed = [call.arguments[@"speed"] floatValue];
        [_aliPlayer setRate:speed];
        result(nil);
    } else if ([call.method isEqualToString:@"player_dispose"]){
        [self shutdown];
        result(nil);
    } else if ([call.method isEqualToString:@"player_set_source"]){
        NSString *sourceType = call.arguments[@"type"];
        NSString *source = call.arguments[@"source"];
        
        [self setSource:sourceType sourceJson:source];
        [_aliPlayer prepare];
        
        result(nil);
    }
}

- (void)setSource:(NSString *)sourceType sourceJson: (NSString *)sourceJson {
    NSData *data = [sourceJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([sourceType isEqualToString:@"UrlSource"]) {
        AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:dic[@"uri"]];
        [_aliPlayer setUrlSource:source];
        
    } else if ([sourceType isEqualToString:@"VidSts"]) {
        AVPVidStsSource *source = [[AVPVidStsSource alloc] initWithVid:dic[@"vid"] accessKeyId:dic[@"accessKeyId"] accessKeySecret:dic[@"accessKeySecret"] securityToken:dic[@"securityToken"] region:[self emptyIfNull:dic[@"region"]]];
        
        if (![self isNullOrEmpty:dic[@"playConfig"]]) {
            NSDictionary *playConfig = dic[@"playConfig"];
            if (![self isNullOrEmpty:playConfig[@"configMap"]]) {
                NSDictionary *configMap = playConfig[@"configMap"];
                if (![self isNullOrEmpty:configMap[@"PreviewTime"]]) {
                    int previewTime = [configMap[@"PreviewTime"] intValue];
                    VidPlayerConfigGenerator* vp = [[VidPlayerConfigGenerator alloc] init];
                    [vp setPreviewTime: previewTime]; //试看
                    source.playConfig = [vp generatePlayerConfig];
                }
            }
        }
        
        [_aliPlayer setStsSource:source];
    }
}

- (void)setupSurface {
    if (_tid < 0) {
        _textureRegistry = [_registrar textures];
        int64_t temp = [_textureRegistry registerTexture:self];
        _tid = temp;
    }
}

- (void)shutdown {
    [_aliPlayer destroy];
    if (_tid >= 0) {
        [_textureRegistry unregisterTexture:_tid];
        _tid = -1;
        _textureRegistry = nil;
    }
    
    
    CVPixelBufferRef old = _latestPixelBuffer;
    while (!OSAtomicCompareAndSwapPtrBarrier(old, nil,
                                             (void **)&_latestPixelBuffer)) {
        old = _latestPixelBuffer;
    }
    if (old) {
        CFRelease(old);
    }
    
    if (_lastBuffer) {
        CVPixelBufferRelease(_lastBuffer);
        _lastBuffer = nil;
    }
    
    [eventSink setDelegate:nil];
    eventSink = nil;
    [eventChannel setStreamHandler:nil];
    eventChannel = nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    eventSink = nil;
    return  nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    eventSink = events;
    return nil;
}

- (CVPixelBufferRef _Nullable)copyPixelBuffer {
    CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
    while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil,
                                             (void **)&_latestPixelBuffer)) {
        pixelBuffer = _latestPixelBuffer;
    }
    return pixelBuffer;
}

- (BOOL)onVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer pts:(int64_t)pts {
    
    if (_lastBuffer == nil) {
        _lastBuffer = CVPixelBufferRetain(pixelBuffer);
        CFRetain(pixelBuffer);
    } else if (_lastBuffer != pixelBuffer) {
        CVPixelBufferRelease(_lastBuffer);
        _lastBuffer = CVPixelBufferRetain(pixelBuffer);
        CFRetain(pixelBuffer);
    }
    
    CVPixelBufferRef newBuffer = pixelBuffer;
    
    CVPixelBufferRef old = _latestPixelBuffer;
    while (!OSAtomicCompareAndSwapPtrBarrier(old, newBuffer,
                                             (void **)&_latestPixelBuffer)) {
        old = _latestPixelBuffer;
    }
    
    _latestPixelBuffer = CVPixelBufferRetain(pixelBuffer);
    
    if(newBuffer){
        CFRelease(newBuffer);
    }

    if (old && old != pixelBuffer) {
        CFRelease(old);
    }
    if (_tid >= 0) {
        [_textureRegistry textureFrameAvailable:_tid];
    }
    
    
    return YES;
}

- (void)onPlayerStatusChanged:(AliPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    if (eventSink) {
        eventSink(@{
            @"event": @"stateChanged",
            @"value": @(newStatus)
                  });
    }
}

- (void)onLoadingProgress:(AliPlayer *)player progress:(float)progress{
    eventSink(@{
        @"event": @"loadingProgress",
        @"percent": @(progress),
        @"netSpeed": @(0),
              });
}

- (void)onTrackChanged:(AliPlayer *)player info:(AVPTrackInfo *)info{
    eventSink(@{
        @"event": @"playEvent",
        @"value": @(8)
              });
}

- (void)onVideoSizeChanged:(AliPlayer *)player width:(int)width height:(int)height rotation:(int)rotation {
    eventSink(@{
        @"event": @"videoSizeChanged",
        @"height": @(height),
        @"width": @(width),
              });
}

- (void)onBufferedPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    if (eventSink) {
        eventSink(@{
            @"event": @"bufferedPosition",
            @"value": @(position)
                  });
    }
}

- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    if (eventSink) {
        eventSink(@{
            @"event": @"currentPosition",
            @"value": @(position)
                  });
    }
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"onError:%@", errorModel.message);
    eventSink(@{
        @"event": @"error",
        @"errorMsg": errorModel.message,
        @"errorCode": @([errorModel code])
              });
}



- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    if (eventSink) {
        eventSink(@{
            @"event": @"playEvent",
            @"value": @(eventType)
                  });
    }
    switch (eventType) {
        case AVPEventPrepareDone:{
            AVPMediaInfo *info = [_aliPlayer getMediaInfo];
            int duration = info.duration;
            eventSink(@{
                @"event" : @"prepared",
                @"duration" : @(duration),
                @"width" : @([player width]),
                @"height" : @([player height]),
                      });
            [_aliPlayer start];
        }
            break;
        default:
            break;
    }
}


#pragma mark - 判断是否为空
- (NSString *)emptyIfNull:(id)value
{
    if (value == nil || value == NULL)
    {
        return @"";
    }
    
    if ([value isKindOfClass:[NSNull class]])
    {
        return @"";
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqual:@"<null>"]) {
            return @"";
        }
    }
    
    return value;
}


- (BOOL)isNullOrEmpty:(id)value
{
    if (value == nil || value == NULL)
    {
        return YES;
    }
    
    if ([value isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        if ([(NSString *)value length] == 0) {
            return YES;
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)value count] == 0) {
            return YES;
        }
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)value count] == 0) {
            return YES;
        }
    }
    
    return NO;
}



@end

