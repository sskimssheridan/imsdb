package imsdb;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Admin_OrderSearch_Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		
		request.setAttribute("valid", "1");
		request.getRequestDispatcher("/jsp/task/order/OrderSearch.jsp").forward(request, response);
		
	}

}
