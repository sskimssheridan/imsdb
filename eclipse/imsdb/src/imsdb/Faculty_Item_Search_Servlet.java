package imsdb;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Date;
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

public class Faculty_Item_Search_Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	//variables for database connection
	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
	private ResultSet rs = null;
	private ResultSet rsSub = null;
	
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
		String itemDesc = request.getParameter("itemDesc");
		
		if(btnSearch.toUpperCase().trim().equals("SEARCH ITEM") || btnSearch.toUpperCase().trim().equals("ADVANCE ITEM SEARCH"))
		{
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
			//setting valid for showing in the item search in SEARCH ITEM FORM
	    	session.setAttribute("itemDesc",itemDesc);
	    	request.setAttribute("valid", "1");
	    	request.getRequestDispatcher("/jsp/task/faculty/FacultyItemSearch.jsp").forward(request, response);
		}
		else if (btnSearch.toUpperCase().trim().equals("YES BORROW"))
		{ //for book item but after post back from quantity less than asked quantity and yes borrow is clicked
			try
			{
				String qntBorrow = session.getAttribute("quantityAvalable").toString();
				int qtyHold = Integer.parseInt(qntBorrow);
				
				String userID = session.getAttribute("username").toString();
				String holdItemID = session.getAttribute("holdItemID").toString();
				
				Date date = new Date();
				String holdDate= new SimpleDateFormat("dd-MMM-yy").format(date);
				
				//inserting data into ITEM HOLD table
				try
				{
					String msg = null;
					conn.setAutoCommit(false);
					rs = st.executeQuery("SELECT * FROM ITEM_HOLD WHERE USER_ID ='"+userID.trim().toUpperCase()+"' "+
										"AND ITEM_ID = '"+holdItemID.trim().toUpperCase()+"' "+
										"AND TRUNC(DATE_OF_HOLD) = '"+holdDate+"'");
					
					if(!rs.isBeforeFirst())
					{//data not present hold not done
						st.executeUpdate("INSERT INTO ITEM_HOLD (USER_ID, ITEM_ID, DATE_OF_HOLD, QUANTITY_HOLD, NOTIFIED_BY_EMAIL)"+
								" VALUES ('"+userID.trim().toUpperCase()+"','"+holdItemID.trim().toUpperCase()+"',sysdate,"+qtyHold+",'N')");
				
						rsSub = st.executeQuery("SELECT COUNT(*) As count, SUM(QUANTITY_HOLD) As sum FROM ITEM_HOLD WHERE ITEM_ID = '"+holdItemID.trim().toUpperCase()+"'");
						
						msg = "ITEM has been put on hold for you with <strong>"+qtyHold+"</strong> quantity<br/>"+
									"please see <strong>LAB REPRESENTATIVE</strong> for checking out the item.";
						if(rsSub.next())
						{
							String count = rsSub.getString("count");
							String sum = rsSub.getString("sum");
							
							msg += "<br/>Including you, total of <strong>"+count+"</strong> user/users have put <strong>"+sum+"</strong> quantities on hold for this item";
						}
						request.setAttribute("valid", "5");
						messages.put("searchResult",msg);
						request.getRequestDispatcher("/jsp/task/faculty/FacultyItemSearch.jsp").forward(request, response);
						
					}
					else
					{// data already present hold already done
						request.setAttribute("valid", "2");
						messages.put("error", "You have already placed a HOLD on this ITEM<br/>Please see <strong>LAB REPRESENTATIVE</strong> for more information");
						request.getRequestDispatcher("/jsp/task/faculty/FacultyItemSearch.jsp").forward(request, response);
					}
					
					conn.commit();
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
				
				session.removeAttribute("holdItemID");
				session.removeAttribute("quantityAvalable");
				session.removeAttribute("askedQuantity");
			}
	 	    catch(Exception e)
	 	    {
	 	    	request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
	 	    }
		}
		else if (btnSearch.toUpperCase().trim().equals("NO THANKS"))
		{//for book item but after post back from quantity less than asked quantity and no thanks is clicked
			//removing session variable
			try
			{
				session.removeAttribute("holdItemID");
				session.removeAttribute("quantityAvalable");
				session.removeAttribute("askedQuantity");
			}
	 	    catch(Exception e)
	 	    {
	 	    	request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
	 	    }
			request.setAttribute("valid", "5");
			messages.put("searchResult", "No Item was put on hold for you");
			request.getRequestDispatcher("/jsp/task/faculty/FacultyItemSearch.jsp").forward(request, response);
		}
		else
		{	//for book item
			boolean error = false;
			String itemID = btnSearch;
			session.setAttribute("holdItemID", btnSearch);
			String qntBorrow = request.getParameter("quantityBorrow"+itemID).trim();
			int itemQuantityToBorrow = 0;
			if(!qntBorrow.isEmpty())
			{
				itemQuantityToBorrow = Integer.parseInt(qntBorrow);
			}
			
			if(itemQuantityToBorrow == 0)
			{
				request.setAttribute("valid", "2");
				error = true;
				messages.put("error", "To book an <strong>ITEM, quantity to borrow</strong> must be greater than <strong>0</strong>");
			}
			else
			{
				int quantity;
		    	try
		    	{
		    		rs = st.executeQuery("SELECT QUANTITY FROM ITEM WHERE ITEM_ID ='"+itemID+"'");
		    		if(rs.next())
		    		{
		    			quantity = Integer.parseInt(rs.getString("QUANTITY"));
		    			if(quantity == 0)
		    			{
		    				request.setAttribute("valid", "4");
		    				error = true;
		    				messages.put("askLabRep", "Please consult <strong>LAB REPRESENTATIVE</strong> for borrowing this ITEM");
		    			}
		    			else if(quantity < itemQuantityToBorrow)
		    			{
		    				request.setAttribute("valid", "3");
		    				error = true;
		    				session.setAttribute("quantityAvalable", quantity);
		    				session.setAttribute("askedQuantity", itemQuantityToBorrow);
		    				messages.put("error", "You are trying to borrow more than available quantity");
		    			}
		    			else if(quantity >= itemQuantityToBorrow)
		    			{//if quantity is more than asked quantity then inserting data into database
		    				try
		    				{
		    					int qtyHold = itemQuantityToBorrow;
		    					
		    					String userID = session.getAttribute("username").toString();
		    					String holdItemID = session.getAttribute("holdItemID").toString();
		    					
		    					Date date = new Date();
		    					String holdDate= new SimpleDateFormat("dd-MMM-yy").format(date);
		    					
		    					//inserting data into ITEM HOLD table
		    					try
		    					{
		    						String msg = null;
		    						conn.setAutoCommit(false);
		    						rs = st.executeQuery("SELECT * FROM ITEM_HOLD WHERE USER_ID ='"+userID.trim().toUpperCase()+"' "+
		    											"AND ITEM_ID = '"+holdItemID.trim().toUpperCase()+"' "+
		    											"AND TRUNC(DATE_OF_HOLD) = '"+holdDate+"'");
		    						
		    						if(!rs.isBeforeFirst())
		    						{//data not present hold not done
		    							st.executeUpdate("INSERT INTO ITEM_HOLD (USER_ID, ITEM_ID, DATE_OF_HOLD, QUANTITY_HOLD, NOTIFIED_BY_EMAIL)"+
		    									" VALUES ('"+userID.trim().toUpperCase()+"','"+holdItemID.trim().toUpperCase()+"',sysdate,"+qtyHold+",'N')");
		    					
		    							rsSub = st.executeQuery("SELECT COUNT(*) As count, SUM(QUANTITY_HOLD) As sum FROM ITEM_HOLD WHERE ITEM_ID = '"+holdItemID.trim().toUpperCase()+"'");
		    							
		    							msg = "ITEM has been put on hold for you with <strong>"+qtyHold+"</strong> quantity<br/>"+
		    										"please see <strong>LAB REPRESENTATIVE</strong> for checking out the item.";
		    							if(rsSub.next())
		    							{
		    								String count = rsSub.getString("count");
		    								String sum = rsSub.getString("sum");
		    								
		    								msg += "<br/>Including you, total of <strong>"+count+"</strong> user/users have put <strong>"+sum+"</strong> quantities on hold for this item";
		    							}
		    							request.setAttribute("valid", "5");
		    							messages.put("searchResult",msg);
		    							request.getRequestDispatcher("/jsp/task/faculty/FacultyItemSearch.jsp").forward(request, response);
		    							
		    						}
		    						else
		    						{// data already present hold already done
		    							request.setAttribute("valid", "2");
		    							messages.put("error", "You have already placed a HOLD on this ITEM<br/>Please see <strong>LAB REPRESENTATIVE</strong> for more information");
		    							request.getRequestDispatcher("/jsp/task/faculty/FacultyItemSearch.jsp").forward(request, response);
		    						}
		    						
		    						conn.commit();
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
		    					
		    					session.removeAttribute("holdItemID");
		    					session.removeAttribute("quantityAvalable");
		    					session.removeAttribute("askedQuantity");
		    				}
		    		 	    catch(Exception e)
		    		 	    {
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
			if(error)
			{
				request.getRequestDispatcher("/jsp/task/faculty/FacultyItemSearch.jsp").forward(request, response);
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
