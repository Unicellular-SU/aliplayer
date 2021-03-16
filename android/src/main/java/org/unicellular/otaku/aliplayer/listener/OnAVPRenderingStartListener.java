package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import java.util.HashMap;
import java.util.Map;

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
        Map<String, Object> map = new HashMap<>(4);
        map.put("event", "playEvent");
        map.put("value", 2);
        
        //首帧渲染显示事件
        eventSink.success(map);

    }
}
