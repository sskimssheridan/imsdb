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

public class Item_Checkout_Servlet extends HttpServlet
{
	private static final long serialVersionUID = 1L;

	//variables for database connection
	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
	private ResultSet rs = null;
	private ResultSet rsSub = null;
	private ResultSet rsSub2 = null;
		
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
			    
		String btnSearch = request.getParameter("act");
		String userID = request.getParameter("userID").toUpperCase().trim();
		
		boolean error = false;
		
		//checking container code
	    if(userID.length()==0 || userID == null)
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
	    	catch(Exception e)
			{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
	    }
		
	    if(error)
	    {
	    	request.getRequestDispatcher("/jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
	    }
	    else
	    {
	    	//if no error
	    	
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
			
	    	//if items on hold is clicked
	    	if(btnSearch.toUpperCase().trim().equals("ITEMS ON HOLD"))
			{
	    		//setting valid for showing in the item user put on hold
		    	session.setAttribute("userID",userID);
		    	request.setAttribute("valid", "1");
		    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
			}
	    	//if checkout new item is clicked
	    	else if(btnSearch.toUpperCase().trim().equals("CHECKOUT NEW ITEM"))
	    	{
	    		//setting valid for creating new item booking/checkout for user 
		    	session.setAttribute("userID",userID);
		    	request.setAttribute("valid", "2");
		    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
	    	}
	    	else if(btnSearch.toUpperCase().trim().equals("YES RENT ITEM"))
	    	{
	    		String itemID = session.getAttribute("itemID").toString();
	    		String strQuantity = session.getAttribute("quantityAvalable").toString();
	    		int quantity = Integer.parseInt(strQuantity);
	    		
	    		try
	    		{
	    			conn.setAutoCommit(false);
	    			
	    			//inserting record in ITEM_BORROW table if its not consumable item
	    			rsSub2 = st.executeQuery("SELECT CATEGORY_ID FROM ITEM WHERE ITEM_ID = '"+itemID+"'");
	    			rsSub2.next();
	    			if(!(rsSub2.getString("CATEGORY_ID").trim().toUpperCase().equals("C")))
	    			{
	    				st.executeUpdate("INSERT INTO ITEM_BORROW(USER_ID, ITEM_ID, DATE_OF_BORROW, QUANTITY_BORROWED)"+
	    							" VALUES ('"+userID+"','"+itemID+"',sysdate,"+quantity+")");
	    			}
	    			//updating quantity for the ITEM in the ITEM table
	    			st.executeUpdate("UPDATE ITEM SET QUANTITY = QUANTITY - "+quantity+" WHERE ITEM_ID = '"+itemID+"'");
	    			conn.commit();
	    			
	    			request.setAttribute("valid", "5");
	    			messages.put("rented", "Item Rented out Successfully with "+quantity+" Quantity");
			    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
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
	    	else if(btnSearch.toUpperCase().trim().equals("YES RENT"))
	    	{
	    		String itemID = session.getAttribute("itemID").toString();
	    		String strQuantity = session.getAttribute("quantityAvalable").toString();
	    		int quantity = Integer.parseInt(strQuantity);
	    		
	    		try
	    		{
	    			conn.setAutoCommit(false);
	    			//deleting record for the user and item in the ITEM_HOLD table
	    			st.executeUpdate("DELETE FROM ITEM_HOLD WHERE ITEM_ID='"+itemID+"' AND USER_ID='"+userID+"'");
	    			//inserting record in ITEM_BORROW table if its not consumable item
	    			rsSub2 = st.executeQuery("SELECT CATEGORY_ID FROM ITEM WHERE ITEM_ID = '"+itemID+"'");
	    			rsSub2.next();
	    			if(!(rsSub2.getString("CATEGORY_ID").trim().toUpperCase().equals("C")))
	    			{
	    				st.executeUpdate("INSERT INTO ITEM_BORROW(USER_ID, ITEM_ID, DATE_OF_BORROW, QUANTITY_BORROWED)"+
	    							" VALUES ('"+userID+"','"+itemID+"',sysdate,"+quantity+")");
	    			}
	    			//updating quantity for the ITEM in the ITEM table
	    			st.executeUpdate("UPDATE ITEM SET QUANTITY = QUANTITY - "+quantity+" WHERE ITEM_ID = '"+itemID+"'");
	    			conn.commit();
	    			
	    			request.setAttribute("valid", "5");
	    			messages.put("rented", "Item Rented out Successfully with "+quantity+" Quantity");
			    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
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
	    	else if(btnSearch.toUpperCase().trim().equals("NO THANKS"))
	    	{
	    		//deleting record for the user and item in the ITEM_HOLD table
	    		String itemID = session.getAttribute("itemID").toString();
	    		
	    		try
	    		{
	    			conn.setAutoCommit(false);
	    			st.executeQuery("DELETE FROM ITEM_HOLD WHERE ITEM_ID='"+itemID+"' AND USER_ID='"+userID+"'");
	    			conn.commit();
	    			request.setAttribute("valid", "5");
	    			messages.put("rented", "Item Relesed form hold with no Quantity");
			    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
	    			
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
	    	else if(btnSearch.toUpperCase().trim().equals("RENT OUT"))
	    	{
	    		String itemRentID = request.getParameter("itemID");
	    		String itemID = itemRentID.trim().substring(Math.max(0, itemRentID.trim().length() - 6));
	    		String strQuantity = request.getParameter("rentQuantity");
	    		
	    		//checking for item id
	    		if(itemID.length() == 0 || itemID.isEmpty() || itemID == null)
	    		{
	    			request.setAttribute("valid", "3");
	    			messages.put("error", "ITEM ID cannot be blank");
			    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
			    	return;
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
			    			request.setAttribute("valid", "3");
			    			messages.put("error", "ITEM ID must be an ITEM, <strong>'"+itemID+"'</strong> is not an ITEM");
			    			request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
			    			return;
			    		} 
		    		}
		    		catch(Exception e)
		    		{
		    			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		    			return;
		    		}
	    		}
	    		//if quantity is not empty
	    	    if (!(strQuantity.isEmpty() || strQuantity == null ))
	    		{
	    			int quantity = Integer.parseInt(strQuantity);
		    		//if quantity is 0
		    		if(quantity == 0)
		    		{
		    			request.setAttribute("valid", "3");
		    			messages.put("error", "Quantity cannot be 0 while renting");
				    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
		    		}
		    		//else if quantity is not 0
		    		else
		    		{
		    			try
		    			{
		    				rs = st.executeQuery("SELECT * FROM ITEM_BORROW WHERE USER_ID='"+userID+"' AND ITEM_ID='"+itemID+"' AND DATE_OF_RETURN IS NULL");
		    				
		    				if(rs.isBeforeFirst())
		    				{
		    					request.setAttribute("valid", "3");
				    			messages.put("error", "User already rented out the item. <br/>For additional quantity :<br/>Please return the item and rent again.");
						    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
		    				}
		    				else
		    				{
		    					int itemQuantity = 0;
		    					
				    			rsSub = st.executeQuery("SELECT QUANTITY FROM ITEM WHERE ITEM_ID ='"+itemID+"'");
				    			if(rsSub.next())
				    			{
				    				itemQuantity = Integer.parseInt(rsSub.getString("QUANTITY"));
				    				
				    				if(itemQuantity == 0)
			    					{
			    						request.setAttribute("valid", "3");
					    				messages.put("error", "ITEM cannot be rented out as quantity is 0 <br/>please re-order the ITEM");
					    				request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
			    					}
				    				else if(itemQuantity < quantity)
			    					{
				    					request.setAttribute("valid", "6");
				    					session.setAttribute("itemID", itemID);
			    						session.setAttribute("quantityAvalable", itemQuantity);
			    						session.setAttribute("askedQuantity", quantity);
					    				messages.put("error", "Quantity Avaliable is less than Quantity Asked");
					    				request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
			    					}
				    				else if(itemQuantity >= quantity)
				    				{
				    					try
			    			    		{
			    			    			conn.setAutoCommit(false);
			    			    			//inserting record in ITEM_BORROW table if its not consumable item
			    			    			rsSub2 = st.executeQuery("SELECT CATEGORY_ID FROM ITEM WHERE ITEM_ID = '"+itemID+"'");
			    			    			rsSub2.next();
			    			    			if(!(rsSub2.getString("CATEGORY_ID").trim().toUpperCase().equals("C")))
			    			    			{
			    			    				st.executeUpdate("INSERT INTO ITEM_BORROW(USER_ID, ITEM_ID, DATE_OF_BORROW, QUANTITY_BORROWED)"+
			    			    							" VALUES ('"+userID+"','"+itemID+"',sysdate,"+quantity+")");
			    			    			}
			    			    			//updating quantity for the ITEM in the ITEM table
			    			    			st.executeUpdate("UPDATE ITEM SET QUANTITY = QUANTITY - "+quantity+" WHERE ITEM_ID = '"+itemID+"'");
			    			    			conn.commit();
			    			    			
			    			    			request.setAttribute("valid", "5");
			    			    			messages.put("rented", "Item Rented out Successfully with "+quantity+" Quantity");
			    					    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
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
				    			}
		    				}
		    			}
		    			catch (SQLException e) {
							// TODO Auto-generated catch block
				    		request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
						}
		    		}
	    		}
	    		//if quantity is empty
	    		else
	    		{
	    			//if string quantity value passed is null
	    			request.setAttribute("valid", "3");
	    			messages.put("error", "Quantity cannot be blank while renting");
			    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
	    		}
	    		
	    	}
	    	else
	    	{
	    		String itemID = btnSearch;
	    		String strQuantity = request.getParameter("bookID"+itemID);
	    		session.setAttribute("itemID", itemID);
	    		
	    		//if quantity is not empty
	    		if (!(strQuantity.isEmpty() || strQuantity == null ))
	    		{
	    			int quantity = Integer.parseInt(strQuantity);
	    		
	    			//if quantity is 0
		    		if(quantity == 0 )
		    		{
		    			request.setAttribute("valid", "3");
		    			messages.put("error", "Quantity cannot be 0 while releaseing");
				    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
		    		}
		    		//else if quantity is not 0
		    		else
		    		{
		    			int itemQuantity = 0;
		    			//getting quantity form the ITEM table for the particular ITEM
		    			try
		    			{
		    				rs = st.executeQuery("SELECT QUANTITY FROM ITEM WHERE ITEM_ID ='"+itemID+"'");
		    				if(rs.next())
		    				{
		    					itemQuantity = Integer.parseInt(rs.getString("QUANTITY"));
		    					
		    					if(itemQuantity == 0)
		    					{
		    						request.setAttribute("valid", "3");
				    				messages.put("error", "ITEM cannot be checkout as quantity is 0 <br/>please re-order the ITEM");
				    				request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
		    					}
		    					else if(itemQuantity < quantity)
		    					{
		    						request.setAttribute("valid", "4");
		    						session.setAttribute("quantityAvalable", itemQuantity);
		    						session.setAttribute("askedQuantity", quantity);
				    				messages.put("error", "Quantity Avaliable is less than Quantity Asked");
				    				request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
		    					}
		    					else if(itemQuantity >= quantity)
		    					{
		    						try
		    			    		{
		    			    			conn.setAutoCommit(false);
		    			    			//deleting record for the user and item in the ITEM_HOLD table
		    			    			st.executeUpdate("DELETE FROM ITEM_HOLD WHERE ITEM_ID='"+itemID+"' AND USER_ID='"+userID+"'");
		    			    			//inserting record in ITEM_BORROW table if its not consumable item
		    			    			rsSub2 = st.executeQuery("SELECT CATEGORY_ID FROM ITEM WHERE ITEM_ID = '"+itemID+"'");
		    			    			rsSub2.next();
		    			    			if(!(rsSub2.getString("CATEGORY_ID").trim().toUpperCase().equals("C")))
		    			    			{
		    			    				st.executeUpdate("INSERT INTO ITEM_BORROW(USER_ID, ITEM_ID, DATE_OF_BORROW, QUANTITY_BORROWED)"+
		    			    							" VALUES ('"+userID+"','"+itemID+"',sysdate,"+quantity+")");
		    			    			}
		    			    			//updating quantity for the ITEM in the ITEM table
		    			    			st.executeUpdate("UPDATE ITEM SET QUANTITY = QUANTITY - "+quantity+" WHERE ITEM_ID = '"+itemID+"'");
		    			    			conn.commit();
		    			    			
		    			    			request.setAttribute("valid", "5");
		    			    			messages.put("rented", "Item Rented out Successfully with "+quantity+" Quantity");
		    					    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
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
		    				}
		    			}
		    			catch (SQLException e) {
							// TODO Auto-generated catch block
				    		request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
						}
		    		}
	    		}
	    		//if quantity is empty
	    		else
	    		{
	    			//if string quantity value passed is null
	    			request.setAttribute("valid", "3");
	    			messages.put("error", "Quantity cannot be blank while releaseing");
			    	request.getRequestDispatcher("jsp/task/item/ItemCheckout/CheckoutItem.jsp").forward(request, response);
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
