package org.unicellular.otaku.aliplayer.listener;

import android.graphics.Bitmap;

import com.aliyun.player.IPlayer;
import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

/**
 * 播放器截图事件监听
 */
public class OnAVPSnapShotListener implements IPlayer.OnSnapShotListener {

    private AliQueuingEventSink eventSink;

    public OnAVPSnapShotListener(AliQueuingEventSink eventSink){
        this.eventSink = eventSink;
    }

    @Override
    public void onSnapShot(Bitmap bm, int with, int height) {
        //截图事件
    }
}
