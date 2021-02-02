package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import cn.hutool.core.map.MapUtil;

/**
 * 播放器播放完成监听
 */
public class OnAVPCompletionListener implements IPlayer.OnCompletionListener {

    private final AliQueuingEventSink eventSink;

    public OnAVPCompletionListener(AliQueuingEventSink eventSink){
        this.eventSink = eventSink;
    }

    @Override
    public void onCompletion() {
        //播放完成事件
//        eventSink.success(MapUtil.builder("event", "completion").build());
        eventSink.success(MapUtil.builder("event", (Object) "playEvent").put("value",3).build());

    }
}
