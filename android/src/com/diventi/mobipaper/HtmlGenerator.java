package com.diventi.mobipaper;

import java.io.StringWriter;
import android.content.Context;

public class HtmlGenerator {
  
  public void generate(Context context) {

    try
    {
      com.icl.saxon.trax.Processor processor =
          com.icl.saxon.trax.Processor.newInstance("xslt");
    
      org.xml.sax.InputSource xmlInputSource =
          new org.xml.sax.InputSource(context.getResources().openRawResource(R.raw.test_xml));
      org.xml.sax.InputSource xsltInputSource =
          new org.xml.sax.InputSource(context.getResources().openRawResource(R.raw.test_xsl));
 
      StringWriter output = new StringWriter();
      com.icl.saxon.trax.Result result =
          new com.icl.saxon.trax.Result(output);
 
    // create a new compiled stylesheet
    com.icl.saxon.trax.Templates templates =
        processor.process(xsltInputSource);
 
    // create a transformer that can be used for a single transformation
    com.icl.saxon.trax.Transformer trans = templates.newTransformer( );
    trans.transform(xmlInputSource, result);
    
//    mResult = output.toString();
  }
  catch (Exception e)
  {

  }
  
  

  }
  
}
