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
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<html>
	<head>
		<meta http-equiv="Content-Style-Type" content="text/css">
		<style type="text/css">
		<%@ include file="../Style.css" %>
		</style>
		<title>Browse Messages</title>
	</head>
	<body>
		<%if (session.getAttribute("UserID") == null) {%>
			<b>Are you logged in to system? 
			If not do so in <a href='../Index.html'>here </a></b>
		<%} else {
			Util newUtil = new Util();
			Connection conn = null;
			ResultSet rs = null;

			String UserID = session.getAttribute("UserID").toString();
			String qName = request.getParameter("QName").toString();
			String qMgr = request.getParameter("qMgr").toString();
			long qMgrID = Long.parseLong(request.getParameter("qMgr").toString());
			
			
			String usrQmgrQuery = "SELECT QSM_QMGR_NAME, QSM_QMGR_PORT, QSM_QMGR_HOST, QSM_QMGR_CHL  FROM QMGR_MSTR "+
					"WHERE QSM_ID = (SELECT UQSM_QSM_ID FROM USER_QMGR_MSTR "+
										" WHERE UQSM_USER_ID = '"+UserID+"' "+
										" AND UQSM_QSM_ID = "+qMgrID+")";
			String qHost = null;
			String qChannel = null;
			String gMgrName = null;

			int qPort=0;

			try{
				conn = newUtil.createConn();
				Statement stmt = conn.createStatement();
				rs = stmt.executeQuery(usrQmgrQuery);
				if(rs.next()){
					qPort = rs.getInt("QSM_QMGR_PORT");
					qHost = rs.getString("QSM_QMGR_HOST");
					qChannel = rs.getString("QSM_QMGR_CHL");
					gMgrName = rs.getString("QSM_QMGR_NAME");
				}
				
			}catch(Exception e){
			%>
				We have encountered the following error<br>
				<font color=red><b><%=e%></b></font> 
				<%
			}finally{
				rs.close();
				newUtil.closeConn(conn);
			}
		

		%>
		You have selected to browse the Queue - <b><%=qName%></b> 
		/ Queue Manager - <b><%=gMgrName%></b>
		<%
			int inCrement = 0;
			int iCount = 0;
			int inMsgCtr = 0;

			MQAdminUtil newMQAdUtil = new MQAdminUtil();
			ArrayList<String> alQueueList = null;
			alQueueList = newMQAdUtil.browseQueue(gMgrName, qName);
			iCount = alQueueList.size();
			if (iCount != 0) {
		%>
		<table border=1 align=center width=100% class="gridtable">
			<tr>
				<th style="width: 4%;">Message No</th>
				<th style="width: 56%;">Message Data</th>
				<th style="width: 20%;">Message PutDateTime</th>
			</tr>
			<%
				String msgId = new String();
				while (inCrement < iCount) {
					msgId = alQueueList.get(inCrement + 1);
			%>
			<tr>
				<td><a
					href='../DownloadMsgFromQueue?qMgr=<%=qMgr%>
							&qName=<%=qName%>&message=<%=alQueueList.get(inCrement + 1)%>'>
								<%=inMsgCtr + 1%></a></td>
				<td><%=alQueueList.get(inCrement)%></td>
				<td><%=alQueueList.get(inCrement + 2)%></td>
				<%
					inCrement = inCrement + 3;
								inMsgCtr++;
				}
				%>
			</tr>			
		</table>
		<center><button type="button" onClick="window.location.reload();">Refresh</button></center>
		<%
			} else {
		%>
		<br> <u>There are no messages on this queue</u>
		<%
			}
		}
		%>
</body>
</html>