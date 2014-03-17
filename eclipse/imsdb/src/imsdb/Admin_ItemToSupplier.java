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

public class Admin_ItemToSupplier extends HttpServlet {
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

		String[] supplierItem = request.getParameterValues("supplierItem");

		String SupplierName = request.getParameter("SupplierID");

		//System.out.println(SupplierName);
		// checking if the credentials are submitted with an error
		// creating boolean variable for login error check
		boolean loginError = false;
		for (int i = 0; i < supplierItem.length; i++) {

			// checking Item ID
			if (supplierItem[i] == null || supplierItem[i].trim().isEmpty()) {

				messages.put("supplierItem", "Please enter ITEM ID");

				loginError = true;
			}

			else {

				//System.out.println(supplierItem[i]);

				// checking if items in the machinery item fields is not an item
				try {

					// extracting ITEM_ID from the string
					String toSearchID = supplierItem[i].trim().substring(
							Math.max(0, supplierItem[i].trim().length() - 6));

					rs = st.executeQuery("SELECT ITEM_ID FROM ITEM WHERE ITEM_ID ='"
							+ toSearchID + "'");

					if (!rs.isBeforeFirst()) {
						messages.put("supplierItem",
								"ITEM ID must be an ITEM, <strong>'"
										+ supplierItem[i].trim().toUpperCase()
										+ "'</strong> is not an ITEM");

						loginError = true;
					}
				}

				catch (Exception e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			}

		}

		if (loginError) {
			request.getRequestDispatcher(
					"/jsp/task/Supplier/AddItemtoSupplier.jsp").forward(
					request, response);
		} else {

			try {
				for (int i = 0; i < supplierItem.length; i++) {
					// extracting ITEM_ID from the string
					 String insertID = supplierItem[i].trim().toUpperCase().substring(
							Math.max(0, supplierItem[i].trim().length() - 6));

					rs = st.executeQuery("SELECT * FROM SUPPLIER_ITEM WHERE ITEM_ID = '"
							+ insertID
							+ "' AND "
							+ "SUPPLIER_ID = '"
							+ SupplierName.trim().toUpperCase() + "'");
					if (rs.next()) {
						//System.out
								//.println("this item was already set for this supplier in the database");
					} else {

						conn.setAutoCommit(false);
						String query = "INSERT INTO SUPPLIER_ITEM (ITEM_ID, SUPPLIER_ID) "
								+ "VALUES ('"
								+ insertID
								+ "', '"
								+ SupplierName.trim().toUpperCase() + "')";
						PreparedStatement prstm = null;
						prstm = conn.prepareStatement(query);
						prstm.executeUpdate();
						//System.out.println("SUPPLIER_ITEM was added");
					}
				}

				conn.commit();
				request.setAttribute("RESULT", "1");
				request.getRequestDispatcher(
						"/jsp/task/Supplier/AddItemtoSupplier.jsp").forward(
						request, response);
			} catch (Exception e) {
				request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				// TODO Auto-generated catch block
				if (conn != null) {
					try {
						conn.rollback();
					} catch (SQLException e1) {
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
				}
			}
		}
	}
}
