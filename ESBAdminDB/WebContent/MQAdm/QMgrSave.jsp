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
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.ibm.mq.MQEnvironment"%>
<%@ page import="com.ibm.mq.MQQueueManager"%>
<%@ page import="java.sql.*"%>

<html>
<head>
<meta http-equiv="Content-Style-Type" content="text/css">
<style type="text/css">
<%@ include file="../Style.css" %>
</style>
<title>Queue Manager Environment</title>
</head>
<body>
	<%
	if(session.getAttribute("UserID")==null){
	%>
		<center>
		Looks like you are not logged in.<br>
		
		Please login with a valid user id <a href='../Index.html'><b>Here</b> </a>
		</center>
	
	<%	
	}else{
		String UserID = session.getAttribute("UserID").toString();
		Util newUtil = new Util();
		
		Connection conn = null;
		ResultSet rs = null;
		
		String QMName = request.getParameter("qmgrName").toString();
		String QMHost = request.getParameter("qmgrHost").toString();
		String QMPort = request.getParameter("qmgrPort").toString();
		String QMChannel = request.getParameter("qmgrChl").toString();

	%>
			<center><h3> Queue Manager Environment</h3></center>
			
			<Table border=1 align=center class="gridtable">
				<tr>
					<th><b>Queue Manager HostName</b></th>
					<th><b>Queue Manager Name</b></th>
					<th><b>Queue Manager Port</b></th>
					<th><b>Queue Manager Channel</b></th>
				</tr>
				<tr>
					<td><%=QMHost%></td>
					<td><%=QMName%></td>
					<td><%=QMPort%></td>
					<td><%=QMChannel%></td>
				</tr>
			</table>
	<%	
		MQAdminUtil newMQAdUtil = new MQAdminUtil();
		PCFCommons newPCFCom = new PCFCommons();

		try{
			conn = newUtil.createConn();
			Statement stmt = conn.createStatement();
			rs = stmt.executeQuery("SELECT * FROM QMGR_MSTR "+
												" WHERE QSM_QMGR_NAME = '"+QMName+"'"+
												" AND QSM_QMGR_HOST = '"+QMHost+"'");
			if(rs.next()){
				%>
				<center>
    			The Queue Manager with above details has already been registered.<br>
    			</center>
				<hr>
				<%					
			}else{
				try{
					MQEnvironment.channel = QMChannel;
					MQEnvironment.port = Integer.parseInt(QMPort);
					MQEnvironment.hostname = QMHost;
					MQQueueManager qmgr = new MQQueueManager(QMName);
					qmgr.disconnect();
					String insertQmgrMstrQuery = "INSERT INTO QMGR_MSTR VALUES(QMGR_MSTR_SEQ.NEXTVAL,'"+QMName+"','"+QMHost+"',"+QMPort+",'"+QMChannel+"' )";
					stmt.execute(insertQmgrMstrQuery);
					
					String insertUserQmgrMstrQuery = "INSERT INTO USER_QMGR_MSTR VALUES(USER_QMGR_MSTR_SEQ.NEXTVAL,'"+UserID+"',"+
													" (SELECT QSM_ID FROM QMGR_MSTR "+ 
															" WHERE QSM_QMGR_NAME = '"+QMName+"'"+
							 								" AND QSM_QMGR_HOST = '"+QMHost+"'))";
					stmt.execute(insertUserQmgrMstrQuery);
					%>
					<center>
					The Queue Manager with above details has been successfully registered.<br>
					</center>
					<hr>
					<%	
					}catch(Exception e){
					%>
						<center>
	    				Cannot register with the following details.<br>
	    				<%=e.getMessage()%>
	    				</center>
						<hr>
	    			<%	
					}
			}
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			rs.close();
			newUtil.closeConn(conn);
		}
	}
%>
</body>
</html>