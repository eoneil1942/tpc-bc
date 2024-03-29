/* This file is part of VoltDB.
 * Copyright (C) 2008-2011 VoltDB Inc.
 *
 * This file contains original code and/or modifications of original code.
 * Any modifications made by VoltDB Inc. are licensed under the following
 * terms and conditions:
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
/* Copyright (C) 2008
 * Michael McCanna
 * Massachusetts Institute of Technology
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

package com.tpcbprocedures;

import org.voltdb.*;

/*
 * NOTE:
 * Select all won't work without distribution. For now it really does
 * select all from the site partitioned to wid 0.
 */

@ProcInfo (
    singlePartition = false,
    isCVoltDBExecution = true
)
public class SelectAll extends VoltProcedure {

    public final SQLStmt branch = new SQLStmt("SELECT * FROM BRANCH ORDER BY B_ID;");

    public final SQLStmt account = new SQLStmt("SELECT * FROM ACCOUNT ORDER BY A_ID;");
    
    public final SQLStmt teller = new SQLStmt("SELECT * FROM TELLER ORDER BY T_ID;");

    public final SQLStmt history = new SQLStmt("SELECT * FROM HISTORY;");


    public VoltTable[] run() {
        voltQueueSQL(branch);
        voltQueueSQL(account);
        voltQueueSQL(teller);
        voltQueueSQL(history);
    
        return voltExecuteSQL();
    }
}
