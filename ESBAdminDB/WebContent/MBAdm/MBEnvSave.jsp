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
<%@ page import="java.sql.*"%>
<%@ page import="com.ibm.broker.config.proxy.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.ibm.mq.MQEnvironment"%>
<%@ page import="com.ibm.mq.MQQueueManager"%>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>
<%@ page import="java.sql.Timestamp"%>

<html>
<head>
<meta http-equiv="Content-Style-Type" content="text/css">
<style type="text/css">
<%@ include file="../Style.css" %>
</style>
<title>Message Broker Environment</title>
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
		MBCommons newMBCmn = new MBCommons();
		
		Connection conn = null;
		ResultSet rs = null;
		
		String MBName = request.getParameter("brkName").toString();
		String MBHost = request.getParameter("brkHost").toString();
		int MBPort =  Integer.parseInt(request.getParameter("brkPort").toString());
		String MBEnv = request.getParameter("brkEnv").toString();
		
		String QMName = request.getParameter("brkQMgr");
		String QMChannel =  request.getParameter("brkQMgrChl");

	%>
			<center><h3> Message Broker Environment</h3></center>
			<form action='MBEnvSave.jsp' method="post">

			<Table border=1 align=center class="gridtable">
				<tr>
					<th><b>Broker Environment</b></th>
					<th><b>Broker Name</b></th>
					<th><b>Broker IP Address/HostName</b></th>
					<th><b>Broker QM Port</b></th>
				</tr>
				<tr>
					<td><%=MBEnv%></td>
					<td><%=MBName%></td>
					<td><%=MBHost%></td>
					<td><%=MBPort%></td>
				</tr>
			</table>
	<%	
			String qmgrQuery = null;
			try{
				
				conn = newUtil.createConn();
				Statement stmt = conn.createStatement();
				
				qmgrQuery = "SELECT * FROM QMGR_MSTR "+
						" WHERE QSM_QMGR_NAME = '"+QMName+"'"+
						" AND QSM_QMGR_HOST = '"+MBHost+"'";

				rs = stmt.executeQuery(qmgrQuery);
				
				if(!rs.next()){
					MQEnvironment.channel = QMChannel;
					MQEnvironment.port = MBPort;
					MQEnvironment.hostname = MBHost;
					MQQueueManager qmgr = new MQQueueManager(QMName);
					qmgr.disconnect();

					String insertQmgrMstrQuery = "INSERT INTO QMGR_MSTR VALUES(QMGR_MSTR_SEQ.NEXTVAL,'"+QMName+"','"+MBHost+"',"+MBPort+",'"+QMChannel+"' )";
					stmt.execute(insertQmgrMstrQuery);
					
					String insertUserQmgrMstrQuery = "INSERT INTO USER_QMGR_MSTR VALUES(USER_QMGR_MSTR_SEQ.NEXTVAL,'"+UserID+"',"+
													" (SELECT QSM_ID FROM QMGR_MSTR "+ 
															" WHERE QSM_QMGR_NAME = '"+QMName+"'"+
							 								" AND QSM_QMGR_HOST = '"+MBHost+"'))";
					stmt.execute(insertUserQmgrMstrQuery);

				}
				
				rs = stmt.executeQuery("SELECT * FROM IIB_MSTR "+
						" WHERE IBMST_IIB_NAME = '"+MBName+"'"+
						" AND IBMST_IIB_HOST = '"+MBHost+"'");
				
				if(rs.next()){
					%>
					<center>
	    			The Message Broker with above details has already been registered.<br>
	    			</center>
					<hr>
					<%					
				}else{

					BrokerConnectionParameters bcp = new MQBrokerConnectionParameters(MBHost,MBPort, "");
					BrokerProxy brkProxy = BrokerProxy.getInstance(bcp);
					brkProxy.disconnect();
					String insertIIBMstrQuery = "INSERT INTO IIB_MSTR VALUES(IIB_MSTR_SEQ.NEXTVAL,'"+MBEnv+"','"+MBName+"','"+MBHost+"',"+MBPort+" )";
					stmt.execute(insertIIBMstrQuery);
					
					String insertIIBQmgrMstrQuery = "INSERT INTO USER_IIB_MSTR VALUES(USER_IIB_MSTR_SEQ.NEXTVAL,'"+UserID+"',"+
													" (SELECT IBMST_ID FROM IIB_MSTR "+ 
															" WHERE IBMST_IIB_NAME = '"+MBName+"'"+
							 								" AND IBMST_IIB_HOST = '"+MBHost+"'))";
					stmt.execute(insertIIBQmgrMstrQuery);
	
					%>
						<center>
	    				The broker runtime with above details has been successfully registered.<br>
	    				</center>
						<hr>
	    			<%
				}
			}catch(Exception e){
				%>
					<center>
    				Cannot register with the following details.<br>
    				<%=e.getMessage()%>
    				</center>
					<hr>
    			<%	
			}finally{
				rs.close();
				newUtil.closeConn(conn);
			}
		}
%>
</body>
</html>