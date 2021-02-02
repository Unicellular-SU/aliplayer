package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorInfo;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import cn.hutool.core.map.MapUtil;

/**
 * 错误事件监听
 */
public class OnAVPErrorListener implements IPlayer.OnErrorListener {

    private final AliQueuingEventSink eventSink;

    public OnAVPErrorListener(AliQueuingEventSink eventSink){
        this.eventSink = eventSink;
    }

    @Override
    public void onError(ErrorInfo errorInfo) {
        // 出错事件
        eventSink.success(MapUtil.builder("event", (Object) "error")
                .put("errorCode", errorInfo.getCode().getValue())
                .put("errorEvent", Integer.toHexString(errorInfo.getCode().getValue()))
                .put("errorMsg", errorInfo.getMsg())
                .build());
    }
}
