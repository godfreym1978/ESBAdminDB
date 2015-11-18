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

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.commons.io.FileUtils;

/**
 * Servlet implementation class DownloadMsg.
 */
@WebServlet("/MBAdmin")
public class MBAdmin extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public MBAdmin() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(final HttpServletRequest request,
			final HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		// ServletContext ctx = getServletContext();
		Connection conn = null;
		ResultSet rs = null;
		Statement stmt = null;
		Util newUtil = new Util();

		try {
			HttpSession session = request.getSession(true);
			MBCommons newMBComm = new MBCommons();
			String action = request.getParameter("action").toString();
			String userID = session.getAttribute("UserID").toString();
			String brkName = request.getParameter("brkName").toString();
			String brkHost = new String();
			int brkPort = 0;
			String env = new String();
			
			String usrIIBQuery = "SELECT IBMST_ENV, IBMST_IIB_HOST, IBMST_QMGR_PORT FROM USER_IIB_MSTR UIM, IIB_MSTR IM "+
									" WHERE UIM.UIBM_USER_ID = '"+userID+"' "+
									" AND IM.IBMST_IIB_NAME =  '"+brkName+"'"+
									" AND UIM.UIBM_IBMST_ID = IM.IBMST_ID";
 			
			conn = newUtil.createConn();
			stmt = conn.createStatement();
			rs = stmt.executeQuery(usrIIBQuery);

			if (rs.next()) {
				env = rs.getString("IBMST_ENV");
				brkHost = rs.getString("IBMST_IIB_HOST");
				brkPort = rs.getInt("IBMST_QMGR_PORT");
			}

			if (userID.indexOf("admin") > -1
					|| (env.equals("DEV") || env.equals("QA"))
					&& userID.indexOf("dev") > -1) {
				if (action.indexOf("EG") == 0) {
					//brkName = request.getParameter("brkName").toString();
					String egName = request.getParameter("egName").toString();
					if (action.indexOf("start") > 0) {
						System.out.println("Starting Execution Group - "
								+ egName + " /Broker - " + brkName);
						newMBComm.StartEG(brkName, egName, brkHost, brkPort);
					} else if (action.indexOf("stop") > 0) {
						System.out.println("Stopping Execution Group - "
								+ egName + " /Broker - " + brkName);
						newMBComm.StopEG(brkName, egName, brkHost, brkPort);
					} else {
						System.out.println("Deleting Execution Group - "
								+ egName + " /Broker - " + brkName);
						newMBComm.DeleteEG(brkName, egName, brkHost, brkPort);
					}
				} else if (action.indexOf("MF") == 0) {
					//brkName = request.getParameter("brkName").toString();
					String egName = request.getParameter("egName").toString();
					String mfName = request.getParameter("mfName").toString();
					if (action.indexOf("start") > 0) {
						System.out.println("Starting MF - " + mfName
								+ "/ Execution Group - " + egName
								+ " /Broker - " + brkName);
						newMBComm.StartMsgFlow(brkName, egName, mfName, brkHost, brkPort);
					} else if (action.indexOf("stop") > 0) {
						System.out.println("Stopping MF - " + mfName
								+ "/ Execution Group - " + egName
								+ " /Broker - " + brkName);
						newMBComm.StopMsgFlow(brkName, egName, mfName, brkHost, brkPort);
					} else {
						System.out.println("Deleting MF - " + mfName
								+ "/ Execution Group - " + egName
								+ " /Broker - " + brkName);
						newMBComm.DeleteEGObject(brkName, egName, mfName,
								brkHost, brkPort);
					}
				} else if (action.indexOf("APPL") == 0) {

					//brkName = request.getParameter("brkName").toString();
					String egName = request.getParameter("egName").toString();
					String applName = request.getParameter("applName")
							.toString();
					if (action.indexOf("start") > 0) {
						System.out.println("Starting Application - " + applName
								+ "/ Execution Group - " + egName
								+ " /Broker - " + brkName);
						newMBComm.StartApplication(brkName, egName, applName,
								brkHost, brkPort);
					} else if (action.indexOf("stop") > 0) {
						System.out.println("Stopping Application - " + applName
								+ "/ Execution Group - " + egName
								+ " /Broker - " + brkName);
						newMBComm.StopApplication(brkName, egName, applName,
								brkHost, brkPort);
					} else {
						System.out.println("Deleting Application - " + applName
								+ "/ Execution Group - " + egName
								+ " /Broker - " + brkName);
						newMBComm.DeleteEGObject(brkName, egName, applName,
								brkHost, brkPort);
					}
				} else if (action.indexOf("LIB") == 0) {

					//brkName = request.getParameter("brkName").toString();
					String egName = request.getParameter("egName").toString();
					String libName = request.getParameter("libName").toString();
					System.out.println("Deleting Library - " + libName
							+ "/ Execution Group - " + egName + " /Broker - "
							+ brkName);
					newMBComm.DeleteEGObject(brkName, egName, libName, brkHost, brkPort);
				}

			}

			response.sendRedirect(request.getHeader("referer"));

		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			try {
				rs.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			newUtil.closeConn(conn);
		}

	}

}
