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

public class Admin_SupplierAccountModify extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException 
	{
		HttpSession session = request.getSession(false);
		Context initContext;
		Context envContext;
		DataSource ds = null;
		Connection conn = null;
		PreparedStatement ps = null;

		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		boolean loginError = false;

		String supplierId = "";
		String name, address, phone, email;
		int i = 0;

		try 
		{
			initContext = new InitialContext();
			envContext = (Context) initContext.lookup("java:/comp/env");
			ds = (DataSource) envContext.lookup("jdbc/myoracle");
			conn = ds.getConnection();
		} 
		catch (Exception e) 
		{
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}

		supplierId = request.getParameter("supplierId");
		name = request.getParameter("name");
		address = request.getParameter("address");
		phone = request.getParameter("phone");
		email = request.getParameter("email");

		if (email.length() == 0) 
		{
			messages.put("email", "Please enter Supplier Email Address");
			loginError = true;
		}
		else 
		{
			try 
			{
				String emailreg = "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$";
				Boolean b = email.matches(emailreg);

				if (b == false) 
				{
					messages.put("email", "Please enter valid Email Address");
					loginError = true;
				}
			} 
			catch (Exception e) 
			{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}

		if (phone.length() == 0) 
		{
			messages.put("phone", "Please enter Supplier Phone Number");
			loginError = true;
		} 
		else if(phone.length()<10)
		{
			messages.put("phone", "Phone Number must be 10 digits long");
			loginError = true;
		}

		if (name.length() == 0) 
		{
			messages.put("name", "Please enter Supplier Name");
			loginError = true;
		}

		if (address.length() == 0)
		{
			messages.put("address", "Please enter Supplier Address");
			loginError = true;
		}

		if (loginError) 
		{
			request.setAttribute("supplierId", supplierId);
			request.setAttribute("name", name);
			request.setAttribute("address", address);
			request.setAttribute("email", email);
			request.setAttribute("phone", phone);
			request.setAttribute("valid_employee_id", "1");
			session.setAttribute("returning_with_error", "YES");
			request.getRequestDispatcher("/jsp/task/Supplier/SupplierAccountModify.jsp").forward(request, response);
		} 
		else 
		{
			try 
			{
				conn.setAutoCommit(false);
				ps = conn.prepareStatement("UPDATE SUPPLIER SET " + "SNAME ='"
						+ name.trim().toUpperCase() + "', " + "EMAIL = '"
						+ email.trim().toUpperCase() + "'," + " PHONE = '"
						+ phone.trim().toUpperCase() + "'," + " ADDRESS = '"
						+ address.trim().toUpperCase() + "'"
						+ " WHERE supplier_id = '" + supplierId + "'");

				i = ps.executeUpdate();
				conn.commit();
				if (i == 1) 
				{
					request.setAttribute("Update_result", "1");
					request.removeAttribute("supplierId");
					request.removeAttribute("name");
					request.removeAttribute("address");
					request.removeAttribute("email");
					request.removeAttribute("phone");
					request.removeAttribute("valid_employee_id");
					session.removeAttribute("returning_with_error");
				} 
				else
				{
					request.setAttribute("Update_result", "0");
				}
				request.getRequestDispatcher("/jsp/task/Supplier/SupplierAccountModify.jsp").forward(request, response);
			} 
			catch (Exception e) 
			{	
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
