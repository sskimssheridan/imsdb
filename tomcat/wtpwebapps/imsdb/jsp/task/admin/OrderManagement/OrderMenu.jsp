<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Order IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
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
			<h4>You are logged in as Administrator / Technician</h4>
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
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_OrderPlace" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Place Order">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_OrderSearch" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Order">
						</form>
					</td>
				</tr>
				<% 
					if(session.getAttribute("role").equals("ADMINISTRATOR"))
					{
				%>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_OrderPending" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Pending Order">
						</form>
					</td>
				</tr>
				<% 
					}
				%>
			</table>
		</td>
		<!-- <td id = "workingBar" colspan="3">
			Area for displaying information
		</td>  -->
	</tr>
</table>
</body>
</html>