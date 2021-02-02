package org.unicellular.otaku.aliplayer;

import android.content.Context;
import android.util.Log;
import android.util.LongSparseArray;

import androidx.annotation.NonNull;

import cn.hutool.core.util.StrUtil;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.TextureRegistry;

public class AliplayerPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String TAG = "FlutterAliplayerPlugin";
    private final LongSparseArray<AliyunPlayer> videoPlayers = new LongSparseArray<>();

    private FlutterState flutterState;

    public AliplayerPlugin() {
    }

    private AliplayerPlugin(Registrar registrar) {
        this.flutterState = new FlutterState(registrar.context(), registrar.messenger(), registrar.textures(), this);
    }

    public static void registerWith(Registrar registrar) {
        final AliplayerPlugin plugin = new AliplayerPlugin(registrar);
        registrar.addViewDestroyListener(
                new PluginRegistry.ViewDestroyListener() {
                    @Override
                    public boolean onViewDestroy(FlutterNativeView view) {
                        plugin.onDestroy();
                        return false;
                    }
                });
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        this.flutterState = new FlutterState(binding.getApplicationContext(), binding.getBinaryMessenger(),
                binding.getTextureRegistry(), this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (flutterState == null) {
            Log.wtf(TAG, "Detached from the engine before registering to it.");
        }
        flutterState.stopListening();
        flutterState = null;
    }

    private void disposeAllPlayers() {
        for (int i = 0; i < videoPlayers.size(); i++) {
            videoPlayers.valueAt(i).dispose();
        }
        videoPlayers.clear();
    }

    private void onDestroy() {
        disposeAllPlayers();
    }

    public void initialize() {
        disposeAllPlayers();
    }

    public void create(String sourceType, String source, @NonNull Result result) {
        TextureRegistry.SurfaceTextureEntry handle =
                flutterState.textureRegistry.createSurfaceTexture();
        EventChannel eventChannel = new EventChannel(
                flutterState.binaryMessenger, "aliplayer/videoEvents" + handle.id());

        AliyunPlayer player =
                new AliyunPlayer(flutterState.applicationContext, eventChannel, handle, sourceType, source);
        videoPlayers.put(handle.id(), player);

        result.success(handle.id());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.startsWith("player_")) {
            if (call.method.equals("player_create")) {
                String type = call.argument("type");
                String source = call.argument("source");
                if (StrUtil.isBlank(type) || StrUtil.isBlank(source)) {
//          result.error(
//                  "Param blank",
//                  "Param type and source cannot be blank",
//                  null);
                    create(null, null, result);
                } else {
                    create(type, source, result);
                }
            } else {
                Number temp = ((Number) call.argument("textureId"));
                if (temp != null) {
                    long textureId = temp.longValue();
                    AliyunPlayer aliyunPlayer = videoPlayers.get(textureId);
                    if (aliyunPlayer == null) {
                        result.error(
                                "Unknown textureId",
                                "No video player associated with texture id " + textureId,
                                null);
                    } else {
                        aliyunPlayer.onMethodCall(call, result);
                    }
                } else {
                    result.error(
                            "Unknown textureId",
                            "No video player associated with texture id",
                            null);
                }
            }
        } else if (call.method.equals("init")) {
            initialize();
        } else {
            result.notImplemented();
        }
    }

    private static final class FlutterState {
        private final Context applicationContext;
        private final BinaryMessenger binaryMessenger;
        private final TextureRegistry textureRegistry;

        private final MethodChannel channel;

        public FlutterState(Context applicationContext, BinaryMessenger binaryMessenger, TextureRegistry textureRegistry,
                            MethodCallHandler methodCallHandler) {
            this.applicationContext = applicationContext;
            this.binaryMessenger = binaryMessenger;
            this.textureRegistry = textureRegistry;

            this.channel = new MethodChannel(binaryMessenger, "aliplayer");
            channel.setMethodCallHandler(methodCallHandler);
        }

        void stopListening() {
            this.channel.setMethodCallHandler(null);
        }
    }
}
