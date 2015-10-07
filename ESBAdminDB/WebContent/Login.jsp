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
<%@ page import="java.io.IOException"%>
<%@ page import="org.apache.commons.csv.*"%>
<%@ page
	import="org.apache.commons.fileupload.*,org.apache.commons.io.*,java.io.*"%>
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
<%@ include file="Style.css" %>
</style>
<title>Login Page</title>
</head>
<body>
	<%
	Util newUtil = new Util();

	Connection conn = null;
	ResultSet rs = null;
		try {
			String UserID = new String();
			String queryString = new String();
			Map<String, Object> map = new HashMap<String, Object>();
			String[] qMgrDtl = new String[3];
			if (session.getAttribute("UserID") != null) {
				UserID = session.getAttribute("UserID").toString();
	%>
	<h4>
		Welcome
		<%=UserID %></h4>
	<HR>
	<h4>WebSphere MQ Environment</h4>
	<%if(UserID.equals("admin")){%>
		<a href='MQAdm/QMgrSetup.jsp' target='dynamic'>Setup/Change Queue
			Manager Environment</a>
		<br>
	<%}
	
	conn = newUtil.createConn();
	Statement stmt = conn.createStatement();
	rs = stmt.executeQuery("SELECT UQM.UQSM_ID, UQM.UQSM_QSM_ID, QMST.QSM_ID ,QMST.QSM_QMGR_NAME ,QMST.QSM_QMGR_HOST "+
										" ,QMST.QSM_QMGR_PORT ,QMST.QSM_QMGR_CHL "+
										" FROM USER_QMGR_MSTR UQM, QMGR_MSTR QMST "+
										" WHERE UQM.UQSM_USER_ID = '"+UserID+"'"+
										" AND UQM.UQSM_QSM_ID = QMST.QSM_ID "	);
	
	
	int userQsmID;
	while(rs.next()){
		userQsmID = rs.getInt("UQSM_QSM_ID");
	%>
	<a href="javascript:unhide('<%=rs.getString("QSM_QMGR_NAME")%>');"> <b>Queue Manager - <%=rs.getString("QSM_QMGR_NAME")%>
			/ Host - <%=rs.getString("QSM_QMGR_HOST")%>
	</b><br>
	</a>
	<div id="col2">
		<div id="<%=rs.getString("QSM_QMGR_NAME")%>" class="hidden">
			<a href='MQAdm/UserQMgrQList.jsp?qMgr=<%=userQsmID%>' target='dynamic'>
				Queues for Admin</a><br> <a
				href='MQAdm/QueueList.jsp?qMgr=<%=userQsmID%>' target='dynamic'> Qs
				in QMgr</a><br>
			<%if(UserID.equals("admin")){%>
			<a href='MQAdm/ChannelList.jsp?qMgr=<%=userQsmID%>' target='dynamic'>
				Channels in QMgr</a><br> <a
				href='MQAdm/ListenerList.jsp?qMgr=<%=userQsmID%>' target='dynamic'>
				Listeners in QMgr</a><br> <a
				href='MQAdm/CreateObject.jsp?qMgr=<%=userQsmID%>' target='dynamic'>
				Create Objects in QMgr</a><br>
			<%}%>
			<%if(UserID.equals("admin") || UserID.indexOf("dev")==0){ %>
			<a href='MQAdm/QMgrTopicList.jsp?qMgr=<%=userQsmID%>' target='dynamic'>
				Topics in QMgr </a><br> 
			<a href='MQAdm/QMgrSubList.jsp?qMgr=<%=userQsmID%>' target='dynamic'>
				Subscriptions in QMgr </a><br> 
			<a href='MQAdm/MQDataMove.jsp?qMgr=<%=userQsmID%>' target='dynamic'>
				Data Move </a><br> 
			<a href='DownloadQMgr?qMgr=<%=userQsmID%>'
				target='dynamic'> Download QMgr </a><br>
			<%} %>
		</div>
	</div>
	<HR>
	<%
			}
		}
	%>
	<h4>Message Broker Environment</h4>
	<%if(UserID.equals("admin")){%>
		<a href='MBAdm/MBEnvSetup.jsp' target='dynamic'>Setup Message
			Brokers Environment</a>
		<br>
	<%}%>
	<a href='MBAdm/MBEnvDtl.jsp' target='dynamic'>Message Brokers
		Environment</a>
	<br>
	<HR>
	<h4>Datapower Environment</h4>
	<%if(UserID.equals("admin")){%>
		<a href='DPAdm/DPEnvSetup.jsp' target='dynamic'>Setup Datapower
			Environment</a>
		<br>
	<%}%>

	<a href='DPAdm/DPEnvDtl.jsp' target='dynamic'>Datapower Environment</a>
	<br>
	<a href='DPAdm/DPDevices.jsp' target='dynamic'>Datapower Devices</a>
	<br>

	<%if(UserID.equals("admin")){%>
		<HR>
		<h4>User Management</h4>
		<a href='UsrAdm/CreateUser.jsp' target='dynamic'>Create Users for
			this Site</a>
		<br>
		<a href='UsrAdm/UserList.jsp' target='dynamic'>List of Users for
			this Site</a>
		<br>
	<%}%>
	<HR>
	<h4>User Access</h4>
	<a href='UsrAdm/ChangePwd.jsp' target='dynamic'>Change Password</a>
	<br>
	<a href='Logout.jsp' target='_top'>Logout from this site</a>
	<br>
	<%
			} catch(SQLException sqlEx){
				sqlEx.printStackTrace();
			} catch(FileNotFoundException ex){
				ex.printStackTrace();
			}finally{
				rs.close();
				newUtil.closeConn(conn);
			}
			%>
</body>
</html>