package org.unicellular.otaku.aliplayer.util;

import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.TypeFactory;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author valor.
 */
abstract class BaseMarker<M extends ObjectMapper> {

    /**
     * @return mapper
     */
    public abstract M mapper();

    /**
     * @return typeFactory
     */
    public TypeFactory javaType() {
        return mapper().getTypeFactory();
    }

    /**
     * format entity to text.
     *
     * @return String 「TEXT」
     */
    public String write(Object o) throws Exception {
        return mapper().writeValueAsString(o);
    }

    /* --------------------- toMap(..., ...) --------------------- */

    /**
     * parse text to map.
     *
     * @return Map<String, V> 「HashMap」
     */
    public <V> Map<String, V> toMap(String text, Class<V> value) throws Exception {
        JavaType type = javaType().constructMapType(HashMap.class, String.class, value);
        return mapper().readValue(text, type);
    }

    /**
     * parse text to map.
     *
     * @return Map<K, V> 「HashMap」
     */
    public <K, V> Map<K, V> toMap(String text, Class<K> key, Class<V> value) throws Exception {
        JavaType type = javaType().constructMapType(HashMap.class, key, value);
        return mapper().readValue(text, type);
    }

    /**
     * parse bytes to map.
     *
     * @return Map<String, V> 「HashMap」
     */
    public <V> Map<String, V> toMap(byte[] json, Class<V> value) throws Exception {
        JavaType type = javaType().constructMapType(HashMap.class, String.class, value);
        return mapper().readValue(json, type);
    }

    /**
     * parse bytes to map.
     *
     * @return Map<K, V> 「HashMap」
     */
    public <K, V> Map<K, V> toMap(byte[] json, Class<K> key, Class<V> value) throws Exception {
        JavaType type = javaType().constructMapType(HashMap.class, key, value);
        return mapper().readValue(json, type);
    }

    /**
     * format object to map.
     *
     * @return Map<String, V> 「HashMap」
     */
    public <V> Map<String, V> toMap(Object o, Class<V> value) {
        JavaType type = javaType().constructMapType(HashMap.class, String.class, value);
        return mapper().convertValue(o, type);
    }

    /**
     * format object to map.
     *
     * @return Map<K, V> 「HashMap」
     */
    public <K, V> Map<K, V> toMap(Object o, Class<K> key, Class<V> value) {
        JavaType type = javaType().constructMapType(HashMap.class, key, value);
        return mapper().convertValue(o, type);
    }

    /* --------------------- toList(..., ...) --------------------- */

    /**
     * parse text to list.
     *
     * @return List<T> 「ArrayList」
     */
    public <T> List<T> toList(String text, Class<T> clazz) throws Exception {
        JavaType type = javaType().constructCollectionType(ArrayList.class, clazz);
        return mapper().readValue(text, type);
    }

    /**
     * parse text to list.
     *
     * @return List<T> 「ArrayList」
     */
    public <T> List<T> toList(String text, JavaType javaType) throws Exception {
        JavaType type = javaType().constructCollectionType(ArrayList.class, javaType);
        return mapper().readValue(text, type);
    }

    /**
     * parse bytes to list.
     *
     * @return List<T> 「ArrayList」
     */
    public <T> List<T> toList(byte[] bytes, Class<T> clazz) throws Exception {
        JavaType type = javaType().constructCollectionType(ArrayList.class, clazz);
        return mapper().readValue(bytes, type);
    }

    /**
     * parse bytes to list.
     *
     * @return List<T> 「ArrayList」
     */
    public <T> List<T> toList(byte[] bytes, JavaType javaType) throws Exception {
        JavaType type = javaType().constructCollectionType(ArrayList.class, javaType);
        return mapper().readValue(bytes, type);
    }

    /**
     * format object to list.
     *
     * @return List<T> 「ArrayList」
     */
    public <T> List<T> toList(Object o, Class<T> clazz) {
        JavaType type = javaType().constructCollectionType(ArrayList.class, clazz);
        return mapper().convertValue(o, type);
    }

    /**
     * format object to list.
     *
     * @return List<T> 「ArrayList」
     */
    public <T> List<T> toList(Object o, JavaType javaType) {
        JavaType type = javaType().constructCollectionType(ArrayList.class, javaType);
        return mapper().convertValue(o, type);
    }

    /* --------------------- toSet(..., ...) --------------------- */

    /**
     * parse text to set.
     *
     * @return Set<T> 「HashSet」
     */
    public <T> Set<T> toSet(String text, Class<T> clazz) throws Exception {
        JavaType type = javaType().constructCollectionType(HashSet.class, clazz);
        return mapper().readValue(text, type);
    }

    /**
     * parse text to set.
     *
     * @return Set<T> 「HashSet」
     */
    public <T> Set<T> toSet(String text, JavaType javaType) throws Exception {
        JavaType type = javaType().constructCollectionType(HashSet.class, javaType);
        return mapper().readValue(text, type);
    }

    /**
     * parse bytes to set.
     *
     * @return Set<T> 「HashSet」
     */
    public <T> Set<T> toSet(byte[] bytes, Class<T> clazz) throws Exception {
        JavaType type = javaType().constructCollectionType(HashSet.class, clazz);
        return mapper().readValue(bytes, type);
    }

    /**
     * parse bytes to set.
     *
     * @return Set<T> 「HashSet」
     */
    public <T> Set<T> toSet(byte[] bytes, JavaType javaType) throws Exception {
        JavaType type = javaType().constructCollectionType(HashSet.class, javaType);
        return mapper().readValue(bytes, type);
    }

    /**
     * format object to set.
     *
     * @return Set<T> 「HashSetHashSet」
     */
    public <T> Set<T> toSet(Object o, Class<T> clazz) {
        JavaType type = javaType().constructCollectionType(HashSet.class, clazz);
        return mapper().convertValue(o, type);
    }

    /**
     * format object to set.
     *
     * @return Set<T> 「HashSet」
     */
    public <T> Set<T> toSet(Object o, JavaType javaType) {
        JavaType type = javaType().constructCollectionType(HashSet.class, javaType);
        return mapper().convertValue(o, type);
    }

    /* --------------------- from(..., ...) --------------------- */

    /**
     * parse text to entity.
     *
     * @return T 「entity」
     */
    public <T> T from(String text, Class<T> clazz) throws Exception {
        return mapper().readValue(text, clazz);
    }

    /**
     * parse text to entity.
     *
     * @return T 「entity」
     */
    public <T> T from(String text, JavaType javaType) throws Exception {
        return mapper().readValue(text, javaType);
    }

    /**
     * parse bytes to entity.
     *
     * @return T 「entity」
     */
    public <T> T from(byte[] bytes, Class<T> clazz) throws Exception {
        return mapper().readValue(bytes, clazz);
    }

    /**
     * parse bytes to entity.
     *
     * @return T 「entity」
     */
    public <T> T from(byte[] bytes, JavaType javaType) throws Exception {
        return mapper().readValue(bytes, javaType);
    }

    /**
     * format object to entity.
     *
     * @return T 「entity」
     */
    public <T> T from(Object o, Class<T> clazz) {
        return mapper().convertValue(o, clazz);
    }

    /**
     * format object to entity.
     *
     * @return T 「entity」
     */
    public <T> T from(Object o, JavaType javaType) {
        return mapper().convertValue(o, javaType);
    }

}
