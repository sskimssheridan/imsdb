package imsdb;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
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

public class Admin_AddNewCampus extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
	private ResultSet rsSub = null;

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		/* creating database connection variables */

		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		// getting parameter value from login form
		String CampusID = request.getParameter("CampusID");
		String CampusName = request.getParameter("CampusName");

		String CampusLocation = request.getParameter("CampusLocation");

		// checking if the credentials are submitted with an error
		// creating boolean variable for login error check
		boolean loginError = false;

		// checking CampusID
		if (CampusID == null || CampusID.trim().isEmpty()) {
			messages.put("CampusID", "Please enter Campus ID");
			loginError = true;
		}
		else
		{
			try
			{
				//extracting ITEM_ID from the string
				String toSearchID = CampusID.trim().toUpperCase();
			
				 rsSub = st.executeQuery("SELECT CAMPUS_ID FROM CAMPUS WHERE CAMPUS_ID ='"+ toSearchID +"'");
					if(rsSub.next()) 
					{    
						String empname = rsSub.getString("CAMPUS_ID");
						if(empname.equals(""))
						{
						 //System.out.println("user name is null - so can insert student");	
						}
						else
						{
						messages.put("CampusID", "<strong>'"+CampusID.trim().toUpperCase()+"'</strong> is already a Campus!");
						loginError = true;
						}
					
					}
			}
			catch(Exception e)
    		{
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
    		}
		}
		// checking Campus Name
		if (CampusName == null || CampusName.trim().isEmpty()) {
			messages.put("CampusName", "Please enter Campus Name");
			loginError = true;
		}
		// checking Campus Location
		if (CampusLocation == null || CampusLocation.trim().isEmpty()) {
			messages.put("CampusLocation", "Please enter Campus Location");
			loginError = true;
		}

		if (loginError) {
			request.getRequestDispatcher("/jsp/task/Campus/AddCampus.jsp")
					.forward(request, response);
		} else {
			// connecting with the database
			try {
				initContext = new InitialContext();
				envContext = (Context) initContext.lookup("java:/comp/env");
				ds = (DataSource) envContext.lookup("jdbc/myoracle");
				conn = ds.getConnection();
				st = conn.createStatement();
			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}

			try {

				conn.setAutoCommit(false);
				String query = "INSERT INTO CAMPUS (CAMPUS_ID, CNAME, CAMPUS_LOCATION) "
						+ "VALUES ('"
						+ CampusID.trim().toUpperCase()
						+ "', '"
						+ CampusName.trim().toUpperCase()
						+ "', '"
						+ CampusLocation.trim().toUpperCase() + "')";
				PreparedStatement prstm = null;
				prstm = conn.prepareStatement(query);
				prstm.executeUpdate();
				System.out.println("campus was added");

			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
			// removing session variables
			try {
				conn.commit();
				request.setAttribute("RESULT", "1");
				request.getRequestDispatcher("/jsp/task/Campus/AddCampus.jsp")
						.forward(request, response);
			} catch (Exception e) {
				if (conn != null) {
					try {
						conn.rollback();
					} catch (SQLException e1) {
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
				}
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}
	}

}
