package com.icl.saxon.functions;
import com.icl.saxon.*;
import com.icl.saxon.expr.*;
import org.xml.sax.SAXException;
import java.util.*;


public class Current extends Function {

    public String getName()       { return "current"; };
    /**
    * Determine the data type of the exprssion, if possible
    * @return Value.NODESET
    */

    public int getDataType() {
        return Value.NODESET;
    }

    public Value eval(Vector args, Context context) throws SAXException {
        int numArgs = checkArgumentCount(0, 0);
        return new SingletonNodeSet(context.getCurrentNode());
    }

    /**
    * Determine which aspects of the context the expression depends on. The result is
    * a bitwise-or'ed value composed from constants such as Context.VARIABLES and
    * Context.CURRENT_NODE
    */

    public int getIntrinsicDependencies() {
        return Context.CURRENT_NODE;
    }

    /**
    * Remove intrinsic dependencies. 
    */

    protected Expression reduceIntrinsic(int dependencies, Context context)
            throws SAXException {
        checkArgumentCount(0, 0);
        if ((dependencies & Context.CURRENT_NODE) != 0) {
            return new SingletonNodeSet(context.getCurrentNode());
        } else {
            return this;
        }
    }

}




//
// The contents of this file are subject to the Mozilla Public License Version 1.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/ 
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied.
// See the License for the specific language governing rights and limitations under the License. 
//
// The Original Code is: all this file. 
//
// The Initial Developer of the Original Code is
// Michael Kay of International Computers Limited (Michael.Kay@icl.com).
//
// Portions created by (your name) are Copyright (C) (your legal entity). All Rights Reserved. 
//
// Contributor(s): none. 
//
