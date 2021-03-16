package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import java.util.HashMap;
import java.util.Map;

/**
 * 播放器加载状态监听
 */
public class OnAVPLoadingStatusListener implements IPlayer.OnLoadingStatusListener {

    private final AliQueuingEventSink eventSink;

    public OnAVPLoadingStatusListener(AliQueuingEventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onLoadingBegin() {
        Map<String, Object> map = new HashMap<>(4);
        map.put("event", "playEvent");
        map.put("value", 4);
        
        //缓冲开始。
//        eventSink.success(MapUtil.builder("event", (Object) "loadingBegin").build());
        eventSink.success(map);
    }

    @Override
    public void onLoadingProgress(int percent, float netSpeed) {
        Map<String, Object> map = new HashMap<>(4);
        map.put("event", "loadingProgress");
        map.put("percent", percent);
        map.put("netSpeed", netSpeed);
        
        //缓冲进度
        eventSink.success(map);

    }

    @Override
    public void onLoadingEnd() {
        Map<String, Object> map = new HashMap<>(4);
        map.put("event", "playEvent");
        map.put("value", 5);
        
        //缓冲结束
//        eventSink.success(MapUtil.builder("event", (Object) "loadingEnd").build());
        eventSink.success(map);

    }
}
