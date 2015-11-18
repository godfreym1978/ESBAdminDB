<!-- 
/********************************************************************************/
/* */
/* Project: ESBAdmin */
/* Author: Godfrey Peter Menezes */
/* 
Copyright � 2015 Godfrey P Menezes
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
<%@ page import="java.net.*,java.io.*"%>  
<%@ page import="org.apache.commons.fileupload.*,org.apache.commons.io.*" %>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style type="text/css">
<%@ include file="../Style.css" %>
</style>
<title>Write Message to Queue</title>
</head>

<body>
		<center>
			<%
if(session.getAttribute("UserID")==null){
%>

		<center>
		Looks like you are not logged in.<br>
		
		Please login with a valid user id <a href='../Index.html'><b>Here</b> </a>
		</center>
<%}else{
		Util newUtil = new Util();
		String UserID = session.getAttribute("UserID").toString();
		Connection conn = null;
		ResultSet rs = null;

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

				// Create a new file upload handler 

				DiskFileUpload upload = new DiskFileUpload();
				// parse request
				List items = upload.parseRequest(request);

				// get qMgr Name
				String qMgr = new String();
				//qMgr = request.getParameter("QMgr").toString();

				//get qName
				String qName = new String();
				qName = request.getParameter("QName").toString();

				//get uploaded file 
				FileItem file = (FileItem) items.get(0);
				String source = file.getName();

				File outfile = new File(System.getProperty("catalina.base")+File.separator+"upload.txt");
				file.write(outfile);

				MQAdminUtil newMQAdmUtil = new MQAdminUtil();
				String returnMsg = newMQAdmUtil.writeMessageToQueue(gMgrName, qName,
						FileUtils.readFileToString(outfile));
			%>
			<table border=1 align=center width=100% class="gridtable">
				<tr>
					<td>Queue Manager</td>
					<td><%=qMgr%></td>
				</tr>
				<tr>
					<td>Queue Name</td>
					<td><%=qName%></td>
				</tr>
				<tr>
					<td>Message</td>
					<td><xmp><%=FileUtils.readFileToString(outfile)%></xmp></td>
				</tr>
			</table>
			<%
				if (returnMsg.equalsIgnoreCase("Success")) {
					%>Message written to the queue successfully<%
				} else {
			%>
					Following Error occurred while writing the message to the queue
					<%=returnMsg %>
			<%} 
			}%>
</body>
</html>