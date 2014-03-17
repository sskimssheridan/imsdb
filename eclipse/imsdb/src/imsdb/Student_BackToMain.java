package imsdb;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class Student_BackToMain extends HttpServlet {
	private static final long serialVersionUID = 1L;
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		//creating session variable
		HttpSession session = request.getSession(false);
		
		String role = session.getAttribute("role").toString();
		
		if(role.toUpperCase().equals("STUDENT"))
		{
			request.getRequestDispatcher("jsp/loginForward/StudentLogin.jsp").forward(request, response);
		}
		else
		{
			session.invalidate();
			request.getRequestDispatcher("index.jsp").forward(request, response);
		}
	}
}