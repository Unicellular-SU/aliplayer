package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.InfoBean;
import com.aliyun.player.bean.InfoCode;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import java.util.HashMap;
import java.util.Map;

/**
 * 播放信息监听
 */
public class OnAVPInfoListener implements IPlayer.OnInfoListener {

    private final AliQueuingEventSink eventSink;

    public OnAVPInfoListener(AliQueuingEventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onInfo(InfoBean infoBean) {
        //其他信息的事件，type包括了：循环播放开始，缓冲位置，当前播放位置，自动播放开始等
        if (infoBean.getCode() == InfoCode.CurrentPosition) {
            Map<String, Object> map = new HashMap<>(4);
            map.put("event", "currentPosition");
            map.put("value", infoBean.getExtraValue());
            
//            eventSink.success(MapUtil.builder("event", (Object) "position")
//                    .put("position", infoBean.getExtraValue()).build());
            eventSink.success(map);
        } else if (infoBean.getCode() == InfoCode.BufferedPosition) {
            Map<String, Object> map = new HashMap<>(4);
            map.put("event", "bufferedPosition");
            map.put("value", infoBean.getExtraValue());
            
            eventSink.success(map);
        }
    }
}
