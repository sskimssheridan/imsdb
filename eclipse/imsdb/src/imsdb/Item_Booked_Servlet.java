package imsdb;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

public class Item_Booked_Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	//variables for database connection
	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
		
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		//connecting to the database
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
    	
    	//creating session variable
    	HttpSession session = request.getSession(false);
    			
    	String itemID = request.getParameter("act");
		String userID = session.getAttribute("username").toString().trim().toUpperCase();
		
		try
		{
			conn.setAutoCommit(false);
			st.executeUpdate("DELETE FROM ITEM_HOLD WHERE USER_ID = '"+userID+"' AND ITEM_ID = '"+itemID+"'");
			conn.commit();
			request.getRequestDispatcher("jsp/task/item/ItemBooked/BookedItem.jsp").forward(request, response);
		}
		catch(SQLException ex)
		{
			if(conn != null)
    		{
    			try {
					conn.rollback();
				} catch (SQLException e1) {
					// TODO Auto-generated catch block
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
    		}
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}
		//closing connection
	    try {
			conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}
	}

}
