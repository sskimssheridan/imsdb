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

public class Item_Delete_Servlet extends HttpServlet {
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
    	
    	
		//creating session variable
		HttpSession session = request.getSession(false);
		/*creating database connection variables*/
		
		Map<String, String> messages = new HashMap<String, String>();
	    request.setAttribute("messages", messages);
	    
	    String btnClick = request.getParameter("act");
	    String itemID = request.getParameter("itemDeleteId");
	    String toSearchID = null;
	    
	    boolean loginError = false;
	    
	    if (itemID == null || itemID.trim().isEmpty())
	    {
	        messages.put("itemDeleteId", "Please enter Item ID to DELETE");
	        loginError = true;
	    }
	    else
	    {
	    	//checking if item is not an item
			try
    		{
				//extracting ITEM_ID from the string
				toSearchID = itemID.trim().substring(Math.max(0, itemID.trim().length() - 6));
				
	    		rs = st.executeQuery("SELECT ITEM_ID FROM ITEM WHERE ITEM_ID ='"+ toSearchID +"'");
	    		if (!rs.isBeforeFirst() ) 
	    		{    
	    			messages.put("itemDeleteId", "<strong>'"+itemID.trim()+"'</strong> is not an ITEM");
	    			loginError = true;
	    		} 
    		}
    		catch(Exception e)
    		{
    			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
    		}
	    }
	    if(loginError)
	    {
	    	request.getRequestDispatcher("jsp/task/item/ItemDelete/DeleteItem.jsp").forward(request, response);
	    }
	    else
	    {
	    	
		    if(btnClick.toUpperCase().equals("DELETE ITEM"))
		    {
		    	request.setAttribute("valid", "-1");
		    	
		    	try
		    	{
		    		conn.setAutoCommit(false);
		    		rs = st.executeQuery("SELECT CATEGORY_ID FROM ITEM WHERE ITEM_ID ='"+toSearchID+"'");
		    		String categoryID = null;
		    		//getting category
		    		if(rs.next())
		    		{
		    			categoryID = rs.getString("CATEGORY_ID");
		    		}
		    		//deleting machinery if category is machinery or going to else part to delete machinery part
		    		if(categoryID.trim().equals("M"))
		    		{
		    			st.executeUpdate("DELETE FROM MACHINERY WHERE MACHINERY_ITEM_ID = '"+toSearchID+"'");
		    		}
		    		else
		    		{
		    			st.executeUpdate("DELETE FROM MACHINERY WHERE MACHINERY_CONTAINING_ITEM_ID = '"+toSearchID+"'");
		    		}
		    		//deleting additional description 
		    		st.executeUpdate("DELETE FROM ITEM_ADDITIONAL_DESCRIPTION WHERE ITEM_ID = '"+toSearchID+"'");
		    		//deleting additional information
		    		st.executeUpdate("DELETE FROM ITEM_DETAIL WHERE ITEM_ID = '"+toSearchID+"'");
		    		//deleting from item
		    		st.executeUpdate("DELETE FROM ITEM WHERE ITEM_ID = '"+toSearchID+"'");
		    		
		    		conn.commit();
		    		request.getRequestDispatcher("jsp/task/item/ItemDelete/DeleteItem.jsp").forward(request, response);
		    	}
		    	catch(Exception e)
		    	{
		    		// TODO Auto-generated catch block
    	    		if(conn != null)
    	    		{
    	    			try {
							conn.rollback();
						} catch (SQLException e1) {
							// TODO Auto-generated catch block
							request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
						}
    	    			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
    	    		}
		    	}
		    	
		    	
		    }
		    else if(btnClick.toUpperCase().equals("DISPLAY ITEM"))
		    {
		    	//setting valid for showing in the item description in DELETE ITEM FORM
		    	session.setAttribute("itemDeleteId",itemID);
		    	request.setAttribute("valid", "1");
		    	request.getRequestDispatcher("jsp/task/item/ItemDelete/DeleteItem.jsp").forward(request, response);
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
