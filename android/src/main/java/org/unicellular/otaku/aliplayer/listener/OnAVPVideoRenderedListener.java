package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

/**
 * 视频渲染回调
 */
public class OnAVPVideoRenderedListener implements IPlayer.OnVideoRenderedListener {

    private final AliQueuingEventSink eventSink;

    public OnAVPVideoRenderedListener(AliQueuingEventSink eventSink){
        this.eventSink = eventSink;
    }

    @Override
    public void onVideoRendered(long timeMs, long pts) {
        // 视频帧被渲染
    }
}
