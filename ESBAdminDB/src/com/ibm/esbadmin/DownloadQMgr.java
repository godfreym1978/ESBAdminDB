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
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class DownloadMsg
 */
@WebServlet("/DownloadQMgr")
public class DownloadQMgr extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public DownloadQMgr() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		HttpSession httpSession = request.getSession(true);
		if (httpSession.getAttribute("UserID") != null) {
			// TODO Auto-generated method stub
			response.setContentType("text/plain");
			response.setHeader("Content-Disposition", "attachment;filename="
					+ request.getParameter("qMgr") + ".mqsc");

			OutputStream outStream = response.getOutputStream();
			byte[] qMgrBytes;

			String UserID = httpSession.getAttribute("UserID").toString();
			String qMgr = request.getParameter("qMgr");
			int qPort = 0;
			String qHost = null;
			String qChannel = null;

			/*
			MQAdminUtil newMQAdUtil = new MQAdminUtil();
			List<Map<String, String>> MQList = new ArrayList<Map<String, String>>();
			*/
			Connection conn = null;
			ResultSet rs = null;
			Util newUtil = new Util();

			try {

				int qMgrID = Integer.parseInt(request.getParameter("qMgr")
						.toString());

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

				PCFCommons pcfCM = new PCFCommons();

				List<Map<String, Object>> ListQueueNames = pcfCM
						.ListQueueNamesDtl(qHost, qPort, qChannel);
				for (int i = 0; i < ListQueueNames.size(); i++) {
					qMgrBytes = String.valueOf(
							pcfCM.createQScript(qHost, qPort, ListQueueNames
									.get(i).get("MQCA_Q_NAME").toString()
									.trim(), qChannel)).getBytes();
					outStream.write(qMgrBytes);
				}

				List<Map<String, Object>> listChannels = pcfCM.channelDetails(
						qHost, qPort, qChannel);

				for (int i = 0; i < listChannels.size(); i++) {
					qMgrBytes = String.valueOf(
							pcfCM.createChlScript(qHost, qPort, listChannels
									.get(i).get("MQCACH_CHANNEL_NAME")
									.toString().trim(), qChannel)).getBytes();
					outStream.write(qMgrBytes);
				}

				List<Map<String, Object>> listListener = pcfCM.listenerDetails(
						qHost, qPort, qChannel);

				for (int i = 0; i < listListener.size(); i++) {
					qMgrBytes = String.valueOf(
							pcfCM.createListScript(qHost, qPort, listListener
									.get(i).get("MQCACH_LISTENER_NAME")
									.toString().trim(), qChannel)).getBytes();
					outStream.write(qMgrBytes);
				}
				List<Map<String, Object>> listTopic = pcfCM.ListTopicNames(
						qHost, qPort, qChannel);

				for (int i = 0; i < listTopic.size(); i++) {
					qMgrBytes = String.valueOf(
							pcfCM.createTopicScript(qHost, qPort, listTopic
									.get(i).get("MQCA_TOPIC_NAME").toString()
									.trim(), qChannel)).getBytes();
					outStream.write(qMgrBytes);
				}
				List<Map<String, Object>> listSubs = pcfCM.ListSubNames(qHost,
						qPort, qChannel);

				for (int i = 0; i < listSubs.size(); i++) {
					qMgrBytes = String.valueOf(
							pcfCM.createSubScript(qHost, qPort, listSubs.get(i)
									.get("MQCACF_SUB_NAME").toString().trim(),
									qChannel)).getBytes();
					outStream.write(qMgrBytes);
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
			outStream.flush();
			outStream.close();

		} else {
			System.out.println("not logged in");
		}

		System.gc();
	}

}
