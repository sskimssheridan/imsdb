package imsdb;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.ParseException;
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

public class Item_Modify_Servlet extends HttpServlet {
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
	    
	    String btnClick = request.getParameter("act");
	    String itemID = request.getParameter("itemModifyId");
	    String toSearchID = null;
	    String categoryID = "";
	    
	    boolean loginError = false;
	    
	    if (itemID == null || itemID.trim().isEmpty())
	    {
	        messages.put("itemModifyId", "Please enter Item ID to MODIFY");
	        loginError = true;
	    }
	    else
	    {
	    	//checking if item is not an item
			try
    		{
				//extracting ITEM_ID from the string
				toSearchID = itemID.trim().substring(Math.max(0, itemID.trim().length() - 6));
				
	    		rs = st.executeQuery("SELECT ITEM_ID,CATEGORY_ID FROM ITEM WHERE ITEM_ID ='"+ toSearchID +"'");
	    		if (!rs.isBeforeFirst() ) 
	    		{    
	    			messages.put("itemModifyId", "<strong>'"+itemID.trim()+"'</strong> is not an ITEM");
	    			loginError = true;
	    		} 
	    		else
	    		{	rs.next();
	    			categoryID = rs.getString("CATEGORY_ID");
	    		}
    		}
    		catch(Exception e)
    		{
    			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
    		}
	    }
	    if(loginError)
	    {
	    	request.getRequestDispatcher("jsp/task/item/ItemModify/ModifyItem.jsp").forward(request, response);
	    }
	    else
	    {
	    	if(btnClick.toUpperCase().equals("MODIFY ITEM"))
		    {	
	    		//getting values from fields
	    		//getting all the values in the String variables, byte array or string array
	    		String [] machineryItem = request.getParameterValues("machineryItem");
	    	    String containerCode = request.getParameter("containerCode");
	    	    String quantity = request.getParameter("quantity");
	    	    String minQuantity = request.getParameter("minQuantity");
	    	    String status = request.getParameter("status");
	    	    String warranty = request.getParameter("warranty");
	    	    String purchaseDate = request.getParameter("purchaseDate");
	    	    String price = request.getParameter("price");
	    	    String expiryDate = request.getParameter("expiryDate");
	    	    String description = request.getParameter("description"); 
	    	    String [] descField = request.getParameterValues("descField");
	    	    String [] descValue = request.getParameterValues("descValue");
	    	    
	    	   //converting string to date
	    	    DateFormat formatter; 
	    	    Date dtPurchaseDate = null; 
	    	    Date dtExpiryDate = null;
	    	    formatter = new SimpleDateFormat("MM/dd/yyyy");
	    		
	    	    loginError = false;
	    	    
	    	   //checking container code
	    	    if(containerCode.length()==0 || containerCode == null)
	    	    {
	    	    	messages.put("container", "CONTINER CODE cannot be blank");
	    	    	loginError = true;
	    	    }
	    	    else if(containerCode.length()>5)
	    	    {
	    	    	messages.put("container", "CONTINER CODE must be below 5 caracters");
	    	    	loginError = true;
	    	    }
	    	    //checking quantity
	    	    if(quantity.length() == 0 || quantity == null)
	    	    {
	    	    	messages.put("quantity", "QUANTITY cannot be blank");
	    	    	loginError = true;
	    	    }
	    	    else if(quantity.length()>5)
	    	    {
	    	    	messages.put("quantity", "QUANTITY must be below 5 numbers");
	    	    	loginError = true;
	    	    }
	    	    if(quantity.contains("."))
	    	    {
	    	    	messages.put("quantity", "QUANTITY cannot contain period '.'");
	    	    	loginError = true;
	    	    }
	    	    //checking min quantity
	    	    if(minQuantity.length() == 0 || minQuantity == null)
	    	    {
	    	    	messages.put("minQuantity", "MIN QUANTITY cannot be blank");
	    	    	loginError = true;
	    	    }
	    	    else if(minQuantity.length()>5)
	    	    {
	    	    	messages.put("minQuantity", "MIN QUANTITY must be below 5 numbers");
	    	    	loginError = true;
	    	    }
	    	    if(minQuantity.contains("."))
	    	    {
	    	    	messages.put("minQuantity", "MIN QUANTITY cannot contain period '.'");
	    	    	loginError = true;
	    	    }
	    	    else if(quantity.length() != 0 && minQuantity.length() != 0 && loginError == false)
	    	    {
	    	    	//checking if min quantity is less than quantity
	    	    	//parsing quantity and min quantity into int values
	    	    	int qty = Integer.parseInt(quantity);
	    	    	int minQty = Integer.parseInt(minQuantity);
	    	    	
	    	    	//raising an error for min quantity
	    	    	if(qty < minQty)
	    	    	{
	    	    		messages.put("minQuantity", "MIN QUANTITY must be LESS than QUANTITY");
	    		    	loginError = true;
	    	    	}
	    	    	
	    	    }
	    	   //checking warranty 
	    	    if(warranty.length()==0 || warranty == null)
	    	    {
	    	    	messages.put("warranty", "Warranty cannot be blank");
	    	    	loginError = true;
	    	    }
	    	    else if(warranty.length()>50)
	    	    {
	    	    	messages.put("warranty", "warranty must be below 50 caracters");
	    	    	loginError = true;
	    	    }
	    	   //checking purchaseDate
	    	    if(purchaseDate.length()==0 || purchaseDate == null)
	    	    {
	    	    	messages.put("purchaseDate", "PURCHASE DATE cannot be blank");
	    	    	loginError = true;
	    	    }
	    	    else
	    	    {
	    	    	//setting purchase date
	    	    	try {
	    				dtPurchaseDate = formatter.parse(purchaseDate);
	    			} catch (ParseException e) {
	    				// TODO Auto-generated catch block
	    				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
	    			}
	    	    }
	    	    //checking price
	    	    if(price.length() == 0 || price == null)
	    	    {
	    	    	messages.put("price", "PRICE cannot be blank");
	    	    	loginError = true;
	    	    }
	    	    //checking expiry date
	    	    if(expiryDate.length()==0 || expiryDate == null)
	    	    {
	    	    	messages.put("date", "Expiry DATE cannot be blank");
	    	    	loginError = true;
	    	    }
	    	    else
	    	    {
	    	    	try {
	    				dtExpiryDate = formatter.parse(expiryDate);
	    			} catch (ParseException e) {
	    				// TODO Auto-generated catch block
	    				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
	    			}
	    	    }
	    	  
	    	    //checking for expiry date and purchase date, 
	    	    //expiry date should be greated than or equal to purchase date
	    	    if(dtPurchaseDate != null && dtExpiryDate != null && dtExpiryDate.before(dtPurchaseDate))
	    	    {
	    	    	messages.put("date", "EXPIRY DATE must be after PURCHASE DATE");
	    	    	loginError = true;
	    	    }
	    	    
	    	    //checking description
	    	    if(description.length()==0 || description == null)
	    	    {
	    	    	messages.put("description", "DESCRIPTION cannot be blank");
	    	    	loginError = true;
	    	    }
	    	    else if(description.length()>4000)
	    	    {
	    	    	messages.put("description", "DESCRIPTION must be below 4000 caracters");
	    	    	loginError = true;
	    	    }
	    	   //checking for machinery Item if category is Machinery 
	    	    if(categoryID.trim().equals("M"))
	    	    {
	    	    	if(machineryItem == null || machineryItem.length == 0)
	    	    	{
	    	    		messages.put("item", "MACHINERY must cointain atleast one item");
    	    			loginError = true;
	    	    	}
	    	    	else
	    	    	{
		    	    	for(int i=0; i<machineryItem.length; i++)
		    	    	{
		    	    		//messages.put("item"+(i+1), machineryItem[i].trim());
		    	    		if(machineryItem[i].trim().equals("") || machineryItem[i] == null)
		    	    		{
		    	    			messages.put("item", "All ITEM ID must contain ITEM, delete blank fields<br/>One ITEM is must for a MACHINERY");
		    	    			loginError = true;
		    	    		}
		    	    		else
		    	    		{
		    	    			//checking if items in the machinery item fields is not an item
		    	    			try
		    		    		{
		    	    				//extracting ITEM_ID from the string
		    	    				String toSearchID2 = machineryItem[i].trim().substring(Math.max(0, machineryItem[i].trim().length() - 6));
		    			    		rs = st.executeQuery("SELECT ITEM_ID FROM ITEM WHERE ITEM_ID ='"+ toSearchID2 +"'");
		    			    		if (!rs.isBeforeFirst() ) 
		    			    		{    
		    			    			messages.put("item", "ITEM ID must be an ITEM, <strong>'"+machineryItem[i].trim()+"'</strong> is not an ITEM");
		    			    			loginError = true;
		    			    		} 
		    		    		}
		    		    		catch(Exception e)
		    		    		{
		    		    			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		    		    		}
		    	    		}
		    	    	}
	    	    	}
	    	    }
	    	    //sending request back to item add page if error is true
	    	    //or perform actions if no error is encountered
	    	    if(loginError)
	    	    {
	    	    	request.setAttribute("valid", "1");
	    	    	request.getRequestDispatcher("jsp/task/item/ItemModify/ModifyItem.jsp").forward(request, response);
	    	    }
	    	    else
	    	    {
	    	    	request.setAttribute("valid", "-1");
	    	    	try 
	    	    	{
	    	    		conn.setAutoCommit(false);
	    	    		//updating item table
						st.executeUpdate("UPDATE ITEM SET CONTAINER_CODE ='"+containerCode.trim().toUpperCase()+"', "+
										"QUANTITY ="+Integer.parseInt(quantity)+", "+
										"MIN_QUANTITY ="+Integer.parseInt(minQuantity)+", "+
										"STATUS ='"+status.trim().toUpperCase()+"', "+
										"DESCRIPTION = '"+description.trim()+"' "+
										"WHERE ITEM_ID ='"+toSearchID+"'");
						
						//converting date to dd-MMM-yy format
			    		SimpleDateFormat format1 = new SimpleDateFormat("MM/dd/yyyy");
			    	    SimpleDateFormat format2 = new SimpleDateFormat("dd-MMM-yy");
			    		
			            Date datePur = format1.parse(purchaseDate);
			            Date dateExp = format1.parse(expiryDate);
			           
			            String purDt = format2.format(datePur);
			            String expDt = format2.format(dateExp);
						//updating item details table
			            
			           //removing comma ',' from price
			            price = price.replace(",", "");
			            
						st.executeUpdate("UPDATE ITEM_DETAIL SET WARRANTY_INFORMATION = '"+warranty.trim()+"', "+
										"PURCHASE_DATE ='"+purDt+"', "+
										"EXPIRY_DATE = '"+expDt+"', "+
										"PRICE = "+price+
										" WHERE ITEM_ID ='"+toSearchID+"'");
						
						//deleting from machinery table
						st.executeUpdate("DELETE FROM MACHINERY WHERE MACHINERY_ITEM_ID = '"+toSearchID+"'");
						
						//Inserting into machinery table
			    		if(categoryID.trim().equals("M"))
			    	    {	
							//inserting into machinery table
			    	    	for(int i=0; i<machineryItem.length; i++)
			    	    	{
			    	    		//extracting ITEM_ID from the string
			    	    		if(machineryItem[i].length() != 0)
			    	    		{
			    	    			String toSearchID2 = machineryItem[i].trim().substring(Math.max(0, machineryItem[i].trim().length() - 6));
			    	    			//checking if recode exists
			    	    			rs = st.executeQuery("SELECT * FROM MACHINERY WHERE MACHINERY_ITEM_ID = '"+toSearchID+"' AND MACHINERY_CONTAINING_ITEM_ID ='"+toSearchID2+"'");
			    	    			if (!rs.isBeforeFirst() && !toSearchID.endsWith(toSearchID2)) 
						    		{ 
				    	    			String itemInsert = "INSERT INTO MACHINERY (MACHINERY_ITEM_ID, MACHINERY_CONTAINING_ITEM_ID)"+
				    	    						"VALUES ('"+toSearchID+"','"+toSearchID2+"')";
				    			    	st.executeUpdate(itemInsert);
						    		}
			    	    		}
			    	    	}
			    	    }
			    		
			    		//deleting from Additional Item Information
			    		st.executeUpdate("DELETE FROM ITEM_ADDITIONAL_DESCRIPTION WHERE ITEM_ID = '"+toSearchID+"'");
			    		
			    		//Inserting into Additional Information of Item Table
		    			if(descField != null)
		    			{
				    		for(int i=0; i<descField.length ; i++)
			    	    	{
			    	    		//extracting ITEM_ID from the string
				    			if(!(descField[i].trim().toString().equals("")  || descField[i].trim().toString() == null))
				    			{
				    				if(descValue[i].length() == 0)
				    				{
				    					descValue[i] = "N/A";
				    				}
					    			String itemInsert = "INSERT INTO ITEM_ADDITIONAL_DESCRIPTION (ITEM_ID, DESCRIPTION_FIELD, DESCRIPTION_VALUE)"+
					    						"VALUES('"+toSearchID+"','"+descField[i].trim().toString()+"','"+descValue[i].trim().toString()+"')";
							    	st.executeUpdate(itemInsert);
				    			}
			    	    	}
		    			}
						
		    			conn.commit();
		    			request.getRequestDispatcher("jsp/task/item/ItemModify/ModifyItem.jsp").forward(request, response);
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
	    	else if(btnClick.toUpperCase().equals("DISPLAY ITEM"))
		    {
		    	//setting valid for showing in the item description in MODIFY ITEM FORM
		    	session.setAttribute("itemModifyId",itemID);
		    	request.setAttribute("valid", "1");
		    	request.getRequestDispatcher("jsp/task/item/ItemModify/ModifyItem.jsp").forward(request, response);
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
