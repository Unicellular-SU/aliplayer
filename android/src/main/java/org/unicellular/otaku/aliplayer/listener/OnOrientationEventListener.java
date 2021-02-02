package org.unicellular.otaku.aliplayer.listener;

import android.content.Context;
import android.view.OrientationEventListener;

import org.unicellular.otaku.aliplayer.AliQueuingEventSink;

import java.util.HashMap;
import java.util.Map;

/**
 * 设备方向监听
 */
public class OnOrientationEventListener extends OrientationEventListener {

    private AliQueuingEventSink eventSink;

    public OnOrientationEventListener(Context context, AliQueuingEventSink eventSink) {
        super(context);
        this.eventSink = eventSink;
    }

    @Override
    public void onOrientationChanged(int orientation) {
        if (orientation == OrientationEventListener.ORIENTATION_UNKNOWN) {
            return;  //手机平放时，检测不到有效的角度
        }
        Map<String, Object> orientationMap = new HashMap<>();
        orientationMap.put("event", "orientation");
        orientationMap.put("orientation", orientation);
        eventSink.success(orientationMap);
    }
}
