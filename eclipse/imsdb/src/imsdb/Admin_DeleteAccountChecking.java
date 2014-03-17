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

public class Admin_DeleteAccountChecking extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
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
		
		String SupplierId, query;
		
		try
		{
			initContext = new InitialContext();
			envContext  = (Context)initContext.lookup("java:/comp/env");
			ds = (DataSource)envContext.lookup("jdbc/myoracle");
			conn = ds.getConnection();
			st = conn.createStatement();
		}
		catch(Exception e)
		{
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}
		
		SupplierId = request.getParameter("supplierId");
		
		System.out.println(SupplierId+ "1");
		if (SupplierId.length() == 0)
	    {
			System.out.println(SupplierId + "0");
	        messages.put("SupplierId", "Please entre Supplier Id");
	        loginError = true;
	    }
		else{
			try{
				query = "SELECT SUPPLIER_ID FROM SUPPLIER WHERE SUPPLIER_ID = '"+ SupplierId + "'";
				
				rs = st.executeQuery(query);
				if (!rs.isBeforeFirst() ) 
	    		{    
	    			messages.put("SupplierId", "<strong>'"+SupplierId.trim()+"'</strong> is not Found!");
	    			loginError = true;
	    		} 
				
			}catch(Exception e)
    		{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
    		}
		}
		
		
		if(loginError)
	    {
			request.getRequestDispatcher("/jsp/task/Supplier/DeleteSupplier.jsp").forward(request, response);
	    }
		else{
			try{
				query = "SELECT SUPPLIER_ID FROM SUPPLIER WHERE SUPPLIER_ID = '"+ SupplierId + "'";
				rs = st.executeQuery(query);
				
				request.setAttribute("valid_employee_id", "0");
				while (rs.next()) {
					request.setAttribute("valid_employee_id", "1");
					session.setAttribute("supplierId", SupplierId);
				}
				
				request.getRequestDispatcher("/jsp/task/Supplier/DeleteSupplier.jsp").forward(request, response);		
			} catch (SQLException e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}
		 //closing connection
	    try {
			conn.close();
		} catch (SQLException e) {
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}
	}

}
