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

public class Faculty_OrderPlace_Servlet extends HttpServlet {
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
		
		Map<String, String> messages = new HashMap<String, String>();
	    request.setAttribute("messages", messages);
    	
	    String itemID = request.getParameter("orderItemId");
	    String btnClick = request.getParameter("act");
	   
	    boolean error = false;
	    
	    if (itemID == null || itemID.trim().isEmpty())
	    {
	        messages.put("orderItemId", "Please enter Item ID to ORDER");
	        error = true;
	    }
	    else
	    {
	    	//checking if item is not an item, it it is an item then asking user to fill remaining form
			try
    		{
				//extracting ITEM_ID from the string
				String toSearchID = itemID.trim().substring(Math.max(0, itemID.trim().length() - 6));
				
	    		rs = st.executeQuery("SELECT ITEM_ID,CATEGORY_ID FROM ITEM WHERE ITEM_ID ='"+ toSearchID +"'");
	    		if (!rs.isBeforeFirst()) 
	    		{    
	    			messages.put("orderItemId", "<strong>'"+itemID.trim()+"'</strong> is not an ITEM");
	    			error = true;
	    		}
    		}
    		catch(Exception e)
    		{
    			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
    		}
	    }
	    //post back for item id error
	    if(error)
	    {
	    	request.getRequestDispatcher("/jsp/task/faculty/FacultyOrderPlace.jsp").forward(request, response);
	    }
	    else
	    {
	    	//operations for if show supplier is clicked
	    	if(btnClick.toUpperCase().equals("SHOW SUPPLIERS"))
	    	{
	    		request.setAttribute("valid", "1");
	    		request.getRequestDispatcher("/jsp/task/faculty/FacultyOrderPlace.jsp").forward(request, response);
	    	}
	    	//operations for if place order is clicked
	    	else if (btnClick.toUpperCase().equals("PLACE ORDER"))
	    	{
				String supplierID = request.getParameter("supplierID");
				String orderPurpose = request.getParameter("purposeOfOrder").trim();
				String description = request.getParameter("descriptionOfOrder").trim();
				String strQuantity = request.getParameter("orderQuantity").trim();
				int quantity = 0;
				
			    error = false;
			    
			    //checking supplier
			    if (supplierID.trim().equals("-1"))
			    {
			        messages.put("supplierID", "Please select Supplier");
			        error = true;
			    }
			    //checking quantity
			    if(strQuantity.length() == 0 || strQuantity == null)
			    {
			    	messages.put("orderQuantity", "QUANTITY cannot be blank");
			    	error = true;
			    }
			    else if(strQuantity.trim().equals("0"))
			    {
			    	messages.put("orderQuantity", "QUANTITY cannot be 0 (zero)");
			    	error = true;
			    }
			    //post back for supplier or quantity error
			    if(error)
			    {
			    	request.setAttribute("valid", "1");
			    	request.getRequestDispatcher("/jsp/task/faculty/FacultyOrderPlace.jsp").forward(request, response);
			    }
			    //if no error in any field then inserting data with checking 
			    else
			    {
			    	//String role = session.getAttribute("role").toString();
			    	String employeeID = session.getAttribute("username").toString();
			    	String itemOrderID = "";
			    	String status = "PENDING";
			    	String itemInsertID = itemID.trim().substring(Math.max(0, itemID.trim().length() - 6));
			    	quantity = Integer.parseInt(strQuantity);
			    	
			    	//getting order ID from the database and incrementing it by 1
			    	try
			    	{
			    		int orderID = 0;
			    		int count = 0; 
			    		rs = st.executeQuery("SELECT to_number(ITEM_ORDER_ID) AS ORDER_ID FROM ITEM_ORDER ORDER BY ORDER_ID");
			    		while(rs.next())
			    		{
			    			count++;
			    			int idInDataBase = Integer.parseInt(rs.getString("ORDER_ID").trim());
			    			
			    			if(idInDataBase != count)
			    			{
			    				orderID = count -1;
			    				break;
			    			}
			    			orderID = count;
			    		}
			    	
		    			String leadingZero = "";
		    			for(int i = 1; i <= 6-String.valueOf(orderID + 1).length(); i++)
		    			{
		    				leadingZero += "0";
		    			}
		    			itemOrderID = leadingZero + String.valueOf(orderID + 1);
		    			
		    			//checking and initializing description and order purpose 
		    			if(description.trim().length() == 0)
		    			{
		    				description = "N/A";
		    			}
		    			if(orderPurpose.trim().length() == 0)
		    			{
		    				orderPurpose = "N/A";
		    			}
		    			
		    			
		    			//setting auto commit to false
		    			conn.setAutoCommit(false);
		    			//inserting into ITEM_ORDER
		    			st.executeUpdate("INSERT INTO ITEM_ORDER (ITEM_ORDER_ID, SUPPLIER_ID, ITEM_ID, EMPLOYEE_ID,"+
		    							" DATE_OF_ORDER, PURPOSE_OF_ORDER, ORDER_ITEM_QUANTITY, DESCRIPTION, ORDER_STATUS)"+
		    							" VALUES ('"+itemOrderID+"','"+supplierID+"','"+itemInsertID+"','"+employeeID+"',"+
		    							" sysdate,'"+orderPurpose.trim()+"',"+quantity+",'"+description+"','"+status+"')");
		    			//commit insert
		    			conn.commit();
		    			
		    			messages.put("result", "Order for Item ID: <strong>"+itemID+"</strong> placed successfully with <strong>"+quantity+"</strong> Quantities"+
		    						"<br/>Order ID: <strong>"+itemOrderID+"</strong> Status: <strong>"+status+"</strong>");
		    			request.setAttribute("valid", "2");
		    			request.getRequestDispatcher("/jsp/task/faculty/FacultyOrderPlace.jsp").forward(request, response);
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
