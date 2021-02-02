package org.unicellular.otaku.aliplayer.listener;

import android.util.Log;

import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.nativeclass.TrackInfo;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import cn.hutool.core.map.MapUtil;
import cn.hutool.json.JSONUtil;

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
        //切换音视频流或者清晰度成功
        eventSink.success(MapUtil.builder("event", (Object) "playEvent").put("value", 8).build());
        Log.i("playEvent", JSONUtil.toJsonStr(MapUtil.builder("event", (Object) "playEvent").put("value", 8).build()));

    }

    @Override
    public void onChangedFail(TrackInfo trackInfo, ErrorInfo errorInfo) {
        //切换音视频流或者清晰度失败
        eventSink.success(MapUtil.builder("event", (Object) "playEvent").put("value", 9).put("msg", errorInfo.getMsg()).build());
        Log.i("playEvent", JSONUtil.toJsonStr(MapUtil.builder("event", (Object) "playEvent").put("value", 9).put("info", errorInfo.getMsg()).build()));

    }
}
