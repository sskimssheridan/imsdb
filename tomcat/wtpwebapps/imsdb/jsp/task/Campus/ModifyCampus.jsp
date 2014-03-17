<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Modify Campus IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
</head>
<body>
<%!
	String campusId = "", cname, campusLocation, query;
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
			<h4>You are in Campus Modify</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_CampusAdd" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Add Campus">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<%!
			String task = "CHECKING";
			%>
			<%session.setAttribute("ACCOUNT", "CAMPUS");
			if(null != session.getAttribute("TASK")){
			session.removeAttribute("TASK");
			}
			%>
			<%Context initContext;
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
			
			<form name="idForm" action="${pageContext.request.contextPath}/Admin_AccountChecking" method="post">
				<table>
					<colgroup>
					    <col width="25%">
					    <col width="25%">
					    <col width="25%">
					    <col width="25%">
						</colgroup>
					<tr>
						<td colspan="4">
							<h3>CAMPUS MODIFY FORM</h3>
							<h4>Fields marked with an <span class="required">*</span> are required.</h4>
							Select Campus below to modify the Campus.
						</td>
					</tr>
					<tr>
						<td class="field">CAMPUS: <span class="required">*</span></td>
						<td>
							<select name="campusId" id="campusId" >
							<% 
								try
								{
									rs = st.executeQuery("SELECT DISTINCT CAMPUS_ID, CNAME FROM CAMPUS ORDER BY CAMPUS_ID");
									while(rs.next())
						    		{
						    			%>
						    			<option value="<%= rs.getString("CAMPUS_ID").trim()%>" 
						    			><%= rs.getString("CNAME")%></option>
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
						<td>
							<span class="error">${messages.campusId}</span>
						</td>
					</tr>
					<tr>
						<td><input type="submit" class="btnSubmit" value="Search Campus" /></td>
					</tr>
				</table>
			</form>
			<%
				campusId = request.getParameter("campusId");
				if(request.getAttribute("valid_employee_id") != null && request.getAttribute("valid_employee_id").equals("1")){
					if(null != session.getAttribute("returning_with_error")){
						cname = request.getAttribute("name").toString();
						campusLocation = request.getAttribute("location").toString();
					}
					else{
						try {
							//fethching data from the table
							query = "SELECT * FROM CAMPUS WHERE CAMPUS_ID = '" + campusId + "'";
							rs = st.executeQuery(query);
							while (rs.next()) {
								campusId = rs.getString("CAMPUS_ID");
								cname = rs.getString("CNAME");
								campusLocation =  rs.getString("CAMPUS_LOCATION");
							}
						} catch (SQLException e) {
							request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
						}
					}
				%>
				<h4>MODIFY CAMPUS:</h4>	
				<form action="${pageContext.request.contextPath}/Admin_CampusAccountModify" method="post">
					<table>
						<tr>
							<td class="field">CAMPUS ID:</td>
							<td><%=campusId%>
							<input type="text" style="visibility:hidden ;display:none;" name="campusId" value="<%=campusId%>" /></td>
						</tr>
						<tr>
							<td class="field">CAMPUS NAME:<span class="required">*</span></td>
							<td>
								<textarea cols="20" rows="3" maxlength="50"  name="name" ><%=cname %></textarea>
							</td>
							<td>
								<span class="error">${messages.name}</span>
							</td>
						</tr>
						<tr>
							<td class="field">CAMPUS LOCATION:<span class="required">*</span></td>
							<td>
								<input type="text" name="location" maxlength="20" value="<%=campusLocation %>"/>
							</td>
							<td>
								<span class="error">${messages.location}</span><br>
							</td>
						</tr>
						<tr>
							<td><input type="Submit" class="btnSubmit" value="Modify Campus" /></td>
							<td align="right">
								
							</td>
							<td>
							</td>
						</tr>	
					</table>
				</form>
			<%}
				
				if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("1")){
				%>
					<span class="error">Campus has been modified</span>
				<%
				}
				else if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("0")){
				%>
					<span class="error">Campus has not been modified</span>
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