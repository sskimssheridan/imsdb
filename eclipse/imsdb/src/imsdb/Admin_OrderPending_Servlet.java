package imsdb;

import java.io.IOException;
import java.sql.Connection;
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

public class Admin_OrderPending_Servlet extends HttpServlet {
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
    	
		//creating Map message
		Map<String, String> messages = new HashMap<String, String>();
	    request.setAttribute("messages", messages);
	    
	    //getting data from the form
	    String strQuantity = request.getParameter("quantity");
	    String supplierID = request.getParameter("supplierID");
	    int quantity = 0;
	    
	    boolean error = false;
	    
	    if(strQuantity.length() == 0 || strQuantity.isEmpty())
	    {
	    	messages.put("error", "Quantity cannot be empty while APPROVING/CANCELING");
	    	error = true;
	    }
	    else if(strQuantity.equals("0"))
	    {
	    	messages.put("error", "Quantity cannot be 0 (Zero) while APPROVING/CANCELING");
		    error = true;
	    }
	    else
	    {
	    	quantity = Integer.parseInt(strQuantity);
	    }
	    //checking for error
	    if(error)
	    {
	    	request.setAttribute("valid", "2");
	    	request.getRequestDispatcher("/jsp/task/order/OrderPending.jsp").forward(request, response);
	    }
	    else
	    {	
	    	//getting button value in the variable
	    	String btnClick = request.getParameter("act"); 
	    	
	    	String operation = btnClick.substring(0,3);
	    	String orderID = btnClick.trim().substring(Math.max(0, btnClick.trim().length() - 6));
	    	String status = "";
	    	String sql = "";
	    	
	    	try
	    	{		
	    		conn.setAutoCommit(false);
	    		
	    		//adjusting the update and status acoording to the button clicked
		    	if(operation.toUpperCase().equals("CAN"))
		    	{
		    		status = "CANCELED";
		    		sql = "UPDATE ITEM_ORDER SET ORDER_STATUS = '"+status+"' WHERE ITEM_ORDER_ID = '"+orderID+"'";
		    	}
		    	else if(operation.toUpperCase().equals("APP"))
		    	{
		    		status = "APPROVED";
		    		sql = "UPDATE ITEM_ORDER SET ORDER_STATUS = '"+status+"', "+
		    				" ORDER_ITEM_QUANTITY = "+quantity+", "+
		    				" SUPPLIER_ID = '"+supplierID +"' WHERE ITEM_ORDER_ID = '"+orderID+"'";
		    	}
		    	
	    		st.executeUpdate(sql);
	    		conn.commit();
	    		
	    		//initializing Map message and valid variable
	    		//sending control back to Pending Order JSP page (post back)
	    		messages.put("result", "Order ID: <strong>"+orderID+"</strong> was <strong>"+status+"</strong> successfully");
				request.setAttribute("valid", "1");
		    	request.getRequestDispatcher("/jsp/task/order/OrderPending.jsp").forward(request, response);
	    	}
	    	catch (Exception e)
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
    	//closing connection
	    try {
			conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}
	}

}
