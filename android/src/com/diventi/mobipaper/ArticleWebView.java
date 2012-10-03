package com.diventi.mobipaper;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

@SuppressLint("SetJavaScriptEnabled")
public class ArticleWebView extends WebView
{
  public static final String TAG = "ArticleWebView";
  private static GestureDetector mGestureDetector;
  
  private WebViewClient mWebViewClient = new WebViewClient()
  {
    public void onPageFinished(WebView view, String url)
    {

    }

    public void onPageStarted(WebView paramWebView, String paramString, Bitmap paramBitmap)
    {
      
    }

    public void onReceivedError(WebView paramWebView, int paramInt, String paramString1, String paramString2)
    {
      
    }
  };
 
  public ArticleWebView(Context context, AttributeSet attrs)
  {
    this(context, attrs, 0);
  }

  public ArticleWebView(Context context, AttributeSet attrs, int paramInt)
  {
    super(context, attrs, paramInt);
    getGestureDetector(getContext());
    getSettings().setJavaScriptEnabled(true);

    initJavascriptInterface();
    
    setInitialScale(100);
    setWebViewClient(this.mWebViewClient);
  }

  private GestureDetector getGestureDetector(Context paramContext)
  {
    if (mGestureDetector == null)
    {
      mGestureDetector = new GestureDetector(paramContext, new GestureDetector.SimpleOnGestureListener()
      {
        public boolean onDoubleTap(MotionEvent paramMotionEvent)
        {
          return false;
        }

        public boolean onDoubleTapEvent(MotionEvent paramMotionEvent)
        {
          return false;
        }

        public boolean onSingleTapConfirmed(MotionEvent paramMotionEvent)
        {
          Log.d(TAG, "Aca va un tap");
          if (ToolbarProvider.getInstance().getToolbar() != null)
            ToolbarProvider.getInstance().getToolbar().onTap();
          return false;
        }
      });
    }
    
    return mGestureDetector;
  }

  private void initJavascriptInterface()
  {
    setWebChromeClient(new WebChromeClient()
    {
      public boolean onJsAlert(WebView paramWebView, String paramString1, String paramString2, JsResult paramJsResult)
      {
        paramJsResult.confirm();
        return true;
      }
    });
    
    addJavascriptInterface(new JavaScriptInterface(), "jsinterface");
  }

  public void loadContent(String paramString, int paramInt)
  {

  }

  public void onTextSizeChanged(int paramInt)
  {
    loadUrl("javascript:newsArticle.fontSizes.update(" + paramInt + ")");
  }

  public boolean onTouchEvent(MotionEvent paramMotionEvent)
  {
    mGestureDetector.onTouchEvent(paramMotionEvent);
    return super.onTouchEvent(paramMotionEvent);
  }

  class JavaScriptInterface
  {
    JavaScriptInterface()
    {

    }

    public void onClickToPlay(String paramString)
    {

    }

    public void onLoad()
    {
    
    }
  }
}

/* Location:           /Users/matias/Downloads/bbc-app/bbc/out_dex2jar.jar
 * Qualified Name:     bbc.mobile.news.view.ArticleWebView
 * JD-Core Version:    0.6.0
 */