package org.unicellular.otaku.aliplayer.listener;

import android.util.Log;

import com.aliyun.player.IPlayer;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;
import org.unicellular.otaku.aliplayer.util.JsonMarker;

import java.util.HashMap;
import java.util.Map;

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

        Map<String, Object> map = new HashMap<>(4);
        map.put("event", "videoSizeChanged");
        map.put("width", width);
        map.put("height", height);

        eventSink.success(map);

        String msg;
        try {
            msg = JsonMarker.instance().write(map);
        } catch (Throwable e) {
            msg = e.getMessage();
        }
        Log.i("video_size_changed", msg);
    }
}
