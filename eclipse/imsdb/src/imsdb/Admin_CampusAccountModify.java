package imsdb;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
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

public class Admin_CampusAccountModify extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		HttpSession session = request.getSession(false);
		Context initContext;
		Context envContext;
		DataSource ds = null;
		Connection conn = null;
		PreparedStatement ps = null;
		Map<String, String> messages = new HashMap<String, String>();
	    request.setAttribute("messages", messages);
    
	    boolean loginError = false;  
		int i =0;
		String campusId, name, location;
		try
		{
			initContext = new InitialContext();
			envContext  = (Context)initContext.lookup("java:/comp/env");
			ds = (DataSource)envContext.lookup("jdbc/myoracle");
			conn = ds.getConnection();
		}
		catch(Exception e)
		{
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}

		name = request.getParameter("name");
		campusId = request.getParameter("campusId");
		location = request.getParameter("location");	
		
		if(location == null || location.trim().isEmpty()){
			messages.put("location", "Please enter Campus Location");
	        loginError  = true;
		}

		if(name == null || name.trim().isEmpty()){
			messages.put("name", "Please enter Campus Name");
	        loginError  = true;
		}
		
					
		if(loginError)
	    {
		
			request.setAttribute("name", name);
			request.setAttribute("campusId", campusId);
			request.setAttribute("location", location);
			request.setAttribute("valid_employee_id", "1");
			session.setAttribute("returning_with_error", "YES");
			request.getRequestDispatcher("/jsp/task/Campus/ModifyCampus.jsp").forward(request, response);
	    }
		else{
		
			try {
				conn.setAutoCommit(false);
				ps = conn.prepareStatement("UPDATE CAMPUS SET CNAME ='"+name.trim().toUpperCase() +"', CAMPUS_LOCATION ='"+location.trim().toUpperCase()+"' WHERE CAMPUS_ID ='"+campusId.trim()+"'");
				i = ps.executeUpdate();
			
				
			} catch (SQLException e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
			
			try
	 	    {
	    		conn.commit();
	    		if(i==1){
	    			
					request.setAttribute("Update_result", "1");
					request.removeAttribute("name");
					request.removeAttribute("campusId");
					request.removeAttribute("locations");
					request.removeAttribute("valid_employee_id");
					session.removeAttribute("returning_with_error");
				}
				else{
					request.setAttribute("Update_result", "0");
				}
	    		request.getRequestDispatcher("/jsp/task/Campus/ModifyCampus.jsp").forward(request, response);
	 	    }
	    	catch(Exception e)
	 	    {
	    		// TODO Auto-generated catch block
	    		if(conn != null)
	    		{
	    			try {
						conn.rollback();
					} catch (SQLException e1) {
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
	
	    		}
	    		request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
	 	    }
		}
		 //closing connection
	    try {
			conn.close();
		} catch (SQLException e) {
			request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
		}
	}
}
