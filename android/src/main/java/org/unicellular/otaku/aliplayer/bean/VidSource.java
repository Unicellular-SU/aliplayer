package org.unicellular.otaku.aliplayer.bean;

import com.aliyun.player.source.Definition;
import com.aliyun.player.source.MediaFormat;
import com.aliyun.player.source.SourceBase;
import com.aliyun.player.source.VidSourceBase;

import java.util.List;
import java.util.Set;

public class VidSource extends SourceBase {
    private List<MediaFormat> mFormats;
    private List<Definition> mDefinitions;
    // 使用自定义的VidPlayerConfigGen用于JSON反序列化
    private VidPlayerConfigGen mPlayConfig = null;
    private VidSourceBase.OutputType mOutputType = null;
    private Set<VidSourceBase.StreamType> mStreamTypes = null;
    private String mReAuthInfo = null;
    private VidSourceBase.ResultType mResultType = null;
    private long mAuthTimeout = 3600L;

    public List<MediaFormat> getFormats() {
        return mFormats;
    }

    public void setFormats(List<MediaFormat> mFormats) {
        this.mFormats = mFormats;
    }

    public List<Definition> getDefinitions() {
        return mDefinitions;
    }

    public void setDefinitions(List<Definition> mDefinitions) {
        this.mDefinitions = mDefinitions;
    }

    public VidPlayerConfigGen getPlayConfig() {
        return mPlayConfig;
    }

    public void setPlayConfig(VidPlayerConfigGen mPlayConfig) {
        this.mPlayConfig = mPlayConfig;
    }

    public VidSourceBase.OutputType getOutputType() {
        return mOutputType;
    }

    public void setOutputType(VidSourceBase.OutputType mOutputType) {
        this.mOutputType = mOutputType;
    }

    public Set<VidSourceBase.StreamType> getStreamTypes() {
        return mStreamTypes;
    }

    public void setStreamTypes(Set<VidSourceBase.StreamType> mStreamTypes) {
        this.mStreamTypes = mStreamTypes;
    }

    public String getReAuthInfo() {
        return mReAuthInfo;
    }

    public void setReAuthInfo(String mReAuthInfo) {
        this.mReAuthInfo = mReAuthInfo;
    }

    public VidSourceBase.ResultType getResultType() {
        return mResultType;
    }

    public void setResultType(VidSourceBase.ResultType mResultType) {
        this.mResultType = mResultType;
    }

    public long getAuthTimeout() {
        return mAuthTimeout;
    }

    public void setAuthTimeout(long mAuthTimeout) {
        this.mAuthTimeout = mAuthTimeout;
    }
}
