<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Add Employee IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
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
			<h4>You are in Employee Account Add</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_SearchEmployee" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Employee">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_EmployeeModify" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Modify Employee">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<h3>ADD NEW EMPLOYEE</h3>
			<h4>Fields marked with an <span class="required" >*</span> are required.</h4>
			<form action="${pageContext.request.contextPath}/Admin_AddNewEmployee" method="post">
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
				if(request.getAttribute("RESULT") != null && request.getAttribute("RESULT").equals("2")){
				%>
				<tr>
					<td colspan="3">
						<span class="error">
							ID Already Exists 
						</span>
						<br/><br/>
					</td>
				</tr>
				<% 
				}
				else if(request.getAttribute("RESULT") != null && request.getAttribute("RESULT").equals("1")){
				%>
				<tr>
					<td colspan="3">
						<span class="error">
							Employee Added Successfully 
						</span>
						<br/><br/>
					</td>
				</tr>
				<% 
				}
				%>
				<tr>
					<td class="field">EMPLOYEE ID: <span class="required">*</span></td>
					<td>
						<input type="text" id="EmployeeID" name="EmployeeID" size="20" maxlength="9" onkeypress='validate(event)' value="${param.EmployeeID}"/>
					</td>
					<td>
						<span class="error" >${messages.EmployeeID}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">EMPLOYEE NAME: <span class="required" >*</span></td>
					<td>
						<input type="text" id="EmployeeName" name="EmployeeName" size="20" maxlength="30" value="${param.EmployeeName}" />
					</td>
					<td>
						<span class="error" >${messages.EmployeeName}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">
						EMPLOYEE ROLE: <span class="required" >*</span>
					</td>
					<td>
						<!-- Populating EROLE from Database -->
						<select name="EmployeeRole" id="EmployeeRole" >
						<% 
							try
							{
								rs = st.executeQuery("SELECT DISTINCT EROLE FROM EMPLOYEE ORDER BY EROLE");
								while(rs.next())
					    		{
					    			%>
					    			<option value="<%= rs.getString("EROLE").trim()%>" 
					    			><%= rs.getString("EROLE")%></option>
					    			<% 
					    		}
							}
							catch(Exception e)
							{
								request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
							}
						%>
						</select>
					</td>
					<td></td>
				</tr>
				<tr>
					<td class="field">EMAIL: <span class="required" >*</span></td>
					<td>
						<input type="text" id="Email" name="Email" size="20" maxlength="30" value="${param.Email}"/>
					</td>
					<td>
						<span class="error" >${messages.Email}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">EXTENSION: <span class="required" >*</span></td>
					<td>
						<input type="text" id="Phone" name="Extension" maxlength="5" onkeypress='validate(event)' size="20" value="${param.Extension}"/>
					</td>
					<td>
						<span class="error" >${messages.Extension}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">PASSWORD: <span class="required" >*</span></td>
					<td>
						<input type="Password" id="Password" name="Password" maxlength="15" size="20"/>
					</td>
					<td>
						<span class="error" >${messages.Password}</span><br>
					</td>
				</tr>
				<tr>
					<td>
						<input id="submit" type="submit" class="btnSubmit" value="Add Employee">
					</td>
					<td>	
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