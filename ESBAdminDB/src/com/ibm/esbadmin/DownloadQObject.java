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

package com.ibm.esbadmin;

import java.io.IOException;
import java.io.OutputStream;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.sql.*;

/**
 * Servlet implementation class DownloadMsg
 */
@WebServlet("/DownloadQObject")
public class DownloadQObject extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public DownloadQObject() {
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
		HttpSession session = request.getSession(true);

		if (session.getAttribute("UserID") != null) {
			Connection conn = null;
			ResultSet rs = null;
			Util newUtil = new Util();

			try {

				response.setContentType("text/plain");
				response.setHeader("Content-Disposition",
						"attachment;filename="
								+ request.getParameter("objName").toString()
								+ ".mqsc");

				OutputStream outStream = response.getOutputStream();
				byte[] qMgrBytes;
				//int qMgrID = Integer.parseInt(request.getParameter("qMgr").toString());
				long qMgrID = Long.parseLong(request.getParameter("qMgr").toString());

				int qPort = 0;
				String qHost = null;
				String qChannel = null;

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

				String objType = request.getParameter("objType").toString();
				String objName = request.getParameter("objName").toString();

				PCFCommons pcfCM = new PCFCommons();

				if (objType.equals("QUEUE")) {
					qMgrBytes = String
							.valueOf(
									pcfCM.createQScript(qHost, qPort, objName,
											qChannel)).getBytes();
					outStream.write(qMgrBytes);
				}

				if (objType.equals("CHANNEL")) {
					qMgrBytes = String.valueOf(
							pcfCM.createChlScript(qHost, qPort, objName,
									qChannel)).getBytes();
					outStream.write(qMgrBytes);
				}

				if (objType.equals("LISTENER")) {
					qMgrBytes = String.valueOf(
							pcfCM.createListScript(qHost, qPort, objName,
									qChannel)).getBytes();
					outStream.write(qMgrBytes);
				}

				if (objType.equals("TOPIC")) {
					qMgrBytes = String.valueOf(
							pcfCM.createTopicScript(qHost, qPort, objName,
									qChannel)).getBytes();
					outStream.write(qMgrBytes);
				}

				if (objType.equals("SUB")) {
					qMgrBytes = String.valueOf(
							pcfCM.createSubScript(qHost, qPort, objName,
									qChannel)).getBytes();
					outStream.write(qMgrBytes);
				}

				outStream.flush();
				outStream.close();
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

		} else {
			System.out.println("Not logged in");
		}
	}
}
