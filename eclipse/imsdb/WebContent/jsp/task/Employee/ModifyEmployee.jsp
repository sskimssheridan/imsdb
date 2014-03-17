<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Modify Employee IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
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
		<td id="role" colspan="4">
			<h4>You are in Employee Account Modify</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_EmployeeAdd" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Add Employee ">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
		<%!
			String EmployeeId= "",userId = "", sql = "", employeeName ="", employeeRole = "", employeeEmail="", employeeExt ="", user = "EMPLOYEE";
			
		%>
		<%
			//SETTING A USER FOR CHECKING IF IT IS EXITS OR NOT 
			session.setAttribute("USER", user);
		
		if(null != session.getAttribute("TASK")){
			session.removeAttribute("TASK");
		}
		%>
			<form name="idForm" action="${pageContext.request.contextPath}/Admin_EmployeeAccountChecking" method="post">
				<table>
					<colgroup>
					    <col width="40%">
					    <col width="20%">
					    <col width="40%">
					</colgroup>
					<tr>
						<td colspan="3">
							<h3>EMPLOYEE MODIFY FORM</h3>
							<h4>Fields marked with an <span class="required">*</span> are required.</h4>
							Enter the Employee ID below to search for employee.
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">EMPLOYEE ID: <span class="required">*</span></td>
						<td colspan="2">
							<input type="text" maxlength="9" onkeypress='validate(event)' name="userId" id="userId" maxlength="9" />
						</td>
					</tr>
					<tr>
						<td></td>
						<td colspan="2">
						<span class="error">${messages.userId}</span>
						</td>
					</tr>
					<tr>
						<td><input type="submit" name="submit" class="btnSubmit" value="Search Employee" /></td>
						
					</tr>
				</table>
				
			</form>
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
				
				//GETTING USER/EMPLOYEE ID 
				userId = request.getParameter("userId");
				try {
					//Fethching data from the table
					sql = "SELECT * FROM EMPLOYEE WHERE EMPLOYEE_ID = '"+ userId + "'";
					rs = st.executeQuery(sql);
					while (rs.next()) {
						employeeName = rs.getString("ENAME");
						userId = rs.getString("EMPLOYEE_ID");
						employeeRole = rs.getString("EROLE");
						employeeExt = rs.getString("EXT");
						employeeEmail = rs.getString("EMAIL");
					}
				} catch (SQLException e) {
					request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
				}
				
				//CHECKING IF THE EMPLOYEE IS VALID OR NOT 
				if(request.getAttribute("valid_employee_id") != null && request.getAttribute("valid_employee_id").equals("1")){
					//CHECKING IF THE VALID EMPLOYEE ID RETURNING WITH ERROR 
					if(null != session.getAttribute("returning_with_error")){
						
						//IF IT IS RETURNING WITH ERROR THEN UPDATED FIELD WILL REMAIN SAME IT WILL NOT TAKE DATA FROM DATABASE NOW
						userId = session.getAttribute("userId").toString();
						employeeName = session.getAttribute("employeeName").toString();
						employeeRole = session.getAttribute("employeeRole").toString();
						employeeExt = session.getAttribute("employeeExt").toString();
						employeeEmail = session.getAttribute("employeeEmail").toString();
						
					}
					%>
					<h4>MODIFY EMPLOYEE:</h4>
					<form name="dataForm" action="${pageContext.request.contextPath}/Admin_EmployeeAccountModify" method="post">
						<table>
							<tr>
								<td class="field">EMPLOYEE ID: </td>
								<td><%=userId %><input type="text" style="visibility:hidden;display:none;" name="userId" value="<%=userId%>" /></td>
							</tr>
							<tr>
								<td class="field">EMPLOYEE NAME: <span class="required">*</span></td>
								<td>
									<input type="text" name="employeeName" id="employeeName" maxlength="30" value="<%=employeeName%>"/>
								</td>
								<td>
									<span class="error">${messages.employeeName}</span><br>
								</td>
							</tr>
							<tr>
								<td class="field">EMPLOYEE ROLE: <span class="required">*</span></td>
								<td>
									<select name="employeeRole" id="employeeRole" >
									<% 
										try
										{
											rs = st.executeQuery("SELECT DISTINCT EROLE FROM EMPLOYEE ORDER BY EROLE");
											while(rs.next())
								    		{
												String eRole = rs.getString("EROLE").trim();
								    			%>
								    			<option value="<%= eRole%>" 
								    			<% if(employeeRole.trim().equals(eRole)){%>selected="selected"<%}%>
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
							</tr>
							<tr>
								<td class="field">EXTENSION: <span class="required">*</span></td>
								<td>
									<input type="text" name="employeeExt" maxlength="5" onkeypress='validate(event)' value="<%=employeeExt%>"/>
								</td>
								<td>
									<span class="error">${messages.employeeExt}</span><br>
								</td>
							</tr>
							<tr>
								<td class="field">EMAIL: <span class="required">*</span></td>
								<td>
									<input type="text" name="employeeEmail" maxlength="30" value="<%=employeeEmail%>"/>
								</td>
								<td>
									<span class="error">${messages.employeeEmail}</span><br>
								</td>
							</tr>
							<tr>
								<td><input type="submit" class="btnSubmit" value="Modify Employee" /></td>
							</tr>
						</table>
					</form>
					<%
					}
					//checking if the result has been updated or not 
					if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("1")){
					%>
						<span class="error">Employee account has been modified</span>
					<%
					}
					else if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("0")){
					%>
						<span class="error">Employee account has not been modified</span>
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