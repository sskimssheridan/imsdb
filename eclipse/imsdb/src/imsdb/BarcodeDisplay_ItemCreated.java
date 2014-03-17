package imsdb;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;


public class BarcodeDisplay_ItemCreated extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		Context initContext;
		Context envContext;
		DataSource ds = null;
		Connection conn = null;
		Statement st = null;
		try
		{
			initContext = new InitialContext();
			envContext  = (Context)initContext.lookup("java:/comp/env");
			ds = (DataSource)envContext.lookup("jdbc/myoracle");
			conn = ds.getConnection();
			st = conn.createStatement();
			
			Blob image1 = null;
			byte[] imgData = null;
			String itemID = request.getParameter("itemID");
			itemID = itemID.substring(Math.max(0, itemID.trim().length() - 6));
			
			ResultSet rsSuper = st.executeQuery("SELECT BARCODE FROM ITEM WHERE ITEM_ID = '"+itemID+"'");

			if (rsSuper.next()) 
			{
				image1 = rsSuper.getBlob(1);
				imgData = image1.getBytes(1, (int) image1.length());
				response.setContentType("image/gif");
				OutputStream o = response.getOutputStream();
				o.write(imgData);
				o.flush();
				o.close();
			}
			/*else
			{
				PrintWriter out = response.getWriter();
			    out.println("No Image");
			}*/
			conn.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}	
	}
}
