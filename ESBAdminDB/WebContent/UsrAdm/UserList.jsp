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
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<style type="text/css">
			<%@ include file="../Style.css" %>
		</style>
		<title>User List</title>
	</head>
<body>
	<%if(session.getAttribute("UserID")==null){%>
		Looks like you are not logged in.<br>
		Please login with a valid user id <a href='../Index.html'><b>Here</b> </a>
	<%}else{
		String UserID = session.getAttribute("UserID").toString();
		if(UserID.equals("admin")){
			Connection conn = null;
			ResultSet rs = null;
			Util newUtil = new Util();
			try{ 
				conn = newUtil.createConn();
				Statement stmt = conn.createStatement();
				rs = stmt.executeQuery("SELECT * FROM USER_MSTR ");
				%>
				<center>The list of users for this site.</center>
				<table border=1 align=center class="gridtable">
					<tr>
						<td><b>User Name</b></td>
						<td><b>Remove User</b></td>
					</tr>
				<%while(rs.next()){%>
					<tr>
						<td><%=rs.getString("USM_USER_ID")%></td>
						<td><a href='RemUser.jsp?userID=<%=rs.getString("USM_USER_ID")%>&usmID=<%=rs.getLong("USM_ID")%>'> <b>YES</b></a></td>
					</tr>	 
				<%}%>
				</table>
				<%
			}catch(Exception e){
				e.printStackTrace();
			}finally{
				rs.close();
				newUtil.closeConn(conn);
			}
		}
	}
	%>
</body>
</html>
