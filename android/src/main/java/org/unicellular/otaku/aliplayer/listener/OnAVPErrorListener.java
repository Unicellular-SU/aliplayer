package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorInfo;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import java.util.HashMap;
import java.util.Map;

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
        Map<String, Object> map = new HashMap<>(8);
        map.put("event", "error");
        map.put("errorCode", errorInfo.getCode().getValue());
        map.put("errorEvent", Integer.toHexString(errorInfo.getCode().getValue()));
        map.put("errorMsg", errorInfo.getMsg());

        // 出错事件
        eventSink.success(map);
    }
}
