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
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<style type="text/css">
			<%@ include file="../Style.css" %>
		</style>
		<title>Subscription List</title>
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
		
				
				PCFCommons newPFCCM = new PCFCommons();

				List<Map<String, Object>> topicDtls = 
						newPFCCM.ListSubNames(qHost, qPort, qChannel);
				int listCtr =0;
				int listCount =topicDtls.size();
		%>
		<b><u>List of Subscriptions in Queue Manager - <%=gMgrName %></u></b><br>
		<table border=1 class="gridtable">
			<tr>
				<th><b>Sub Name</b></th>
				<th><b>Sub Topic Name</b></th>
				<th><b>Sub Topic String</b></th>
				<th><b>Destination</b></th>
				<th><b>Sub User ID</b></th>
				<th><b>Sub Creation Date</b></th>
				<th><b>Sub Creation Time</b></th>
				<th><b>Sub Alteration Date</b></th>
				<th><b>Sub Alteration Time</b></th>
				<th><b>Download MQSC Script</b></th>
			</tr>
			<%
				while(listCtr<listCount) {
			%>
			<tr>
				<td><a
					href='QMgrSubDtl.jsp?qMgr=<%=qMgrID%>
						&subName=<%=topicDtls.get(listCtr).get("MQCACF_SUB_NAME").toString()%>'> 
						<%=topicDtls.get(listCtr).get("MQCACF_SUB_NAME")%></a>
				</td>
				<td><%=topicDtls.get(listCtr).get("MQCA_TOPIC_NAME")%></td>
				<td><%=topicDtls.get(listCtr).get("MQCA_TOPIC_STRING")%></td>
				<td><%=topicDtls.get(listCtr).get("MQCACF_DESTINATION")%></td>
				<td><%=topicDtls.get(listCtr).get("MQCACF_SUB_USER_ID")%></td>
				<td><%=topicDtls.get(listCtr).get("MQCA_CREATION_DATE")%></td>
				<td><%=topicDtls.get(listCtr).get("MQCA_CREATION_TIME")%></td>
				<td><%=topicDtls.get(listCtr).get("MQCA_ALTERATION_DATE")%></td>
				<td><%=topicDtls.get(listCtr).get("MQCA_ALTERATION_TIME")%></td>
				<td><a
					href='../DownloadQObject?qMgr=<%=qMgrID%>
							&objType=SUB
							&objName=<%=topicDtls.get(listCtr).get("MQCACF_SUB_NAME").toString()%>'> 
							Download MQSC Script For This Subscription</a>
				</td>
			</tr>
		<%
					out.flush();
					listCtr++;
				}
		%>
		</table>
		<%}catch(Exception e){%>
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
