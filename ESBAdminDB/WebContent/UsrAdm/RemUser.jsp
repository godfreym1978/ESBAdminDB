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
<%@ page import="com.ibm.esbadmin.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style type="text/css">
<%@include file="../Style.css" %>
</style>
</head>
<body>
<%
if (session.getAttribute("UserID") != null&&session.getAttribute("UserID").toString().equals("admin")) {
	
	long usmID = Long.parseLong(request.getParameter("usmID").toString());
	String userID = request.getParameter("userID").toString();
	Util newUtil = new Util();
	Connection conn = null;
	ResultSet rs = null;
	
	try{
		conn = newUtil.createConn();
		Statement stmt = conn.createStatement();
		
		String delUserQmgr = "DELETE FROM USER_QMGR_MSTR WHERE UQSM_USER_ID = (SELECT USM_USER_ID FROM USER_MSTR WHERE USM_ID = "+usmID+")"; 
		String delIIB = "DELETE FROM USER_IIB_MSTR WHERE UIBM_USER_ID = (SELECT USM_USER_ID FROM USER_MSTR WHERE USM_ID = "+usmID+")";
		String qAccess = "DELETE FROM QADM_MSTR WHERE QAM_UQSM_ID = "+usmID;
		String delUser = "DELETE FROM USER_MSTR WHERE USM_ID = "+usmID;
		
		//delete qmgr access
		stmt.execute(delUserQmgr);
		//delete iib access
		stmt.execute(delIIB);
		//delete q access
		stmt.execute(qAccess);
		//delete user
		stmt.execute(delUser);

	}finally{
		conn.close();
		
		%>
		<center>User <b><%=userID %></b> removed from the system successfully.</center>
		<%
	}
	
}else{
	%>
	<center><b>You don't have access to this page.<br> 
			Please login with a valid user id <a href='../Index.html'><b>Here</b> </a></b><center>
	<%
}
		%>
</body>
</html>