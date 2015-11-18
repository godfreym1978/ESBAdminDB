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
<%@ page import="java.net.*,java.io.*"%>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style type="text/css">
<%@include file="../Style.css"%>
</style>
<title>Write Message to Queue</title>
</head>

<body>
	<center>
	<%
	if(session.getAttribute("UserID")==null){%>
		<center>
			Looks like you are not logged in.<br> Please login with a valid
			user id <a href='../Index.html'><b>Here</b> </a>
		</center>
	<%	
	}else{
		String UserID = session.getAttribute("UserID").toString();
		
		Connection conn = null;
		ResultSet rs = null;
		Util newUtil = new Util();
		
		try{
			String qMgr = request.getParameter("qMgr");
			
			long qMgrID = Long.parseLong(qMgr);
			
			String usrQmgrQuery = "SELECT QSM_QMGR_PORT, QSM_QMGR_HOST, QSM_QMGR_CHL, QSM_QMGR_NAME FROM QMGR_MSTR "+
					"WHERE QSM_ID = "+qMgrID;
			
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

			PCFCommons newPFCCM = new PCFCommons();
			
			
				String srcQueueName = request.getParameter("srcQueueName");
		String tarQueueName = request.getParameter("tarQueueName");
		String msgCount = request.getParameter("msgCount");
		ArrayList<String> messagesMoved = null;
		
		MQAdminUtil newMQAdUtil = new MQAdminUtil();  
		
		if (msgCount.equals("")){
			messagesMoved = 
				newMQAdUtil.messageMove(qMgr,qPort,qHost,srcQueueName,tarQueueName,"all");
		}else{
			messagesMoved = 
				newMQAdUtil.messageMove(qMgr,qPort,qHost,srcQueueName,tarQueueName,msgCount);
		}
		
			%>
		<table border=1 align=center width=50% class="gridtable">
			<tr>
				<td>Queue Mgr</td>
				<td><input type=hidden name=qMgr value=<%=gMgrName%>><%=gMgrName%></td>
			</tr>
			<tr>
				<td>Source Queue</td>
				<td><input type=hidden name=srcQueueName value=<%=srcQueueName%>><%=srcQueueName%></td>
			</tr>
			<tr>
				<td>Source Queue</td>
				<td><input type=hidden name=srcQueueName value=<%=tarQueueName%>><%=tarQueueName%></td>
			</tr>
			<tr>
				<td>Message Count</td>
				<td><input type=hidden name=msgCount value=<%=messagesMoved.size()%>><%=messagesMoved.size()%></td>
			</tr>
		<%
		for(int i=0;i<messagesMoved.size();i++){
			%>
			<tr>
				<td><%=(i+1)%></td>
				<td><%=messagesMoved.get(i)%></td>
			</tr>
			
		<%
		}
		}catch(Exception e){
			%>
			<center>
			We have encountered the following error<br>
			
			<font color=red><b><%=e%></b></font> 
			</center>
			<%
		}finally{
			rs.close();
			newUtil.closeConn(conn);
		}
	}
			 %>	
		</table>
		
</body>
</html>