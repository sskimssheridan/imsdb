<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Administrator Inventory IMSDB</title>
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
	String task = "CHECKING",query, returning = "NO", supplierId, name, email, phone, address;
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
			<h4>You are in Modify Supplier</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_SupplierAdd" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Add Supplier ">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_AddItemToSupplier" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Supplier Items">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<%session.setAttribute("ACCOUNT", "SUPPLIER"); %>
		<td id = "workingBar" colspan="3">
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
				    <col width="50%">
				    <col width="30%">
				    <col width="20%">
					</colgroup>
					<tr>
						<td colspan="3">
							<h3>SUPPLIER MODIFY FORM</h3>
							<h4>Fields marked with an <span class="required">*</span> are required.</h4>
							Chose the supplier below to search details.
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">SUPPLIER: <span class="required">*</span></td>
						<td colspan="2">
						<select name="supplierId" id="supplierId">
						<% 
							try
							{
								rs = st.executeQuery("SELECT SUPPLIER_ID,SNAME FROM SUPPLIER ORDER BY SNAME");
								while(rs.next())
					    		{
					    			String sCode = rs.getString("SUPPLIER_ID");
					    			String sName = rs.getString("SNAME");
					    			%>
					    			<option value="<%= sCode%>" 
					    			><%= sName%></option>
					    <% 
					    		}
							}
							catch(Exception e)
							{
								request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
							}
						%>
						</select>
						<!--  
							<input type="text" maxlength="6" name="supplierId" id="supplierId" />-->
						</td>
					</tr>
					<tr>
						<td><input type="submit" name="submit" value="Search Supplier" /></td>
					</tr>
				</table>
			</form>
			<%
			supplierId = request.getParameter("supplierId");
			
			if(request.getAttribute("valid_employee_id") != null && request.getAttribute("valid_employee_id").equals("1")){
				task = "UPDATING";
				if(null != session.getAttribute("returning_with_error")){
					name = request.getAttribute("name").toString();
					supplierId = request.getAttribute("supplierId").toString();
					phone = request.getAttribute("phone").toString();
					email = request.getAttribute("email").toString();
					address = request.getAttribute("address").toString();
				}
				else{
					try {
						//fethching data from the table
						query = "SELECT * FROM SUPPLIER WHERE SUPPLIER_ID = '" + supplierId + "'";
						rs = st.executeQuery(query);
						while (rs.next()) {
							name = rs.getString("SNAME");
							supplierId = rs.getString("SUPPLIER_ID");
							phone = rs.getString("PHONE");
							email = rs.getString("EMAIL");
							address = rs.getString("ADDRESS");
						}
					} catch (SQLException e) {
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
				}
				
				%>
				<form action="${pageContext.request.contextPath}/Admin_SupplierAccountModify" method="post">
				<h4>MODIFY SUPPLIER:</h4>
				<table>			
					<tr>
						<td class="field">SUPPLIER ID:</td>
						<td><%=supplierId%>
						<input type="text" style="`visibility:hidden;display:none;" name="supplierId" value="<%=supplierId%>" /></td>
					</tr>
					<tr>
						<td class="field">SUPPLIER NAME:<span class="required">*</span></td>
						<td>
							<input type="text" name="name" size="20" maxlength="30" value="<%=name%>"/>
						</td>
						<td>
							<span class="error">${messages.name}</span><br>
						</td>
					</tr>
					<tr>
						<td class="field">SUPPLIER ADDRESS:<span class="required">*</span></td>
						<td>
							<textarea name="address" cols="20" rows="3" maxlength="100" ><%=address%></textarea>
						</td>
						<td>
							<span class="error">${messages.address}</span><br>
						</td>
					</tr>
					<tr>
						<td class="field">SUPPLIER PHONE:<span class="required">*</span></td>
						<td>
							<input onkeypress='validate(event)' type="text" name="phone" size="20" maxlength="10" value="<%=phone%>"/>
						</td>
						<td>
							<span class="error">${messages.phone}</span><br>
						</td>
					</tr>
					<tr>
						<td class="field">SUPPLIER EMAIL:<span class="required">*</span></td>
						<td>
							<input type="text" name="email" size="20" maxlength="30" value="<%=email%>"/>
						</td>
						<td>
							<span class="error">${messages.email}</span><br>
						</td>
					</tr>
					<tr>
						<td><input type="Submit" value="Modify Supplier" /></td>
					</tr>
				</table>
				</form>
				<%}
				//checking if the result has been updated or not 
				if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("1")){
				%>
					<span class="error">Supplier account has been modified</span>
				<% 
				}
				else if(request.getAttribute("Update_result") != null && request.getAttribute("Update_result").equals("0")){
				%>
					<span class="error">Supplier account has not been modified</span>
				<%
				}
				%>
		</td>
		<!-- Closing database connection-->	
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
	</tr>
</table>
</body>
</html>