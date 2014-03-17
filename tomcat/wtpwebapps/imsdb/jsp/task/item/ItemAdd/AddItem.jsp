<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
 <%@ page import="java.sql.*,javax.sql.*,javax.naming.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Item Add IMSDB</title>
	<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.price_format.1.8.js"></script>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
	<script>
	//setting the price in the price section
		$(function(){
			$('#price').priceFormat({
				prefix: '',
			    limit: 9,
			    centsLimit: 2
			});
		});
	//setting date by datepicker
		$(function() {
		    $( "#purchaseDate" ).datepicker();
		 });
		$(function() {
		    $( "#expiryDate" ).datepicker();
		 });
		
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
	
	//adding item description dynamically
		$(document).ready(function(){
			var counter = 1;
			var counterMachinery = 2;
			//for adding ITEM Additional Information
		    $("#addRow").click(function () { 
		    	var descRow = "<tr id=\"descField"+counter+"\">"+
		    					"<td>"+
		    						"FIELD: <span class=\"required\">*</span><br/>"+
		    						"<textarea maxlength=\"100\" name=\"descField\" cols=\"15\" rows=\"3\"></textarea><br/>"+
		    						"<sub>100 Character Max</sub>"+
		    					"</td>"+
		    					"<td>"+
		    						"VALUE:<br/>"+
		    						"<textarea maxlength=\"4000\" name=\"descValue\" cols=\"35\" rows=\"3\"></textarea><br/>"+
		    						"<sub>4000 Character Max</sub>"+
		    					"</td>"+
		    				   "</tr>";
				$("#additionalDescriptionItem").find("tbody").append(descRow);
				counter++;
		    });
			//for deleting textbox from Item Additional Information
		    $("#deleteRow").click(function () {
			    if(counter==1){
			        alert("No field to remove");
			        return false;
			    }   
		        counter--;
		        $("#descField" + counter).remove();
			});
			
			//for Machenery adding Items
			$("#categoryID").change(function(){
				if($(this).val()=='M')
				{
					$("#machineryInfo").show('');
				}
				else
				{
					$("#machineryInfo").hide('');
				}
			});
			
			//for adding Machinery Item 
		    $("#addMachineryRow").click(function () { 
		    	var descRow = "<tr id=\"machineryItem"+counterMachinery+"\">"+
		    					"<td>"+
		    						"ITEM ID "+counterMachinery+ ": <span class=\"required\">*</span> <input type=\"text\" name=\"machineryItem\"/>"+
		    						//"<br/>"+
		    						//"<span class=\"error\">${messages['item"+ counterMachinery +"']}</span>"+
		    					"</td>"+
		    				  "</tr>";
		    		
				$("#machineryInfo").find("tbody").append(descRow);
				counterMachinery++;
		    });
			//for deleting Machinery Item 
		    $("#deleteMachineryRow").click(function () {
			    if(counterMachinery==2){
			        alert("Machenery must cointain atleast one ITEM");
			        return false;
			    }   
			    counterMachinery--;
		        $("#machineryItem" + counterMachinery).remove();
			});
		    
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
		<td colspan="4">
			<h4>You are in Add Item Form</h4>
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
						<form action="${pageContext.request.contextPath}/Item_Search" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Item">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Booked" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Items on Hold">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Checkout" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Checkout Item">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Return" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Return Item">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Modify" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Modify Item">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Item_Delete" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Delete Item">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<form method="post" action="Item_Add_Create_Servlet" enctype="multipart/form-data">
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
				<colgroup>
				    <col width="40%">
				    <col width="30%">
				    <col width="30%">
				</colgroup>
					<tr>
						<td colspan="3">
							<h3>ITEM ADD FORM</h3>
							<h4>Fields marked with an <span class="required">*</span> are required.</h4>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							CATEGORY: <span class="required">*</span>
						</td>
						<td colspan="2">
							<!-- Populating Category from Database -->
							<select name="categoryID" id="categoryID" >
							<% 
								try
								{
									rs = st.executeQuery("SELECT DISTINCT CATEGORY_ID, CATEGORY_TYPE FROM CATEGORY ORDER BY CATEGORY_TYPE");
									while(rs.next())
						    		{
						    			%>
						    			<option value="<%= rs.getString("CATEGORY_ID").trim()%>" 
						    			><%= rs.getString("CATEGORY_TYPE")%></option>
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
					<tr style="display:none" id="machineryInfo">
						<td colspan="3">
							<table id="machineryInfo">
								<tr>
									<td>
										<strong>ADD MACHENERY ITEMS </strong>
										<input type="button" value="+" id="addMachineryRow"/>
										<input type='button' value='-' id='deleteMachineryRow'><br/>
										You can scan an ITEM Bar code or type in ITEM ID manually. 
										<br/>
										<span class="error">${messages.item}</span>
									</td>
								</tr>
								<tr id="machineryItem1">
									<td>
		    						ITEM ID 1: <span class="required">*</span> <input type="text" name="machineryItem"/>
		    						<!-- <br/>
		    						<span class="error">${messages.item1}</span>  -->
		    						</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							CAMPUS: <span class="required">*</span>
						</td>
						<td colspan="2">
							<!-- Populating Campus from Database -->
							<select name="campusID" id="campusID">
							<% 
								try
								{
									rs = st.executeQuery("SELECT DISTINCT CAMPUS_ID, CNAME FROM CAMPUS ORDER BY CNAME");
									while(rs.next())
						    		{
						    			%>
						    			<option value="<%= rs.getString("CAMPUS_ID").trim()%>"><%= rs.getString("CNAME")%></option>
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
						<td colspan="1" class="field">
							LAB ID: <span class="required">*</span>
						</td>
						<td colspan="2">
							<!-- Populating Lab from Database -->
							<select name="labID" id="labID">
							<% 
								try
								{
									rs = st.executeQuery("SELECT DISTINCT LAB_ID FROM LAB ORDER BY LAB_ID");
									while(rs.next())
						    		{
						    			%>
						    			<option value="<%= rs.getString("LAB_ID").trim()%>"><%= rs.getString("LAB_ID")%></option>
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
						<td colspan="1" class="field">
							CONTAINER CODE: <span class="required">*</span>
						</td>
						<td colspan="3">
							<input maxlength="5" type="text" id="containerCode" name="containerCode" size="7" 
								value="<%= session.getAttribute("containerCode") != null? session.getAttribute("containerCode"):"" %>"/>
								<sub> 5 Character Max</sub>
							<br/>
							<span class="error">${messages.container}</span>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							IMAGE:
						</td>
						<td colspan="2">
							<input type="file" name="itemImage" id="containerCode"/><br/>
							<sub>UPTO 100 KB File Size Allowed</sub>
							<br/>
							<span class="error">${messages.image}</span>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							QUANTITY: <span class="required">*</span>
						</td>
						<td colspan="2">
							<input maxlength="5" type='text' name="quantity" id="quantity" onkeypress='validate(event)' size="7"
								value="<%= session.getAttribute("quantity") != null? session.getAttribute("quantity"):"" %>"/>
								<sub> 5 Numbers Max</sub>
							<br/>
							<span class="error">${messages.quantity}</span>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							MIN QUANTITY: <span class="required">*</span>
						</td>
						<td colspan="2">
							<input maxlength="5" type='text' name="minQuantity" id="minQuantity" onkeypress='validate(event)' size="7"
								value="<%= session.getAttribute("minQuantity") != null? session.getAttribute("minQuantity"):"" %>"/>
								<sub> 5 Numbers Max</sub>
							<br/>
							<span class="error">${messages.minQuantity}</span>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							STATUS: <span class="required">*</span>
						</td>
						<td colspan="2">
							<input type="radio" name="status" id="status" value="good" checked>GOOD
							<input type="radio" name="status" id="status" value="damaged">DAMAGED
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							MANUFACTURER: <span class="required">*</span>
						</td>
						<td colspan="2">
							<!-- Populating Manufacturer from Database -->
							<select name="manufacturerID" id="manufacturerID">
							<% 
								try
								{
									rs = st.executeQuery("SELECT DISTINCT MANUFACTURER_ID, MNAME FROM MANUFACTURER ORDER BY MNAME");
									while(rs.next())
						    		{
						    			%>
						    			<option value="<%= rs.getString("MANUFACTURER_ID").trim()%>"><%= rs.getString("MNAME")%></option>
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
						<td colspan="1" class="field">
							WARRANTY: <span class="required">*</span>
						</td>
						<td colspan="2">
							<textarea maxlength="50" name="warranty" id="warranty" cols="30" rows="2"><%= session.getAttribute("warranty") != null? session.getAttribute("warranty"):"" %></textarea>
							<br/>
							<sub>50 Character Max</sub>
							<br/>
							<span class="error">${messages.warranty}</span>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							PRODUCT CODE: <span class="required">*</span>
						</td>
						<td colspan="2">
							<input maxlength="15" type="text" name="productCode" id="productCode" size="22" 
								value="<%= session.getAttribute("productCode") != null? session.getAttribute("productCode"):"" %>"/>
								<sub> 15 Character Max</sub>
							<br/>
							<span class="error">${messages.productCode}</span>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							PURCHASE DATE: <span class="required">*</span>
						</td>
						<td colspan="2">
							<input type="text" name="purchaseDate" id="purchaseDate" readonly
								value="<%= session.getAttribute("purchaseDate") != null? session.getAttribute("purchaseDate"):"" %>"/>
							<br/>
							<span class="error">${messages.purchaseDate}</span>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							PRICE $: <span class="required">*</span>
						</td>
						<td colspan="2">
							<input maxlength="12" type='text' name="price" id="price" onkeypress='validate(event)' size="12"
								value="<%= session.getAttribute("price") != null? session.getAttribute("price"):"" %>"/>
							<br/>
							<span class="error">${messages.price}</span>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							EXPIRY DATE: <span class="required">*</span>
						</td>
						<td colspan="2">
							<input type="text" name="expiryDate" id="expiryDate" readonly
								value="<%= session.getAttribute("expiryDate") != null? session.getAttribute("expiryDate"):"" %>"/>
							<br/>
							<span class="error">${messages.date}</span>
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							DESCRIPTION: <span class="required">*</span>
						</td>
						<td colspan="2">
							<textarea maxlength="4000" name="description" id="description" cols="30" rows="5"><%= session.getAttribute("description") != null? session.getAttribute("description"):"" %></textarea>
							<br/>
							<sub>4000 Character Max</sub>
							<br/>
							<span class="error">${messages.description}</span>
						</td>
					</tr>
					<tr>
						<td colspan="3">
							<table id="additionalDescriptionItem">
								<tr>
									<td colspan=2>
										<strong>Additional Item Description</strong>
										<input type="button" value="+" id="addRow"/>
										<input type='button' value='-' id='deleteRow'>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td colspan="2">
						</td>
						<td colspan="1">
							<input id="submit" type="submit" class="btnSubmit" value="Create Item">
						</td>
					</tr>
				</table>
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
			</form>
		</td>
	</tr>
</table>
</body>
</html>