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
import javax.sql.DataSource;

public class Item_Return_Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	//variables for database connection
	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
	private ResultSet rs = null;
		
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
    	
    	//deleting data from ITEM_HOLD Table older than 1 days
		try
		{
			conn.setAutoCommit(false);
			st.executeUpdate("DELETE FROM ITEM_HOLD WHERE DATE_OF_HOLD <= systimestamp - INTERVAL '1 00:00:00.0' DAY TO SECOND(1)");
			conn.commit();
		}
		catch(Exception e)
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
		
    	//creating  variable
		Map<String, String> messages = new HashMap<String, String>();
	    request.setAttribute("messages", messages);
			    
		String userID = request.getParameter("userID").toUpperCase().trim();
		String itemID = request.getParameter("itemID").toUpperCase().trim();
		String returnQuantity = request.getParameter("returnQuantity").toUpperCase().trim();
		String state = request.getParameter("state").toUpperCase().trim();
		
		int quantity = 0;
		
		boolean error = false;
		//checking for user id
		if(userID.isEmpty() || userID.length() == 0 || userID == null)
		{
			messages.put("userID", "USER ID cannot be blank");
	    	error = true;
		}
		else
		{
			try
			{
				rs = st.executeQuery("SELECT * FROM EMPLOYEE, STUDENT WHERE EMPLOYEE_ID = '"+userID+"' OR STUDENT_ID = '"+userID+"'");
	    		if(!rs.isBeforeFirst())
	    		{
	    			messages.put("userID", "USER ID is invalid");
	    	    	error = true;
	    		}
			}
			catch (SQLException e) {
				// TODO Auto-generated catch block
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				return;
			}
		}
		
		//checking for item id
		if(itemID.length() == 0 || itemID.isEmpty() || itemID == null)
		{
			messages.put("itemID", "ITEM ID cannot be blank");
	    	error = true;
		}
		else
		{
			//checking if item id provided is not an item
			try
    		{
				//extracting ITEM_ID from the string
				String toSearchID = itemID.trim().substring(Math.max(0, itemID.trim().length() - 6));
				
	    		rs = st.executeQuery("SELECT ITEM_ID FROM ITEM WHERE ITEM_ID ='"+ toSearchID +"'");
	    		if (!rs.isBeforeFirst() ) 
	    		{    
	    			messages.put("itemID", "ITEM ID is invalid");
	    	    	error = true;
	    		} 
    		}
    		catch(Exception e)
    		{
    			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
    			return;
    		}
		}
		//checking quantity
		if(returnQuantity.isEmpty())
		{
			messages.put("quantity", "QUANTITY RETURENED cannot be blank");
	    	error = true;
		}
		
		if(error)
		{
			request.getRequestDispatcher("/jsp/task/item/ItemReturn/ReturnItem.jsp").forward(request, response);
		}
		else
		{
			quantity = Integer.parseInt(returnQuantity);
			itemID = itemID.trim().substring(Math.max(0, itemID.trim().length() - 6));
			try
			{
				conn.setAutoCommit(false);
				
				rs = st.executeQuery("SELECT * FROM ITEM_BORROW WHERE ITEM_ID  = '"+itemID+"' AND USER_ID = '"+userID+"' AND DATE_OF_RETURN IS NULL");
				//checking for no records
				if(!rs.isBeforeFirst())
				{
					request.setAttribute("valid", "1");
	    			messages.put("error", "No Records Found in the database for the User and the Item<br/>"+
	    						"ITEM must be returned by the one who borrowed/rented the Item<br/>");
	    			request.getRequestDispatcher("jsp/task/item/ItemReturn/ReturnItem.jsp").forward(request, response);
	    			return;
				}
				else
				{
					//updating item borrow table
					st.executeUpdate("UPDATE ITEM_BORROW SET DATE_OF_RETURN = sysdate, ITEM_STATE = '"+state+"' WHERE ITEM_ID  = '"+itemID+"' AND USER_ID = '"+userID+"' AND DATE_OF_RETURN IS NULL");
					//updating quantity in item table
					st.executeUpdate("UPDATE ITEM SET QUANTITY = QUANTITY + "+quantity+" WHERE ITEM_ID = '"+itemID+"'");
				}
				conn.commit();
				
				request.setAttribute("valid", "2");
    			messages.put("returned", "Item returned successfully");
    			request.getRequestDispatcher("jsp/task/item/ItemReturn/ReturnItem.jsp").forward(request, response);		
			}
			catch(Exception e)
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
