<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Item on Hold IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.price_format.1.8.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.elevatezoom.js"></script>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("STUDENT")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
	<script>
	$(document).ready(function(){
		//for image zooming
		$(".itemImage").elevateZoom();

	})
	</script>
</head>
<body>
<table id="mainView">
<colgroup>
    <col width="25%">
    <col width="25%">
    <col width="25%">
    <col width="25%">
</colgroup>
	<tr>
		<td id = "logoBar" colspan="3">
			<img src="${pageContext.request.contextPath}/images/Sheridan_College_Logo.jpg" height="75">
		</td>
		<td id = "welcomeMsg" colspan="1">	
			Welcome ${sessionScope.name}
			<br/>
			<% // setting date format and Displaying it
				java.text.DateFormat df = new java.text.SimpleDateFormat("EEE, MMM d, YYYY h:mm a");
			%> 
			<%= df.format(new java.util.Date()) %>
			<form action="${pageContext.request.contextPath}/LogoutServlet" method="post">
				<input id="submit" type="submit" class="btnLogout" value="Logout">
			</form>
		</td>
	</tr>
	<tr>
		<td colspan="4">
			<h4>Items put on hold by you</h4>
		</td>
	</tr>
	<tr>
		<td id = "menuBar" colspan="1">
			<table>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Student_BackToMain" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Back To Main">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Student_Item_Search" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Item">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<form method="post" action="${pageContext.request.contextPath}/Student_Item_Booked_Servlet">
			<table>
			<!-- Connecting to the database -->
			<%
				Context initContext;
				Context envContext;
				DataSource ds = null;
				Connection conn = null;
				Statement st = null;
				Statement st1 = null;
				ResultSet rs = null;
				ResultSet rsSub = null;
				ResultSet rsSub1 = null;
				
				try
				{
					initContext = new InitialContext();
					envContext  = (Context)initContext.lookup("java:/comp/env");
					ds = (DataSource)envContext.lookup("jdbc/myoracle");
					conn = ds.getConnection();
					st = conn.createStatement();
					st1 = conn.createStatement();
					
				}
				catch(Exception e)
				{
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
				//deleting data from ITEM_HOLD Table older than 1 days
				try
				{
					conn.setAutoCommit(false);
					st.executeUpdate("DELETE FROM ITEM_HOLD WHERE DATE_OF_HOLD <= systimestamp - INTERVAL '1 00:00:00.0' DAY TO SECOND(1)");
					conn.commit();
				}
				catch(Exception e)
				{
					if(conn != null)
		    		{
		    			try {
							conn.rollback();
						} catch (SQLException e1) {
							// TODO Auto-generated catch block
							request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
						}
		    		}
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			%>
			
			<colgroup>
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			</colgroup>
			<%
				String userID = session.getAttribute("username").toString().trim().toUpperCase();
				try
				{
					rs = st.executeQuery("SELECT * FROM ITEM_HOLD WHERE USER_ID = '"+userID+"' ORDER BY DATE_OF_HOLD");
					
					if(!rs.isBeforeFirst())
					{
			%>
			<tr>
				<td colspan="4">
					<span class="error">
						No Records Found
					</span>
				</td>
			</tr>
			<% 		
					}
					else
					{
						while(rs.next())
						{
							String itemID = rs.getString("ITEM_ID");
							String barcodeID = "";
							
							String dateOfHold = rs.getString("DATE_OF_HOLD");
							String quantity = String.valueOf(rs.getInt("QUANTITY_HOLD"));
							rsSub = st1.executeQuery("SELECT * FROM ITEM WHERE ITEM_ID = '"+itemID+"'");
							if(rsSub.next())
							{
								String campusID = rsSub.getString("CAMPUS_ID").trim();
								String labID = rsSub.getString("LAB_ID").trim();
								String containerCode = rsSub.getString("CONTAINER_CODE").trim();
								String categoryID = rsSub.getString("CATEGORY_ID").trim();
								
								barcodeID = campusID + labID + containerCode + categoryID + itemID;
						
			%>
			<tr class="itemBookedRows">
				<td>
					<table width="100%" border="1">
					<colgroup>
					    <col width="35%">
					    <col width="25%">
					    <col width="40%">
					</colgroup>
					<tr>
						<td>
							<div id="imageItem">
								<img class="itemImage" 
								src="${pageContext.request.contextPath}/ItemDisplay_ItemCreated?itemID=<%= itemID %>" 
								width="90" height="90" alt="no image" onerror="this.src='${pageContext.request.contextPath}/images/no-photo.jpg';"/>
							</div>
						</td>
						<td colspan="2"  class="field">
							<%= barcodeID %>
						</td>
					</tr>
					<tr>
						<td class="field">
							DATE OF HOLD :
						</td>
						<td colspan="2">
							<%= dateOfHold.trim() %>
						</td>
					</tr>
					<tr>
						<td class="field">
							QUANTITY HOLDED :
						</td>
						<td colspan="2">
							<%= quantity.trim() %>
						</td>
					</tr>
					<tr>
						<td class="field">
							CAMPUS :
						</td>
						<td colspan="2">
							<%
								rsSub1 = st1.executeQuery("SELECT * FROM CAMPUS WHERE CAMPUS_ID ='"+campusID+"'");
								if (rsSub1.next())
								{%>
									<%= rsSub1.getString("CNAME").trim() %>
								<%}
							%>
						</td>
					</tr>
					<tr>
						<td class="field">
							CATEGORY :
						</td>
						<td colspan="2">
							<%
								rsSub1 = st1.executeQuery("SELECT * FROM CATEGORY WHERE CATEGORY_ID ='"+categoryID+"'");
								if (rsSub1.next())
								{%>
									<%= rsSub1.getString("CATEGORY_TYPE").trim() %>
								<%}
							%>
						</td>
					</tr>
					<tr>
						<td class="field">
							CONTAINER :
						</td>
						<td colspan="2">
							<%=  containerCode %>
						</td>
					</tr>
					<tr>
						<td colspan="3">
							<button id="deleteBookedItem" name="act" type="submit" class="btnSubmit" value="<%= itemID %>">Delete My Hold</button>
						</td>
					</tr>
					</table>
				</td>
			</tr>
			<% 		
							}
						}
					}
				}
				catch(Exception e)
				{
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			%>
			<% 
				try
				{
					conn.close();
				}
				catch(Exception e)
				{
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}		
			%>
			</table>
			</form>
		</td>
	</tr>
</table>
</body>
</html>