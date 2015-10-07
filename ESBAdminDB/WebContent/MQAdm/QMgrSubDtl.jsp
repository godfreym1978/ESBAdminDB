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
<%@ page import="java.sql.*"%>
<%@ page import="org.apache.commons.csv.*"%>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<style type="text/css">
			<%@ include file="../Style.css" %>
		</style>
		<title>Subscription Detail</title>
	</head>
	<body>
		<%if(session.getAttribute("UserID")==null){%>
			Looks like you are not logged in.<br> Please login with a valid
			user id <a href='../Index.html'><b>Here</b> </a>
		<%	
		}else{
			
			String UserID = session.getAttribute("UserID").toString();
			Connection conn = null;
			ResultSet rs = null;
			Util newUtil = new Util();
			
			try{
				int qMgrID = Integer.parseInt(request.getParameter("qMgr").toString());
				String subName = request.getParameter("subName");
				
				String usrQmgrQuery = "SELECT QSM_QMGR_PORT, QSM_QMGR_HOST, QSM_QMGR_CHL  FROM QMGR_MSTR "+
											"WHERE QSM_ID = (SELECT UQSM_QSM_ID FROM USER_QMGR_MSTR "+
																" WHERE UQSM_USER_ID = '"+UserID+"' "+
																" AND UQSM_QSM_ID = "+qMgrID+")";
				conn = newUtil.createConn();
				Statement stmt = conn.createStatement();
				rs = stmt.executeQuery(usrQmgrQuery);
				int qPort=0;
				String qHost = null;
				String qChannel = null;
			
				if(rs.next()){
					qPort = rs.getInt("QSM_QMGR_PORT");
					qHost = rs.getString("QSM_QMGR_HOST");
					qChannel = rs.getString("QSM_QMGR_CHL");
				}
		
				
				PCFCommons newPFCCM = new PCFCommons();

				List<Map<String, Object>> subDtls = newPFCCM.ListSubStatus(qHost, qPort, subName, qChannel);
		%>
		<b><u>List of Topics in Queue Manager - <%=qMgrID %></u></b>
		<br>
		<table border=1 align=center class="gridtable">
			<tr>
				<td>Connection ID</td>
				<td><%=subDtls.get(0).get("MQBACF_CONNECTION_ID")%></td>
			</tr>
			<tr>
				<td>Durable Sub</td>
				<td><%=subDtls.get(0).get("MQIACF_DURABLE_SUBSCRIPTION")%></td>
			</tr>
			<tr>
				<td>Default Put Response Type</td>
				<td><%=subDtls.get(0).get("MQCACF_LAST_MSG_DATE")%></td>
			</tr>
			<tr>
				<td>Def Priority</td>
				<td><%=subDtls.get(0).get("MQCACF_LAST_MSG_TIME")%></td>
			</tr>
			<tr>
				<td>Durable Sub</td>
				<td><%=subDtls.get(0).get("MQIACF_PUBLISH_COUNT")%></td>
			</tr>
			<tr>
				<td>Resume Date</td>
				<td><%=subDtls.get(0).get("MQCA_RESUME_DATE")%></td>
			</tr>
			<tr>
				<td>Resume Time</td>
				<td><%=subDtls.get(0).get("MQCA_RESUME_TIME")%></td>
			</tr>
			<tr>
				<td>Sub User ID</td>
				<td><%=subDtls.get(0).get("MQCACF_SUB_USER_ID")%></td>
			</tr>
			<tr>
				<td>Subscription ID</td>
				<td><%=subDtls.get(0).get("MQBACF_SUB_ID")%></td>
			</tr>
		</table>
		<%
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
