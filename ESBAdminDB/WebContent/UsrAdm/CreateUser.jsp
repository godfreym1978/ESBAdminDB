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
<%@ page import="org.apache.commons.csv.*"%>
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
	<%if (session.getAttribute("UserID") != null&&session.getAttribute("UserID").toString().equals("admin")) {
	
		Util newUtil = new Util();
		Connection conn = null;
		ResultSet rsQmgr = null;
		ResultSet rsIIB = null;
		
		conn = newUtil.createConn();
		Statement stmt = conn.createStatement();
		String qmgrMstr = "SELECT * FROM QMGR_MSTR ";
		String iibMstr = "SELECT * FROM IIB_MSTR ";
	%>
	<form action='CreateAccessUser.jsp' method="post">
		<table align=center borders=1 class="gridtable">
			<tr>
				<td>User ID</td>
				<td><input type="text" name="UserID" /></td>
			</tr>
			<tr>
				<td>User Password</td>
				<td><input type="password" name="Pwd" /></td>
			</tr>
			<tr>
				<th>Queue Manager(Host)</th>
				<th>Allow Access</th>
			</tr>
			<%
			try{
				rsQmgr = stmt.executeQuery(qmgrMstr);
				while(rsQmgr.next()) {
				%>
					<tr>
						<td>Queue Manager - <%=rsQmgr.getString("QSM_QMGR_NAME")%> , Host - <%=rsQmgr.getString("QSM_QMGR_HOST")%></td>
						<td><input type="checkbox" name="QueueMgr" value="<%=rsQmgr.getLong("QSM_ID")%>"></td>
					</tr>
				<%}%>
				<tr>
					<th>Broker (Host)</th>
					<th>Allow Access</th>
				</tr>
				<%
				rsIIB = stmt.executeQuery(iibMstr);
				while(rsIIB.next()) {
					%>
					<tr>
						<td>Host - <%=rsIIB.getString("IBMST_IIB_HOST")%> , QM Port <%=rsIIB.getString("IBMST_QMGR_PORT")%></td>
						<td><input type="checkbox" name="Broker" value="<%=rsIIB.getLong("IBMST_ID")%>"></td>
					</tr>
					<%
				} 
			}catch(SQLException sqlEx){
				sqlEx.printStackTrace();
			}finally{
				rsQmgr.close();
				rsIIB.close();
				newUtil.closeConn(conn);
			}
			%>
			<tr>
				<td colspan=2><input type="submit" value="CreateUser" /></td>
			</tr>
		</table>
		</form>
	<%}else{%>
		<center>
			<b>You don't have access to this page.<br> Please login with
				a valid user id <a href='../Index.html'><b>Here</b> </a></b>
		<center>
	<%}%>
</body>
</html>