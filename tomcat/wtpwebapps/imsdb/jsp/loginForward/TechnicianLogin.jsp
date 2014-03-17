<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Administrator IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/FeedCSS.css"/>
	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/FeedEk.js"></script>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !session.getAttribute("role").equals("TECHNICIAN"))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
	<script type="text/javascript" >
    $(document).ready(function () {  
        $('#divSheridanRss').FeedEk({
            FeedUrl: 'http://sheridanlibraryservicesnews.wordpress.com/feed/',
            MaxCount: 10
        });
    });
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
		<td id="role" colspan="4">
			<h4>You are logged in as Technician</h4>
		</td>
	</tr>
	<tr>
		<td id = "menuBar" colspan="1">
			<table>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_InvManagement" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Inventory Management">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_AccManagement" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Account Management">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_OrderManagement" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Order Management">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_SupplierManagement" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Supplier Management">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_Alerts" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Alerts">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_ItemBarcode" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Item Barcode">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<p><h3>SHERIDAN LIBRARY BLOG top 10 NEWS</h3><p/>
			<div id="divSheridanRss"></div>
		</td>
	</tr>
</table>
</body>
</html>