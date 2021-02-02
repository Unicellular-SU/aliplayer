#import "AliplayerPlugin.h"
#import "AliyunPlayer.h"

@implementation AliplayerPlugin{
    NSObject<FlutterPluginRegistrar> *_registrar;
    NSMutableDictionary<NSNumber *, AliyunPlayer *> *_players;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"aliplayer"
            binaryMessenger:[registrar messenger]];
  AliplayerPlugin* instance = [[AliplayerPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];

}
- (instancetype)initWithRegistrar:
    (NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        _registrar = registrar;
        _players = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *argsMap = call.arguments;
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
      if ([@"player_create" isEqualToString:call.method]) {
          //每次创建之前先销毁之前的
          [self destroy];
          AliyunPlayer *player = [[AliyunPlayer alloc] initWithRegistrar:_registrar];
          _players[player.textureId] = player;
          result(player.textureId);
      }else{
          NSNumber *tid = argsMap[@"textureId"];
          AliyunPlayer *player = [_players objectForKey:tid];
          [player onMethodCall:call result:result];
      }
    result(FlutterMethodNotImplemented);
  }
}

- (void)destroy{
    
}

@end
