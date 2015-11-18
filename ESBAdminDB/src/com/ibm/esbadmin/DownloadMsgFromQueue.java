/* Project: ESBAdmin */
/* */
/* Author: Godfrey Peter Menezes */
/* 
 Copyright © 2015 Godfrey P Menezes
 All rights reserved. This code or any portion thereof
 may not be reproduced or used in any manner whatsoever
 without the express written permission of Godfrey P Menezes(godfreym@gmail.com).

 */

package com.ibm.esbadmin;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ibm.mq.MQException;

/* Servlet implementation class DownloadMsg */
@WebServlet("/DownloadMsgFromQueue")
public class DownloadMsgFromQueue extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public DownloadMsgFromQueue() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		
		// TODO Auto-generated method stub
		// ServletContext ctx = getServletContext();
		String qMgr = request.getParameter("qMgr");
		String qName = request.getParameter("qName");
		String message = new String(request.getParameter("message"));
		
		
		Connection conn = null;
		ResultSet rs = null;
		Util newUtil = new Util();

		int qPort = 0;
		String qHost = null;
		String qChannel = null;

		String usrQmgrQuery = "SELECT QSM_QMGR_PORT, QSM_QMGR_HOST, QSM_QMGR_CHL, QSM_QMGR_NAME  FROM QMGR_MSTR "
				+ "WHERE QSM_ID = " + qMgr;
		
		String qMgrName = null;

		try{
			conn = newUtil.createConn();
			Statement stmt = conn.createStatement();
			rs = stmt.executeQuery(usrQmgrQuery);

			if (rs.next()) {
				qMgrName = rs.getString("QSM_QMGR_NAME");
				qPort = rs.getInt("QSM_QMGR_PORT");
				qHost = rs.getString("QSM_QMGR_HOST");
				qChannel = rs.getString("QSM_QMGR_CHL");
			}
			
		} catch (SQLException se) {
			se.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				rs.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			newUtil.closeConn(conn);
		}

		


		response.setContentType("text/plain");
		response.setHeader("Content-Disposition", "attachment;filename="
				+ qName + "-" + message);

		MQAdminUtil newMQAdmUtil = new MQAdminUtil();
		String data = new String();
		/*
		 * System.out.println(message);
		 * System.out.println(message.getBytes("US-ASCII").length);
		 * System.out.println(newUtil.byteArrayToHexString(message.getBytes()));
		 */
		try {
			data = newMQAdmUtil.displayMessage(qMgrName, qName, message);
		} catch (MQException e) {
			System.out.println("Error in download of data");
		}

		OutputStream outStream = response.getOutputStream();
		outStream.write(data.getBytes());
		outStream.flush();
		outStream.close();
		System.gc();
	}

}
