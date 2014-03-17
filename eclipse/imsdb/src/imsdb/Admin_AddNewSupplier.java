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


public class Admin_AddNewSupplier extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Context initContext, envContext;
	private DataSource ds = null;
	private Connection conn = null;
	private Statement st = null;
	private ResultSet rs = null;

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

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
		/* creating database connection variables */

		Map<String, String> messages = new HashMap<String, String>();
		request.setAttribute("messages", messages);

		// getting parameter value from login form
		// String SupplierID = request.getParameter("SupplierID");
		String SupplierName = request.getParameter("SupplierName");
		String Phone = request.getParameter("Phone");
		String Email = request.getParameter("Email");
		String Address = request.getParameter("Address");
		String supplierID = null;
		String toSearchName = null;

		// checking if the credentials are submitted with an error
		// creating boolean variable for login error check
		boolean loginError = false;

		// checking SupplierName
		if (SupplierName == null || SupplierName.trim().isEmpty()) {
			messages.put("SupplierName", "Please enter Supplier Name");
			loginError = true;
		} else {
			// checking if supplier is already a supplier
			try {
				// extracting ITEM_ID from the string
				toSearchName = SupplierName.trim().toUpperCase();

				rs = st.executeQuery("SELECT SNAME FROM SUPPLIER WHERE SNAME ='"
						+ toSearchName + "'");
				if (rs.isBeforeFirst()) {
					
						messages.put("SupplierName","<strong>'" + SupplierName.trim()+ "'</strong> already Exists");
						loginError = true;
				}
			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}

		// checking Address
		if (Address == null || Address.trim().isEmpty()) {
			messages.put("Address", "Please enter Supplier Address");
			loginError = true;
		}
		// checking Phone
		if (Phone == null || Phone.trim().isEmpty()) {
			messages.put("Phone", "Please enter Supplier Phone Number");
			loginError = true;
		}
		else if (Phone.length() < 10 )
		{
			messages.put("Phone", "Phone number must be 10 digits long");
			loginError = true;
		}
		// checking Email
		if (Email == null || Email.trim().isEmpty()) {
			messages.put("Email", "Please enter Supplier Email Address");
			loginError = true;
		} else {
			try {
				String emailreg = "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$";
				Boolean b = Email.matches(emailreg);

				if (b == false) {
					messages.put("Email", "Please enter valid Email Address");
					loginError = true;
				} 
			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}
		}

		if (loginError) {
			request.getRequestDispatcher("/jsp/task/Supplier/AddSupplier.jsp")
					.forward(request, response);
		} else {

			try {

				rs = st.executeQuery("SELECT * FROM SUPPLIER S WHERE S.SNAME = '"
						+ SupplierName.trim().toUpperCase()
						+ "' AND "
						+ "S.PHONE = '"
						+ Phone.trim().toUpperCase()
						+ "' AND "
						+ "S.EMAIL = '"
						+ Email.trim().toUpperCase()
						+ "' AND "
						+ "S.ADDRESS = '" + Address.trim().toUpperCase() + "'");

				if (!rs.isBeforeFirst()) {
					// getting item ID from the database and incrementing it by
					// 1
					try {
						int intItemID = 0;
						int count = 0;
						rs = st.executeQuery("SELECT to_number(SUPPLIER_ID) AS SUPPLIER_ID FROM SUPPLIER ORDER BY SUPPLIER_ID");
						while (rs.next()) {
							count++;
							int idInDataBase = Integer.parseInt(rs.getString(
									"SUPPLIER_ID").trim());

							if (idInDataBase != count) {
								intItemID = count - 1;
								break;
							}
							intItemID = count;
						}

						String leadingZero = "";
						for (int i = 1; i <= 6 - String.valueOf(intItemID + 1)
								.length(); i++) {
							leadingZero += "0";
						}
						supplierID = leadingZero
								+ String.valueOf(intItemID + 1);
						
					} catch (Exception e) {
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}

					try {
						
						rs = st.executeQuery("SELECT * FROM SUPPLIER WHERE SNAME = '"+SupplierName.trim().toUpperCase()+"'");
						
						if(rs.isBeforeFirst())
						{
							request.setAttribute("RESULT", "2");
							request.getRequestDispatcher(
									"/jsp/task/Supplier/AddSupplier.jsp").forward(
									request, response);
						}
						else
						{
							conn.setAutoCommit(false);
							String query = "INSERT INTO SUPPLIER (SUPPLIER_ID, SNAME, PHONE, EMAIL, ADDRESS) "
									+ "VALUES ('"
									+ supplierID.trim().toUpperCase()
									+ "', '"
									+ SupplierName.trim().toUpperCase()
									+ "', '"
									+ Phone.trim().toUpperCase()
									+ "', '"
									+ Email.trim().toUpperCase()
									+ "', '"
									+ Address.trim().toUpperCase() + "')";
							PreparedStatement prstm = null;
							prstm = conn.prepareStatement(query);
							prstm.executeUpdate();
							conn.commit();
							request.setAttribute("RESULT", "1");
							request.getRequestDispatcher(
									"/jsp/task/Supplier/AddSupplier.jsp").forward(
									request, response);
						}
					} catch (Exception e) {
						// TODO Auto-generated catch block
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
				else {
					request.setAttribute("RESULT", "2");
					request.getRequestDispatcher(
							"/jsp/task/Supplier/AddSupplier.jsp").forward(
							request, response);
				}
			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
			}

		}
	}

}
