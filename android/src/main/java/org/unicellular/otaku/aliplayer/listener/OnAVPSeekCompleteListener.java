package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import cn.hutool.core.map.MapUtil;

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
        //拖动结束
        eventSink.success(MapUtil.builder("event", (Object) "playEvent").put("value",6).build());

    }
}
