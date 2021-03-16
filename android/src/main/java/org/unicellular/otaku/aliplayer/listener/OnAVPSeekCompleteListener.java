package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import java.util.HashMap;
import java.util.Map;

/**
 * 播放器seek完成监听
 */
public class OnAVPSeekCompleteListener implements IPlayer.OnSeekCompleteListener {

    private AliQueuingEventSink eventSink;

    public OnAVPSeekCompleteListener(AliQueuingEventSink eventSink){
        this.eventSink = eventSink;
    }

    @Override
    public void onSeekComplete() {
        Map<String, Object> map = new HashMap<>(4);
        map.put("event", "playEvent");
        map.put("value", 6);
        
        //拖动结束
        eventSink.success(map);

    }
}
