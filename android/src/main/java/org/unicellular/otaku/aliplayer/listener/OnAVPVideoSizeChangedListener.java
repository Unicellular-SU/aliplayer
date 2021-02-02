package org.unicellular.otaku.aliplayer.listener;

import android.util.Log;

import com.aliyun.player.IPlayer;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import cn.hutool.core.map.MapUtil;
import cn.hutool.json.JSONUtil;

/**
 * 视频分辨率变化监听
 */
public class OnAVPVideoSizeChangedListener implements IPlayer.OnVideoSizeChangedListener {

    private final AliQueuingEventSink eventSink;

    public OnAVPVideoSizeChangedListener(AliQueuingEventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onVideoSizeChanged(int width, int height) {
        eventSink.success(
                MapUtil.builder("event", (Object) "videoSizeChanged")
                        .put("width", width)
                        .put("height", height)
                        .build());
        Log.i("video_size_changed", JSONUtil.toJsonStr(MapUtil.builder("width", width).put("height", height).build()));
    }
}
