<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Place Order IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("FACULTY")))
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
			<h4>You are in Place Order Form</h4>
		</td>
	</tr>
	<tr>
		<td id = "menuBar" colspan="1">
			<table>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Faculty_BackToMain" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Back To Main">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Faculty_Item_Search" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Item">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Faculty_Item_Booked" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Items on Hold">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<form method="post" action="${pageContext.request.contextPath}/Faculty_OrderPlace_Servlet">
				<table>
				<colgroup>
				    <col width="45%">
				    <col width="25%">
				    <col width="30%">
				</colgroup>
				<!-- Connecting to the database -->
				<%
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
						st1 = conn.createStatement();
					}
					catch(Exception e)
					{
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
				%>
				<tr>
					<td colspan="3">
						<h3>PLACE ORDER FORM</h3>
						<h4>Fields marked with an <span class="required">*</span> are required.</h4>
					</td>
				</tr>
				<tr>
					<td class="field">
						ITEM ID: <span class="required">*</span>
					</td>
					<td colspan="2">
						<input type="text" name="orderItemId" id="orderItemId" value="${param.orderItemId}"/>
						<br/>
						<span class="error">${messages.orderItemId}</span>
					</td>
				</tr>
				<tr>
					<td class="field">
						EMPLOYEE ID:
					</td>
					<td colspan="2">
						<%= session.getAttribute("username").toString() %>
					</td>
				</tr>
				<tr>
					<td class="field">
						LOGIN AS:
					</td>
					<td colspan="2">
						<%= session.getAttribute("role").toString() %>
					</td>
				</tr>
				<tr>
					<td class="field">
						ORDER DATE:
					</td>
					<td colspan="2">
						<% 
							DateFormat dateFormat = new SimpleDateFormat("dd-MMM-yy");
							Date date = new Date();
						%>
						<%= dateFormat.format(date) %>
					</td>
				</tr>
				<tr>
					<td>
						<input id="act" name="act" type="submit" class="btnSubmit" value="Show Suppliers">
					</td>
					<td colspan="2">
					</td>
				</tr>
				<% 
				String valid = request.getAttribute("valid") != null ? request.getAttribute("valid").toString() : "";
				if(valid != null && valid.trim().equals("1"))
				{
					boolean supError = false;
				%>
				<tr>
					<td class="field">
						SUPPLIER: <span class="required">*</span>
					</td>
					<td colspan="2">
					<!-- populating supplier from database -->
						<select name="supplierID" id="supplierID">
						<option value="-1" >SELECT</option>
						<%
							try
							{
								String itemID = request.getParameter("orderItemId");
								String toSearchID = itemID.trim().substring(Math.max(0, itemID.trim().length() - 6));
								
								rsSub = st1.executeQuery("SELECT DISTINCT SUPPLIER_ID FROM SUPPLIER_ITEM WHERE ITEM_ID = '"+toSearchID+"'");
								if(!rsSub.isBeforeFirst())
								{
									supError = true;
								}
								else
								{
									while(rsSub.next())
									{
										String supID = rsSub.getString("SUPPLIER_ID");
										rs = st.executeQuery("SELECT SNAME FROM SUPPLIER WHERE SUPPLIER_ID = '"+supID.trim()+"'");
										while(rs.next())
							    		{
							    			%>
							    			<option value="<%= supID.trim()%>" 
							    			><%= rs.getString("SNAME")%></option>
							    			<% 
							    		}
									}
								}
							}
							catch(Exception e)
							{
								request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
							}
						%>
						</select>
						<br/>
						<span class="error">${messages.supplierID}</span>
					</td>
				</tr>
						<%
							if(supError)
							{
						%>
				<tr>
					<td></td>
					<td colspan="2">
						<span class="error">
							No Supplier found for this Item 
						</span>
					</td>
				</tr>
						<% 	
							}
						%>
				<tr>
					<td colspan="1" class="field">
						PURPOSE OF ORDER:
					</td>
					<td colspan="2">
						<textarea maxlength="100" name="purposeOfOrder" id="purposeOfOrder" cols="30" rows="2"></textarea>
						<br/>
						<sub>100 Character Max</sub>
					</td>
				</tr>
				<tr>
					<td class="field">
						QUANTITY : <span class="required">*</span> 
					</td>
					<td colspan="2">
						<input maxlength="5" type="text" name="orderQuantity" id="orderQuantity" value="${param.orderQuantity}" size="9" onkeypress='validate(event)' />
						<br/>
						<span class="error">${messages.orderQuantity}</span>
					</td>
				</tr>
				<tr>
					<td colspan="1" class="field">
						DESCRIPTION:
					</td>
					<td colspan="2">
						<textarea maxlength="4000" name="descriptionOfOrder" id="descriptionOfOrder" cols="30" rows="4"></textarea>
						<br/>
						<sub>4000 Character Max</sub>
					</td>
				</tr>
				<tr>
					<td>
						<input id="act" name="act" type="submit" class="btnSubmit" value="Place Order">
					</td>
					<td colspan="2">
					</td>
				</tr>
				<%
				} // ending if for hidden feild valid = 1
				else if(valid != null && valid.trim().equals("2"))
				{
				%>
				<tr>
					<td colspan="3">
						<span class="error">
							${messages.result}
						</span>
					</td>
				</tr>
				<%	
				}
				%>
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
				</table>
			</form>
		</td> 
	</tr>
</table>
</body>
</html>