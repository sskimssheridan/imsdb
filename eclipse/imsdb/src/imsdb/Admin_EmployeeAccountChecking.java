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

public class Admin_EmployeeAccountChecking extends HttpServlet 
{
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException
	{
		Context initContext;
		Context envContext;
		DataSource ds = null;
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
		String userId = "";
		String query = "";
		HttpSession session = request.getSession(false);

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

		userId = request.getParameter("userId");

		// HERE USER MEANS WHICH USER ACCOUNT IS GOING TO UPDATE E.G.
		// EMPLOYEE/STUDENT/ETC

		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		boolean loginError = false;

		if (userId == null || userId.trim().isEmpty())
		{
			messages.put("userId", "Please enter Employee ID");
			loginError = true;
		} 
		else 
		{
			try 
			{

				query = "SELECT EMPLOYEE_ID FROM EMPLOYEE WHERE EMPLOYEE_ID = '"+ userId + "'";

				rs = st.executeQuery(query);
				if (!rs.isBeforeFirst())
				{
					messages.put("userId", "Please enter valid Employee ID");
					loginError = true;
				}
			} 
			catch (Exception e) 
			{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}

		String task = "";
		if (null != session.getAttribute("TASK")) 
		{
			task = session.getAttribute("TASK").toString();
		}

		if (loginError) {
			if (task.equals("11")) 
			{
				request.getRequestDispatcher("/jsp/task/Employee/SearchEmployee.jsp").forward(request, response);
			} 
			else 
			{
				request.getRequestDispatcher(
						"/jsp/task/Employee/ModifyEmployee.jsp").forward(
						request, response);
			}

		} 
		else 
		{
			try
			{
				query = "SELECT EMPLOYEE_ID FROM EMPLOYEE WHERE EMPLOYEE_ID = '"+ userId + "'";

				rs = st.executeQuery(query);

				request.setAttribute("valid_employee_id", "0");
				while (rs.next()) 
				{
					request.setAttribute("valid_employee_id", "1");
				}

				if (null != session.getAttribute("returning_with_error")) 
				{
					session.removeAttribute("returning_with_error");
				}
				if (task.equals("11")) 
				{
					request.getRequestDispatcher("/jsp/task/Employee/SearchEmployee.jsp").forward(request, response);
				} 
				else 
				{
					request.getRequestDispatcher("/jsp/task/Employee/ModifyEmployee.jsp").forward(request, response);
				}
			} 
			catch (SQLException e) 
			{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
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
			}
		}
		// closing connection
		try 
		{
			conn.close();
		} 
		catch (SQLException e) 
		{
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}
	}

}
