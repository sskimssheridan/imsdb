<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Add Student IMSDB</title>
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
			<h4>You are in Student Account Add</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_SearchStudent" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Student">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_StudentModify" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Modify Student">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<h3>ADD NEW STUDENT</h3>
			<h4>Fields marked with an <span class="required" >*</span> are required.</h4>
			<form action="${pageContext.request.contextPath}/Admin_AddNewStudent" method="post">
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
							Student Added Successfully
						</span>
						<br/><br/>
					</td>
				</tr>
				<%
					}	
				%>
				<tr>
					<td class="field">STUDENT ID: <span class="required" >*</span></td>
					<td>
						<input type="text" id="StudentID" name="StudentID" maxlength="9" onkeypress='validate(event)' size="20" value="${param.StudentID}"/>
					</td>
					<td>
						<span class="error" >${messages.StudentID}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">PROGRAM CODE: <span class="required" >*</span></td>
					<td>
						<!-- Populating Category from Database -->
						<select name="ProgramCode" id="ProgramCode" >
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
					<td></td>
				</tr>
				<tr>
						<td class="field">
							CAMPUS ID: <span class="required" >*</span>
						</td>
						<td>
							<!-- Populating Category from Database -->
							<select name="CampusID" id="CampusID" >
							<% 
								try
								{
									rs = st.executeQuery("SELECT DISTINCT CAMPUS_ID, CNAME FROM CAMPUS ORDER BY CAMPUS_ID");
									while(rs.next())
						    		{
						    			String cCode = rs.getString("CAMPUS_ID");
						    			String cName = rs.getString("CNAME");
						    			%>
						    			<option value="<%= cCode%>" 
						    			><%= cName%></option>
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
					<td class="field">STUDENT NAME: <span class="required" >*</span></td>
					<td>
						<input type="text" id="StudentName" name="StudentName" size="20" maxlength="20" value="${param.StudentName}"/>
					</td>
					<td>
						<span class="error" >${messages.StudentName}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">STATUS: <span class="required" >*</span></td>
					<td>
						<select name="Status" id="Status">
							<option value="A" selected>AVAILABLE</option>
							<option value="I">INVALID</option>
							<option value="N">NOT AVAILABLE</option>
						</select>
					</td>
					<td></td>
				</tr>
				<tr>
					<td class="field">PASSWORD: <span class="required" >*</span></td>
					<td>
						<input type="Password" id="Password" name="Password" size="20" maxlength="15"/>
					</td>
					<td>
						<span class="error" >${messages.Password}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">PHONE: <span class="required" >*</span></td>
					<td>
						<input onkeypress='validate(event)' type="text" id="Phone" name="Phone" maxlength="10" size="20" value="${param.Phone}"/>
					</td>
					<td>
						<span class="error" >${messages.Phone}</span><br>
					</td>
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
					<td>
						<input id="submit" type="submit" class="btnSubmit" value="Add Student">
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