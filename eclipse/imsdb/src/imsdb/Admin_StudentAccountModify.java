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
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

public class Admin_StudentAccountModify extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		Context initContext;
		Context envContext;
		DataSource ds = null;
		Connection conn = null;
		Statement st = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		boolean loginError = false;
		int i = 0;
		String StudentId = "", name, programCode, campusId, status, phone, email, query;

		try {
			initContext = new InitialContext();
			envContext = (Context) initContext.lookup("java:/comp/env");
			ds = (DataSource) envContext.lookup("jdbc/myoracle");
			conn = ds.getConnection();
			st = conn.createStatement();
		} catch (Exception e) {
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}

		StudentId = request.getParameter("StudentId");
		name = request.getParameter("name");
		programCode = request.getParameter("programCode");
		campusId = request.getParameter("campusId");
		status = request.getParameter("status");
		phone = request.getParameter("phone");
		email = request.getParameter("email");

		if (programCode.length() != 0) {
			try {
				// fethching data from the table
				query = "SELECT * FROM PROGRAM WHERE PROGRAM_CODE = '"
						+ programCode + "'";
				rs = st.executeQuery(query);
				loginError = true;

				while (rs.next()) {
					loginError = false;
				}
				if (loginError == true) {
					messages.put("programCode", "Please Correct Program Code");
				}
			} catch (SQLException e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}

		if (phone.length() == 0) {
			messages.put("phone", "Please enter Phone Number");
			loginError = true;
		} else {
			try {
				String phonereg = "^\\s*(\\d{7,15})||(\\d{3,12}[\\-.]?\\s?\\d{3,12}[\\-.\\s]?)||([(]?\\d{3,9}[)\\-.]?\\s?\\d{3,9}[\\-.\\s]?\\d{3,9})\\s*";
				Boolean b = phone.matches(phonereg);
				
				if (b == false) {
					messages.put("phone", "Please enter valid Phone number");
					loginError = true;
				}
			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				
			}
		}

		if (email.length() == 0) {
			messages.put("email", "Please enter Email address");
			loginError = true;
		} else {
			try {
				String emailreg = "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$";
				Boolean b = email.matches(emailreg);

				if (b == false) {
					messages.put("email", "Please enter valid Email address");
					loginError = true;
				}
			} catch (Exception e) {

				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				
			}
		}

		if (name.length() == 0) {
			messages.put("name", "Please enter Name");
			loginError = true;
			
		}
		if (programCode.length() == 0) {
			messages.put("programCode", "Please enter Program Code");
			loginError = true;
		}


		if (loginError) {

			request.setAttribute("studentId", StudentId);
			request.setAttribute("name", name);
			request.setAttribute("email", email);
			request.setAttribute("phone", phone);
			request.setAttribute("status", status);
			request.setAttribute("programCode", programCode);
			request.setAttribute("campusId", campusId);
			request.setAttribute("valid_employee_id", "1");
			session.setAttribute("returning_with_error", "YES");

			request.getRequestDispatcher("/jsp/task/Student/ModifyStudent.jsp")
					.forward(request, response);
		} else {
			try {
				conn.setAutoCommit(false);
				ps = conn
						.prepareStatement("UPDATE STUDENT SET SNAME =?, PROGRAM_CODE =?, CAMPUS_ID =?, STATUS =?, PHONE= ?, EMAIL= ? WHERE STUDENT_ID = ?");
				ps.setString(1, name.trim().toUpperCase());
				ps.setString(2, programCode.trim().toUpperCase());
				ps.setString(3, campusId.trim().toUpperCase());
				ps.setString(4, status.trim().toUpperCase());
				ps.setString(5, phone.trim().toUpperCase());
				ps.setString(6, email.trim().toUpperCase());
				ps.setString(7, StudentId.trim().toUpperCase());
				i = ps.executeUpdate();

			} catch (SQLException e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}

			try {
				conn.commit();
				if (i == 1) {
					request.setAttribute("Update_result", "1");
					request.removeAttribute("studentId");
					request.removeAttribute("name");
					request.removeAttribute("email");
					request.removeAttribute("phone");
					request.removeAttribute("status");
					request.removeAttribute("programCode");
					request.removeAttribute("campusId");
					request.removeAttribute("valid_employee_id");
					session.removeAttribute("returning_with_error");
				} else {
					request.setAttribute("Update_result", "0");
				}
				request.getRequestDispatcher(
						"/jsp/task/Student/ModifyStudent.jsp").forward(request,
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
