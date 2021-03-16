package org.unicellular.otaku.aliplayer.listener;

import android.util.Log;

import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.nativeclass.TrackInfo;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;
import org.unicellular.otaku.aliplayer.util.JsonMarker;

import java.util.HashMap;
import java.util.Map;

/**
 * 播放器TrackChanged监听
 */
public class OnAVPTrackChangedListener implements IPlayer.OnTrackChangedListener {

    private AliQueuingEventSink eventSink;

    public OnAVPTrackChangedListener(AliQueuingEventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onChangedSuccess(TrackInfo trackInfo) {

        Map<String, Object> map = new HashMap<>(4);
        map.put("event", "playEvent");
        map.put("value", 8);
        
        //切换音视频流或者清晰度成功
        eventSink.success(map);

        String msg;
        try {
            msg = JsonMarker.instance().write(map);
        } catch (Throwable e) {
            msg = e.getMessage();
        }
        Log.i("playEvent", msg);
    }

    @Override
    public void onChangedFail(TrackInfo trackInfo, ErrorInfo errorInfo) {

        Map<String, Object> map = new HashMap<>(4);
        map.put("event", "playEvent");
        map.put("value", 9);
        map.put("msg", errorInfo.getMsg());

        //切换音视频流或者清晰度失败
        eventSink.success(map);

        String msg;
        try {
            msg = JsonMarker.instance().write(map);
        } catch (Throwable e) {
            msg = e.getMessage();
        }
        Log.i("playEvent", msg);
    }
}
