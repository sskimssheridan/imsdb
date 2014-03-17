<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Add Program IMSDB</title>
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
			<h4>You are in Add Program</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_SearchProgram" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Program">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_ProgramModify" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Modify Program">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<h3>ADD NEW PROGRAM</h3>
			<h4>Fields marked with an <span class="required" >*</span> are required.</h4>
			<form action="${pageContext.request.contextPath}/Admin_AddNewProgram" method="post">
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
			<table>
				<%
				if(request.getAttribute("RESULT") != null && request.getAttribute("RESULT").equals("1")){
					%>
				<tr>
					<td colspan="3">
						<span class="error">
							Program Added Successfully
						</span>
					</td>
				</tr>
					<%
				}
				if(request.getAttribute("RESULT") != null && request.getAttribute("RESULT").equals("2")){
					%>
				<tr>
					<td colspan="3">
						<span class="error">
							Program Already Exists
						</span>
					</td>
				</tr>
					<%
				}
				%>
				<tr>
					<td class="field">PROGRAM CODE: <span class="required" >*</span></td>
					<td>
						<input type="text" maxlength="5" id="ProgramCode" name="ProgramCode" size="20" value="${param.ProgramCode}"/>
					</td>
					<td>
						<span class="error" >${messages.ProgramCode}</span>
					</td>
				</tr>
				<tr>
					<td class="field">PROGRAM NAME: <span class="required" >*</span></td>
					<td>
						<textarea cols="20" rows="3" maxlength="100" id="ProgramName" name="ProgramName" >${param.ProgramName}</textarea>
					</td>
					<td>
						<span class="error" >${messages.ProgramName}</span>
					</td>
				</tr>
				<tr>
					<td class="field">NUMBER OF YEARS: <span class="required" >*</span></td>
					<td>
						<input type="text" maxlength="1" onkeypress='validate(event)' id="NumberOfYears" name="NumberOfYears" size="20" value="${param.NumberOfYears}"/>
					</td>
					<td>
						<span class="error" >${messages.NumberOfYears}</span>
					</td>
				</tr>
				<tr>
					<td>
						<input id="submit" type="submit" class="btnSubmit" value="Submit">
					</td>
				</tr>	
			</table>
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
			</form>
		</td>
	</tr>
</table>
</body>
</html>