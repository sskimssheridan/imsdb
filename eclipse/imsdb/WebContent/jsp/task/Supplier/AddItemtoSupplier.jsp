<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Add new item to supplier</title>
<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
<script src="${pageContext.request.contextPath}/jQuery/jquery.price_format.1.8.js"></script>
<script type="text/javascript">
//adding item description dynamically
$(document).ready(function(){
	var counter = 1;
	var counterMachinery = 2;
//for adding Machinery Item 
$("#addItemRow").click(function () { 
	var descRow = "<tr id=\"supplierItem"+counterMachinery+"\">"+
					"<td>"+
						"ITEM ID "+counterMachinery+ ": <span class=\"required\">*</span> <input type=\"text\" name=\"supplierItem\"/>"+
						//"<br/>"+
						//"<span class=\"error\">${messages['item"+ counterMachinery +"']}</span>"+
					"</td>"+
				  "</tr>";
		
	$("#itemInfo").find("tbody").append(descRow);
	counterMachinery++;
});
//for deleting Machinery Item 
$("#deleteItemRow").click(function () {
    if(counterMachinery==2){
        alert("SUPPLIER must cointain atleast one ITEM");
        return false;
    }   
    counterMachinery--;
    $("#supplierItem" + counterMachinery).remove();
});
});
</script>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
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
			<h4>You are in Add Item to Supplier</h4>
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
						<form action="${pageContext.request.contextPath}/Admin_SupplierModify" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Modify Supplier">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="2">
			<h3>ADD ITEMS TO SUPPLIER</h3>
			<h4>Fields marked with an <span class="required" style="color: #f00;">*</span> are required.</h4>
			<form action="${pageContext.request.contextPath}/Admin_ItemToSupplier" method="post">
			<!-- Connecting to the database -->
			<%
				Context initContext;
				Context envContext;
				DataSource ds = null;
				Connection conn = null;
				Statement st = null;
				ResultSet rs = null;
				Statement st1 = null;
				ResultSet rsSub = null;
				String suppliername = "";
				
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
					System.out.println("Error occured :"+ e);
				}
			%>
			<table>
				<tr>
					<td colspan="1" class="field">
						SUPPLIER ID: <span class="required" style="color: #f00;">*</span>
					</td>
					<td colspan="2">
						<!-- Populating Category from Database -->
						<select name="SupplierID" id="SupplierID" >
						<% 
							try
							{
								rs = st.executeQuery("SELECT * FROM SUPPLIER");
								while(rs.next())
					    		{
					    			 String SUPPLIER = rs.getString("SUPPLIER_ID").trim();	
					    			 String SUPPLIERNAME = rs.getString("SNAME").trim();
					    			%>
					    			<option value="<%= SUPPLIER%>" 
					    			><%= SUPPLIERNAME%></option>
					    			<% 
					    		}
							}
							catch(Exception e)
							{
								System.out.println("Error occured :"+ e);
							}
						%>
						</select>
					</td>
				</tr>
				<tr id="itemInfo">
					<td colspan="3">
						<table id="itemInfo">
							<tr>
								<td>
									<strong>ADD ITEMS TO SUPPLIER </strong>
									<input type="button" value="+" id="addItemRow"/>
									<input type='button' value='-' id='deleteItemRow'><br/>
									You can scan an ITEM Bar code or type in ITEM ID manually. 
									<br/>
									<span class="error">${messages.supplierItem}</span>
								</td>
							</tr>
							<tr id="supplierItem1">
								<td>
	    							ITEM ID 1: <span class="required">*</span> <input type="text" name="supplierItem"/>
	    						</td>
	    						<td>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td><input id="submit" type="submit" class="act1" value="Add Items"></td>
					<td>
						
					</td>
				</tr>	
				<%
					if(request.getAttribute("RESULT") != null && request.getAttribute("RESULT").equals("1"))
					{
				%>
				<tr>
					<td>
					<span class="error">
						Item(s) Added to Supplier
					</span>
					</td>
				</tr>
				<%
					}
				%>
			</table>
			</form>
		</td>
	</tr>
</table>
</body>
</html>