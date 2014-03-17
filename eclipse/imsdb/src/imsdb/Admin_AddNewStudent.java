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

public class Admin_AddNewStudent extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
	private ResultSet rs = null;
	private ResultSet rsSub = null;

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

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
		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		// getting parameter value from login form
		String StudentID = request.getParameter("StudentID");
		String ProgramCode = request.getParameter("ProgramCode");
		String CampusID = request.getParameter("CampusID");
		String StudentName = request.getParameter("StudentName");
		String Status = request.getParameter("Status");
		String Password = request.getParameter("Password");
		String Phone = request.getParameter("Phone");
		String Email = request.getParameter("Email");
		String toSearchID = null;

		// checking if the credentials are submitted with an error
		// creating boolean variable for login error check
		boolean loginError = false;
		// checking studentID
		if (StudentID == null || StudentID.trim().isEmpty()) {
			messages.put("StudentID", "Please enter Student ID");
			loginError = true;
		} else if (StudentID.trim().length() < 9
				|| StudentID.trim().length() > 9) {
			messages.put("StudentID", "Student ID must be 9 digits");
			loginError = true;
		} else {
			// checking if supplier is already a supplier
			try {
				// extracting ITEM_ID from the string
				toSearchID = StudentID.trim().toUpperCase();

				rs = st.executeQuery("SELECT STUDENT_ID FROM STUDENT WHERE STUDENT_ID ='"
						+ toSearchID + "'");
				if (rs.next()) {
					String name = rs.getString("STUDENT_ID");
					if (name.equals("")) {
					
					} else {
						messages.put("StudentID","<strong>" + StudentID.trim()+ "</strong> already Exists");
						loginError = true;
					}

				}

			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}

			try {
				// extracting ITEM_ID from the string
				toSearchID = StudentID.trim().toUpperCase();

				rsSub = st
						.executeQuery("SELECT EMPLOYEE_ID FROM EMPLOYEE WHERE EMPLOYEE_ID ='"
								+ toSearchID + "'");
				if (rsSub.next()) {
					String empname = rsSub.getString("EMPLOYEE_ID");
					if (empname.equals("")) {
		
					} else {
						messages.put("StudentID",
								"<strong>" + StudentID.trim()
										+ "</strong> is an <strong>Employee</strong>");
						loginError = true;
					}

				}

			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}
		// checking ProgramCode
		if (ProgramCode == null || ProgramCode.trim().isEmpty()) {
			messages.put("ProgramCode", "Please enter Program Code");
			loginError = true;
		}

		// checking CampusID
		if (CampusID == null || CampusID.trim().isEmpty()) {
			messages.put("CampusID", "Please select Campus");
			loginError = true;
		}
		// checking StudentName
		if (StudentName == null || StudentName.trim().isEmpty()) {
			messages.put("StudentName", "Please enter Student Name");
			loginError = true;
		}
		// checking Status
		if (Status == null || Status.trim().isEmpty()) {
			messages.put("Status", "Please enter Status");
			loginError = true;
		}
		// checking Phone
		if (Phone == null || Phone.trim().isEmpty()) {
			messages.put("Phone", "Please enter Phone Number");
			loginError = true;
		}
		else if(Phone.length() < 10)
		{
			messages.put("Phone", "Phone number must be 10 digits");
			loginError = true;
		}
		// checking Email
		if (Email == null || Email.trim().isEmpty()) {
			messages.put("Email", "Please enter Email Address");
			loginError = true;
		} else {
			try {
				String emailreg = "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$";
				Boolean b = Email.matches(emailreg);

				if (b == false) {
					messages.put("Email", "Please enter valid Email Address");
					loginError = true;
				} 
			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}
		// checking password
		if (Password == null || Password.trim().isEmpty()) {
			messages.put("Password", "Please enter Password");
			loginError = true;
		} else if (Password.length() > 15) {
			messages.put("Password", "Password must be below 15 characters");
			loginError = true;
		}

		if (loginError) {
			request.getRequestDispatcher("/jsp/task/Student/AddStudent.jsp")
					.forward(request, response);
		} else {
			try {

				conn.setAutoCommit(false);
				String query = "INSERT INTO STUDENT (STUDENT_ID, PROGRAM_CODE, CAMPUS_ID, SNAME, STATUS, PASSWORD, PHONE, EMAIL) "
						+ "VALUES ('"
						+ StudentID.trim().toUpperCase()
						+ "', '"
						+ ProgramCode.trim().toUpperCase()
						+ "', '"
						+ CampusID.trim().toUpperCase()
						+ "', '"
						+ StudentName.trim().toUpperCase()
						+ "', '"
						+ Status.trim().toUpperCase()
						+ "', '"
						+ Password.trim().toUpperCase()
						+ "', '"
						+ Phone.trim().toUpperCase()
						+ "', '"
						+ Email.trim().toUpperCase() + "')";
				PreparedStatement prstm = null;
				prstm = conn.prepareStatement(query);
				prstm.executeUpdate();
			

			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
			// removing session variables
			try {
				conn.commit();
				request.setAttribute("RESULT", "1");
				request.getRequestDispatcher("/jsp/task/Student/AddStudent.jsp")
						.forward(request, response);
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
