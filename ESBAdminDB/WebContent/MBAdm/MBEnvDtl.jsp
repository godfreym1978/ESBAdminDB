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
<%@ page import="org.apache.commons.csv.*"%>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>

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
		Connection conn = null;
		ResultSet rs = null;

		String UserID = session.getAttribute("UserID").toString();
		Util newUtil = new Util();
		MBCommons newMBCommons = new MBCommons(); 
		boolean chkFlag = false;
		String notRunning = new String("");
		String env = null;		
		String hostName = null;
		String iibName = null;
		int portNum =0;
		BrokerProxy brkProxy  = null;

		try{
			conn = newUtil.createConn();
			Statement stmt = conn.createStatement();
			rs = stmt.executeQuery("SELECT UIM.UIBM_ID, UIM.UIBM_IBMST_ID, IBMST.IBMST_ID ,IBMST.IBMST_IIB_NAME  "+
												" ,IBMST.IBMST_IIB_HOST ,IBMST.IBMST_QMGR_PORT ,IBMST.IBMST_ENV "+
												" FROM USER_IIB_MSTR UIM, IIB_MSTR IBMST "+
												" WHERE UIM.UIBM_USER_ID = '"+UserID+"'"+
												" AND UIM.UIBM_IBMST_ID = IBMST.IBMST_ID "	);
			ArrayList<ExecutionGroupProxy> egProxy = null;
			int egCtr;
			int egCount;
			%>
			<center><h3> Message Broker Environment</h3></center>
			<Table border=1 align=center class="gridtable">
				<tr>
					<th><b>Broker Details</b></th>
					<th><b>Broker EGs</b></th>
					<th><b>Broker EGs Action</b></th>
					<th><b>Broker Logs</b></th>
				</tr>
			<%
			while(rs.next()){
				iibName = rs.getString("IBMST_IIB_NAME");
				env = rs.getString("IBMST_ENV");
				hostName = rs.getString("IBMST_IIB_HOST");
				portNum = rs.getInt("IBMST_QMGR_PORT");
				try{
					BrokerConnectionParameters bcp = new MQBrokerConnectionParameters(
							hostName, portNum, "");
					brkProxy = BrokerProxy.getInstance(bcp);
					brkProxy.getName();
			%>
			<tr>
				<td><%=brkProxy.getName()%>
					<br>
					<a href='MBLogProxy.jsp?brokerName=<%=iibName%>'>	<%=iibName%> Log </a>
					<br><font color=blue>Broker QM</font> - <%=brkProxy.getQueueManagerName()%> 
					<br><font color=blue>Broker OS</font> - <%=brkProxy.getBrokerOSName()%> 
					<br><font color=blue>Broker OS Version</font> - <%=brkProxy.getBrokerOSVersion()%> 
					<br><font color=blue>Broker Version</font> - <%=brkProxy.getBrokerVersion()%> 
				</td>
				<td>
				<%
				egProxy = Collections.list(brkProxy.getExecutionGroups(null));
				egCount = egProxy.size();
				for (egCtr=0;egCount>egCtr;egCtr++){
					%><a href='MBGetEG.jsp?brokerName=<%=iibName%>&egName=<%=egProxy.get(egCtr).getName()%>'>
					<%=egProxy.get(egCtr).getName()%></a> - <%
					if(egProxy.get(egCtr).isRunning()){
						%>
						<font color=green>Running</font><br>
						<%						
					}else{
						 %>
						<font color=red>Stopped</font><br>
						<%
					}
				}
				%>
				</td>
				<td>
					<%
						if(UserID.equals("admin")){
						egCount = egProxy.size();
						for (egCtr = 0; egCount > egCtr; egCtr++) {
							%>	<%=egProxy.get(egCtr).getName()%> -> 
							<a
							href='../MBAdmin?action=EGstart&egName=<%=egProxy.get(egCtr).getName()%>&brkName=<%=iibName%>' >
								START </a> 
								| 
							<a
							href='../MBAdmin?action=EGstop&egName=<%=egProxy.get(egCtr).getName()%>&brkName=<%=iibName%>' >
								STOP </a>
								| 	 
							<a
							href='../MBAdmin?action=EGdelete&egName=<%=egProxy.get(egCtr).getName()%>&brkName=<%=iibName%>' >
								DELETE </a><br> 
						<%}
						}else if((env.equals("DEV")||env.equals("QA"))&&UserID.indexOf("dev-")>-1){
							egCount = egProxy.size();
				 
							for (egCtr = 0; egCount > egCtr; egCtr++) {
								%>	<%=egProxy.get(egCtr).getName()%> -> 
								<a
								href='../MBAdmin?action=EGstart&egName=<%=egProxy.get(egCtr).getName()%>&brkName=<%=iibName%>' >
									START </a> 
									| 
								<a
								href='../MBAdmin?action=EGstop&egName=<%=egProxy.get(egCtr).getName()%>&brkName=<%=iibName%>' >
									STOP </a>
									| 	 
								<a
								href='../MBAdmin?action=EGdelete&egName=<%=egProxy.get(egCtr).getName()%>&brkName=<%=iibName%>' >
									DELETE </a><br> 
							<%}
						}
					%>
				</td>
				<td>					
					<%
					egProxy = Collections.list(brkProxy.getExecutionGroups(null));
					egCount = egProxy.size();
					for (egCtr=0;egCount>egCtr;egCtr++){
						%>
						<a href='MBActLogProxy.jsp?brokerName=<%=iibName%>&egName=<%=egProxy.get(egCtr).getName()%>'>
						<%=egProxy.get(egCtr).getName()%> Activity Log </a>
						<br>
					<%}%>
				</td>
			</tr>
				<%
				egProxy.clear();
				brkProxy.disconnect();
			}catch(ConfigManagerProxyLoggedMQException e){
				e.printStackTrace();
				chkFlag = true;
				notRunning = notRunning+" "+hostName;
			}catch(ConfigManagerProxyPropertyNotInitializedException e){
				e.printStackTrace();
				chkFlag = true;
				notRunning = notRunning+" "+hostName;
			}
		}//end of while loop. all IIB environment are read
	}catch(SQLException e){
		e.printStackTrace();		
	}finally{
		rs.close();
		newUtil.closeConn(conn);
	}
	%>
	</Table>
		<%
		if(chkFlag){
			%>
			<center><b>The following host dont have broker queue managers up and running <%=notRunning%></b></center>
			<%
		}
	}
	%>

</body>
</html>