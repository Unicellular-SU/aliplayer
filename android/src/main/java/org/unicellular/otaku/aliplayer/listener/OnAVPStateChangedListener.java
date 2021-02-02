package org.unicellular.otaku.aliplayer.listener;

import android.util.Log;

import com.aliyun.player.IPlayer;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import cn.hutool.core.map.MapUtil;
import cn.hutool.json.JSONUtil;

/**
 * 播放器状态改变监听
 */
public class OnAVPStateChangedListener implements IPlayer.OnStateChangedListener {

    private final AliQueuingEventSink eventSink;

    public OnAVPStateChangedListener(AliQueuingEventSink eventSink){
        this.eventSink = eventSink;
    }

    @Override
    public void onStateChanged(int newState) {
        //播放器状态改变事件
        eventSink.success(
                MapUtil.builder("event", (Object) "stateChanged")
                        .put("value", newState)
                        .build());
        Log.i("stateChanged", JSONUtil.toJsonStr(MapUtil.builder("value", newState).build()));
    }
}
