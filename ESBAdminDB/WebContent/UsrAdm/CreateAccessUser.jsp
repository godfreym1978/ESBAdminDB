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
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>
<%@ page import="org.apache.commons.csv.*"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style type="text/css">
<%@include file="../Style.css" %>
</style>
<title>Write Message to Port</title>
</head>
<body>

	<%if (session.getAttribute("UserID") != null&&session.getAttribute("UserID").toString().equals("admin")) {
	
		String UsrID = new String(request.getParameter("UserID"));
		String UsrPwd = new String(request.getParameter("Pwd"));
		
		String []qMgr = request.getParameterValues("QueueMgr");
		String []broker = request.getParameterValues("Broker");
	
		Util newUtil = new Util();
		Connection conn = null;
		ResultSet rsUser = null;
			
		try{
			conn = newUtil.createConn();
			Statement stmt = conn.createStatement();
			String userMstr = "SELECT * FROM USER_MSTR WHERE USM_USER_ID = '"+UsrID+"'";
			rsUser = stmt.executeQuery(userMstr);
			if(rsUser.next()){
				%>
				<center>User <b><%=UsrID %></b> already exists.</center>
				<%			
			}else{
				String createUsrStmt = "INSERT INTO USER_MSTR VALUES("+newUtil.retLong()+",'"+UsrID+"','"+UsrID+"','"+newUtil.md5Digest(UsrPwd)+"')";
				stmt.execute(createUsrStmt);
				String insertUserQmgrMstrQuery = new String(); 
				for (int newQMCtr=0;newQMCtr<qMgr.length;newQMCtr++){
					insertUserQmgrMstrQuery = "INSERT INTO USER_QMGR_MSTR VALUES("+newUtil.retLong()+",'"+UsrID+"',"+qMgr[newQMCtr]+")";
					stmt.execute(insertUserQmgrMstrQuery);
				}
				String insertIIBQmgrMstrQuery = new String();
				for (int newMBCtr=0;newMBCtr<broker.length;newMBCtr++){
					insertIIBQmgrMstrQuery = "INSERT INTO USER_IIB_MSTR VALUES("+newUtil.retLong()+",'"+UsrID+"',"+broker[newMBCtr]+")";
					stmt.execute(insertIIBQmgrMstrQuery);
				}
			}
		}catch(SQLException sqlEx){
			sqlEx.printStackTrace();
		}finally{
			rsUser.close();
			newUtil.closeConn(conn);
		}
		%>
		User - <%=UsrID%> - has been created successfully.
		<%
	}else{
		%>
		<center>
		Looks like you are not logged in.<br>
		
		Please login with a valid user id <a href='Index.html'><b>Here</b> </a>
		</center>
	<%}%>
</body>
</html>