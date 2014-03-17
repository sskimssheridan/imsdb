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

public class Admin_EmployeeAccountModify extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		Context initContext;
		Context envContext;
		DataSource ds = null;
		Connection conn = null;
		PreparedStatement ps = null;
		

		int i = 0;
		String userId = "", employeeName = "", employeeRole = "", employeeEmail = "", employeeExt = "";
		boolean loginError = false;

		HttpSession session = request.getSession(false);

		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		userId = request.getParameter("userId");
		employeeName = request.getParameter("employeeName");
		employeeRole = request.getParameter("employeeRole");
		employeeExt = request.getParameter("employeeExt");
		employeeEmail = request.getParameter("employeeEmail");

		// checking if the employeeExt is greater then 30
		if (employeeEmail.length() >= 30) {
			messages.put("employeeEmail",
					"Please enter Email less then 30 characters");
			loginError = true;
		} else {
			try {
				String emailreg = "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$";
				Boolean b = employeeEmail.matches(emailreg);

				if (b == false) {
					messages.put("employeeEmail",
							"Please enter valid Email address");
					loginError = true;
				}
			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}

		// checking EmployeeName
		if (employeeName == null || employeeName.trim().isEmpty()) {
			//System.out.println("2");
			messages.put("employeeName", "Please enter Employee Name");
			loginError = true;
		}
		// checking Extension
		if (employeeExt == null || employeeExt.trim().isEmpty()) {
			messages.put("employeeExt", "Please enter Extension");
			loginError = true;
		}
		// checking if the employeeExt is greater then 5
		if (employeeExt.length() >= 30) {
			messages.put("employeeExt",
					"Please enter Extension less then 5 characters");
			loginError = true;
		}
		// checking Email
		if (employeeEmail == null || employeeEmail.trim().isEmpty()) {
			messages.put("employeeEmail", "Please enter Email");
			loginError = true;
		}

		try {
			initContext = new InitialContext();
			envContext = (Context) initContext.lookup("java:/comp/env");
			ds = (DataSource) envContext.lookup("jdbc/myoracle");
			conn = ds.getConnection();
			
		} catch (Exception e) {
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}

		if (loginError) {
			
			// HERE ALL THE UPDATED DATA IS SENDING BACK TO THE MAIN PAGE
			session.setAttribute("userId", userId);
			session.setAttribute("employeeName", employeeName);
			session.setAttribute("employeeRole", employeeRole);
			session.setAttribute("employeeEmail", employeeEmail);
			session.setAttribute("employeeExt", employeeExt);
			session.setAttribute("returning_with_error", "YES");
			request.setAttribute("valid_employee_id", "1");
			request.getRequestDispatcher(
					"/jsp/task/Employee/ModifyEmployee.jsp").forward(request,
					response);
		} else {

			try {
				conn.setAutoCommit(false);
				ps = conn
						.prepareStatement("UPDATE EMPLOYEE SET ENAME = ?, EROLE = ?, EMAIL = ?, EXT = ? WHERE EMPLOYEE_ID = ?");
				ps.setString(1, employeeName.trim().toUpperCase());
				ps.setString(2, employeeRole.trim().toUpperCase());
				ps.setString(3, employeeEmail.trim().toUpperCase());
				ps.setString(4, employeeExt.trim().toUpperCase());
				ps.setString(5, userId.trim().toUpperCase());

				i = ps.executeUpdate();

			} catch (SQLException e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}

			try {
				conn.commit();
				if (i == 1) {
					// IF THE EMPLOYEE IS UPDATED SUCCEDFULLY
					request.setAttribute("Update_result", "1");
					session.removeAttribute("userId");
					session.removeAttribute("employeeName");
					session.removeAttribute("employeeRole");
					session.removeAttribute("employeeEmail");
					session.removeAttribute("employeeExt");

				} else {
					request.setAttribute("Update_result", "0");
				}
				request.getRequestDispatcher(
						"/jsp/task/Employee/ModifyEmployee.jsp").forward(
						request, response);
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
