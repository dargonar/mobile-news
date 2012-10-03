package com.diventi.mobipaper;

import java.io.InputStream;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.AnimationUtils;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;

public class HomeActivity extends Activity implements OnClickListener, OnItemClickListener {

	  private ImageButton        mBtnOptions;
	  private ImageButton        mBtnRefresh;
	  private ImageView          mImgRefreshLoading;
	  private HomeWebView        mWebView;
	  private ActionsContentView mActionsView;
	  private ListView           mActionsList;
    
	  @Override
    public void onCreate(Bundle savedInstanceState) {
        
      super.onCreate(savedInstanceState);
      setContentView(R.layout.newhome);
    
      setupViews();

      __load_html();
    }

    @Override
    public void onBackPressed() {
      
      if(mActionsView.isActionsShown()) {
        mActionsView.showContent();
        return;
      }
      
      super.onBackPressed();
    }
    
    private void __load_html() {
      try {
        InputStream in_s = this.getResources().openRawResource(R.raw.test_html);
        byte[] b = new byte[in_s.available()];
        in_s.read(b);
      
        mWebView.loadData(new String(b), "text/html", "utf-8");
      } catch (Exception e) {
          mWebView.loadData("<b>Error: can't load html.</b>", "text/html", "utf-8");
      }
    }

    private void setupViews() {
      mBtnOptions = (ImageButton)findViewById(R.id.btn_options);
      mBtnOptions.setOnClickListener(this);
      
      mBtnRefresh = (ImageButton)findViewById(R.id.btn_refresh);
      mBtnRefresh.setOnClickListener(this);
      
      mActionsView = (ActionsContentView) findViewById(R.id.content);
      mActionsView.setSwipingEnabled(true);
      
      mImgRefreshLoading = (ImageView)findViewById(R.id.img_refresh_loading);
      
      mActionsList = (ListView) findViewById(R.id.actions);
      mActionsList.setOnItemClickListener(this);
      mActionsList.setAdapter(new SitesAdapter(this, R.array.site_names));

      mWebView = (HomeWebView)findViewById(R.id.feed_webview);
      
      SlidebarProvider.getInstance().setActionView(mActionsView);
      
      //BORRAR
      //final ToolbarView toolbarView = (ToolbarView)findViewById(R.id.toolbar);
      //ToolbarProvider.getInstance().setToolbar(toolbarView);
    }

    public void onClick(View v) {
      if( v.getId() == R.id.btn_options )
        OnOptions();

      if( v.getId() == R.id.btn_refresh )
        OnRefresh();
    }

    public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
      mActionsView.showContent();
    }
    
    private void OnRefresh() {
      showLoading(true);
      
      //turn off
      final Handler handler = new Handler();
      handler.postDelayed(new Runnable() {
        public void run() {
          showLoading(false);
        }
      }, 4000);

    }

    private void OnOptions() {

      if (mActionsView.isActionsShown())
        mActionsView.showContent();
      else
        mActionsView.showActions();
    }

    private void showLoading(boolean show)
    {
      mImgRefreshLoading.setVisibility(show ? View.VISIBLE : View.INVISIBLE);
      mBtnRefresh.setVisibility(show ? View.INVISIBLE : View.VISIBLE);

      if(show)
        mImgRefreshLoading.startAnimation(AnimationUtils.loadAnimation(this, R.anim.rotate_indefinitely));
      else
        mImgRefreshLoading.clearAnimation();
    }

}
