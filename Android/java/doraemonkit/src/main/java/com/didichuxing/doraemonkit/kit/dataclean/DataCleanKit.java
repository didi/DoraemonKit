package com.didichuxing.doraemonkit.kit.dataclean;

import android.content.Context;

import com.didichuxing.doraemonkit.R;
import com.didichuxing.doraemonkit.constant.FragmentIndex;
import com.didichuxing.doraemonkit.kit.AbstractKit;
import com.didichuxing.doraemonkit.kit.Category;
import com.google.auto.service.AutoService;

/**
 * Created by wanglikun on 2018/11/17.
 */
@AutoService(AbstractKit.class)
public class DataCleanKit extends AbstractKit {


    @Override
    public int getName() {
        return R.string.dk_kit_data_clean;
    }

    @Override
    public int getIcon() {
        return R.mipmap.dk_data_clean;
    }

    @Override
    public void onClick(Context context) {
        startUniversalActivity(DataCleanFragment.class, context, null,true);
    }

    @Override
    public void onAppInit(Context context) {

    }

    @Override
    public boolean isInnerKit() {
        return true;
    }

    @Override
    public String innerKitId() {
        return "dokit_sdk_comm_ck_cache";
    }
}