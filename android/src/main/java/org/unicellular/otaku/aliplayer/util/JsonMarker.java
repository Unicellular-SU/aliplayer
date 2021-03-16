package org.unicellular.otaku.aliplayer.util;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.json.JsonMapper;

/**
 * @author valor.
 */
public class JsonMarker extends BaseMarker<JsonMapper> {

    /* --------------- instance --------------- */

    private JsonMarker() { }

    private static final Object LOCK = new Object();

    private static volatile JsonMarker marker;

    public static JsonMarker instance() {
        if (null == marker) {
            synchronized (LOCK) {
                if (null == marker) {
                    marker = new JsonMarker();
                }
            }
        }

        return marker;
    }

    /* --------------- variable --------------- */

    private static final JsonMapper mapper;

    @Override
    public JsonMapper mapper() {
        return mapper;
    }

    static {
        mapper = new JsonMapper();

        // 在序列化时忽略值为 null 的属性
//        mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
        // 允许json进行注释 "//"
//        mapper.configure(JsonParser.Feature.ALLOW_COMMENTS, true);
        // 允许json进行注释 "#"
//        mapper.configure(JsonParser.Feature.ALLOW_YAML_COMMENTS, true);
        // 在反序列化时忽略在 json 中存在但 Java 对象不存在的属性
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        // 将日期转为时间戳
//        mapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
    }

}
