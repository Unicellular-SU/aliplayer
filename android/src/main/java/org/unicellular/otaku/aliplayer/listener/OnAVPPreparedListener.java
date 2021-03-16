package org.unicellular.otaku.aliplayer.listener;

import android.util.Log;

import com.aliyun.player.AliPlayer;
import com.aliyun.player.IPlayer;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;
import org.unicellular.otaku.aliplayer.AliyunPlayer;
import org.unicellular.otaku.aliplayer.util.JsonMarker;

import java.util.HashMap;
import java.util.Map;

/**
 * 准备完成监听
 */
public class OnAVPPreparedListener implements IPlayer.OnPreparedListener {

    private AliQueuingEventSink eventSink;
    private final AliPlayer mAliPlayer;
    private AliyunPlayer aliyunPlayer;

    public OnAVPPreparedListener(AliQueuingEventSink eventSink, AliPlayer mAliPlayer, AliyunPlayer aliyunPlayer) {
        this.eventSink = eventSink;
        this.mAliPlayer = mAliPlayer;
        this.aliyunPlayer = aliyunPlayer;
    }

    @Override
    public void onPrepared() {
        this.aliyunPlayer.initialized();

        Map<String, Object> map = new HashMap<>(8);
        map.put("event", "prepared");
        map.put("duration", mAliPlayer.getDuration());
        map.put("width", mAliPlayer.getVideoWidth());
        map.put("height", mAliPlayer.getVideoHeight());
        
        //准备成功事件
        eventSink.success(map);

        String msg;
        try {
            msg = JsonMarker.instance().write(map);
        } catch (Throwable e) {
            msg = e.getMessage();
        }
        Log.i("prepared", msg);
    }
}
