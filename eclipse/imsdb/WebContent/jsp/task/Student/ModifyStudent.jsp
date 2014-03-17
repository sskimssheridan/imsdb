<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Modify Student IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
<script>
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
	//adding item description dynamically
	$(document).ready(function(){
			    
		//selecting selected values in dropdown list if session stores the values
	    $("#categoryID").val('<%= session.getAttribute("categoryID")%>').attr('selected', 'selected');
	   
		if("<%= session.getAttribute("categoryID")%>"== "M")
		{
			$("#machineryInfo").show('');
		}
		else
		{
			$("#machineryInfo").hide('');
		}
	    $("#campusID").val('<%= session.getAttribute("campusID")%>').attr('selected', 'selected');
	    $("#labID").val('<%= session.getAttribute("labID")%>').attr('selected', 'selected');
	    $("#manufacturerID").val('<%= session.getAttribute("manufacturerID")%>').attr('selected', 'selected');
	    $('input:radio[name="status"]').filter('[value="<%= session.getAttribute("status")%>"]').attr('checked', true);
	});
		
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
			<h4>You are in Student Account Modify</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_StudentAdd" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Add Student">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
		
		<%!
		String task = "CHECKING", studentId = "", query ="", name, programCode, campusId, status, email, phone;
		%>
		<%
		session.setAttribute("ACCOUNT", "STUDENT");
		if(null != session.getAttribute("TASK")){
			session.removeAttribute("TASK");
		}
		%>
			<form name="idForm" action="${pageContext.request.contextPath}/Admin_AccountChecking" method="post">
				<table>
					<colgroup>
					    <col width="40%">
					    <col width="30%">
					    <col width="30%">
						</colgroup>
					<tr>
						<td colspan="3">
							<h3>STUDENT MODIFY FORM</h3>
							<h4>Fields marked with an <span class="required">*</span> are required.</h4>
							Enter the Student ID below to search for student.
						</td>
					</tr>
					<tr>
						<td colspan="1"  class="field">STUDENT ID :<span class="required">*</span></td>
						<td colspan="2">
							<input type="text" name="StudentId" maxlength="9" onkeypress='validate(event)' id="StudentId" maxlength="9" />
						</td>
					</tr>
					<tr>
						<td></td>
						<td colspan="2">
							<span class="error">${messages.StudentId}</span>
						</td>
					</tr>
					<tr>
						<td><input type="submit" class="btnSubmit" value="Search Student" /></td>
						<td align="right">
							
						</td>
						<td>
						</td>
					</tr>
				</table>
			</form>
			
			<%
			
				studentId = request.getParameter("StudentId");
				Context initContext;
				Context envContext;
				DataSource ds = null;
				Connection conn = null;
				Statement st = null;
				Statement st1 = null;
				ResultSet rs = null;
				ResultSet rsSub = null;
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

				if(request.getAttribute("valid_employee_id") != null && request.getAttribute("valid_employee_id").equals("1")){
					
					task = "UPDATING";
					if(null != session.getAttribute("returning_with_error")){
						name = request.getAttribute("name").toString();
						studentId = request.getAttribute("studentId").toString();
						campusId = request.getAttribute("campusId").toString();
						programCode = request.getAttribute("programCode").toString();
						status = request.getAttribute("status").toString();
						phone = request.getAttribute("phone").toString();
						email = request.getAttribute("email").toString();
					}
					else{
						try {
							//fethching data from the table
							query = "SELECT * FROM STUDENT WHERE STUDENT_ID = '" + studentId + "'";
							rs = st.executeQuery(query);
							while (rs.next()) {
								name = rs.getString("SNAME");
								studentId = rs.getString("STUDENT_ID");
								campusId = rs.getString("CAMPUS_ID");
								programCode = rs.getString("PROGRAM_CODE");
								status = rs.getString("STATUS");
								phone = rs.getString("PHONE");
								email = rs.getString("EMAIL");
							}
						} catch (SQLException e) {
							request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
						}
					}
			%>
			<form name="dataForm" action="${pageContext.request.contextPath}/Admin_StudentAccountModify" method="post">
			<h4>MODIFY STUDENT:</h4>
				<table>
					<tr>
						<td class="field">STUDENT ID:</td>
						<td><%=studentId%>
						<input type="text" style="visibility:hidden;display:none;" name="StudentId" value="<%=studentId%>" /></td>
					</tr>
					<tr>
						<td class="field">NAME:<span class="required">*</span></td>
						<td>
							<input type="text" name="name" maxlength="20" value="<%=name%>"/>
						</td>
						<td>
							<span class="error">${messages.name}</span><br>
						</td>
					</tr>
					<tr>
						
						<td class="field">PROGRAME CODE:<span class="required">*</span></td>
						<td>
							<select name="programCode" id="programCode">
							<% 
							try
							{
								rs = st.executeQuery("SELECT DISTINCT PROGRAM_CODE FROM PROGRAM");
								while(rs.next())
					    		{
					    			String pCode = rs.getString("PROGRAM_CODE");
					    			
					    			%>
					    			<option value="<%= pCode%>" <%if(pCode.toUpperCase().trim().equals(programCode.trim().toUpperCase())){%>selected="selected"<%} %>
					    			><%= pCode%></option>
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
							<span class="error">${messages.programCode}</span><br>
						</td>
					</tr>
					<tr>
						<td class="field">CAMPUS:<span class="required">*</span></td>
						<td>
							<select name="campusId" id="campusId">
							<% 
							try
							{
								rs = st.executeQuery("SELECT DISTINCT CAMPUS_ID, CNAME FROM CAMPUS");
								while(rs.next())
					    		{
					    			String cCode = rs.getString("CAMPUS_ID");
					    			String cName = rs.getString("CNAME");
					    			%>
					    			<option value="<%= cCode%>" <%if(cCode.toUpperCase().trim().equals(campusId.trim().toUpperCase())){%>selected="selected"<%} %>
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
					</tr>
					<tr>
						<td class="field">STATUS:<span class="required">*</span></td>
						<td>
							<select name="status" id="status">
							<%if(status.startsWith("A")){%>
								<option value="A" selected>AVAILABLE</option>
								<option value="I">INVALID</option>
								<option value="N">NOT AVAILABLE</option>
							<%}else if(status.startsWith("N")){%>
								<option value="A">AVAILABLE</option>
								<option value="I">INVALID</option>
								<option value="N" selected>NOT AVAILABLE</option>
							<%}else{%>
								<option value="A">AVAILABLE</option>
								<option value="I" selected>INVALID</option>
								<option value="N">NOT AVAILABLE</option>
							<% }%>
							</select>
						</td>
					</tr>
					<tr>
						<td class="field">PHONE:<span class="required">*</span></td>
						<td>
							<input type="text" name="phone" maxlength="10" value="<%=phone%>"/>
						</td>
						<td>
							<span class="error">${messages.phone}</span><br>
						</td>
					</tr>
					<tr>
						<td class="field">EMAIL:<span class="required">*</span></td>
						<td>
							<input type="text" name="email" maxlength="30" value="<%=email%>"/>
						</td>
						<td>
							<span id="email" class="error">${messages.email}</span><br>
						</td>
					</tr>
					<tr>
						<td><input type="Submit" class="btnSubmit" value="Modify Student" /></td>
					</tr>
				</table>
			</form>
				<%}
				//checking if the result has been updated or not 
				if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("1")){
				%>
					<span class="error">Student account has been modified</span>
				<%
				}
				else if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("0")){
				%>
					<span class="error">Student account has not been modified</span>
				<%
				}
				%>
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
		</td>
	</tr>
</table>
</body>
</html>
<%session.setAttribute("TASK", task); %>