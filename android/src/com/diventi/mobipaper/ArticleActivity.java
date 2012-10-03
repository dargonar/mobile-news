package com.diventi.mobipaper;

import java.io.InputStream;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;

public class ArticleActivity extends Activity implements OnClickListener {

	  private ImageButton        mBtnBack;
	  private ArticleWebView     mWebView;
    
	  @Override
    public void onCreate(Bundle savedInstanceState) {
        
      super.onCreate(savedInstanceState);
      setContentView(R.layout.article_content);
    
      setupViews();
      __load_html();
    }
    
    private void __load_html() {
      try {
        InputStream in_s = this.getResources().openRawResource(R.raw.test_nota_html);
        byte[] b = new byte[in_s.available()];
        in_s.read(b);
      
        mWebView.loadData(new String(b), "text/html", "utf-8");
      } catch (Exception e) {
          mWebView.loadData("<b>Error: can't load html.</b>", "text/html", "utf-8");
      }
    }

    private void setupViews() {
      
      mWebView = (ArticleWebView)findViewById(R.id.article_webview);
      
      mBtnBack = (ImageButton)findViewById(R.id.btn_back_article);
      mBtnBack.setOnClickListener(this);
      
      final ToolbarView toolbarView = (ToolbarView)findViewById(R.id.toolbar);
      ToolbarProvider.getInstance().setToolbar(toolbarView);
    }

    public void onClick(View v) {
      if( v.getId() == R.id.btn_back_article )
        OnBack();
    }
    
    private void OnBack() {
      super.onBackPressed();
    }

}
