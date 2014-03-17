<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Item Return IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.price_format.1.8.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.elevatezoom.js"></script>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
	
	<script type="text/javascript">
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
		<td colspan="4">
			<h4>You are in Return Item Form</h4>
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
						<form action="${pageContext.request.contextPath}/Item_Search" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Item">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Booked" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Items on Hold">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Checkout" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Checkout Item">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Add" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Add Item">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Modify" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Modify Item">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Delete" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Delete Item">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<form method="post" action="${pageContext.request.contextPath}/Item_Return_Servlet">
				<table>
				<colgroup>
				    <col width="25%">
				    <col width="25%">
				    <col width="25%">
				    <col width="25%">
				</colgroup>
					<tr>
						<td colspan="4">
							<h3>ITEM RETURN FORM</h3>
							<h4>Fields marked with an <span class="required">*</span> are required.</h4>
							You can scan an ITEM Bar code or type in ITEM ID manually.
						</td>
					</tr>
					<tr>
						<td colspan="2" class="field">
							USER ID : <span class="required">*</span>
						</td>
						<td colspan="2">
							<input type="text" name="userID" id="userID" value="${param.userID}" />
							<br/>
							<span class="error">${messages.userID}</span>
						</td>
					</tr>
					<tr>
						<td colspan="2" class="field">
							ITEM ID : <span class="required">*</span>
						</td>
						<td colspan="2">
							<input type="text" name="itemID" id="itemID" value="${param.itemID}" />
							<br/>
							<span class="error">${messages.itemID}</span>
						</td>
					</tr>
					<tr>
						<td colspan="2" class="field">
							DATE OF RETURN :
						</td>
						<td colspan="2">
							<% 
								DateFormat dateFormat = new SimpleDateFormat("dd-MMM-yy");
								Date date = new Date();
							%>
							<%= dateFormat.format(date) %>
						</td>
					</tr>
					<tr>
						<td colspan="2" class="field">
							QUANTITY RETURNED : <span class="required">*</span> 
						</td>
						<td colspan="2">
							<input type="text" name="returnQuantity" id="returnQuantity" value="0" size="5" maxlength="3" onkeypress='validate(event)' />
							<sub>999 Max</sub>
							<br/>
							<span class="error">${messages.quantity}</span>
						</td>
					</tr>
					<tr>
						<td colspan="2" class="field">
							STATE OF RETURN : <span class="required">*</span> 
						</td>
						<td colspan="2">
							<select name="state" id="state">
								<option value="N">NORMAL</option>
								<option value="D">DAMAGED</option>
							</select>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<input id="submit" name="act" type="submit" class="btnSubmit" value="Return Item">
						</td>
					</tr>
					<%
						String valid = request.getAttribute("valid") != null ? request.getAttribute("valid").toString() : "";
						//for errors
						if(valid != null && valid.trim().equals("1"))
						{
					%>
					<tr>
						<td colspan="4">
							<span class="error">
							<strong>ERROR:</strong>
							<br/>
							${messages.error}
							</span>
						</td>
					</tr>
					<%
						}
						//for successfully returned item
						else if(valid != null && valid.trim().equals("2"))
						{
					%>
					<tr>
						<td colspan="4">
							<span class="error">
							<strong>SUCCESSFUL:</strong>
							<br/>
							${messages.returned}
							</span>
						</td>
					</tr>
					<script>
						document.getElementById('userID').value='';
						document.getElementById('itemID').value='';
						document.getElementById('returnQuantity').value='0';
					</script>
					<% 
						}
					%>
				</table>
			</form>
		</td>
	</tr>
</table>
</body>
</html>