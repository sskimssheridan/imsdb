package imsdb;

import java.io.IOException;
import java.sql.Connection;
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

public class Admin_AccountChecking extends HttpServlet {

	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		Context initContext;
		Context envContext;
		DataSource ds = null;
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);
		
		boolean loginError = false;
		String StudentId = "", SupplierId, campusId, query = "", task, task2 = "";

		try {
			initContext = new InitialContext();
			envContext = (Context) initContext.lookup("java:/comp/env");
			ds = (DataSource) envContext.lookup("jdbc/myoracle");
			conn = ds.getConnection();
			st = conn.createStatement();
		} catch (Exception e) {
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}
		
		task = session.getAttribute("ACCOUNT").toString();
		if (null != session.getAttribute("TASK")) {
			task2 = session.getAttribute("TASK").toString();
		}

		

		if (task.equals("SUPPLIER")) {
			SupplierId = request.getParameter("supplierId").toUpperCase();

			if (SupplierId.length() == 0) {
				
				messages.put("SupplierId", "Please entre Supplier ID");
				loginError = true;
			} else {
				try {
					query = "SELECT SUPPLIER_ID FROM SUPPLIER WHERE SUPPLIER_ID = '"
							+ SupplierId + "'";

					rs = st.executeQuery(query);
					if (!rs.isBeforeFirst()) {
						messages.put("SupplierId",
								"<strong>'" + SupplierId.trim()
										+ "'</strong> is not Found!");
						loginError = true;
					}

				} catch (Exception e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			}

			if (loginError) {
				request.getRequestDispatcher(
						"/jsp/task/Supplier/SupplierAccountModify.jsp")
						.forward(request, response);
			} else {
				try {
					query = "SELECT SUPPLIER_ID FROM SUPPLIER WHERE SUPPLIER_ID = '"
							+ SupplierId + "'";
					rs = st.executeQuery(query);

					request.setAttribute("valid_employee_id", "0");
					while (rs.next()) {
						request.setAttribute("valid_employee_id", "1");
					}

					if (null != session.getAttribute("returning_with_error")) {
						session.removeAttribute("returning_with_error");
					}

					request.getRequestDispatcher(
							"/jsp/task/Supplier/SupplierAccountModify.jsp")
							.forward(request, response);
				} catch (SQLException e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			}

		}

		if (task.equals("STUDENT")) {
			StudentId = request.getParameter("StudentId").toUpperCase();
			
			if (StudentId == null || StudentId.trim().isEmpty()) {
				messages.put("StudentId", "Please Entre Student ID");
				loginError = true;
			} else {
				try {
					query = "SELECT STUDENT_ID FROM STUDENT WHERE STUDENT_ID = '"
							+ StudentId + "'";

					rs = st.executeQuery(query);
					if (!rs.isBeforeFirst()) {
						messages.put("StudentId","Please enter valid Student ID");
						loginError = true;
					}

				} catch (Exception e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			}

			if (loginError) {
				if (task2.equals("11")) {
					request.getRequestDispatcher(
							"/jsp/task/Student/SearchStudent.jsp").forward(
							request, response);
				} else {
					request.getRequestDispatcher(
							"/jsp/task/Student/ModifyStudent.jsp").forward(
							request, response);
				}

			} else {
				try {
					
					query = "SELECT STUDENT_ID FROM STUDENT WHERE STUDENT_ID = '"
							+ StudentId + "'";
					rs = st.executeQuery(query);

					request.setAttribute("valid_employee_id", "0");
					while (rs.next()) {
						request.setAttribute("valid_employee_id", "1");
						
					}

					if (null != session.getAttribute("returning_with_error")) {
						session.removeAttribute("returning_with_error");
					}

					if (task2.equals("11")) {

						request.getRequestDispatcher(
								"/jsp/task/Student/SearchStudent.jsp").forward(
								request, response);
					} else {
						request.getRequestDispatcher(
								"/jsp/task/Student/ModifyStudent.jsp").forward(
								request, response);
					}
				} catch (SQLException e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			}
		}

		if (task.equals("CAMPUS")) {
			campusId = request.getParameter("campusId").toUpperCase();
			
			if (campusId == null || campusId.trim().isEmpty()) {
				messages.put("campusId", "Please entre campus id");
				loginError = true;
			} else {
				try {
					query = "SELECT CAMPUS_ID FROM CAMPUS WHERE CAMPUS_ID = '"
							+ campusId + "'";

					rs = st.executeQuery(query);
					if (!rs.isBeforeFirst()) {
						messages.put("campusId", "<strong>'" + campusId.trim()
								+ "'</strong> is not Found!");
						loginError = true;
					}

				} catch (Exception e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			}

			if (loginError) {
				if (task2.equals("11")) {

					request.getRequestDispatcher(
							"/jsp/task/Campus/SearchCampus.jsp").forward(
							request, response);
				} else {
					request.getRequestDispatcher(
							"/jsp/task/Campus/ModifyCampus.jsp").forward(
							request, response);
				}
			} else {
				try {
					query = "SELECT CAMPUS_ID FROM CAMPUS WHERE CAMPUS_ID = '"
							+ campusId + "'";
					rs = st.executeQuery(query);

					request.setAttribute("valid_employee_id", "0");
					while (rs.next()) {
						request.setAttribute("valid_employee_id", "1");
						if (null != session
								.getAttribute("returning_with_error")) {
							session.removeAttribute("returning_with_error");
						}
					}
					if (task2.equals("11")) {

						request.getRequestDispatcher(
								"/jsp/task/Campus/SearchCampus.jsp").forward(
								request, response);
					} else {
						request.getRequestDispatcher(
								"/jsp/task/Campus/ModifyCampus.jsp").forward(
								request, response);
					}

				} catch (SQLException e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}

			}
		}

		if (task.equals("PROGRAM")) {
			String programCode = request.getParameter("programCode").toUpperCase();
			
			if (programCode == null || programCode.trim().isEmpty()) {
				messages.put("programCode", "Please entre Program Code");
				loginError = true;
			} else {
				try {
					query = "SELECT PROGRAM_CODE FROM PROGRAM WHERE PROGRAM_CODE = '"
							+ programCode + "'";

					rs = st.executeQuery(query);
					if (!rs.isBeforeFirst()) {
						messages.put("programCode","Please enter valid Program Code");
						loginError = true;
					}

				} catch (Exception e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			}

			if (loginError) {
				if (task2.equals("11")) {

					request.getRequestDispatcher(
							"/jsp/task/Program/SearchProgram.jsp").forward(
							request, response);
				} else {
					request.getRequestDispatcher(
							"/jsp/task/Program/ModifyProgram.jsp").forward(
							request, response);
				}
			} else {
		
				try {
					query = "SELECT PROGRAM_CODE FROM PROGRAM WHERE PROGRAM_CODE = '"
							+ programCode + "'";
					rs = st.executeQuery(query);

					request.setAttribute("valid_employee_id", "0");
					while (rs.next()) {
						request.setAttribute("valid_employee_id", "1");
						request.setAttribute("programCode", programCode);
					}

					if (null != session.getAttribute("returning_with_error")) {
						session.removeAttribute("returning_with_error");
					}

					if (task2.equals("11")) {

						request.getRequestDispatcher(
								"/jsp/task/Program/SearchProgram.jsp").forward(
								request, response);
					} else {
						request.getRequestDispatcher(
								"/jsp/task/Program/ModifyProgram.jsp").forward(
								request, response);
					}

				} catch (SQLException e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			}
		}

		if (task.equals("LAB")) {
			String labId = request.getParameter("labId");
			
			if (labId == null || labId.trim().isEmpty()) {
				messages.put("labId", "Please Entre Lab ID");
				loginError = true;
			} else {
				try {
					query = "SELECT LAB_ID FROM LAB WHERE LAB_ID = '" + labId
							+ "'";

					rs = st.executeQuery(query);
					if (!rs.isBeforeFirst()) {
						messages.put("labId", "<strong>'" + labId.trim()
								+ "'</strong> is not Found!");
						loginError = true;
					}

				} catch (Exception e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			}

			if (loginError) {
				if (task2.equals("11")) {

					request.getRequestDispatcher("/jsp/task/Lab/SearchLab.jsp")
							.forward(request, response);
				} else {
					request.getRequestDispatcher("/jsp/task/Lab/ModifyLab.jsp")
							.forward(request, response);
				}

			} else {
				try {
					query = "SELECT LAB_ID FROM LAB WHERE LAB_ID = '" + labId
							+ "'";
					rs = st.executeQuery(query);

					request.setAttribute("valid_employee_id", "0");
					while (rs.next()) {
						request.setAttribute("labId", labId);
						request.setAttribute("valid_employee_id", "1");
					}
					if (task2.equals("11")) {

						request.getRequestDispatcher(
								"/jsp/task/Lab/SearchLab.jsp").forward(request,
								response);
					} else {
						request.getRequestDispatcher(
								"/jsp/task/Lab/ModifyLab.jsp").forward(request,
								response);
					}

				} catch (SQLException e) {
					if (conn != null) {
						try {
							conn.rollback();
						} catch (SQLException e1) {
							request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
						}
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
				}
			}

		}

		// closing connection
		try {
			conn.close();
		} catch (SQLException e) {
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}

		if (null != session.getAttribute("returning_with_error")) {
			session.removeAttribute("returning_with_error");
		}
	}
}
