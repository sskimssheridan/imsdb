<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Add Campus IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
<script>

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
			<h4>You are in Campus Add</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_SearchCampus" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Campus">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_CampusModify" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Modify Campus">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<h3>ADD NEW CAMPUS</h3>
			<h4>Fields marked with an <span class="required" >*</span> are required.</h4>
			<form action="${pageContext.request.contextPath}/Admin_AddNewCampus" method="post">
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
							Campus Added Successfully
						</span>
					</td>
				</tr>
				<%
				}
				%>
				<tr>
					<td class="field">CAMPUS ID: <span class="required" >*</span></td>
					<td>
						<input type="text" maxlength="1" id="CampusID" name="CampusID" size="20" value="${param.CampusID}"/>
					</td>
					<td>
						<span class="error" >${messages.CampusID}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">CAMPUS NAME: <span class="required" >*</span></td>
					<td>
						<textarea cols="20" rows="3" maxlength="50" id="CampusName" name="CampusName">${param.CampusName}</textarea>
					</td>
					<td>
						<span class="error" >${messages.CampusName}</span>
					</td>
				</tr>
				<tr>
					<td class="field">CAMPUS LOCATION: <span class="required" >*</span></td>
					<td>
						<input type="text" maxlength="20" id="CampusLocation" name="CampusLocation" size="20" value="${param.CampusLocation}"/>
					</td>
					<td>
						<span class="error" >${messages.CampusLocation}</span><br>
					</td>
				</tr>
				<tr>		
					<td>
						<input id="submit" type="submit" class="btnSubmit" value="Add Campus">
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