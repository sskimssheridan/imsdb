package imsdb;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

public class Admin_ProgramAccountModify extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		HttpSession session = request.getSession(false);
		Context initContext;
		Context envContext;
		DataSource ds = null;
		Connection conn = null;
		PreparedStatement ps = null;
		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		boolean loginError = false;
		int i = 0;
		String programCode, name, years;

		try {
			initContext = new InitialContext();
			envContext = (Context) initContext.lookup("java:/comp/env");
			ds = (DataSource) envContext.lookup("jdbc/myoracle");
			conn = ds.getConnection();
		
		} catch (Exception e) {
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}

		name = request.getParameter("name");
		programCode = request.getParameter("programCode");
		years = request.getParameter("years");


		if (name.length() == 0) {
			messages.put("name", "Please enter Program Name");
			loginError = true;
		}
		if (years.length() == 0) {
			messages.put("years",
					"Please enter number of year(s) for Program");
			loginError = true;
		}

		if (loginError) {
			request.setAttribute("name", name);
			request.setAttribute("programCode", programCode);
			request.setAttribute("years", years);
			request.setAttribute("valid_employee_id", "1");
			session.setAttribute("returning_with_error", "YES");
			request.getRequestDispatcher("/jsp/task/Program/ModifyProgram.jsp")
					.forward(request, response);
		} else {
			try {
				conn.setAutoCommit(false);
				ps = conn
						.prepareStatement("UPDATE PROGRAM SET NUMBER_OF_YEAR ='"
								+ years
								+ "', PNAME ='"
								+ name
								+ "' WHERE PROGRAM_CODE = '"
								+ programCode
								+ "'");
				i = ps.executeUpdate();
				

			} catch (SQLException e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}

			try {
				conn.commit();
				if (i == 1) {
					request.setAttribute("Update_result", "1");
					request.removeAttribute("name");
					request.removeAttribute("programCode");
					request.removeAttribute("years");
					request.removeAttribute("valid_employee_id");
					session.removeAttribute("returning_with_error");
				} else {
					request.setAttribute("Update_result", "0");
				}
				request.getRequestDispatcher(
						"/jsp/task/Program/ModifyProgram.jsp").forward(request,
						response);
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
		// closing connection
		try {
			conn.close();
		} catch (SQLException e) {
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}
	}
}
