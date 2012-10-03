package com.diventi.mobipaper;

import java.lang.ref.WeakReference;

public class SlidebarProvider
{
  private static final SlidebarProvider mInstance = new SlidebarProvider();
  private static WeakReference<ActionsContentView> mToolbarRef;

  public static SlidebarProvider getInstance()
  {
    synchronized(mInstance) {
      SlidebarProvider local = mInstance;
      return local;
    }
  }

  public ActionsContentView getActionView()
  {
    synchronized (this) {

      ActionsContentView local = null;
      if (mToolbarRef != null)
        local = (ActionsContentView)mToolbarRef.get();
        
      return local;
    }
  }

  public void setActionView(ActionsContentView param)
  {
    synchronized (this) {
      mToolbarRef = new WeakReference(param);
      return;
    }
  }
}

/* Location:           /Users/matias/Downloads/bbc-app/bbc/out_dex2jar.jar
 * Qualified Name:     bbc.mobile.news.view.ToolbarProvider
 * JD-Core Version:    0.6.0
 */