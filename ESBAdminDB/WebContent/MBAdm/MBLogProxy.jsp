<!-- 
/********************************************************************************/
/* */
/* Project: ESBAdmin */
/* Author: Godfrey Peter Menezes */
/* 
Copyright © 2015 Godfrey P Menezes
All rights reserved. This code or any portion thereof
may not be reproduced or used in any manner whatsoever
without the express written permission of Godfrey P Menezes(godfreym@gmail.com).
o
*/
/********************************************************************************/
 -->
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.io.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.ibm.esbadmin.*"%>
<%@ page import="com.ibm.broker.config.proxy.*"%>
<%@ page import="java.util.*"%>
<%@ page import="org.apache.commons.csv.*"%>

<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>

<html>
<head>
<meta http-equiv="Content-Style-Type" content="text/css">
<style type="text/css">
<%@ include file="../Style.css" %>
</style>
<title>Insert title here</title>
</head>
<body>

<%if(session.getAttribute("UserID")==null){
%>
		<center>
		Looks like you are not logged in.<br>
		
		Please login with a valid user id <a href='../Index.html'><b>Here</b> </a>
		</center>
<%}else{%>
	<center><button type="button" onClick="window.location.reload();">Refresh</button></center>
	<%
		Connection conn = null;
		ResultSet rs = null;
		
		String UserID = session.getAttribute("UserID").toString();
		Util newUtil = new Util();
		MBCommons newMBCommons = new MBCommons(); 
		boolean chkFlag = false;
		String notRunning = new String("");
		String env = null;		
		String hostName = null;
		int portNum =0;
		BrokerProxy brkProxy  = null;

		String brokerName = request.getParameter("brokerName").toString();
		try{
			conn = newUtil.createConn();
			Statement stmt = conn.createStatement();
			String selectQuery = ("SELECT IBMST_ID ,IBMST_IIB_NAME  "+
					" ,IBMST_IIB_HOST ,IBMST_QMGR_PORT ,IBMST_ENV "+
					" FROM IIB_MSTR "+
					" WHERE IBMST_IIB_NAME= '"+brokerName+"'");
			rs = stmt.executeQuery(selectQuery);

			if(rs.next()){
				hostName = rs.getString("IBMST_IIB_HOST");
				portNum = rs.getInt("IBMST_QMGR_PORT");
			}
			
			brkProxy = newMBCommons.getBrokerProxy(hostName, portNum);
			LogProxy lp = brkProxy.getLog();
			int logCount = lp.getSize(); 
			String logMsg = new String();
	%>
		<Table border=1 align=center width="100%" class="gridtable">
		<tr>
		<th width="10"><b>Message</b></th>
		<th width="60"><b>Detail</b></th>
		<th width="15"><b>Source</b></th>
		<th width="15"><b>Timestamp</b></th>
		</tr>
<%	
	while(logCount>0) {
		logMsg = lp.getLogEntry(logCount).getDetail();
		%>
		<tr>
		<td>
		<%=lp.getLogEntry(logCount).getMessage()%>
		</td>
		<td>
		<%=logMsg.substring(logMsg.indexOf(":")+2, logMsg.length()) %>
		</td>
		<td>
		<%=lp.getLogEntry(logCount).getSource()%>
		</td>
		<td>
		<%=lp.getLogEntry(logCount).getTimestamp() %>
		</td>
		</tr>
		<%
		out.flush();
		logCount--;
	}
	lp.clear();
	brkProxy.disconnect();
		}catch(SQLException e){
			e.printStackTrace();		
		}finally{
			rs.close();
			newUtil.closeConn(conn);
		}
}

%>
 </table>
</body>
</html>