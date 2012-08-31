package com.diventi.mobipaper;

import android.app.Activity;
import android.app.Dialog;
import android.os.Bundle;
import android.os.Handler;
import android.view.KeyEvent;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URL;
import org.xml.sax.SAXException;

public class MobiPaperActivity extends Activity {
	
	protected Dialog mSplashDialog;
	protected WebView mWebView;
	protected String mResult;
	
	/** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        try
        {
	        com.icl.saxon.trax.Processor processor =
	            com.icl.saxon.trax.Processor.newInstance("xslt");
	        
	        org.xml.sax.InputSource xmlInputSource =
	            new org.xml.sax.InputSource(this.getResources().openRawResource(R.raw.test_xml));
	        org.xml.sax.InputSource xsltInputSource =
	            new org.xml.sax.InputSource(this.getResources().openRawResource(R.raw.test_xsl));
	     
	        StringWriter output = new StringWriter();
	        com.icl.saxon.trax.Result result =
	            new com.icl.saxon.trax.Result(output);
	     
	        // create a new compiled stylesheet
	        com.icl.saxon.trax.Templates templates =
	            processor.process(xsltInputSource);
	     
	        // create a transformer that can be used for a single transformation
	        com.icl.saxon.trax.Transformer trans = templates.newTransformer( );
	        trans.transform(xmlInputSource, result);
	        
	        mResult = output.toString();
        }
        catch (Exception e)
        {

        }
        
        
        MyStateSaver data = (MyStateSaver) getLastNonConfigurationInstance();
        if (data != null) {
            // Show splash screen if still loading
            if (data.showSplashScreen) {
                showSplashScreen();
            }
            
            showMain();
            
            // Rebuild your UI with your saved state here
        } else {
            showSplashScreen();
            showMain();
        }

    }
    
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK) && mWebView.canGoBack()) {
            mWebView.goBack();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }    

    private void showMain() {
		setContentView(R.layout.main);
		this.setTitle("Diario EL DIA - Diario Matutino de la Ciudad de La Plata");
		
		mWebView = (WebView) findViewById(R.id.webview);
		mWebView.setWebViewClient(new HelloWebViewClient());
		mWebView.getSettings().setJavaScriptEnabled(true);
		
		mWebView.loadData(mResult, "text/html", "utf-8");
		
	}
    @Override
    public Object onRetainNonConfigurationInstance() {
        MyStateSaver data = new MyStateSaver();
        // Save your important data here
     
        if (mSplashDialog != null) {
            data.showSplashScreen = true;
            removeSplashScreen();
        }
        return data;
    }
     
    /**
     * Removes the Dialog that displays the splash screen
     */
    protected void removeSplashScreen() {
        if (mSplashDialog != null) {
            mSplashDialog.dismiss();
            mSplashDialog = null;
        }
    }
     
    /**
     * Shows the splash screen over the full Activity
     */
    protected void showSplashScreen() {
        mSplashDialog = new Dialog(this, R.style.SplashScreen);
        mSplashDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        mSplashDialog.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
        		WindowManager.LayoutParams.FLAG_FULLSCREEN);
        mSplashDialog.setContentView(R.layout.splashscreen);
        mSplashDialog.setCancelable(false);
        mSplashDialog.show();
     
        // Set Runnable to remove splash screen just in case
        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
          public void run() {
            removeSplashScreen();
          }
        }, 4000);
    }
     
    /**
     * Simple class for storing important data across config changes
     */
    private class MyStateSaver {
        public boolean showSplashScreen = false;
        // Your other important fields here
    }
    
    private class HelloWebViewClient extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            view.loadUrl(url);
            return true;
        }
    }
    
}