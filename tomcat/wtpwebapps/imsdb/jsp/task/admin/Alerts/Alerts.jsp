<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Alerts IMSDB</title>
	<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.elevatezoom.js"></script>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
	<script>
	  $(function() {
	    $( "#alertTabs" ).tabs();
	  });
	  
	  $(document).ready(function(){
			//for image zooming
			$(".itemImage").elevateZoom();

		});
	</script>
	
	<style type="text/css" media='print' >
	@page
    {
        size: auto;   /* auto is the initial value */
        margin: 0mm;  /* this affects the margin in the printer settings */
    }
	body {visibility: hidden;}
	h3
	{
		visibility: visible;
        position: fixed;
        top: 0;
	}
	.alertTables
	{
		border-collapse: separate;
		visibility: visible;
        position: relative;
        top: 0;
	}
	tr
	{
		page-break-inside:avoid;
		page-break-after:auto;
	}
	</style>
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
			<h4>Alerts </h4>
		</td>
	</tr>
	<tr>
		<td id = "menuBar" colspan="1">
			<table>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_BackToMain" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Back To Main">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<div id="alertTabs">
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
			%>
			  <ul>
			    <li><a href="#tabs-1">Item Quantity 0</a></li>
			    <li><a href="#tabs-2">Item Quantity Less</a></li>
			    <li><a href="#tabs-3">Items not Returned</a></li>
			  </ul>
			  <div id="tabs-1">
			  	<h3>Items with Quantity 0 (ZERO)</h3>
			  	<table class="alertTables" border="1">
			  	<colgroup>
				    <col width="35%">
				    <col width="25%">
				    <col width="40%">
				</colgroup>
			<%
			 	try
				{
				 	rs = st.executeQuery("SELECT * FROM ITEM WHERE QUANTITY = 0");
				 	if(!rs.isBeforeFirst())
				 	{
			%>
					<tr>
						<td colspan="3">
						 	<span class="error">
							<strong>
								No Alerts 
								<br/>
								No Items found with quantity 0 (ZERO)
							</strong>
							</span>
						</td>
					</tr>
			<%
				 	}
				 	else
				 	{
				 		while(rs.next())
				 		{
				 			String itemID = rs.getString("ITEM_ID").trim(); 
				 			String campusID = rs.getString("CAMPUS_ID").trim();
							String labID = rs.getString("LAB_ID").trim();
							String containerCode = rs.getString("CONTAINER_CODE").trim();
							String categoryID = rs.getString("CATEGORY_ID").trim();
							
							String barcodeID = campusID + labID + containerCode + categoryID + itemID;
			%>
					<tr>
						<td>
							<div id="imageItem">
								<img class="itemImage" 
								src="${pageContext.request.contextPath}/ItemDisplay_ItemCreated?itemID=<%= itemID %>" 
								width="90" height="90" alt="no image" onerror="this.src='${pageContext.request.contextPath}/images/no-photo.jpg';"/>
							</div>
						</td>
						<td colspan="2"  class="field">
							<%= barcodeID%>
						</td>
					</tr>
			<% 
				 		}
				 	}
				}
				catch(Exception e)
				{
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			%>
				</table>
			  </div>
			  <div id="tabs-2">
			    <h3>Items with Quantity less than Minimum Quantity</h3>
			  	<table class="alertTables" border="1">
			  	<colgroup>
				    <col width="35%">
				    <col width="25%">
				    <col width="40%">
				</colgroup>
			<%
			 	try
				{
				 	rs = st.executeQuery("SELECT * FROM ITEM WHERE QUANTITY < MIN_QUANTITY");
				 	if(!rs.isBeforeFirst())
				 	{
			%>
					<tr>
						<td colspan="3">
						 	<span class="error">
							<strong>
								No Alerts
								<br/>
								No Items are below their Minimum Quantity
							</strong>
							</span>
						</td>
					</tr>
			<%
				 	}
				 	else
				 	{
				 		while(rs.next())
				 		{
				 			String itemID = rs.getString("ITEM_ID").trim(); 
				 			String campusID = rs.getString("CAMPUS_ID").trim();
							String labID = rs.getString("LAB_ID").trim();
							String containerCode = rs.getString("CONTAINER_CODE").trim();
							String categoryID = rs.getString("CATEGORY_ID").trim();
							
							String barcodeID = campusID + labID + containerCode + categoryID + itemID;
			%>
					<tr>
						<td>
							<div id="imageItem">
								<img class="itemImage" 
								src="${pageContext.request.contextPath}/ItemDisplay_ItemCreated?itemID=<%= itemID %>" 
								width="90" height="90" alt="no image" onerror="this.src='${pageContext.request.contextPath}/images/no-photo.jpg';"/>
							</div>
						</td>
						<td colspan="2"  class="field">
							<%= barcodeID%>
						</td>
					</tr>
			<% 
				 		}
				 	}
				}
				catch(Exception e)
				{
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			%>
				</table>
			  </div>
			  <div id="tabs-3">
			        <h3>Items not returned by the user, rented a day ago</h3>
			  	<table class="alertTables" border="1">
			  	<colgroup>
				    <col width="35%">
				    <col width="25%">
				    <col width="40%">
				</colgroup>
			<%
			 	try
				{
				 	rs = st.executeQuery("SELECT * FROM ITEM_BORROW WHERE DATE_OF_RETURN IS NULL AND DATE_OF_BORROW <= (sysdate - 1) ORDER BY DATE_OF_BORROW");
				 	if(!rs.isBeforeFirst())
				 	{
			%>
					<tr>
						<td colspan="3">
						 	<span class="error">
							<strong>
								No Alerts
								<br/>
								All Items were returned by the Users who rented item a day ago
							</strong>
							</span>
						</td>
					</tr>
			<%
				 	}
				 	else
				 	{
				 		while(rs.next())
				 		{
				 			String itemID = rs.getString("ITEM_ID").trim(); 
				 			
				 			rsSub = st1.executeQuery("SELECT * FROM ITEM WHERE ITEM_ID = '"+itemID+"'");
				 			
				 			if(rsSub.next())
				 			{
					 			String campusID = rsSub.getString("CAMPUS_ID").trim();
								String labID = rsSub.getString("LAB_ID").trim();
								String containerCode = rsSub.getString("CONTAINER_CODE").trim();
								String categoryID = rsSub.getString("CATEGORY_ID").trim();
								
								String barcodeID = campusID + labID + containerCode + categoryID + itemID; 
								
								String borrowDate = rs.getDate("DATE_OF_BORROW").toString().trim();
					
								//converting date to dd-MMM-yy format
					    		SimpleDateFormat format10 = new SimpleDateFormat("yyyy-MM-dd");
					    	    SimpleDateFormat format20 = new SimpleDateFormat("dd-MMM-yy");
					    		
					            Date dateBor1 = format10.parse(borrowDate);
					           
					            borrowDate = format20.format(dateBor1);
			%>
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
							USER ID : 
						</td>
						<td colspan="2">
							<%= rs.getString("USER_ID") %>
						</td>
					</tr>
					<tr>
						<td class="field">
							DATE OF BORROW : 
						</td>
						<td colspan="2">
							<%= borrowDate %>
						</td>
					</tr>
					<tr>
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
				</table>
			  </div>
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
			</div>
		</td>
	</tr>
</table>
</body>
</html>