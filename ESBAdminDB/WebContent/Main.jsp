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
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>

<html>
<head>
<meta http-equiv="Content-Style-Type" content="text/css">
<style type="text/css">
<%@ include file ="Style.css" %>
</style>

<title>Main Dashboard</title>
</head>

<%
Util newUtil = new Util();
String actualPassword = new String();
Connection conn = null;
ResultSet rs = null;
try{
	String UserID = request.getParameter("UserID").toString();
	String Passwd = request.getParameter("Pwd").toString();
	conn = newUtil.createConn();
	Statement stmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT * FROM USER_MSTR WHERE USM_USER_ID = '"+UserID+"'");  
	
	if(rs.next()){
		if (newUtil.md5Digest(Passwd).equals(rs.getString("USM_PASSWD"))){
			session.setAttribute("UserID", UserID);
			session.setAttribute("UserName", rs.getString("USM_USER_NAME"));
			%>
			<FRAMESET cols="20%, 80%">
			      <FRAME name="static" src='Login.jsp?UserID=<%=request.getParameter("UserID")%>'>/>
			      <FRAME name="dynamic" src='Readme.html'/>
			</FRAMESET>
		<%}else{%>
			<center>
			Sorry Password does not match!!!!<br>
			
			Please login <a href='Index.html'><b>Here</b> </a>
			</center>
		<%}
	}else{
		if(UserID.equals("admin")){
			System.out.println("admin user logging");
			String createUsrStmt = "INSERT INTO USER_MSTR VALUES("+newUtil.retLong()+",'admin','admin','"+newUtil.md5Digest(Passwd)+"')";
			stmt.execute(createUsrStmt);
			session.setAttribute("UserID", "admin");
			session.setAttribute("UserName", "admin");
			session.setAttribute("usmid", 1);
			System.out.println("about to check user"+request.getParameter("UserID"));
			%>
			<FRAMESET cols="20%, 80%">
			      <FRAME name="static" src='Login.jsp?UserID=<%=request.getParameter("UserID")%>'>/>
			      <FRAME name="dynamic" src='Readme.html'/>
			</FRAMESET>
		<%}else{%>
			<center>
			Sorry No user by that name exist!!!!<br>
				
			Please login with a valid user id <a href='Index.html'><b>Here</b> </a>
			</center>
		<%	
		}
	}
}catch(NullPointerException ex){
	%>
	<center>
	Did you enter an user id and password?<br>
	
	Please login with a valid user id <a href='Index.html'><b>Here</b> </a>
	</center>
	<%	
}catch(SQLException e){
	e.printStackTrace();
	%>
	<center>
	Something just went wrong with the backend database.
	
	Please login with a valid user id <a href='Index.html'><b>Here</b> </a>
	</center>
	<%	
}finally{
	if (rs==null){
		//newUtil.closeConn(conn);
	}else{
		rs.close();
		newUtil.closeConn(conn);
	}
}
%>
</html>