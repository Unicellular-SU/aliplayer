package org.unicellular.otaku.aliplayer.listener;

import com.aliyun.player.IPlayer;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

/**
 * SEI数据回调
 */
public class OnAVPSeiDataListener implements IPlayer.OnSeiDataListener {

    private AliQueuingEventSink eventSink;

    public OnAVPSeiDataListener(AliQueuingEventSink eventSink){
        this.eventSink = eventSink;
    }

    @Override
    public void onSeiData(int type, byte[] data) {
        // 回调
    }
}
