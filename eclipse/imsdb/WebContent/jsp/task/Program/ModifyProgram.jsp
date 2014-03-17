<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Modify Program IMSDB</title>
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
<%!
	String programCode = "", name, years, query;
%>
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
			<h4>You are in Modify Program</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_ProgramAdd" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Add Program">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<%!
			%>
			<%
			session.setAttribute("ACCOUNT", "PROGRAM");
			if(null != session.getAttribute("TASK")){
				session.removeAttribute("TASK");
			}
			%>
			
			<form name="idForm" action="${pageContext.request.contextPath}/Admin_AccountChecking" method="post">
				<table>
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
					<colgroup>
					    <col width="40%">
					    <col width="30%">
					    <col width="30%">
						</colgroup>
					<tr>
						<td colspan="3">
							<h3>PROGRAM MODIFY FORM</h3>
							<h4>Fields marked with an <span class="required">*</span> are required.</h4>
							Select Program code below to modify the Program.
						</td>
					</tr>
					<tr>
						<td colspan="1"  class="field">PROGRAM: <span class="required">*</span></td>
						<td colspan="2">
							<select name="programCode" id="programCode" >
							<% 
								try
								{
									rs = st.executeQuery("SELECT PROGRAM_CODE FROM PROGRAM ORDER BY PROGRAM_CODE");
									while(rs.next())
						    		{
						    			%>
						    			<% String prog = rs.getString("PROGRAM_CODE").trim();
						    			%>
						    			<option value="<%= prog%>" 
						    			><%= prog%></option>
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
					</tr>
					<tr>
						<td></td>
						<td colspan="2">
							<span class="error">${messages.programCode}</span>
						</td>
					</tr>
					<tr>
						<td><input type="submit" class="btnSubmit" value="Search Program" /></td>
					</tr>
				</table>
			</form>
			<%
				programCode = request.getParameter("programCode");

				if(request.getAttribute("valid_employee_id") != null && request.getAttribute("valid_employee_id").equals("1")){
			
					if(null != session.getAttribute("returning_with_error")){
					
				
						name = request.getAttribute("name").toString();
						years = request.getAttribute("years").toString();
					}
					else{
						try {
							//fethching data from the table
							query = "SELECT * FROM PROGRAM WHERE PROGRAM_CODE = '" + programCode.toUpperCase() + "'";
							rs = st.executeQuery(query);
							while (rs.next()) {
								programCode = rs.getString("PROGRAM_CODE");
								name = rs.getString("PNAME");
								years =  rs.getString("NUMBER_OF_YEAR");
							}
						} catch (SQLException e) {
							request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
						}
					}
				%>	
				<h4>MODIFY PROGRAM:</h4>
				<form action="${pageContext.request.contextPath}/Admin_ProgramAccountModify" method="post">
					<table>
						<tr>
							<td class="field">PROGRAM CODE:</td>
							<td><%=programCode%>
							<input type="text" style="visibility:hidden ;display:none;" name="programCode" value="<%=programCode%>" /></td>
						</tr>
						<tr>
							<td class="field">PROGRAM NAME:</td>
							<td>
								<textarea cols="20" rows="3" maxlength="100" name="name" id="name"><%=name %></textarea>
							</td>
							<td>
								<span class="error">${messages.name}</span><br>
							</td>
							</tr>
						<tr >
							<td class="field">NUMBER OF YEARS:</td>
							<td>
								<input onkeypress='validate(event)' type="text" name="years" maxlength="1" value="<%=years %>"/>
							</td>
							<td>
								<span class="error">${messages.years}</span><br>
							</td>
						</tr>
						<tr class="field">
							<td><input type="Submit" class="btnSubmit" value="Modify Program" /></td>
						</tr>	
					</table>				
				</form>
			<%}
				
				if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("1")){
				%>
					<span class="error">Program has been modified</span>
				<%
				}
				else if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("0")){
				%>
					<span class="error">Program has not been modified</span>
				<%
				}
				
				try
				{
					conn.close();
				}
				catch(Exception e)
				{
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}		
			%>
		</td>
	</tr>
</table>
</body>
</html>