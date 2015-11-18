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
<%@ page import="com.ibm.mq.constants.MQConstants" %>

<html>
	<script type="text/javascript">
	  function unhide(divID) {
	    var item = document.getElementById(divID);
	    if (item) {
	      item.className=(item.className=='hidden')?'unhidden':'hidden';
	    }
	  }
	</script>
	<head>
		<meta http-equiv="Content-Style-Type" content="text/css">
		<style type="text/css">
			<%@ include file="../Style.css" %>
		</style>
	<title>Channel Status</title>
	</head>
	<body>
		<% if(session.getAttribute("UserID")==null) {%>
			Looks like you are not logged in.<br> Please login with a valid
			user id <a href='../Index.html'><b>Here</b> </a>
		<%}else{
			
			String UserID = session.getAttribute("UserID").toString();
			Connection conn = null;
			ResultSet rs = null;
			Util newUtil = new Util();

			try{
				long qMgrID = Long.parseLong(request.getParameter("qMgr").toString());
				
				String usrQmgrQuery = "SELECT QSM_QMGR_PORT, QSM_QMGR_HOST, QSM_QMGR_CHL  FROM QMGR_MSTR "+
											"WHERE QSM_ID = (SELECT UQSM_QSM_ID FROM USER_QMGR_MSTR "+
																" WHERE UQSM_USER_ID = '"+UserID+"' "+
																" AND UQSM_QSM_ID = "+qMgrID+")";

				
				conn = newUtil.createConn();
				Statement stmt = conn.createStatement();
				rs = stmt.executeQuery(usrQmgrQuery);
				int qPort=0;
				String qMgr = null;
				String qHost = null;
				String qChannel = null;

				MQAdminUtil newMQAdUtil = new MQAdminUtil();
				if(rs.next()){
					qPort = rs.getInt("QSM_QMGR_PORT");
					qHost = rs.getString("QSM_QMGR_HOST");
					qChannel = rs.getString("QSM_QMGR_CHL");
					
				}
		
				System.out.println(usrQmgrQuery);
				PCFCommons newPFCCM = new PCFCommons();

				String chlName = request.getParameter("chlName").toString();
				
				List<Map<String, Object>> chanelStat  = newPFCCM.channelStatus(qHost, qPort,chlName );
				System.out.println(chlName);
				
		%>
		<table border=1 align=center class="gridtable">
				<tr><td><b>Channel Name</b></td><td><%=chanelStat.get(0).get("MQCACH_CHANNEL_NAME")%></td></tr>
				<tr><td><b>Channel Instance Type</b></td><td><%=chanelStat.get(0).get("MQIACH_CHANNEL_INSTANCE_TYPE")%></td></tr>
		    		<tr><td><b>Channel Status</b></td><td><%=chanelStat.get(0).get("MQIACH_CHANNEL_STATUS")%></td></tr>
				<tr><td><b>Number of completed batches</b></td><td><%=chanelStat.get(0).get("MQIACH_BATCHES")%></td></tr>
				<tr><td><b>Batch size</b></td><td><%=chanelStat.get(0).get("MQIACH_BATCH_SIZE")%></td></tr>
				<tr><td><b>Batch Size Indicator</b></td><td><%=chanelStat.get(0).get("MQIACH_BATCH_SIZE_INDICATOR")%></td></tr>
				<tr><td><b>Buffers Received</b></td><td><%=chanelStat.get(0).get("MQIACH_BUFFERS_RCVD")%></td></tr>
				<tr><td><b>Buffers Sent</b></td><td><%=chanelStat.get(0).get(" MQIACH_BUFFERS_SENT")%></td></tr>
				<tr><td><b>Bytes sent</b></td><td><%=chanelStat.get(0).get("MQIACH_BYTES_SENT")%></td></tr>
				<tr><td><b>Channel disposition</b></td><td><%=chanelStat.get(0).get("MQIACH_CHANNEL_DISP")%></td></tr>
				<tr><td><b>Monitoring Channel</b></td><td><%=chanelStat.get(0).get("MQIA_MONITORING_CHANNEL")%></td></tr>
				<tr><td><b>Compression Rate</b></td><td><%=chanelStat.get(0).get("MQIACH_COMPRESSION_RATE")%></td></tr>
				<tr><td><b>Compression Time</b></td><td><%=chanelStat.get(0).get("MQIACH_COMPRESSION_TIME")%></td></tr>
				<tr><td><b>Channel Start Date</b></td><td><%=chanelStat.get(0).get("MQCACH_CHANNEL_START_DATE")%></td></tr>
				<tr><td><b>Channel Start Time</b></td><td><%=chanelStat.get(0).get("MQCACH_CHANNEL_START_TIME")%></td></tr>
				<tr><td><b>Channel Type</b></td><td><%=chanelStat.get(0).get("MQIACH_CHANNEL_TYPE")%></td></tr>
				<tr><td><b>Connection name </b></td><td><%=chanelStat.get(0).get("MQCACH_CONNECTION_NAME")%></td></tr>
				<tr><td><b>Logical unit of work identifier for in-doubt batch</b></td><td><%=chanelStat.get(0).get("MQCACH_CURRENT_LUWID")%></td></tr>
				<tr><td><b>Number of messages in-doubt </b></td><td><%=chanelStat.get(0).get("MQIACH_CURRENT_MSGS")%></td></tr>
				<tr><td><b>Sequence number of last message in in-doubt batch </b></td><td><%=chanelStat.get(0).get("MQIACH_CURRENT_SEQ_NUMBER")%></td></tr>
				<tr><td><b>Number of conversations currently active on this channel instance</b></td><td><%=chanelStat.get(0).get("MQIACH_CURRENT_SHARING_CONVS")%></td></tr>
				<tr><td><b>Indicator of the time taken executing user exits per message </b></td><td><%=chanelStat.get(0).get("MQIACH_EXIT_TIME_INDICATOR")%></td></tr>
				<tr><td><b>header data sent by the channel is compressed?</b></td><td><%=chanelStat.get(0).get("MQIACH_HDR_COMPRESSION")%></td></tr>
				<tr><td><b>Heartbeat interval</b></td><td><%=chanelStat.get(0).get("MQIACH_HB_INTERVAL")%></td></tr>
				<tr><td><b>KeepAlive interval</b></td><td><%=chanelStat.get(0).get("MQIACH_KEEP_ALIVE_INTERVAL")%></td></tr>
				<tr><td><b>Logical unit of work identifier for last committed batch</b></td><td><%=chanelStat.get(0).get("MQCACH_LAST_LUWID")%></td></tr>
				<tr><td><b>Last Message Date</b></td><td><%=chanelStat.get(0).get("MQCACH_LAST_MSG_DATE")%></td></tr>
				<tr><td><b>Last Message Time</b></td><td><%=chanelStat.get(0).get("MQCACH_LAST_MSG_TIME")%></td></tr>
				<tr><td><b>Sequence number of last message commited in batch</b></td><td><%=chanelStat.get(0).get("MQIACH_LAST_SEQ_NUMBER")%></td></tr>
				<tr><td><b>Local Comm address of channel</b></td><td><%=chanelStat.get(0).get("MQCACH_LOCAL_ADDRESS")%></td></tr>
				<tr><td><b>Number of long retries remaining</b></td><td><%=chanelStat.get(0).get("MQIACH_LONG_RETRIES_LEFT")%></td></tr>
				<tr><td><b>Max Message Length</b></td><td><%=chanelStat.get(0).get("MQIACH_MAX_MSG_LENGTH")%></td></tr>
				<tr><td><b>Max number of conversion permitted</b></td><td><%=chanelStat.get(0).get("MQIACH_MAX_SHARING_CONVS")%></td></tr>
				<tr><td><b>MCA Joba Name</b></td><td><%=chanelStat.get(0).get("MQCACH_MCA_JOB_NAME")%></td></tr>
				<tr><td><b>MCA Status</b></td><td><%=chanelStat.get(0).get("MQIACH_MCA_STATUS")%></td></tr>
				<tr><td><b>MCA User ID</b></td><td><%=chanelStat.get(0).get("MQCACH_MCA_USER_ID")%></td></tr>
				<tr><td><b>Message Compression</b></td><td><%=chanelStat.get(0).get("MQIACH_MSG_COMPRESSION")%></td></tr>
				<tr><td><b>Number of messages sent received</b></td><td><%=chanelStat.get(0).get("MQIACH_MSGS")%></td></tr>
				<tr><td><b>Numerb of messages available</b></td><td><%=chanelStat.get(0).get("MQIACH_XMITQ_MSGS_AVAILABLE")%></td></tr>
				<tr><td><b>Indicator of time of network operation</b></td><td><%=chanelStat.get(0).get("MQIACH_NETWORK_TIME_INDICATOR")%></td></tr>
				<tr><td><b>Speed of non-persistent mesage</b></td><td><%=chanelStat.get(0).get("MQIACH_NPM_SPEED")%></td></tr>
				<tr><td><b>Queue Manager Name</b></td><td><%=chanelStat.get(0).get("MQCA_Q_MGR_NAME")%></td></tr>
				<tr><td><b>remote partner application name</b></td><td><%=chanelStat.get(0).get("MQCACH_REMOTE_APPL_TAG")%></td></tr>
				<tr><td><b>remote partner product identifier</b></td><td><%=chanelStat.get(0).get("MQCACH_REMOTE_PRODUCT")%></td></tr>
				<tr><td><b>remote partner version</b></td><td><%=chanelStat.get(0).get("MQCACH_REMOTE_VERSION")%></td></tr>
				<tr><td><b>Name of the remote queue manager</b></td><td><%=chanelStat.get(0).get("MQCA_REMOTE_Q_MGR_NAME")%></td></tr>
				<tr><td><b>Distinguished Name of the issuer of the remote certificate</b></td><td><%=chanelStat.get(0).get("MQCACH_SSL_CERT_ISSUER_NAME")%></td></tr>
				<tr><td><b>local user ID associated with the remote certificate</b></td><td><%=chanelStat.get(0).get("MQCACH_SSL_CERT_USER_ID")%></td></tr>
				<tr><td><b>Date of the previous successful SSL secret key reset</b></td><td><%=chanelStat.get(0).get("MQCACH_SSL_KEY_RESET_DATE")%></td></tr>
				<tr><td><b>SSL secret key resets </b></td><td><%=chanelStat.get(0).get("MQIACH_SSL_KEY_RESETS")%></td></tr>
				<tr><td><b>Time of the previous successful SSL secret key reset</b></td><td><%=chanelStat.get(0).get("MQCACH_SSL_KEY_RESET_TIME")%></td></tr>
				<tr><td><b>Distinguished Name of the peer queue manager</b></td><td><%=chanelStat.get(0).get("MQCACH_SSL_SHORT_PEER_NAME")%></td></tr>
				<tr><td><b>Channel Stop requested?</b></td><td><%=chanelStat.get(0).get("MQIACH_STOP_REQUESTED")%></td></tr>
				<tr><td><b>Current action being performed by the channel</b></td><td><%=chanelStat.get(0).get("MQIACH_CHANNEL_SUBSTATE")%></td></tr>
				<tr><td><b>Transmit Queue Name</b></td><td><%=chanelStat.get(0).get("MQCACH_XMIT_Q_NAME")%></td></tr>
				<tr><td><b>Transmit Queue Time Indicator</b></td><td><%=chanelStat.get(0).get("MQIACH_XMITQ_TIME_INDICATOR")%></td></tr>
			
		</table>        

	<%}catch(Exception e){
		e.printStackTrace();
	%>
		<b>Encountered the following error  - </b><br>
		<%for (StackTraceElement element : e.getStackTrace()) {%>
			<%=element.toString()%><br>
			<%
		}
	}finally{
		rs.close();
		newUtil.closeConn(conn);
	}

}
	 %>
	</body>
</html>