<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Administrator Inventory IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
<script>
//validating number field
function validate(evt)
{
	var theEvent = evt || window.event;
	var key = theEvent.keyCode || theEvent.which;
	key = String.fromCharCode( key );
	var regex = /[0-9]/;
	if( !regex.test(key) )
	{
		theEvent.returnValue = false;
		if(theEvent.preventDefault) theEvent.preventDefault();
	}
}
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
			<h4>You are in Add Supplier</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_SupplierModify" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Modify Supplier">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_AddItemToSupplier" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Supplier Items">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<h3>ADD NEW SUPPLIER FORM</h3>
			<h4>Fields marked with an <span class="required" >*</span> are required.</h4>
			<form action="${pageContext.request.contextPath}/Admin_AddNewSupplier" method="post">
			<table>
				<%
					if(request.getAttribute("RESULT") != null && request.getAttribute("RESULT").equals("1"))
					{
				%>
				<tr>
					<td colspan="3">
						<span class="error">
							Supplier Added Successfully 
						</span>
						<br/><br/>
					</td>
				</tr>
				<%
					}
					else if(request.getAttribute("RESULT") != null && request.getAttribute("RESULT").equals("2"))
					{
				%>
				<tr>
					<td colspan="3">
						<span class="error">
							Supplier Already Exists  
						</span>
						<br/><br/>
					</td>
				</tr>
				<%
					}
				%>
				<tr>
					<td class="field">SUPPLIER NAME: <span class="required" >*</span></td>
					<td>
						<input type="text" id="SupplierName" name="SupplierName" size="20" maxlength="30" value="${param.SupplierName}"/>
					</td>
					<td>
						<span class="error" >${messages.SupplierName}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">PHONE NUMBER: <span class="required" >*</span></td>
					<td>
						<input maxlength="10" type="text" id="Phone" name="Phone" size="20" value="${param.Phone}" onkeypress='validate(event)'/>
					</td>
					<td>
						<span class="error" >${messages.Phone}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">SUPPLIER EMAIL: <span class="required" >*</span></td>
					<td>
						<input type="text" id="Email" name="Email" size="20" maxlength="30" value="${param.Email}"/>
					</td>
					<td>
						<span class="error" >${messages.Email}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">SUPPLIER ADDRESS: <span class="required" >*</span></td>
					<td>
						<textarea id="Address" name="Address" cols="20" rows="3" maxlength="100" >${param.Address}</textarea>
					</td>
					<td>
						<span class="error" >${messages.Address}</span><br>
					</td>
				</tr>
				<tr>
					<td>
						<input id="submit" type="submit" class="btnSubmit" value="Add Supplier">
					</td>
					<td></td>
				</tr>	
			</table>
			</form>
		</td>
	</tr>
</table>
</body>
</html>