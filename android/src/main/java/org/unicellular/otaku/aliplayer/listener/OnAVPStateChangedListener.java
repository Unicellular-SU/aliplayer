package org.unicellular.otaku.aliplayer.listener;

import android.util.Log;

import com.aliyun.player.IPlayer;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;
import org.unicellular.otaku.aliplayer.util.JsonMarker;

import java.util.HashMap;
import java.util.Map;

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
        Map<String, Object> map = new HashMap<>(4);
        map.put("event", "stateChanged");
        map.put("value", newState);
        
        //播放器状态改变事件
        eventSink.success(map);
        
        String msg;
        try {
            msg = JsonMarker.instance().write(map);
        } catch (Throwable e) {
            msg = e.getMessage();
        }
        Log.i("stateChanged", msg);
    }
}
