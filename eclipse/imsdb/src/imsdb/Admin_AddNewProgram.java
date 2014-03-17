package imsdb;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

public class Admin_AddNewProgram extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
	private ResultSet rs = null;

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub

		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		// getting parameter value from login form
		String ProgramCode = request.getParameter("ProgramCode");
		String ProgramName = request.getParameter("ProgramName");

		String Years = request.getParameter("NumberOfYears");

		// checking if the credentials are submitted with an error
		// creating boolean variable for login error check
		boolean loginError = false;

		// checking ProgramCode
		if (ProgramCode == null || ProgramCode.trim().isEmpty()) {
			messages.put("ProgramCode", "Please enter Program Code");
			loginError = true;
		}
		// checking Program Name
		if (ProgramName == null || ProgramName.trim().isEmpty()) {
			messages.put("ProgramName", "Please enter Program Name");
			loginError = true;
		}
		// checking Number Of Years
		if (Years.length() == 0 || Years == null) {
			messages.put("NumberOfYears", "Please enter Number Of Years");
			loginError = true;
		}

		if (loginError) {
			request.getRequestDispatcher("/jsp/task/Program/AddProgram.jsp")
					.forward(request, response);
		} else {
			// connecting with the database
			try {
				initContext = new InitialContext();
				envContext = (Context) initContext.lookup("java:/comp/env");
				ds = (DataSource) envContext.lookup("jdbc/myoracle");
				conn = ds.getConnection();
				st = conn.createStatement();
			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}

			try {
				
				rs = st.executeQuery("SELECT * FROM PROGRAM WHERE PROGRAM_CODE = '"+ ProgramCode.trim().toUpperCase()+"'");
				
				if(!rs.isBeforeFirst())
				{
					int NumberOfYears = Integer.parseInt(Years);
					conn.setAutoCommit(false);
					String query = "INSERT INTO PROGRAM (PROGRAM_CODE, PNAME, NUMBER_OF_YEAR) "
							+ "VALUES ('"
							+ ProgramCode.trim().toUpperCase()
							+ "', '"
							+ ProgramName.trim().toUpperCase()
							+ "', "
							+ NumberOfYears + ")";
					PreparedStatement prstm = null;
					prstm = conn.prepareStatement(query);
					prstm.executeUpdate();
					
					conn.commit();
					request.setAttribute("RESULT", "1");
					request.getRequestDispatcher("/jsp/task/Program/AddProgram.jsp")
						.forward(request, response);
				}
				else
				{
					request.setAttribute("RESULT", "2");
					request.getRequestDispatcher("/jsp/task/Program/AddProgram.jsp")
					.forward(request, response);
				}
			} catch (Exception e) {
				// TODO Auto-generated catch block
				if (conn != null) {
					try {
						conn.rollback();
					} catch (SQLException e1) {
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
				}
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}
	}

}
