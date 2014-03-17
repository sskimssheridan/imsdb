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

public class LoginServlet extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	
	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
	private ResultSet rs = null;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		//creating session variable
		HttpSession session = request.getSession(false);
		/*creating database connection variables*/
		
		Map<String, String> messages = new HashMap<String, String>();
	    request.setAttribute("messages", messages);
	    
	    //getting parameter value from login form
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String sessionRole = null;
		
		//checking if the credentials are submitted with an error
		//creating boolean variable for login error check
		boolean loginError = false;
		//checking username
		if (username == null || username.trim().isEmpty()) 
		{
	        messages.put("username", "Please enter User ID");
	        loginError = true;
	    }
		//checking password
	    if (password == null || password.trim().isEmpty())
	    {
	        messages.put("password", "Please enter Password");
	        loginError = true;
	    }
	    else if (password.length() > 15)
	    {
	    	messages.put("password", "Password must be below 15 characters");
	        loginError = true;
	    }
	    //sending request back to login index page if login error is true
	    //or perform actions if no login error is encountered
	    if(loginError)
	    {
	    	request.getRequestDispatcher("/index.jsp").forward(request, response);
	    }
	    else
	    {
	    	//creating session attributes
	    	if(session == null)
	    	{
	    		session = request.getSession(true);
	    	}
	    	session.setAttribute("username", username);
	    	//connecting with the database
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
				System.out.println("Error occured :"+ e);
			}
			
	    	//capturing login as
	    	String loginAs = request.getParameter("loginAs").trim();
	    	//checking for student or technician login
	    	if (loginAs.equals("student"))
	    	{
	    		sessionRole = "STUDENT";
	    		session.setAttribute("role", sessionRole);
	    		//validating student
	    		try
	    		{
	    			rs = st.executeQuery("SELECT * FROM STUDENT WHERE STUDENT_ID = '"+username+"' AND PASSWORD = '"+password+"'");
	    			int count = 0;
		    		String name = null;
		    		while(rs.next())
		    		{
		    			//checking for number of users and getting student name
		    			name = rs.getString("SNAME").toUpperCase();
		    			count++;
		    		}
		    		if(count == 1)
		    		{
		    			session.setAttribute("name", name);
		    			request.getRequestDispatcher("jsp/loginForward/StudentLogin.jsp").forward(request, response);
		    		}
		    		else
		    		{
		    			session.setAttribute("error", "Invalid Login please contact administrator");
		    			request.getRequestDispatcher("jsp/loginForward/ErrorLogin.jsp").forward(request, response);
		    		}
	    		}
	    		catch(Exception e)
	    		{
	    			System.out.println("Error occured :"+ e);
	    		}
	    	}
	    	else if(loginAs.equals("employee"))
	    	{
	    		//validating employee
	    		try
	    		{
	    			rs = st.executeQuery("SELECT * FROM EMPLOYEE WHERE EMPLOYEE_ID = '"+username+"' AND PASSWORD = '"+password+"'");
	    			int count = 0;
		    		String name = null;
		    		String role = null;
		    		while(rs.next())
		    		{
		    			//checking for number of users and getting employee name and role
		    			name = rs.getString("ENAME").toUpperCase();
		    			role = rs.getString("EROLE").toUpperCase();
		    			count++;
		    		}
		    		if(count == 1)
		    		{
		    			//setting name 
		    			session.setAttribute("name", name);
		    			sessionRole = role;
		    			session.setAttribute("role", sessionRole);
		    			if(role.equals("TECHNICIAN"))
		    			{
		    				request.getRequestDispatcher("jsp/loginForward/TechnicianLogin.jsp").forward(request, response);
		    			}
		    			else if(role.equals("ADMINISTRATOR"))
		    			{
		    				request.getRequestDispatcher("jsp/loginForward/AdminLogin.jsp").forward(request, response);
		    			}
		    			else if(role.equals("FACULTY"))
		    			{
		    				request.getRequestDispatcher("jsp/loginForward/FacultyLogin.jsp").forward(request, response);
		    			}
		    			else
		    			{
		    				session.setAttribute("error", "Invalid Login please contact administrator");
			    			request.getRequestDispatcher("jsp/loginForward/ErrorLogin.jsp").forward(request, response);
		    			}
		    		}
		    		else
		    		{
		    			session.setAttribute("error", "Invalid Login please contact administrator");
		    			request.getRequestDispatcher("jsp/loginForward/ErrorLogin.jsp").forward(request, response);
		    		}
	    		}
	    		catch(Exception e)
	    		{
	    			System.out.println("Error occured :"+ e);
	    		}
	    	}
	    	//closing connection
	    	try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    }   
	}
}
