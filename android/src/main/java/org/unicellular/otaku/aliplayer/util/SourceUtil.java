package org.unicellular.otaku.aliplayer.util;

import com.aliyun.player.AliPlayer;
import com.aliyun.player.source.LiveSts;
import com.aliyun.player.source.UrlSource;
import com.aliyun.player.source.VidAuth;
import com.aliyun.player.source.VidMps;
import com.aliyun.player.source.VidSts;

public class SourceUtil {

    public static boolean process(String type, String source, AliPlayer mAliPlayer) {
        switch (type) {
            case "UrlSource":
                mAliPlayer.setDataSource(SourceUtil.getUrlSource(source));
                return true;
            case "VidSts":
                mAliPlayer.setDataSource(SourceUtil.getVidSts(source));
                return true;
            case "VidMps":
                mAliPlayer.setDataSource(SourceUtil.getVidMps(source));
                return true;
            case "VidAuth":
                mAliPlayer.setDataSource(SourceUtil.getVidAuth(source));
                return true;
            case "LiveSts":
                mAliPlayer.setDataSource(SourceUtil.getLiveSts(source));
                return true;
        }
        return false;
    }

    private static UrlSource getUrlSource(String source) {
        try {
            return JsonMarker.instance().from(source, UrlSource.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static VidSts getVidSts(String source) {
        try {
            return JsonMarker.instance().from(source, VidSts.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static VidMps getVidMps(String source) {
        try {
            return JsonMarker.instance().from(source, VidMps.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static VidAuth getVidAuth(String source) {
        try {
            return JsonMarker.instance().from(source, VidAuth.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static LiveSts getLiveSts(String source) {
        try {
            return JsonMarker.instance().from(source, LiveSts.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

//    private static <T extends VidSourceBase> T getVidSource(JSONObject jsonObject, T source) {
//        getSource(jsonObject, source);
//        JSONArray formats = jsonObject.getJSONArray("formats");
//        if (formats != null && !formats.isEmpty()) {
//            List<MediaFormat> mfs = new ArrayList<>();
//            for (Object format : formats) {
//                mfs.add(MediaFormat.valueOf((String) format));
//            }
//            source.setFormats(mfs);
//        }
//        JSONArray definitions = jsonObject.getJSONArray("definitions");
//        if (definitions != null && !definitions.isEmpty()) {
//            List<Definition> ds = new ArrayList<>();
//            for (Object definition : definitions) {
//                ds.add(Definition.valueOf((String) definition));
//            }
//            source.setDefinition(ds);
//        }
//        JSONObject playConfig = jsonObject.getJSONObject("playConfig");
//        if (CollectionUtil.isNotEmpty(playConfig)) {
//            playConfig = playConfig.getJSONObject("configMap");
//            VidPlayerConfigGen configGen = new VidPlayerConfigGen();
//            if (playConfig.containsKey("PreviewTime")) {
//                configGen.setPreviewTime(playConfig.getInt("PreviewTime"));
//                playConfig.remove("PreviewTime");
//            }
//            if (playConfig.containsKey("EncryptType")) {
//                configGen.setEncryptType(VidPlayerConfigGen.EncryptType.valueOf(playConfig.getStr("EncryptType")));
//                playConfig.remove("EncryptType");
//            }
//            if (playConfig.containsKey("MtsHlsUriToken")) {
//                configGen.setMtsHlsUriToken(playConfig.getStr("MtsHlsUriToken"));
//                playConfig.remove("MtsHlsUriToken");
//            }
//            for (Map.Entry<String, Object> entry : playConfig.entrySet()) {
//                if (entry.getValue() instanceof String) {
//                    configGen.addPlayerConfig(entry.getKey(), (String) entry.getValue());
//                } else {
//                    configGen.addPlayerConfig(entry.getKey(), (Integer) entry.getValue());
//                }
//            }
//            source.setPlayConfig(configGen);
//        }
//        return source;
//    }

//    private static <T extends SourceBase> T getSource(JSONObject jsonObject, T source) {
//        source.setTitle(jsonObject.getStr("title"));
//        source.setCoverPath(jsonObject.getStr("coverPath"));
//        return source;
//    }
}
