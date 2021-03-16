package org.unicellular.otaku.aliplayer;

import android.content.Context;
import android.view.Surface;

import androidx.annotation.NonNull;

import com.aliyun.player.AliPlayer;
import com.aliyun.player.AliPlayerFactory;
import com.aliyun.player.nativeclass.TrackInfo;

import org.unicellular.otaku.aliplayer.listener.OnAVPCompletionListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPErrorListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPInfoListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPLoadingStatusListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPPreparedListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPRenderingStartListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPSeekCompleteListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPSeiDataListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPSnapShotListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPStateChangedListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPSubtitleDisplayListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPTrackChangedListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPVideoRenderedListener;
import org.unicellular.otaku.aliplayer.listener.OnAVPVideoSizeChangedListener;
import org.unicellular.otaku.aliplayer.util.SourceUtil;
import org.unicellular.otaku.aliplayer.util.StrKit;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public final class AliyunPlayer {

    /**
     * 播放器实例对象
     */
    private AliPlayer mAliPlayer;

    private Surface mSurface;
    private final TextureRegistry.SurfaceTextureEntry textureEntry;

    private AliQueuingEventSink eventSink = new AliQueuingEventSink();

    private final EventChannel eventChannel;

    private boolean isInitialized = false;

    public void initialized() {
        this.isInitialized = true;
        // 解决只有声音没有图像的问题
        this.textureEntry.surfaceTexture().setDefaultBufferSize(this.mAliPlayer.getVideoWidth(), this.mAliPlayer.getVideoHeight());
    }

    public AliyunPlayer(Context context, EventChannel eventChannel, TextureRegistry.SurfaceTextureEntry textureEntry,
                        String sourceType, String source) {
        this.eventChannel = eventChannel;
        this.textureEntry = textureEntry;

        initPlayer(context, eventChannel, textureEntry);

        if (sourceType != null && source != null)
            SourceUtil.process(sourceType, source, this.mAliPlayer);
    }

    private void initPlayer(Context context, EventChannel eventChannel, TextureRegistry.SurfaceTextureEntry textureEntry) {
        mAliPlayer = AliPlayerFactory.createAliPlayer(context);
//        mAliPlayer.setAutoPlay(true);

        // 注册android向flutter发事件
        eventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink.setDelegate(events);
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink.setDelegate(null);
                    }
                }
        );

        mSurface = new Surface(textureEntry.surfaceTexture());
        mAliPlayer.setSurface(mSurface);

        initPlayerListener();
    }

    private void initPlayerListener() {
        mAliPlayer.setOnInfoListener(new OnAVPInfoListener(eventSink));
        mAliPlayer.setOnErrorListener(new OnAVPErrorListener(eventSink));
        mAliPlayer.setOnSeiDataListener(new OnAVPSeiDataListener(eventSink));
        mAliPlayer.setOnSnapShotListener(new OnAVPSnapShotListener(eventSink));
        mAliPlayer.setOnPreparedListener(new OnAVPPreparedListener(eventSink, this.mAliPlayer, this));
        mAliPlayer.setOnCompletionListener(new OnAVPCompletionListener(eventSink));
        mAliPlayer.setOnTrackChangedListener(new OnAVPTrackChangedListener(eventSink));
        mAliPlayer.setOnSeekCompleteListener(new OnAVPSeekCompleteListener(eventSink));
        mAliPlayer.setOnVideoRenderedListener(new OnAVPVideoRenderedListener(eventSink));
        mAliPlayer.setOnLoadingStatusListener(new OnAVPLoadingStatusListener(eventSink));
        mAliPlayer.setOnRenderingStartListener(new OnAVPRenderingStartListener(eventSink));
//        mAliPlayer.setOnVerifyStsCallback(new OnAVPVerifyStsCallback(eventSink));
        mAliPlayer.setOnStateChangedListener(new OnAVPStateChangedListener(eventSink));
        mAliPlayer.setOnSubtitleDisplayListener(new OnAVPSubtitleDisplayListener(eventSink));
        mAliPlayer.setOnVideoSizeChangedListener(new OnAVPVideoSizeChangedListener(eventSink));
    }

    public void dispose() {
        if (isInitialized) {
            this.mAliPlayer.stop();
        }
        textureEntry.release();
        eventChannel.setStreamHandler(null);
        if (mSurface != null) {
            mSurface.release();
        }
        if (this.mAliPlayer != null) {
            this.mAliPlayer.setSurface(null);
            this.mAliPlayer.release();
        }
    }

    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "player_set_source":
                String type = call.argument("type");
                String source = call.argument("source");
                if (StrKit.isBlank(type) || StrKit.isBlank(source)) {
                    result.error(
                            "Param blank",
                            "Param type and source cannot be blank",
                            null);
                } else {
                    setDataSource(type, source);
                }
                result.success(null);
                break;
            case "player_prepare":
                this.mAliPlayer.prepare();
                result.success(null);
                break;
            case "player_start":
                this.mAliPlayer.start();
                result.success(null);
                break;
            case "player_pause":
                this.mAliPlayer.pause();
                result.success(null);
                break;
            case "player_set_speed":
                Double speed = call.argument("speed");
                if (speed != null) {
                    this.mAliPlayer.setSpeed(speed.floatValue());
                }
                result.success(null);
                break;
            case "player_get_speed":
                result.success(this.mAliPlayer.getSpeed());
                break;
            case "player_get_track":
                List<TrackInfo> info = this.mAliPlayer.getMediaInfo().getTrackInfos();
                List<String> list = new ArrayList<>();
                for (TrackInfo i : info) {
                    list.add(i.getVodDefinition());
                }
                result.success(list);
                break;
            case "player_set_track":
                Integer index = call.argument("index");
                if (index != null) {
                    this.mAliPlayer.selectTrack(index, true);
                }
                result.success(null);
                break;
            case "player_seek_to":
                int position = call.argument("position");
                BigDecimal b = new BigDecimal(position);
                this.mAliPlayer.seekTo(b.longValue());
                result.success(null);
                break;
            case "player_dispose":
                dispose();
                result.success(null);
                break;
            case "player_set_loop":
                Boolean isLoop = call.argument("isLoop");
                if (isLoop != null) {
                    this.mAliPlayer.setLoop(isLoop);
                }
                result.success(null);
                break;
            default:
                result.notImplemented();
        }
    }

    private void setDataSource(String type, String source) {
        this.mAliPlayer.stop();
        SourceUtil.process(type, source, this.mAliPlayer);
        this.mAliPlayer.prepare();
        this.mAliPlayer.start();
    }
}
