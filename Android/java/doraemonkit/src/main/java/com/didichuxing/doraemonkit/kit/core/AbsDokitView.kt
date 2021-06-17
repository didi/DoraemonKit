package com.didichuxing.doraemonkit.kit.core

import android.annotation.SuppressLint
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.content.res.Resources
import android.graphics.PixelFormat
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.*
import android.view.ViewTreeObserver.OnGlobalLayoutListener
import android.widget.FrameLayout
import androidx.annotation.IdRes
import androidx.annotation.StringRes
import com.didichuxing.doraemonkit.config.FloatIconConfig
import com.didichuxing.doraemonkit.constant.DoKitConstant
import com.didichuxing.doraemonkit.kit.main.MainIconDokitView
import com.didichuxing.doraemonkit.util.ActivityUtils
import com.didichuxing.doraemonkit.util.LogHelper
import com.didichuxing.doraemonkit.util.ScreenUtils
import kotlinx.coroutines.*
import java.lang.Runnable
import java.lang.ref.WeakReference

/**
 * ================================================
 * 作    者：jint（金台）
 * 版    本：1.0
 * 创建日期：2019-09-20-16:22
 * 描    述：dokit 页面浮标抽象类 一般的悬浮窗都需要继承该抽象接口
 * 修订历史：
 * ================================================
 */
abstract class AbsDokitView : DokitView, TouchProxy.OnTouchEventListener,
    DokitViewManager.DokitViewAttachedListener {

    val doKitViewScope = MainScope().plus(CoroutineName(this.javaClass.simpleName))

    val TAG = this.javaClass.simpleName

    val isNormalMode = DoKitConstant.IS_NORMAL_FLOAT_MODE

    /**
     * 手势代理
     */
    @JvmField
    var mTouchProxy = TouchProxy(this)

    @JvmField
    protected var mWindowManager = DokitViewManager.getInstance().windowManager

    /**
     * 创建FrameLayout#LayoutParams 内置悬浮窗调用
     */
    var normalLayoutParams: FrameLayout.LayoutParams? = null

    /**
     * 创建FrameLayout#LayoutParams 系统悬浮窗调用
     */
    var systemLayoutParams: WindowManager.LayoutParams? = null

    private var mHandler: Handler? = Handler(Looper.myLooper())

    private val mInnerReceiver = InnerReceiver()

    /**
     * 当前dokitViewName 用来当做map的key 和dokitViewIntent的tag一致
     */
    var tag = TAG
    var bundle: Bundle? = null

    /**
     * weakActivity attach activity
     */
    private var mAttachActivity: WeakReference<Activity>? = null

    /**
     * 整个悬浮窗的View
     */
    private var mDoKitView: FrameLayout? = null

    /**
     * rootView的直接子View 一般是用户的xml布局 被添加到mRootView中
     */
    private var mChildView: View? = null

    /**
     * 用来保存rootview的LayoutParams
     */
    private lateinit var mDokitViewLayoutParams: DokitViewLayoutParams

    /**
     * 上一次DoKitview的位置信息
     */
    private lateinit var mLastDokitViewPosInfo: LastDokitViewPosInfo

    /**
     * 根布局的实际宽
     */
    private var mDokitViewWidth = 0

    /**
     * 根布局的实际高
     */
    private var mDokitViewHeight = 0
    private var mViewTreeObserver: ViewTreeObserver? = null

    private val mOnGlobalLayoutListener: OnGlobalLayoutListener = OnGlobalLayoutListener {
        //每次布局发生变动的时候重新赋值
        mDoKitView?.let {
            mDokitViewWidth = it.measuredWidth
            mDokitViewHeight = it.measuredHeight
            mLastDokitViewPosInfo.dokitViewWidth = mDokitViewWidth
            mLastDokitViewPosInfo.dokitViewHeight = mDokitViewHeight
        }

    }

    /**
     * 页面启动模式
     */
    var mode = 0

    /**
     * 执行floatPage create
     *
     * @param context 上下文环境
     */
    @SuppressLint("ClickableViewAccessibility")
    fun performCreate(context: Context) {
        try {
            //调用onCreate方法
            onCreate(context)
            if (!isNormalMode) {
                DokitViewManager.getInstance().addDokitViewAttachedListener(this)
            }
            mDoKitView = if (isNormalMode) {
                DokitFrameLayout(context, DokitFrameLayout.DoKitFrameLayoutFlag_CHILD)
            } else {
                //系统悬浮窗的返回按键监听
                object : DokitFrameLayout(context, DoKitFrameLayoutFlag_CHILD) {
                    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
                        if (event.action == KeyEvent.ACTION_UP && shouldDealBackKey()) {
                            //监听返回键
                            if (event.keyCode == KeyEvent.KEYCODE_BACK || event.keyCode == KeyEvent.KEYCODE_HOME) {
                                return onBackPressed()
                            }
                        }
                        return super.dispatchKeyEvent(event)
                    }
                }
            }
            //添加根布局的layout回调
            addViewTreeObserverListener()

            //调用onCreateView抽象方法
            mChildView = onCreateView(context, mDoKitView)
            //将子View添加到rootview中
            mDoKitView?.addView(mChildView)
            //设置根布局的手势拦截
            mDoKitView?.setOnTouchListener { v, event ->
                if (doKitView != null) {
                    mTouchProxy.onTouchEvent(v, event)
                } else {
                    false
                }
            }
            //调用onViewCreated回调
            onViewCreated(mDoKitView)
            mDokitViewLayoutParams = DokitViewLayoutParams()
            //分别创建对应的LayoutParams
            if (isNormalMode) {
                normalLayoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                )
                normalLayoutParams?.gravity = Gravity.LEFT or Gravity.TOP
                mDokitViewLayoutParams.gravity = Gravity.LEFT or Gravity.TOP
            } else {
                systemLayoutParams = WindowManager.LayoutParams()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    //android 8.0
                    systemLayoutParams?.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    systemLayoutParams?.type = WindowManager.LayoutParams.TYPE_PHONE
                }
                //shouldDealBackKey : fasle 不自己收返回事件处理
                if (shouldDealBackKey()) {
                    //自己处理返回按键
                    systemLayoutParams?.flags =
                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
                    mDokitViewLayoutParams.flags =
                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or DokitViewLayoutParams.FLAG_LAYOUT_NO_LIMITS
                } else {
                    //参考：http://www.shirlman.com/tec/20160426/362
                    //设置WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE会导致RootView监听不到返回按键的监听失效 系统处理返回按键
                    systemLayoutParams?.flags =
                        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
                    mDokitViewLayoutParams.flags =
                        DokitViewLayoutParams.FLAG_NOT_FOCUSABLE or DokitViewLayoutParams.FLAG_LAYOUT_NO_LIMITS
                }
                systemLayoutParams?.apply {
                    format = PixelFormat.TRANSPARENT
                    gravity = Gravity.LEFT or Gravity.TOP
                }


                mDokitViewLayoutParams.gravity = Gravity.LEFT or Gravity.TOP
                //动态注册关闭系统弹窗的广播
                val intentFilter = IntentFilter(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
                context.registerReceiver(mInnerReceiver, intentFilter)
            }
            initDokitViewLayoutParams(mDokitViewLayoutParams)
            if (isNormalMode) {
                normalLayoutParams?.let {
                    onNormalLayoutParamsCreated(it)
                }
            } else {
                systemLayoutParams?.let {
                    onSystemLayoutParamsCreated(it)
                }
            }
        } catch (e: Exception) {
            LogHelper.e(TAG, "e===>" + e.message)
            e.printStackTrace()
        }
    }

    fun performDestroy() {
        if (!isNormalMode) {
            context?.unregisterReceiver(mInnerReceiver)
        }
        //移除布局监听
        removeViewTreeObserverListener()
        mHandler = null
        mDoKitView = null
        onDestroy()
    }

    private fun addViewTreeObserverListener() {
        if (mViewTreeObserver == null && mDoKitView != null) {
            mViewTreeObserver = mDoKitView!!.viewTreeObserver
            mViewTreeObserver?.addOnGlobalLayoutListener(mOnGlobalLayoutListener)
        }
    }

    private fun removeViewTreeObserverListener() {
        mViewTreeObserver?.let {
            if (it.isAlive) {
                it.removeOnGlobalLayoutListener(mOnGlobalLayoutListener)
            }
        }
    }

    /**
     * 确定普通浮标的初始位置
     * LayoutParams创建完以后调用
     * 调用时建议放在实现下方
     *
     * @param params
     */
    private fun onNormalLayoutParamsCreated(params: FrameLayout.LayoutParams) {
        //如果有上一个页面的位置记录 这更新位置
        params.width = mDokitViewLayoutParams.width
        params.height = mDokitViewLayoutParams.height
        params.gravity = mDokitViewLayoutParams.gravity
        val doKitViewInfo = DokitViewManager.getInstance().getDokitViewPos(tag)
        if (doKitViewInfo != null) {
            //竖向
            if (doKitViewInfo.orientation == Configuration.ORIENTATION_PORTRAIT) {
                params.leftMargin = doKitViewInfo.portraitPoint.x
                params.topMargin = doKitViewInfo.portraitPoint.y
            } else if (doKitViewInfo.orientation == Configuration.ORIENTATION_LANDSCAPE) {
                params.leftMargin = doKitViewInfo.landscapePoint.x
                params.topMargin = doKitViewInfo.landscapePoint.y
            }
        } else {
            params.leftMargin = mDokitViewLayoutParams.x
            params.topMargin = mDokitViewLayoutParams.y
        }
        portraitOrLandscape(params)
    }

    /**
     * 用于普通模式下的横竖屏切换
     */
    private fun portraitOrLandscape(params: FrameLayout.LayoutParams) {
        val doKitViewInfo = DokitViewManager.getInstance().getDokitViewPos(tag)
        if (doKitViewInfo != null) {
            //横竖屏切换兼容
            if (ScreenUtils.isPortrait()) {
                if (mLastDokitViewPosInfo.isPortrait) {
                    params.leftMargin = doKitViewInfo.portraitPoint.x
                    params.topMargin = doKitViewInfo.portraitPoint.y
                } else {
                    params.leftMargin =
                        (doKitViewInfo.landscapePoint.x * mLastDokitViewPosInfo.leftMarginPercent).toInt()
                    params.topMargin =
                        (doKitViewInfo.landscapePoint.y * mLastDokitViewPosInfo.topMarginPercent).toInt()
                }
            } else {
                if (mLastDokitViewPosInfo.isPortrait) {
                    params.leftMargin =
                        (doKitViewInfo.portraitPoint.x * mLastDokitViewPosInfo.leftMarginPercent).toInt()
                    params.topMargin =
                        (doKitViewInfo.portraitPoint.y * mLastDokitViewPosInfo.topMarginPercent).toInt()
                } else {
                    params.leftMargin = doKitViewInfo.landscapePoint.x
                    params.topMargin = doKitViewInfo.landscapePoint.y
                }
            }
        } else {
            //横竖屏切换兼容
            if (ScreenUtils.isPortrait()) {
                if (mLastDokitViewPosInfo.isPortrait) {
                    params.leftMargin = mDokitViewLayoutParams.x
                    params.topMargin = mDokitViewLayoutParams.y
                } else {
                    params.leftMargin =
                        (mDokitViewLayoutParams.x * mLastDokitViewPosInfo.leftMarginPercent).toInt()
                    params.topMargin =
                        (mDokitViewLayoutParams.y * mLastDokitViewPosInfo.topMarginPercent).toInt()
                }
            } else {
                if (mLastDokitViewPosInfo.isPortrait) {
                    params.leftMargin =
                        (mDokitViewLayoutParams.x * mLastDokitViewPosInfo.leftMarginPercent).toInt()
                    params.topMargin =
                        (mDokitViewLayoutParams.y * mLastDokitViewPosInfo.topMarginPercent).toInt()
                } else {
                    params.leftMargin = mDokitViewLayoutParams.x
                    params.topMargin = mDokitViewLayoutParams.y
                }
            }
        }
        mLastDokitViewPosInfo.setPortrait()
        mLastDokitViewPosInfo.setLeftMargin(params.leftMargin)
        mLastDokitViewPosInfo.setTopMargin(params.topMargin)
        if (tag == MainIconDokitView::class.java.simpleName) {
            if (isNormalMode) {
                normalLayoutParams?.let {
                    FloatIconConfig.saveLastPosX(it.leftMargin)
                    FloatIconConfig.saveLastPosY(it.topMargin)
                }
            } else {
                systemLayoutParams?.let {
                    FloatIconConfig.saveLastPosX(it.x)
                    FloatIconConfig.saveLastPosY(it.y)
                }

            }
        }
        DokitViewManager.getInstance().saveDokitViewPos(tag, params.leftMargin, params.topMargin)
    }

    @Deprecated("")
    fun portraitOrLandscape(currentOrientation: Int) {
        if (!isNormalMode) {
            return
        }
        if (mDoKitView == null) {
            return
        }
        normalLayoutParams?.apply {
            val (_, portraitPoint, landscapePoint) = DokitViewManager.getInstance()
                .getDokitViewPos(tag) ?: return
            if (currentOrientation == Configuration.ORIENTATION_PORTRAIT) {
                if (landscapePoint == null) {
                    this.leftMargin = 0
                    this.topMargin = 0
                } else {
                    this.leftMargin = landscapePoint.y
                    this.topMargin = landscapePoint.x
                }
            } else if (currentOrientation == Configuration.ORIENTATION_LANDSCAPE) {
                if (portraitPoint == null) {
                    this.leftMargin = 0
                    this.topMargin = 0
                } else {
                    this.leftMargin = portraitPoint.y
                    this.topMargin = portraitPoint.x
                }
            }
            DokitViewManager.getInstance()
                .saveDokitViewPos(tag, this.leftMargin, this.topMargin)
            mDoKitView?.layoutParams = this
        }

    }

    /**
     * 确定系统浮标的初始位置
     * LayoutParams创建完以后调用
     * 调用时建议放在实现下方
     *
     * @param params
     */
    private fun onSystemLayoutParamsCreated(params: WindowManager.LayoutParams) {
        //如果有上一个页面的位置记录 这更新位置
        params.flags = mDokitViewLayoutParams.flags
        params.gravity = mDokitViewLayoutParams.gravity
        params.width = mDokitViewLayoutParams.width
        params.height = mDokitViewLayoutParams.height
        val doKitViewInfo = DokitViewManager.getInstance().getDokitViewPos(
            tag
        )
        if (doKitViewInfo != null) {
            if (ScreenUtils.isPortrait()) {
                params.x = doKitViewInfo.portraitPoint.x
                params.y = doKitViewInfo.portraitPoint.y
            } else if (ScreenUtils.isLandscape()) {
                params.x = doKitViewInfo.landscapePoint.x
                params.y = doKitViewInfo.landscapePoint.y
            }
        } else {
            params.x = mDokitViewLayoutParams.x
            params.y = mDokitViewLayoutParams.y
        }
        DokitViewManager.getInstance().saveDokitViewPos(tag, params.x, params.y)
    }

    override fun onDestroy() {
        if (!isNormalMode) {
            DokitViewManager.getInstance().removeDokitViewAttachedListener(this)
        }
        DokitViewManager.getInstance().removeLastDokitViewPosInfo(tag)
        mAttachActivity = null
        doKitViewScope.cancel()
    }

    /**
     * 默认实现为true
     *
     * @return
     */
    override fun canDrag(): Boolean {
        return true
    }

    /**
     * 搭配shouldDealBackKey使用 自定义处理完以后需要返回true
     * 默认模式的onBackPressed 拦截在NormalDokitViewManager#getDokitRootContentView中被处理
     * 系统模式下的onBackPressed 在当前类的performCreate 初始话DoKitView时被处理
     * 返回false 表示交由系统处理
     * 返回 true 表示当前的返回事件已由自己处理 并拦截了改返回事件
     */
    override fun onBackPressed(): Boolean {
        return false
    }

    /**
     * 默认不自己处理返回按键
     *
     * @return
     */
    override fun shouldDealBackKey(): Boolean {
        return false
    }

    override fun onEnterBackground() {
        mDoKitView?.let {
            if (!isNormalMode) {
                it.visibility = View.GONE
            }
        }

    }

    override fun onEnterForeground() {
        mDoKitView?.let {
            if (!isNormalMode) {
                it.visibility = View.VISIBLE
            }
        }

    }

    override fun onMove(x: Int, y: Int, dx: Int, dy: Int) {
        if (!canDrag()) {
            return
        }
        if (isNormalMode) {
            normalLayoutParams?.apply {
                this.leftMargin += dx
                this.topMargin += dy
            }

            //更新图标位置
            updateViewLayout(tag, false)
        } else {
            systemLayoutParams?.apply {
                this.x += dx
                this.y += dy
            }
            //限制布局边界
            resetBorderline(normalLayoutParams, systemLayoutParams)
            mWindowManager.updateViewLayout(mDoKitView, systemLayoutParams)
        }
    }

    /**
     * 手指弹起时保存当前浮标位置
     *
     * @param x
     * @param y
     */
    override fun onUp(x: Int, y: Int) {
        if (!canDrag()) {
            return
        }
        if (tag == MainIconDokitView::class.java.simpleName) {
            if (isNormalMode) {
                normalLayoutParams?.let {
                    FloatIconConfig.saveLastPosX(it.leftMargin)
                    FloatIconConfig.saveLastPosY(it.topMargin)
                }
            } else {
                systemLayoutParams?.let {
                    FloatIconConfig.saveLastPosX(it.x)
                    FloatIconConfig.saveLastPosY(it.y)
                }
            }
        }
        //保存在内存中
        if (isNormalMode) {
            normalLayoutParams?.let {
                DokitViewManager.getInstance().saveDokitViewPos(tag, it.leftMargin, it.topMargin)
            }
        } else {
            systemLayoutParams?.let {
                DokitViewManager.getInstance().saveDokitViewPos(tag, it.x, it.y)
            }
        }
    }

    /**
     * 手指按下时的操作
     *
     * @param x
     * @param y
     */
    override fun onDown(x: Int, y: Int) {
        if (!canDrag()) {
            return
        }
    }

    /**
     * 广播接收器 系统悬浮窗需要调用
     */
    private inner class InnerReceiver : BroadcastReceiver() {
        val SYSTEM_DIALOG_REASON_KEY = "reason"
        val SYSTEM_DIALOG_REASON_RECENT_APPS = "recentapps"
        val SYSTEM_DIALOG_REASON_HOME_KEY = "homekey"
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            if (Intent.ACTION_CLOSE_SYSTEM_DIALOGS == action) {
                val reason = intent.getStringExtra(SYSTEM_DIALOG_REASON_KEY)
                if (reason != null) {
                    if (reason == SYSTEM_DIALOG_REASON_HOME_KEY) {
                        //点击home键
                        onHomeKeyPress()
                    } else if (reason == SYSTEM_DIALOG_REASON_RECENT_APPS) {
                        //点击menu按钮
                        onRecentAppKeyPress()
                    }
                }
            }
        }
    }

    /**
     * home键被点击 只有系统悬浮窗控件才会被调用
     */
    open fun onHomeKeyPress() {}

    /**
     * 菜单键被点击 只有系统悬浮窗控件才会被调用
     */
    open fun onRecentAppKeyPress() {}

    /**
     * 不能在改方法中进行dokitview的添加和删除 因为处于遍历过程在
     * 只有系统模式下才会调用
     *
     * @param dokitView
     */
    override fun onDokitViewAdd(dokitView: AbsDokitView) {}
    override fun onResume() {}
    override fun onPause() {}

    /**
     * 系统悬浮窗需要调用
     *
     * @return
     */
    val context: Context?
        get() = if (mDoKitView != null) {
            mDoKitView!!.context
        } else {
            null
        }

    val resources: Resources?
        get() = if (context == null) {
            null
        } else context!!.resources

    fun getString(@StringRes resId: Int): String? {
        return if (context == null) {
            null
        } else context!!.getString(resId)
    }

    val isShow: Boolean
        get() = mDoKitView!!.isShown

    protected fun <T : View> findViewById(@IdRes id: Int): T? {
        if (mDoKitView == null) {
            return null
        }
        return mDoKitView?.findViewById(id)
    }

    val doKitView: View?
        get() = mDoKitView

    /**
     * 将当前dokitView于activity解绑
     */
    fun detach() {
        DokitViewManager.getInstance().detach(this)
    }

    /**
     * 操作DecorView的直接子布局
     * 测试专用
     */
    fun dealDecorRootView(decorRootView: FrameLayout?) {
        if (isNormalMode) {
            if (decorRootView == null) {
                return
            }
        }
    }

    /**
     * 更新view的位置
     *
     * @param isActivityResume 是否是从其他页面返回时更新的位置
     */
    open fun updateViewLayout(tag: String, isActivityResume: Boolean) {
        if (mDoKitView == null || mChildView == null || normalLayoutParams == null || !isNormalMode) {
            return
        }
        normalLayoutParams?.apply {
            if (isActivityResume) {
                if (tag == MainIconDokitView::class.java.simpleName) {

                    this.leftMargin = FloatIconConfig.getLastPosX()
                    this.topMargin = FloatIconConfig.getLastPosY()
                } else {
                    val doKitViewInfo = DokitViewManager.getInstance().getDokitViewPos(tag)
                    if (doKitViewInfo != null) {
                        if (doKitViewInfo.orientation == Configuration.ORIENTATION_PORTRAIT) {
                            this.leftMargin = doKitViewInfo.portraitPoint.x
                            this.topMargin = doKitViewInfo.portraitPoint.y
                        } else {
                            this.leftMargin = doKitViewInfo.landscapePoint.x
                            this.topMargin = doKitViewInfo.landscapePoint.y
                        }
                    }
                }
            } else {
                //非页面切换的时候保存当前位置信息
                mLastDokitViewPosInfo.setPortrait()
                mLastDokitViewPosInfo.setLeftMargin(this.leftMargin)
                mLastDokitViewPosInfo.setTopMargin(this.topMargin)
            }
            if (tag == MainIconDokitView::class.java.simpleName) {
                this.width = DokitViewLayoutParams.WRAP_CONTENT
                this.height = DokitViewLayoutParams.WRAP_CONTENT
                //            mFrameLayoutParams.width = ConvertUtils.dp2px(MainIconDokitView.FLOAT_SIZE);
//            mFrameLayoutParams.height = ConvertUtils.dp2px(MainIconDokitView.FLOAT_SIZE);
            } else {
                this.width = mDokitViewWidth
                this.height = mDokitViewHeight
            }

            //portraitOrLandscape(mFrameLayoutParams);
            resetBorderline(this, systemLayoutParams)
            mDoKitView!!.layoutParams = this
        }

    }

    /**
     * 限制边界 调用的时候必须保证是在控件能获取到宽高德前提下
     */
    private fun resetBorderline(
        normalFrameLayoutParams: FrameLayout.LayoutParams?,
        windowLayoutParams: WindowManager.LayoutParams?
    ) {
        //如果是系统模式或者手动关闭动态限制边界
        if (!restrictBorderline()) {
            return
        }


        //普通模式
        if (isNormalMode) {
            if (normalFrameLayoutParams!!.topMargin <= 0) {
                normalFrameLayoutParams.topMargin = 0
            }
            if (ScreenUtils.isPortrait()) {
                if (normalFrameLayoutParams.topMargin >= screenLongSideLength - mDokitViewHeight) {
                    normalFrameLayoutParams.topMargin = screenLongSideLength - mDokitViewHeight
                }
            } else {
                if (normalFrameLayoutParams.topMargin >= screenShortSideLength - mDokitViewHeight) {
                    normalFrameLayoutParams.topMargin = screenShortSideLength - mDokitViewHeight
                }
            }
            if (normalFrameLayoutParams.leftMargin <= 0) {
                normalFrameLayoutParams.leftMargin = 0
            }
            if (ScreenUtils.isPortrait()) {
                if (normalFrameLayoutParams.leftMargin >= screenShortSideLength - mDokitViewWidth) {
                    normalFrameLayoutParams.leftMargin = screenShortSideLength - mDokitViewWidth
                }
            } else {
                if (normalFrameLayoutParams.leftMargin >= screenLongSideLength - mDokitViewWidth) {
                    normalFrameLayoutParams.leftMargin = screenLongSideLength - mDokitViewWidth
                }
            }
        } else {
            //系统模式
            if (windowLayoutParams!!.y <= 0) {
                windowLayoutParams.y = 0
            }
            if (ScreenUtils.isPortrait()) {
                if (windowLayoutParams.y >= screenLongSideLength - mDokitViewHeight) {
                    windowLayoutParams.y = screenLongSideLength - mDokitViewHeight
                }
            } else {
                if (windowLayoutParams.y >= screenShortSideLength - mDokitViewHeight) {
                    windowLayoutParams.y = screenShortSideLength - mDokitViewHeight
                }
            }
            if (windowLayoutParams.x <= 0) {
                windowLayoutParams.x = 0
            }
            if (ScreenUtils.isPortrait()) {
                if (windowLayoutParams.x >= screenShortSideLength - mDokitViewWidth) {
                    windowLayoutParams.x = screenShortSideLength - mDokitViewWidth
                }
            } else {
                if (windowLayoutParams.x >= screenLongSideLength - mDokitViewWidth) {
                    windowLayoutParams.x = screenLongSideLength - mDokitViewWidth
                }
            }
        }
    }

    /**
     * 是否限制布局边界
     *
     * @return
     */
    open fun restrictBorderline(): Boolean {
        return true
    }

    val activity: Activity
        get() = if (mAttachActivity != null) {
            mAttachActivity!!.get()!!
        } else ActivityUtils.getTopActivity()

    fun setActivity(activity: Activity) {
        mAttachActivity = WeakReference(activity)
    }

    fun post(run: Runnable) {
        mHandler?.post(run)
    }

    fun postDelayed(run: Runnable, delayMillis: Long) {
        mHandler?.postDelayed(run, delayMillis)
    }

    /**
     * 设置当前kitView不响应触摸事件
     * 控件默认响应触摸事件
     * 需要在子view的onViewCreated中调用
     */
    fun setDokitViewNotResponseTouchEvent(view: View?) {
        if (isNormalMode) {
            view?.setOnTouchListener { v, event -> false }
        } else {
            view?.setOnTouchListener(null)
        }
    }

    /**
     * 获取屏幕短边的长度 不包含statusBar
     *
     * @return
     */
    val screenShortSideLength: Int
        get() = if (ScreenUtils.isPortrait()) {
            ScreenUtils.getAppScreenWidth()
        } else {
            ScreenUtils.getAppScreenHeight()
        }//ScreenUtils.getScreenHeight(); 包含statusBar
    //ScreenUtils.getAppScreenHeight(); 不包含statusBar
    /**
     * 获取屏幕长边的长度 不包含statusBar
     *
     * @return
     */
    val screenLongSideLength: Int
        get() = if (ScreenUtils.isPortrait()) {
            //ScreenUtils.getScreenHeight(); 包含statusBar
            //ScreenUtils.getAppScreenHeight(); 不包含statusBar
            ScreenUtils.getAppScreenHeight()
        } else {
            ScreenUtils.getAppScreenWidth()
        }

    /**
     * 强制刷新当前dokitview
     */
    open fun invalidate() {
        if (doKitView == null) {
            return
        }
        if (isNormalMode) {
            normalLayoutParams?.apply {
                this.width = FrameLayout.LayoutParams.WRAP_CONTENT
                this.height = FrameLayout.LayoutParams.WRAP_CONTENT
                doKitView?.layoutParams = this
            }
        } else {
            systemLayoutParams?.apply {
                this.width = WindowManager.LayoutParams.WRAP_CONTENT
                this.height = WindowManager.LayoutParams.WRAP_CONTENT
                mWindowManager.updateViewLayout(doKitView, this)
            }

        }
    }

    /**
     * 只控件在布局边界发生大小变化被裁剪的原因：
     * https://juejin.cn/post/6844903624452079623
     *
     * @return
     */
    val rootView: DokitFrameLayout?
        get() = if (isNormalMode && mDoKitView != null) {
            mDoKitView!!.parent as DokitFrameLayout
        } else null

    /**
     * 构造函数
     */
    init {
        if (DokitViewManager.getInstance().getLastDokitViewPosInfo(tag) == null) {
            mLastDokitViewPosInfo = LastDokitViewPosInfo()
            DokitViewManager.getInstance().saveLastDokitViewPosInfo(tag, mLastDokitViewPosInfo)
        } else {
            mLastDokitViewPosInfo = DokitViewManager.getInstance().getLastDokitViewPosInfo(tag)
        }
    }
}