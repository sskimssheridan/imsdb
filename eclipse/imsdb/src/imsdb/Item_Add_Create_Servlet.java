package imsdb;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
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

import net.sourceforge.barbecue.Barcode;
import net.sourceforge.barbecue.BarcodeException;
import net.sourceforge.barbecue.BarcodeFactory;
import net.sourceforge.barbecue.BarcodeImageHandler;
import net.sourceforge.barbecue.output.OutputException;

import com.oreilly.servlet.MultipartRequest;

public class Item_Add_Create_Servlet extends HttpServlet {
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
		
		//System.out.println("Reached Create");
		Map<String, String> messages = new HashMap<String, String>();
	    request.setAttribute("messages", messages);
	    
	    //getting parameters value from the Form
	    MultipartRequest multipartRequest = new MultipartRequest(request, "/temp", 100 *1024 * 1024);
	    
	    //getting all the values in the String variables, byte array or string array
	    String itemID = null;
	    String strBarcode = null;
		String categoryID = multipartRequest.getParameter("categoryID");
		String [] machineryItem = multipartRequest.getParameterValues("machineryItem");
	    String campusID = multipartRequest.getParameter("campusID");
	    String labID = multipartRequest.getParameter("labID");
	    String containerCode = multipartRequest.getParameter("containerCode");
	    byte[] image = null;
	    byte[] barcodeImage = null;
	    String quantity = multipartRequest.getParameter("quantity");
	    String minQuantity = multipartRequest.getParameter("minQuantity");
	    String status = multipartRequest.getParameter("status");
	    String manufacturerID = multipartRequest.getParameter("manufacturerID");
	    String warranty = multipartRequest.getParameter("warranty");
	    String productCode = multipartRequest.getParameter("productCode");
	    String purchaseDate = multipartRequest.getParameter("purchaseDate");
	    String price = multipartRequest.getParameter("price");
	    String expiryDate = multipartRequest.getParameter("expiryDate");
	    String description = multipartRequest.getParameter("description"); 
	    String [] descField = multipartRequest.getParameterValues("descField");
	    String [] descValue = multipartRequest.getParameterValues("descValue");
	    
	    //converting string to date
	    DateFormat formatter; 
	    Date dtPurchaseDate = null; 
	    Date dtExpiryDate = null;
	    formatter = new SimpleDateFormat("MM/dd/yyyy");
	    
	    //creating sessions for variables
	    try
	    {
	    	session.setAttribute("categoryID", categoryID);
		    session.setAttribute("campusID", campusID);
		    session.setAttribute("labID", labID);
		    session.setAttribute("containerCode", containerCode);
		    session.setAttribute("quantity", quantity);
		    session.setAttribute("minQuantity", minQuantity);
		    session.setAttribute("status", status);
		    session.setAttribute("manufacturerID", manufacturerID);
		    session.setAttribute("warranty", warranty);
		    session.setAttribute("productCode", productCode);
		    session.setAttribute("purchaseDate", purchaseDate);
		    session.setAttribute("price", price);
	    	session.setAttribute("expiryDate", expiryDate);
	    	session.setAttribute("description", description);
	    }
	    catch(Exception e)
	    {
	    	request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
	    }
	    //checking for errors
	    boolean loginError = false;
	    
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
	    //checking productCode
	    if(productCode.length()==0 || productCode == null)
	    {
	    	messages.put("productCode", "PRODUCT CODE cannot be blank");
	    	loginError = true;
	    }
	    else if(productCode.length()>15)
	    {
	    	messages.put("productCode", "PRODUCT CODE must be below 15 caracters");
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
	    if(categoryID.equals("M"))
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
	    				String toSearchID = machineryItem[i].trim().substring(Math.max(0, machineryItem[i].trim().length() - 6));
	    				
			    		rs = st.executeQuery("SELECT ITEM_ID FROM ITEM WHERE ITEM_ID ='"+ toSearchID +"'");
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
	    
	    //sending request back to item add page if error is true
	    //or perform actions if no error is encountered
	    if(loginError)
	    {
	    	request.getRequestDispatcher("/jsp/task/item/ItemAdd/AddItem.jsp").forward(request, response);
	    }
	    else
	    {
	    	//getting image into byte array
	    	Enumeration files = multipartRequest.getFileNames(); 
	    	while (files.hasMoreElements()) 
	    	{
	    		FileInputStream fi = null;
	    		try
	    		{
	    		String name = (String)files.nextElement();
	    		File file = multipartRequest.getFile(name);
	    		fi = new FileInputStream(file);
	    		//raising File Size error and forwarding the error to item add page
	    		if (file != null && file.length() > (100 *1024)) 
	    		{
	    			messages.put("image", "IMAGE cannot exceed 100 KB, your image size is "+(file.length()/1024)+" KB");
	    	    	loginError = true;
	    	    	request.getRequestDispatcher("/jsp/task/item/ItemAdd/AddItem.jsp").forward(request, response);
	    	    }
	    		image = new byte[(int) file.length()];
	            fi.read(image);
	            //System.out.print(image.length);
	    		}
	    		catch(Exception e)
	    		{
	    			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
	    		}
	    		finally
	    		{
	    			if (fi!=null) 
	    			{
	    				fi.close();
	    		    }
	    		}
	    	}
	    	
	    	try
	    	{
		    	//converting date to dd-MMM-yy format
	    		SimpleDateFormat format10 = new SimpleDateFormat("MM/dd/yyyy");
	    	    SimpleDateFormat format20 = new SimpleDateFormat("dd-MMM-yy");
	    		
	            Date datePur1 = format10.parse(purchaseDate);
	            Date dateExp1 = format10.parse(expiryDate);
	           
	            String purDt1 = format20.format(datePur1);
	            String expDt1 = format20.format(dateExp1);
	          
	            //removing comma ',' from price
	            price = price.replace(",", "");
		    
		    	rs = st.executeQuery("SELECT * FROM ITEM I, ITEM_DETAIL IL WHERE I.ITEM_ID = IL.ITEM_ID AND "+
		    						"I.CATEGORY_ID = '"+ categoryID.trim().toUpperCase() +"' AND "+
		    						"I.CAMPUS_ID = '"+ campusID.trim().toUpperCase() +"' AND "+
		    						"I.LAB_ID = '"+labID.trim().toUpperCase()+"' AND "+
		    						"I.CONTAINER_CODE = '"+containerCode.trim().toUpperCase()+"' AND "+
		    						"I.QUANTITY = "+Integer.parseInt(quantity)+" AND "+
		    						"I.MIN_QUANTITY ="+Integer.parseInt(minQuantity)+" AND "+
		    						"I.STATUS = '"+ status.trim().toUpperCase() +"' AND "+
		    						"I.DESCRIPTION = '"+description+"' AND "+
		    						"IL.MANUFACTURER_ID = '"+manufacturerID.trim().toUpperCase()+"' AND "+
		    						"IL.WARRANTY_INFORMATION = '"+warranty.trim()+"' AND "+
		    						"IL.PRODUCT_CODE = '"+productCode.trim().toUpperCase()+"' AND "+
		    						"IL.PURCHASE_DATE ='"+purDt1+"' AND "+
		    						"IL.PRICE = "+price+" AND "+
		    						"IL.EXPIRY_DATE = '"+expDt1+"'");
	    	
	    	
		    	if (!rs.isBeforeFirst() ) 
	    		{ 
			    	//getting item ID from the database and incrementing it by 1
			    	try
			    	{
			    		int intItemID = 0;
			    		int count = 0; 
			    		rs = st.executeQuery("SELECT to_number(ITEM_ID) AS ITEM_ID FROM ITEM ORDER BY ITEM_ID");
			    		while(rs.next())
			    		{
			    			count++;
			    			int idInDataBase = Integer.parseInt(rs.getString("ITEM_ID").trim());
			    			
			    			//System.out.println("IN DB : "+idInDataBase+" IN COUNT :"+count );
			    			
			    			if(idInDataBase != count)
			    			{
			    				intItemID = count -1;
			    				break;
			    			}
			    			intItemID = count;
			    		}
			    	
		    			String leadingZero = "";
		    			for(int i = 1; i <= 6-String.valueOf(intItemID + 1).length(); i++)
		    			{
		    				leadingZero += "0";
		    			}
		    			itemID = leadingZero + String.valueOf(intItemID + 1);
		    			//System.out.println(itemID);
			    	}
			    	catch(Exception e)
					{
			    		request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
			    	
			    	//generating Barcode Image in binary format
			    	try 
					{
			    		//Barcode String
			    		strBarcode = campusID.trim().toUpperCase() + 
			    						labID.trim().toUpperCase() +
			    						containerCode.trim().toUpperCase() +
			    						categoryID.trim().toUpperCase() +
			    						itemID.trim().toUpperCase();
			    		
						Barcode barCode=BarcodeFactory.createCode128(strBarcode);
						File file=new File("barcode");
					    
					    ByteArrayOutputStream baos = new ByteArrayOutputStream();
					    BarcodeImageHandler.writePNG(barCode, baos);
					    
					    file.deleteOnExit();
					    FileOutputStream fos = new FileOutputStream(file);
					    BarcodeImageHandler.writePNG(barCode, fos); 
					
					    FileInputStream in = new FileInputStream(file);  
					    int size = in.available();  
					    barcodeImage = new byte[size];  
					    in.read(barcodeImage);  
					    in.close();   
					    file.delete();
					    
					    session.setAttribute("barcodeString", strBarcode);
					} 
					catch (BarcodeException e) 
					{        // TODO Auto-generated catch block
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					} catch (OutputException e) 
					{	// TODO Auto-generated catch block
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
			    	
			    	//Inserting data in the database
			    	try
			    	{
			    		conn.setAutoCommit(false);
			    		//inserting into ITEM table
			    		String itemInsert = "INSERT INTO ITEM(ITEM_ID, CATEGORY_ID,CAMPUS_ID, LAB_ID, CONTAINER_CODE,"+
			    							"IMAGE, QUANTITY, MIN_QUANTITY, STATUS, DESCRIPTION, BARCODE) "+
			    							" VALUES ('"+itemID+"','"+categoryID.trim().toUpperCase()+"','"+campusID.trim().toUpperCase()+"',"+
			    					    	"'"+labID.trim().toUpperCase()+"','"+containerCode.trim().toUpperCase()+"',?,"+
			    					    	Integer.parseInt(quantity)+","+Integer.parseInt(minQuantity)+","+
			    					    	"'"+status.trim().toUpperCase()+"','"+description.trim()+"',?)";
			    		
			    		PreparedStatement prstm = null;
			    		prstm = conn.prepareStatement(itemInsert);
			    		prstm.setBytes(1, image);
			    		prstm.setBytes(2, barcodeImage);
			    		prstm.executeUpdate();
			    		
			    		//converting date to dd-MMM-yy format
			    		SimpleDateFormat format1 = new SimpleDateFormat("MM/dd/yyyy");
			    	    SimpleDateFormat format2 = new SimpleDateFormat("dd-MMM-yy");
			    		
			            Date datePur = format1.parse(purchaseDate);
			            Date dateExp = format1.parse(expiryDate);
			           
			            String purDt = format2.format(datePur);
			            String expDt = format2.format(dateExp);
			          
			            //removing comma ',' from price
			            price = price.replace(",", "");
			            
			            //inserting into item_details table
			    		itemInsert = "INSERT INTO ITEM_DETAIL(ITEM_ID, MANUFACTURER_ID, WARRANTY_INFORMATION, PRODUCT_CODE, PURCHASE_DATE, PRICE, EXPIRY_DATE) "+
			    					"VALUES ('"+itemID+"','"+manufacturerID.trim().toUpperCase()+"','"+warranty.trim()+"','"+
			    				productCode.trim().toUpperCase()+"','"+purDt+"',"+price+",'"+expDt+"')";
			    		
			    		st.executeQuery(itemInsert);
		
			    		//Inserting into machinery table
			    		if(categoryID.equals("M"))
			    	    {
			    	    	for(int i=0; i<machineryItem.length; i++)
			    	    	{
			    	    		//extracting ITEM_ID from the string
			    	    		if(machineryItem[i].length() != 0)
			    	    		{
			    	    			String toSearchID = machineryItem[i].trim().substring(Math.max(0, machineryItem[i].trim().length() - 6));
			    	    			//checking if recode exists
			    	    			rs = st.executeQuery("SELECT * FROM MACHINERY WHERE MACHINERY_ITEM_ID = '"+itemID+"' AND MACHINERY_CONTAINING_ITEM_ID ='"+toSearchID+"'");
			    	    			if (!rs.isBeforeFirst()) 
						    		{ 
				    	    			itemInsert = "INSERT INTO MACHINERY (MACHINERY_ITEM_ID, MACHINERY_CONTAINING_ITEM_ID)"+
				    	    						"VALUES ('"+itemID+"','"+toSearchID+"')";
				    			    	st.executeUpdate(itemInsert);
						    		}
			    	    		}
			    	    	}
			    	    }
		    		
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
					    			itemInsert = "INSERT INTO ITEM_ADDITIONAL_DESCRIPTION (ITEM_ID, DESCRIPTION_FIELD, DESCRIPTION_VALUE)"+
					    						"VALUES('"+itemID+"','"+descField[i].trim().toString()+"','"+descValue[i].trim().toString()+"')";
							    	st.executeUpdate(itemInsert);
				    			}
			    	    	}
		    			}
			    		
		    	    	//removing session variables
		    	    	try
		    	 	    {
		    	 	    	session.removeAttribute("categoryID");
		    	 		    session.removeAttribute("campusID");
		    	 		    session.removeAttribute("labID");
		    	 		    session.removeAttribute("containerCode");
		    	 		    session.removeAttribute("quantity");
		    	 		    session.removeAttribute("minQuantity");
		    	 		    session.removeAttribute("status");
		    	 		    session.removeAttribute("manufacturerID");
		    	 		    session.removeAttribute("warranty");
		    	 		    session.removeAttribute("productCode");
		    	 		    session.removeAttribute("purchaseDate");
		    	 		    session.removeAttribute("price");
		    	 	    	session.removeAttribute("expiryDate");
		    	 	    	session.removeAttribute("description");
		    	 	    }
		    	 	    catch(Exception e)
		    	 	    {
		    	 	    	request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		    	 	    }
		    	    	
		    	    	conn.commit();
		    			request.getRequestDispatcher("/jsp/task/item/DisplayBarcode/DisplayItemBarcode.jsp").forward(request, response);
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
		    	else
		    	{
		    		request.getRequestDispatcher("/jsp/task/item/ItemExists/ItemExists.jsp").forward(request, response);
		    	}
	    	}
	    	catch(Exception e)
	    	{
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
