package org.unicellular.otaku.aliplayer.listener;

import android.util.Log;

import com.aliyun.player.AliPlayer;
import com.aliyun.player.IPlayer;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;
import org.unicellular.otaku.aliplayer.AliyunPlayer;

import cn.hutool.core.map.MapUtil;
import cn.hutool.json.JSONUtil;

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
        //准备成功事件
        eventSink.success(MapUtil.builder("event", (Object) "prepared")
                .put("duration", mAliPlayer.getDuration())
                .put("width", mAliPlayer.getVideoWidth())
                .put("height", mAliPlayer.getVideoHeight())
                .build());
        Log.i("prepared", JSONUtil.toJsonStr(MapUtil.builder("event", (Object) "prepared")
                .put("duration", mAliPlayer.getDuration())
                .put("width", mAliPlayer.getVideoWidth())
                .put("height", mAliPlayer.getVideoHeight())
                .build()));
    }
}
