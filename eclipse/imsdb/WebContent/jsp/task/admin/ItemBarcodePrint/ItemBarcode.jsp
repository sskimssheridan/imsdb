<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Item Barcode IMSDB</title>
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
	
	<style type="text/css" >
    @media print 
    {
	    #barcodeImage
	    {
	        background-color: white;
	        height: 100%;
	        width: 100%;
	        position: fixed;
	        top: 0;
	        left: 0;
	        margin: 0;
	        padding: 15px;
	    }
	}
	@page 
    {
        size: auto;   
        margin: 0mm;  
    }
    </style>
	<style type='text/css' media='print'>
	
	body {visibility: hidden;}
	#barcodeImage {visibility: visible; text-align:left;}
	
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
			<h4>Item Barcode Print</h4>
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
			<form method="post" action="${pageContext.request.contextPath}/Admin_ItemBarcode_Servlet">
			<table>
			<colgroup>
			    <col width="45%">
			    <col width="30%">
			    <col width="25%">
			</colgroup>
			<!-- Connecting to the database -->
			<%
				Context initContext;
				Context envContext;
				DataSource ds = null;
				Connection conn = null;
				Statement st = null;
				ResultSet rs = null;
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
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
			%>
				<tr>
					<td colspan="3">
						<h3>ITEM BARCODE FORM</h3>
						<h4>Fields marked with an <span class="required">*</span> are required.</h4>
						Please select the Item from the drop down list.
					</td>
				</tr>
				<tr>
					<td colspan="1" class="field">
						ITEM ID : <span class="required">*</span>
					</td>
					<td colspan="2">
						<select id="displayBarcodeID" name="displayBarcodeID">
							<option value="-1">SELECT</option>
						<%
						try
						{
							rs = st.executeQuery("SELECT * FROM ITEM ORDER BY ITEM_ID");
							while(rs.next())
							{
								String itemID = rs.getString("ITEM_ID").trim();
								String barcodeID = null;
					
								String campusID = rs.getString("CAMPUS_ID").trim();
								String labID = rs.getString("LAB_ID").trim();
								String containerCode = rs.getString("CONTAINER_CODE").trim();
								String categoryID = rs.getString("CATEGORY_ID").trim();
								
								barcodeID = campusID + labID + containerCode + categoryID + itemID;
								barcodeID = barcodeID.toUpperCase();
								
						%>
							<option value="<%= itemID%>"><%= barcodeID %></option>
						<% 
							}
						}
						catch(Exception e)
						{
							request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
						}
						%>
						</select>
						<br/>
						<span class="error">${messages.displayBarcodeID}</span>
					</td>
				</tr>
				<tr>
					<td>
						<input type="submit" class="btnSubmit" value='Render Barcode'/>
					</td>
				</tr>
			<!-- Closing database connection-->	
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
			<% 
				String valid = request.getAttribute("valid") != null ? request.getAttribute("valid").toString() : "";
				if(valid != null && valid.trim().equals("1"))
				{
			%>
				<table>
				<tr>
					<td>
						<h4>DISPLAYING BARCODE FOR ITEM: ${messages.barcodeID}</h4>
					</td>
				</tr>
				<tr>
					<td>
						<div id="barcodeImage">
							<img src="${pageContext.request.contextPath}/BarcodeDisplay_ItemCreated?itemID=${messages.barcodeItemID}" alt="no image"/>
						</div>
						<br/>
					</td>
				</tr>
				<tr>
					<td>
						<input type='button' class="btnSubmit" value='Print Barcode' onclick='window.print()'/>
					</td>
				</tr>
				</table>
			<%
				}
			%>
		</td>
	</tr>
</table>
</body>
</html>