package imsdb;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
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

public class Admin_ItemBarcode_Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		//connecting to the database
		Context initContext;
		Context envContext;
		DataSource ds = null;
		Connection conn = null;
		Statement st = null;
		ResultSet rs = null;
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
		//creating message map
		Map<String, String> messages = new HashMap<String, String>();
	    request.setAttribute("messages", messages);
	    
	    //getting item id from the JSP page
	    String itemID = request.getParameter("displayBarcodeID");
	    
	    if(itemID.trim().equals("-1"))
	    {
	    	messages.put("displayBarcodeID","Please select ITEM ID");
	    	request.getRequestDispatcher("/jsp/task/admin/ItemBarcodePrint/ItemBarcode.jsp").forward(request, response);
	    }
	    else
	    {
	    	String barcodeID = "";
	    	try
			{
				rs = st.executeQuery("SELECT * FROM ITEM WHERE ITEM_ID = '"+itemID+"'");
				if(rs.next())
				{	
					String campusID = rs.getString("CAMPUS_ID").trim();
					String labID = rs.getString("LAB_ID").trim();
					String containerCode = rs.getString("CONTAINER_CODE").trim();
					String categoryID = rs.getString("CATEGORY_ID").trim();
					
					barcodeID = campusID + labID + containerCode + categoryID + itemID;
					barcodeID = barcodeID.toUpperCase();
				}
			}
			catch(Exception e)
			{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
				
	    	request.setAttribute("valid", "1");
	    	messages.put("barcodeID",barcodeID);
	    	messages.put("barcodeItemID",itemID);
	    	request.getRequestDispatcher("/jsp/task/admin/ItemBarcodePrint/ItemBarcode.jsp").forward(request, response);
	    }
	    
	    try
		{
			conn.close();
		}
		catch(Exception e)
		{
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}	
	}

}
