package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import cn.hutool.core.map.MapUtil;

/**
 * 播放器Render监听
 */
public class OnAVPRenderingStartListener implements IPlayer.OnRenderingStartListener {

    private AliQueuingEventSink eventSink;

    public OnAVPRenderingStartListener(AliQueuingEventSink eventSink){
        this.eventSink = eventSink;
    }

    @Override
    public void onRenderingStart() {
        //首帧渲染显示事件
        eventSink.success(MapUtil.builder("event", (Object) "playEvent").put("value",2).build());

    }
}
