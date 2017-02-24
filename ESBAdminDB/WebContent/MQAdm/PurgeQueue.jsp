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

*/
/********************************************************************************/
 -->
 <%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="com.ibm.esbadmin.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style type="text/css">
<%@ include file="../Style.css" %>
</style>
<title>Purge Queue</title>
</head>

<body>
	
		<center>
<%if(session.getAttribute("UserID")==null){
%>

		<center>
		Looks like you are not logged in.<br>
		
		Please login with a valid user id <a href='../Index.html'><b>Here</b> </a>
		</center>

<%	
}else{
	String UserID = session.getAttribute("UserID").toString();
	String qName = request.getParameter("QName");
	Connection conn = null;
	ResultSet rs = null;
	Util newUtil = new Util();
	MQAdminUtil newMQAdUtil = new MQAdminUtil();
	PCFCommons newPFCCM = new PCFCommons();
	try{
		
		long qMgrID = Long.parseLong(request.getParameter("qMgr").toString());

		String usrQmgrQuery = "SELECT QSM_QMGR_NAME, QSM_QMGR_PORT, QSM_QMGR_HOST, QSM_QMGR_CHL  FROM QMGR_MSTR "+
									"WHERE QSM_ID = (SELECT UQSM_QSM_ID FROM USER_QMGR_MSTR "+
														" WHERE UQSM_USER_ID = '"+UserID+"' "+
														" AND UQSM_QSM_ID = "+qMgrID+")";
		conn = newUtil.createConn();
		Statement stmt = conn.createStatement();
		rs = stmt.executeQuery(usrQmgrQuery);
		int qPort=0;
		String qHost = null;
		String qChannel = null;
		String gMgrName = null;
	
		if(rs.next()){
			qPort = rs.getInt("QSM_QMGR_PORT");
			qHost = rs.getString("QSM_QMGR_HOST");
			qChannel = rs.getString("QSM_QMGR_CHL");
			gMgrName = rs.getString("QSM_QMGR_NAME");
		}

		int msgPurged = newPFCCM.purgeQueue(qHost,qPort, qName, qChannel);

		if (msgPurged<0){
			msgPurged = newMQAdUtil.purgeQueue(gMgrName, qName);
			%>
			<b><%=msgPurged%></b> Messages Purged from the Queue - <b><%=qName%></b>
			- Queue Manager <b><%=gMgrName%></b>
			<%
		}else{
			%>
			Messages Cleared from the Queue - <b><%=qName%></b>
			- Queue Manager <b><%=gMgrName%></b>
			<%
		}
	}catch(SQLException e){
		e.printStackTrace();
	}finally{
		rs.close();
		newUtil.closeConn(conn);
	}
}
			%>
</body>
</html>