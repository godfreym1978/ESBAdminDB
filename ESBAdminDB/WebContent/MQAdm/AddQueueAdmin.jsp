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
<%@ page import="com.ibm.esbadmin.*"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
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
		
		Please login with a valid user id <a href='Index.html'><b>Here</b> </a>
		</center>

<%	
}else{
	String UserID = session.getAttribute("UserID").toString();
	String []newStr = request.getParameterValues("Queue");
	String qMgr = request.getParameter("qMgr").toString();
	long qMgrID = Long.parseLong(request.getParameter("qMgr").toString());
	List<String> setupQueue = new ArrayList<String>();
	
	Util newUtil = new Util();
	
	Connection conn = null;
	ResultSet rs = null;
	
	int lineCtr = 0;
	int newQCtr;

	try{
		conn = newUtil.createConn();
		Statement stmt = conn.createStatement();
		
		for (newQCtr=0;newQCtr<newStr.length;newQCtr++){
			rs = stmt.executeQuery("SELECT * FROM QADM_MSTR WHERE QAM_UQSM_ID = "+qMgrID+" AND QSM_Q_NAME = '"+newStr[newQCtr].toString().trim()+"'");
			if(rs.next()){
				%>
				<center>Queue Name - <%=newStr[newQCtr].toString() %> - Is already setup for admin<br></center>
				<%
			}else{
				stmt.execute("INSERT INTO QADM_MSTR VALUES ("+newUtil.retLong()+","+qMgrID+",'"+newStr[newQCtr].toString().trim()+"')");
				%>
				<center>Queue Name - <%=newStr[newQCtr].toString() %> - Set up for Admin<br></center>
				<%
			}
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
	}
	
%>

</body>
</html>