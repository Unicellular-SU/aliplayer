package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.InfoBean;
import com.aliyun.player.bean.InfoCode;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import cn.hutool.core.map.MapUtil;

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
//            eventSink.success(MapUtil.builder("event", (Object) "position")
//                    .put("position", infoBean.getExtraValue()).build());
            eventSink.success(MapUtil.builder("event", (Object) "currentPosition")
                    .put("value", infoBean.getExtraValue()).build());
        } else if (infoBean.getCode() == InfoCode.BufferedPosition) {
            eventSink.success(MapUtil.builder("event", (Object) "bufferedPosition")
                    .put("value", infoBean.getExtraValue()).build());
        }
    }
}
