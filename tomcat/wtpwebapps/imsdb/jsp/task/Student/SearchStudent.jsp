<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Search Student IMSDB</title>
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
			<h4>You are in Student Account Search</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_StudentAdd" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Add Student">
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
		
		<%!
		String studentId = "", query ="", name, programCode, campusId, status, email, phone;
		%>
		<%
			session.setAttribute("ACCOUNT", "STUDENT");
			session.setAttribute("TASK", "11");
		%>
			<form name="idForm" action="${pageContext.request.contextPath}/Admin_AccountChecking" method="post">
				<table>
					<tr>
						<td colspan="3">
							<h3>STUDENT SEARCH FORM</h3>
							<h4>Fields marked with an <span class="required">*</span> are required.</h4>
							Enter the Student ID below to search for student.
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">STUDENT ID: <span class="required">*</span></td>
						<td colspan="2">
							<input type="text" name="StudentId" id="StudentId" maxlength="9" />
							<br/>
							<span class="error">${messages.StudentId}</span>
						</td>
					</tr>
					<tr>
						<td><input type="submit" class="btnSubmit" value="Search Student" /></td>
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

				if(request.getAttribute("valid_employee_id") != null && request.getAttribute("valid_employee_id").equals("1")){
					
					if(null != session.getAttribute("returning_with_error")){
						System.out.println(studentId + " start retrurning error");
						name = request.getAttribute("name").toString();
						studentId = request.getAttribute("studentId").toString();
						campusId = request.getAttribute("campusId").toString();
						programCode = request.getAttribute("programCode").toString();
						status = request.getAttribute("status").toString();
						phone = request.getAttribute("phone").toString();
						email = request.getAttribute("email").toString();
						System.out.println(studentId + " in retrurning error");
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
				<h4>SEARCH RESULT:</h4>
					<table border="1">
						<tr>
							<td class="field">STUDENT ID: </td>
							<td><%=studentId%>
						</tr>
						<tr>
							<td class="field">NAME: </td>
							<td>
								<%=name%>
							</td>
						</tr>
						<tr>
							<td class="field">PROGRAM CODE: </td>
							<td>
								<%=programCode%>
							</td>
						</tr>
						<tr>
							<td class="field">CAMPUS: </td>
							<td>
							<% 
								try {
										rs = st.executeQuery("SELECT CNAME FROM CAMPUS WHERE CAMPUS_ID='"+campusId.trim().toUpperCase()+"'");
										rs.next();
							%>
								<%= rs.getString("CNAME") %>
							<% 
										
									} catch (SQLException e) {
										request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
									}
							%>
							</td>
						</tr>
						<tr>
							<td class="field">STATUS: </td>
							<td>
							<%	if(status.startsWith("A")){%>
									AVAILABLE
								<%}else if(status.startsWith("N")){%>
									NOT AVAILABLE
								<%}else{%>
									INVALID
								<% }%>
							</td>
						</tr>
						<tr>
							<td class="field">PHONE: </td>
							<td>
							<%=phone%>
							</td>
						</tr>
						<tr>
							<td class="field">EMAIL: </td>
							<td>
							<%=email%>
							</td>
						</tr>
					</table>
				</form>
				<%} 
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
