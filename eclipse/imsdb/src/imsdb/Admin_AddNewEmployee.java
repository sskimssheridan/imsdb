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

public class Admin_AddNewEmployee extends HttpServlet 
{
	private static final long serialVersionUID = 1L;
	
	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
	private ResultSet rs = null;
	private ResultSet rsSub = null;

	protected void doPost(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException 
	{
		// connecting with the database
		try 
		{
			initContext = new InitialContext();
			envContext = (Context) initContext.lookup("java:/comp/env");
			ds = (DataSource) envContext.lookup("jdbc/myoracle");
			conn = ds.getConnection();
			st = conn.createStatement();
		} 
		catch (Exception e) 
		{
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}

		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		// getting parameter value from login form
		String EmployeeID = request.getParameter("EmployeeID");
		String EmployeeName = request.getParameter("EmployeeName");
		String EmployeeRole = request.getParameter("EmployeeRole");
		String Email = request.getParameter("Email");
		String Extension = request.getParameter("Extension");
		String Password = request.getParameter("Password");
		String toSearchID = null;
		// checking if the credentials are submitted with an error
		// creating boolean variable for login error check
		boolean loginError = false;
		if (EmployeeID == null || EmployeeID.trim().isEmpty()) 
		{
			messages.put("EmployeeID", "Please enter Employee ID");
			loginError = true;
		} 
		else if (EmployeeID.trim().length() < 9|| EmployeeID.trim().length() > 9) 
		{
			messages.put("EmployeeID", "Employee ID must be 9 digit long");
			loginError = true;
		} 
		else 
		{
			// checking if id is already a Employee
			try 
			{
				// extracting ITEM_ID from the string
				toSearchID = EmployeeID.trim().toUpperCase();

				rs = st.executeQuery("SELECT EMPLOYEE_ID FROM EMPLOYEE WHERE EMPLOYEE_ID ='" + toSearchID + "'");
				if (rs.isBeforeFirst())
				{
					messages.put("EmployeeID","<strong>" + EmployeeID.trim()+ "</strong> already Exists");
					loginError = true;
				}
			}
			catch (Exception e) 
			{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
			
			try 
			{
				// extracting ITEM_ID from the string
				toSearchID = EmployeeID.trim().toUpperCase();

				rsSub = st.executeQuery("SELECT STUDENT_ID FROM STUDENT WHERE STUDENT_ID ='"+ toSearchID + "'");
				if (rsSub.isBeforeFirst()) 
				{
					messages.put("EmployeeID","<strong>" + EmployeeID.trim()+ "</strong> as a <strong>Student</strong>");
					loginError = true;
				}
			} 
			catch (Exception e)
			{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}
		// checking EmployeeName
		if (EmployeeName == null || EmployeeName.trim().isEmpty())
		{
			messages.put("EmployeeName", "Please enter Name");
			loginError = true;
		}
		// checking Address
		if (EmployeeRole == null || EmployeeRole.trim().isEmpty()) 
		{
			messages.put("EmployeeRole", "Please enter Role");
			loginError = true;
		}
		// checking Extension
		if (Extension == null || Extension.trim().isEmpty())
		{
			messages.put("Extension", "Please enter Extension");
			loginError = true;
		}
		// checking Email
		if (Email == null || Email.trim().isEmpty()) 
		{
			messages.put("Email", "Please enter Email");
			loginError = true;
		}
		else 
		{
			try 
			{
				String emailreg = "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$";
				Boolean b = Email.matches(emailreg);

				if (b == false)
				{
					messages.put("Email", "Email Address is not Valid");
					loginError = true;
				} 
			} 
			catch (Exception e) 
			{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}
		// checking password
		if (Password == null || Password.trim().isEmpty()) 
		{
			messages.put("Password", "Please enter Password");
			loginError = true;
		} 
		else if (Password.length() > 15)
		{
			messages.put("Password", "Password must be below 15 characters");
			loginError = true;
		}

		if (loginError)
		{
			request.getRequestDispatcher("/jsp/task/Employee/AddEmployee.jsp").forward(request, response);
		} 
		else
		{
			try 
			{
				rs = st.executeQuery("SELECT * FROM EMPLOYEE WHERE EMPLOYEE_ID = '"+EmployeeID.trim().toUpperCase()+"' ");
				if(rs.isBeforeFirst())
				{
					request.setAttribute("RESULT", "2");
					request.getRequestDispatcher(
							"/jsp/task/Employee/AddEmployee.jsp").forward(request,
							response);
				}
				else
				{
					conn.setAutoCommit(false);
					String query = "INSERT INTO EMPLOYEE (EMPLOYEE_ID, ENAME, EROLE, EMAIL, EXT, PASSWORD) "
						+ "VALUES ('"
						+ EmployeeID.trim().toUpperCase()
						+ "', '"
						+ EmployeeName.trim().toUpperCase()
						+ "', '"
						+ EmployeeRole.trim().toUpperCase()
						+ "', '"
						+ Email.trim().toUpperCase()
						+ "', '"
						+ Extension.trim().toUpperCase()
						+ "', '"
						+ Password.trim().toUpperCase() + "')";
				PreparedStatement prstm = null;
				prstm = conn.prepareStatement(query);
				prstm.executeUpdate();
				conn.commit();
				request.setAttribute("RESULT", "1");
				request.getRequestDispatcher(
						"/jsp/task/Employee/AddEmployee.jsp").forward(request,
						response);
				}
			
			} 
			catch (Exception e)
			{ 
				// TODO Auto-generated catch block
				if (conn != null) 
				{
					try
					{
						conn.rollback();
					} 
					catch (SQLException e1) 
					{
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
				}
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}
	}
}
