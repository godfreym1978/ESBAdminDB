package com.ibm.esbadmin;

/* Project: ESBAdmin */
/* Author: Godfrey Peter Menezes */
/* 
 Copyright � 2015 Godfrey P Menezes
 All rights reserved. This code or any portion thereof
 may not be reproduced or used in any manner whatsoever
 without the express written permission of Godfrey P Menezes(godfreym@gmail.com).

 */

import java.sql.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.xml.stream.XMLStreamException;

/**
 * Servlet implementation class DownloadMsg
 */
@WebServlet("/DeleteMQObject")
public class DeleteMQObject extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public DeleteMQObject() {
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
		// String qMgr = request.getParameter("qMgr");
		// String qName = request.getParameter("qName");

		PCFCommons newPCFCommons = new PCFCommons();

		HttpSession httpSession = request.getSession(true);

		int qPort = 0;
		String qHost = null;
		String qChannel = null;

		if (httpSession.getAttribute("UserID").toString().indexOf("admin") > -1) {
			Connection conn = null;
			ResultSet rs = null;
			Util newUtil = new Util();
			try {

				//int qMgrID = Integer.parseInt(request.getParameter("qMgr").toString());
				
				long qMgrID = Long.parseLong(request.getParameter("qMgr").toString());
				
				String usrQmgrQuery = "SELECT QSM_QMGR_PORT, QSM_QMGR_HOST, QSM_QMGR_CHL  FROM QMGR_MSTR "
						+ "WHERE QSM_ID = " + qMgrID;
				conn = newUtil.createConn();
				Statement stmt = conn.createStatement();
				rs = stmt.executeQuery(usrQmgrQuery);

				if (rs.next()) {
					qPort = rs.getInt("QSM_QMGR_PORT");
					qHost = rs.getString("QSM_QMGR_HOST");
					qChannel = rs.getString("QSM_QMGR_CHL");
				}

				if (!request.getParameter("qName").isEmpty()) {
					newPCFCommons.deleteQueue(qHost, qPort,
							request.getParameter("qName"), qChannel);
				}
				if (!request.getParameter("qChannel").isEmpty()) {
					newPCFCommons.deleteChannel(qHost, qPort,
							request.getParameter("qChannel"), qChannel);
				}
				if (!request.getParameter("qListener").isEmpty()) {
					newPCFCommons.deleteListener(qHost, qPort,
							request.getParameter("qListener"), qChannel);
				}
				if (!request.getParameter("qTopic").isEmpty()
						|| !request.getParameter("qTopicString").isEmpty()) {
					newPCFCommons.deleteTopic(qHost, qPort,
							request.getParameter("qTopic"),
							request.getParameter("qTopicString"), qChannel);
				}
				if (!request.getParameter("qSubscription").isEmpty()) {
					newPCFCommons.deleteSub(qHost, qPort,
							request.getParameter("qSubscription"), qChannel);
				}
			} catch (Exception e) {
				System.out.println("Error in deleting object");
			}
		}
		response.sendRedirect(request.getHeader("referer"));
	}

}
