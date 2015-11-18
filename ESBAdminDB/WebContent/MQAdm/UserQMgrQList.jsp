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
<%@ page import="java.io.*"%>
<%@ page import="java.sql.*"%>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>
<%@ page import="org.apache.commons.csv.*"%>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<style type="text/css">
			<%@ include file="../Style.css"%>
		</style>
		<title>Get Queue List</title>
	</head>
	<%if(session.getAttribute("UserID")==null){%>
		<center>
			Looks like you are not logged in.<br> Please login with a valid
			user id <a href='../Index.html'><b>Here</b> </a>
		</center>
	<%
		}else{
			String UserID = session.getAttribute("UserID").toString();
			Connection conn = null;
			ResultSet rs = null;
			Util newUtil = new Util();
			try{
				long qMgrID = Long.parseLong(request.getParameter("qMgr").toString());
				
				/*
				String usrQmgrQuery = "SELECT QAM.QSM_Q_NAME, QSM.QSM_QMGR_CHL, QSM.QSM_QMGR_HOST, QSM.QSM_QMGR_NAME, QSM.QSM_QMGR_PORT "+ 
											" FROM QADM_MSTR QAM, USER_QMGR_MSTR UQSM , QMGR_MSTR QSM "+
											" WHERE QAM.QAM_UQSM_ID = UQSM.UQSM_ID "+
											" AND QSM.QSM_ID = UQSM.UQSM_QSM_ID "+
											" AND UQSM.UQSM_USER_ID = '"+UserID+"' "+
											" AND UQSM.UQSM_QSM_ID = "+qMgrID;
				*/
				

				String usrQmgrQuery = "SELECT QAM.QSM_Q_NAME, QSM.QSM_QMGR_CHL, QSM.QSM_QMGR_HOST, QSM.QSM_QMGR_NAME, QSM.QSM_QMGR_PORT "+ 
						" FROM QADM_MSTR QAM, USER_QMGR_MSTR UQSM , QMGR_MSTR QSM "+
						" WHERE QSM.QSM_ID = UQSM.UQSM_QSM_ID "+
						" AND UQSM.UQSM_USER_ID = '"+UserID+"' "+
						" AND UQSM.UQSM_QSM_ID = "+qMgrID;

				System.out.println(usrQmgrQuery);
				conn = newUtil.createConn();
				Statement stmt = conn.createStatement();
				rs = stmt.executeQuery(usrQmgrQuery);
				int qPort=0;
				String qHost = null;
				String qChannel = null;
		
				String qMgr = null;
				boolean firstRec = true;
		
				ArrayList qList = new ArrayList();
				//int qCount = 0;
				while (rs.next()){
					if(firstRec){
						firstRec = false;
						qMgr = rs.getString("QSM_QMGR_NAME");
						qPort = rs.getInt("QSM_QMGR_PORT");
						qHost = rs.getString("QSM_QMGR_HOST");
						qChannel = rs.getString("QSM_QMGR_CHL");
					}
					qList.add(rs.getString("QSM_Q_NAME"));
				}
							
				List<Map<String, Object>> qDepthList = new ArrayList<Map<String, Object>>();
				qDepthList = newUtil.getDepthAll(qList, qPort, qHost, qMgr, qChannel);
			%>
			<center>This Page gets the list of queues for the mentioned
					queue manager.</center>
			
			<table border=1 align=center class="gridtable">
				<tr>
					<th><b>Queue Name</b></th>
					<th><b>Queue Depth</b></th>
					<th><b>Browse Queue?</b></th>
					<th><b>Save Queue Messages?</b></th>
					<th><b>Purge Queue?</b></th>
					<th><b>Write File Data To Queue?</b></th>
					<th><b>Load Queue Messages?</b></th>
				</tr>
				<%
				int qCtr = 0;
				//for (String line : FileUtils.readLines(userFile)) {
				for (int qCount = 0;qCount<qList.size();qCount++) {					
				%>
				<tr>
					<td><a href='QueueDtl.jsp?qName=<%=qList.get(qCount)%>&qMgr=<%=qMgrID%>'><%=qList.get(qCount)%></a></td>
					<td><%=qDepthList.get(qCtr).get(qList.get(qCount)) %></td>
					<td><a href='MQBrowse.jsp?QName=<%=qList.get(qCount)%>&qMgr=<%=qMgrID%>'> <b>YES</b>
					</a></td>
					<td><a
							href='../DownloadMsgsFromQueue?QName=<%=qList.get(qCount)%>&qMgr=<%=qMgrID%>'>
								<b>YES</b>
					</a></td>

				<%if(UserID.indexOf("ba-") !=0){
					if((UserID.indexOf("dev-") ==0 && !qMgr.equals("QMBRKPRD01"))||UserID.equals("admin")){
				%>
					<td><a href='PurgeQueue.jsp?QName=<%=qList.get(qCount)%>&qMgr=<%=qMgrID%>'>
								<b>YES</b>
						</a></td>
					<td><form action='MQWrite.jsp?QName=<%=qList.get(qCount)%>&qMgr=<%=qMgrID%>'
								enctype="multipart/form-data" method="post">
								<input type="file" name="message"> <input type="submit"
									value="Submit" />
							</form></td>
					<td><form
								action='../LoadMsgsToQueue?QName=<%=qList.get(qCount)%>&qMgr=<%=qMgrID%>'
								enctype="multipart/form-data" method="post">
								<input type="file" name="message"> <input type="submit"
									value="Submit" />
							</form></td>

					<%}else{%>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
					<%}
					}else{
					%>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
					<%}
					qCtr++;
					
		}
			%>
		
	</table>
	<%
		}catch(Exception e){
		%>
			<center>
			We have encountered the following error<br>
			
			<font color=red><b><%=e%></b></font> 
			</center>
			<%
		}finally{
			rs.close();
			newUtil.closeConn(conn);
		}
	}
	%>
</body>
</html>
