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
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*,java.io.*"%>  
<%@ page import="org.apache.commons.fileupload.*,org.apache.commons.io.*" %>
<%@ page import="com.ibm.broker.config.proxy.*"%>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style type="text/css">
<%@ include file="../Style.css" %>
</style>
<title>Deploy BAR file to EG</title>
</head>

<body>
		<center>
			<%
if(session.getAttribute("UserID")==null){
%>

		<center>
		Looks like you are not logged in.<br>
		
		Please login with a valid user id <a href='../Index.html'><b>Here</b> </a>
		</center>
<%}else{

	String UserID = session.getAttribute("UserID").toString();
	// Create a new file upload handler 
	DiskFileUpload upload = new DiskFileUpload();

	// parse request
	List items = upload.parseRequest(request);

	Util newUtil = new Util();
	MBCommons newMBCmn = new MBCommons();
	Connection conn = null;
	ResultSet rs = null;
	Statement stmt = null;

	try{
		
		String hostName = new String();
		String env = null;
		String egName = request.getParameter("egName");
		String brokerName = request.getParameter("brokerName");
		int portNum=0;
		BrokerProxy brkProxy  = null;
	
		
		String usrIIBQuery = "SELECT IBMST_ENV, IBMST_IIB_HOST, IBMST_QMGR_PORT FROM USER_IIB_MSTR UIM, IIB_MSTR IM "+
				" WHERE UIM.UIBM_USER_ID = '"+UserID+"' "+
				" AND IM.IBMST_IIB_NAME =  '"+brokerName+"'"+
				" AND UIM.UIBM_IBMST_ID = IM.IBMST_ID";
	
		conn = newUtil.createConn();
		stmt = conn.createStatement();
		rs = stmt.executeQuery(usrIIBQuery);
	
		if (rs.next()) {
			//env = rs.getString("IBMST_ENV");
			hostName = rs.getString("IBMST_IIB_HOST");
			portNum = rs.getInt("IBMST_QMGR_PORT");
		}
	
		brkProxy = newMBCmn.getBrokerProxy(hostName, portNum);
	
		//get uploaded file 
		FileItem file = (FileItem) items.get(0);
		String source = file.getName();
	
		File outfile = new File(System.getProperty("catalina.base")+"\\"+source);
		//File outfile = new File(application.getContextPath()+"\\"+source);
		file.write(outfile);
	
		String returnMsg = 
							newMBCmn.deployBARFileToEG(brkProxy, egName, outfile.getAbsolutePath());
		if(returnMsg.equals("success")){
			%>
			<Center>The BAR file <b><%=source%></b> has been successfully deplolyed to Execution Group <b><%=egName%></b> on Broker <b><%=brokerName%>.</b></Center>					
			<%	
		}else{
			%>
						
			<%	
		}
		
		brkProxy.disconnect();
	
	}catch(Exception e){
		e.printStackTrace();
		%>
		<center> <b>Experienced the following error  - </b></center><br>
		<%
	}finally{
		rs.close();
		newUtil.closeConn(conn);
	}

}
			%>
</body>
</html>