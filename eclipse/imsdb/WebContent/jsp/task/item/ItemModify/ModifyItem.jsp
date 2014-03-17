<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Item Modify IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.price_format.1.8.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.elevatezoom.js"></script>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	String valid2 = request.getAttribute("valid") != null ? request.getAttribute("valid").toString() : "";
	%>
	
	<script type="text/javascript">
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
		var regex = /[0-9]|\./;
		if( !regex.test(key) )
		{
			theEvent.returnValue = false;
			if(theEvent.preventDefault) theEvent.preventDefault();
		}
	}
	
	//zoom for item image
	$(document).ready(function(){
		$(".itemImage").elevateZoom();
	});
	
	
	//toggle modify textbox readonly or editeble
	$(document).ready(function(){
		var text_box = document.getElementById('itemModifyId');
		if(<%= valid2 %> != null && <%= valid2.trim() %> == "1")
		{       
	        text_box.setAttribute('readonly', 'readonly'); 
	    }
		else
		{       
			text_box.removeAttribute('readonly');
	    }
	});
	
	//adding item description dynamically
	$(document).ready(function(){
		var counter = 1;
		var counterMachinery = 2;
		//for adding ITEM Additional Information
	    $("#addRow").click(function () { 
	    	var descRow = "<tr>"+
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
	    });
		//for deleting textbox from Item Additional Information
	    $("#deleteRow").click(function () {
	    	$("#additionalDescriptionItem tr:last-child").remove();
		});
		
	    //for adding Machinery Item 
	    $("#addMachineryRow").click(function () { 
	    	var descRow = "<tr>"+
	    					"<td>"+
	    						"ITEM ID : <span class=\"required\">*</span> <input type=\"text\" name=\"machineryItem\"/>"+
	    					"</td>"+
	    				  "</tr>";
	    		
			$("#machineryInfo").find("tbody").append(descRow);
			counterMachinery++;
	    });
		//for deleting Machinery Item 
	    $("#deleteMachineryRow").click(function () {
		    $("#machineryInfo tr:last-child").remove();
		});
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
			<h4>You are in Modify Item Form</h4>
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
						<form action="${pageContext.request.contextPath}/Item_Add" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Add Item">
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
			<form method="post" action="${pageContext.request.contextPath}/Item_Modify_Servlet">
				<table>
				<colgroup>
				    <col width="25%">
				    <col width="25%">
				    <col width="25%">
				    <col width="25%">
				</colgroup>
					<tr>
						<td colspan="4">
							<h3>ITEM MODIFY FORM</h3>
							<h4>Fields marked with an <span class="required">*</span> are required.</h4>
							You can scan an ITEM Bar code or type in ITEM ID manually.
						</td>
					</tr>
					<tr>
						<td colspan="1" class="field">
							ITEM ID : <span class="required">*</span>
						</td>
						<td colspan="3">
							<input type="text" name="itemModifyId" id="itemModifyId" value="${param.itemModifyId}" />
							<br/>
							<span class="error">${messages.itemModifyId}</span>
						</td>
					</tr>
					<tr>
						<td>
							<input id="display" name="act" type="submit" class="btnSubmit" value="Display Item">
						</td>
						<td>
						</td>
					</tr>
					<% 
					String valid = request.getAttribute("valid") != null ? request.getAttribute("valid").toString() : "";
					if(valid != null && valid.trim().equals("1"))
					{
					%>
					<tr>
						<td colspan="4">
							<table id="itemInformation" border="1">
							<!-- Connecting to the database -->
							<%
								Context initContext;
								Context envContext;
								DataSource ds = null;
								Connection conn = null;
								Statement st = null;
								ResultSet rs = null;
								ResultSet rsSub = null;
								ResultSet rsSub2 = null;
								String itemID = null;
								try
								{
									initContext = new InitialContext();
									envContext  = (Context)initContext.lookup("java:/comp/env");
									ds = (DataSource)envContext.lookup("jdbc/myoracle");
									conn = ds.getConnection();
									st = conn.createStatement();
									
								    itemID = session.getAttribute("itemModifyId").toString().trim();
								}
								catch(Exception e)
								{
									request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
								}
							%>
							<colgroup>
							    <col width="45%">
							    <col width="30%">
							    <col width="25%">
							</colgroup>
							<tr>
								<td>
									<div id="imageItem">
										<img class="itemImage" 
										src="${pageContext.request.contextPath}/ItemDisplay_ItemCreated?itemID=<%= session.getAttribute("itemModifyId") %>" 
										width="90" height="90" alt="no image" onerror="this.src='${pageContext.request.contextPath}/images/no-photo.jpg';"/>
									</div>
								</td>
								<td colspan="2" class="field">
								<%
									try
									{
										itemID = itemID.substring(Math.max(0, itemID.trim().length() - 6));
								
										rs = st.executeQuery("SELECT * FROM ITEM WHERE ITEM_ID = '"+itemID+"'");
										
										while(rs.next())
										{
											String campusID = rs.getString("CAMPUS_ID").trim();
											String labID = rs.getString("LAB_ID").trim();
											String containerCode = rs.getString("CONTAINER_CODE").trim();
											String categoryID = rs.getString("CATEGORY_ID").trim();
											String itemIDDB = rs.getString("ITEM_ID").trim();
											String quantity = String.valueOf(rs.getInt("QUANTITY"));
											String minQuantity = String.valueOf(rs.getInt("MIN_QUANTITY"));
											String status = rs.getString("STATUS").toUpperCase();
											String description = rs.getString("DESCRIPTION");
											
											String barcodeID = campusID + labID + containerCode +categoryID+itemIDDB;
								%>
					
									ITEM ID : <%= barcodeID %>
								</td>
							</tr>
							<tr>
								<td class="field">
									CATEGORY :
								</td>
								<td colspan="2">
									<%
										rsSub = st.executeQuery("SELECT CATEGORY_TYPE FROM CATEGORY WHERE CATEGORY_ID = '"+categoryID+"'");
										while(rsSub.next())
										{%>
											<%= rsSub.getString("CATEGORY_TYPE").toUpperCase() %>
										<%}
									%>
								</td>
							</tr>
							<%
										if(categoryID.trim().equals("M"))
										{
											rsSub = st.executeQuery("SELECT MACHINERY_CONTAINING_ITEM_ID FROM MACHINERY WHERE MACHINERY_ITEM_ID ='"+itemIDDB.trim()+"'");
											
											if(rsSub.isBeforeFirst())
											{
												List<String> listOfString = new ArrayList<String>();
											%>
							<tr>
								<td colspan="3" class="field">
										MACHINERY CONTAINING ITEMS : 
										<input type="button" value="+" id="addMachineryRow"/>
										<input type='button' value='-' id='deleteMachineryRow'>
										<br/>
										<span class="error">${messages.item}</span>
								</td>
							</tr>	
							<tr>
								<td colspan="3">
									<table id="machineryInfo">		
												<%while(rsSub.next())
												{
													String machineItemID = rsSub.getString("MACHINERY_CONTAINING_ITEM_ID");
													listOfString.add(machineItemID);
												}
												for(int i =0 ; i<listOfString.size(); i++)
												{	
													rsSub2 = st.executeQuery("SELECT * FROM ITEM WHERE ITEM_ID = '"+listOfString.get(i).trim()+"'");
													
													while(rsSub2.next())
													{	
														String campusID2 = rsSub2.getString("CAMPUS_ID").trim();
														String labID2 = rsSub2.getString("LAB_ID").trim();
														String containerCode2 = rsSub2.getString("CONTAINER_CODE").trim();
														String categoryID2 = rsSub2.getString("CATEGORY_ID").trim();
														String itemIDDB2 = rsSub2.getString("ITEM_ID").trim();
													
														String barcodeID2 = campusID2 + labID2 + containerCode2 +categoryID2+itemIDDB2;
													%>
										<tr>
											<td colspan="3">
												ITEM ID : <span class="required">*</span>
												<input type="text" name="machineryItem" value="<%= barcodeID2 %>"/>
											</td>
										</tr>							
													<% 
													}
													%>	
																				
												<%
												}
												%>
									</table>	
								</td>
							</tr>				
											<%
											}
										}	
									%>
							<tr>
								<td class="field">
									LAB ID :
								</td>
								<td colspan="2">
									<%= labID.toUpperCase() %>
								</td>
							</tr>
							<tr>
								<td class="field">
									CAMPUS :
								</td>
								<td colspan="2">
									<%
										rsSub = st.executeQuery("SELECT CNAME FROM CAMPUS WHERE CAMPUS_ID = '"+campusID+"'");
										while(rsSub.next())
										{%>
										
											<%= rsSub.getString("CNAME").toUpperCase() %>
										<%}
									%>
								</td>
							</tr>	
							<tr>
								<td class="field">
									CONTAINER CODE : <span class="required">*</span>
								</td>
								<td colspan="2">
									<input maxlength="5" type="text" id="containerCode" name="containerCode" size="7" value="<%= containerCode.toUpperCase() %>"/>
										<sub> 5 Character Max</sub>
									<br/>
									<span class="error">${messages.container}</span>
								</td>
							</tr>	
							<tr>
								<td class="field">
									QUANTITY : <span class="required">*</span>
								</td>
								<td colspan="2">
									<input maxlength="5" type='text' name="quantity" id="quantity" onkeypress='validate(event)' size="7" value="<%= quantity %>"/>
									<sub> 5 Numbers Max</sub>
									<br/>
									<span class="error">${messages.quantity}</span>
								</td>
							</tr>	
							<tr>
								<td class="field">
									MIN QUANTITY : <span class="required">*</span>
								</td>
								<td colspan="2">
									<input maxlength="5" type='text' name="minQuantity" id="minQuantity" onkeypress='validate(event)' size="7" value="<%= minQuantity %>"/>
									<sub> 5 Numbers Max</sub>
									<br/>
									<span class="error">${messages.minQuantity}</span>
								</td>
							</tr>	
							<tr>
								<td class="field">
									STATUS : <span class="required">*</span>
								</td>
								<td colspan="2">
									<input type="radio" name="status" id="status" value="good" <% if(status.trim().toUpperCase().equals("GOOD")){%>checked='checked'<%}%> >GOOD<br>
									<input type="radio" name="status" id="status" value="damaged" <% if(status.trim().toUpperCase().equals("DAMAGED")){%>checked='checked'<%}%> >DAMAGED<br>
								</td>
							</tr>	
							<tr>
								<td class="field">
									MAUNFACTURER :
								</td>
								<td colspan="2">
									<%
										rsSub = st.executeQuery("SELECT * FROM ITEM_DETAIL WHERE ITEM_ID = '"+itemIDDB+"'");
										while(rsSub.next())
										{
											String warranty = rsSub.getString("WARRANTY_INFORMATION");
											String productCode = rsSub.getString("PRODUCT_CODE").trim();
											String price = String.valueOf(rsSub.getDouble("PRICE")).trim();
											
											String purDate = rsSub.getDate("PURCHASE_DATE").toString().trim();
											String expDate = rsSub.getDate("EXPIRY_DATE").toString().trim();
											
											//converting date to MM/dd/yyyy format
								    		SimpleDateFormat format10 = new SimpleDateFormat("yyyy-MM-dd");
								    	    SimpleDateFormat format20 = new SimpleDateFormat("MM/dd/yyyy");
								    		
								            Date datePur1 = format10.parse(purDate);
								            Date dateExp1 = format10.parse(expDate);
								           
								            purDate = format20.format(datePur1);
								            expDate = format20.format(dateExp1);
											
											rsSub2 = st.executeQuery("SELECT MNAME FROM MANUFACTURER WHERE MANUFACTURER_ID ='"+rsSub.getString("MANUFACTURER_ID")+"'");
											
											while(rsSub2.next())
											{%>
												<%= rsSub2.getString("MNAME").toUpperCase() %>
										  <%}
									%>
								</td>
							</tr>		
							<tr>
								<td class="field">
									WARRANTY : <span class="required">*</span>
								</td>
								<td colspan="2">
									<textarea maxlength="50" name="warranty" id="warranty" cols="30" rows="2"><%= warranty.trim() %></textarea>
									<br/>
									<sub>50 Character Max</sub>
									<br/>
									<span class="error">${messages.warranty}</span>
								</td>
							</tr>	
							<tr>
								<td class="field">
									PRODUCT CODE :
								</td>
								<td colspan="2">
									<%= productCode.trim() %>
								</td>
							</tr>
							<tr>
								<td class="field">
									PRICE $ : <span class="required">*</span>
								</td>
								<td colspan="2">
									<input maxlength="12" type='text' name="price" id="price" onkeypress='validate(event)' size="12"value="<%= price.trim() %>"/>
									<br/>
									<span class="error">${messages.price}</span>
								</td>
							</tr>
							<tr>
								<td class="field">
									PURCHASE DATE : <span class="required">*</span>
								</td>
								<td colspan="2">
									<input type="text" name="purchaseDate" id="purchaseDate" readonly value="<%= purDate.trim() %>"/>
									<br/>
									<span class="error">${messages.purchaseDate}</span>
								</td>
							</tr>
							<tr>
								<td class="field">
									EXPIRY DATE : <span class="required">*</span>
								</td>
								<td colspan="2">
									<input type="text" name="expiryDate" id="expiryDate" readonly value="<%= expDate.trim() %>"/>
									<br/>
									<span class="error">${messages.date}</span>
								</td>
							</tr>
										<%
										}
										%>	
							<tr>
								<td class="field">
									DESCRIPTION : <span class="required">*</span>
								</td>
								<td colspan="2">
									<textarea maxlength="4000" name="description" id="description" cols="30" rows="5"><%= description.trim() %></textarea>
									<br/>
									<sub>4000 Character Max</sub>
									<br/>
									<span class="error">${messages.description}</span>
								</td>
							</tr>	
							<tr>
								<td colspan="3" class="field">
										ITEM ADDITIONAL INFORMATION : 
										<input type="button" value="+" id="addRow"/>
										<input type='button' value='-' id='deleteRow'>
								</td>
							</tr>	
							<tr>
								<td colspan="3">
									<table id="additionalDescriptionItem">
									<col width="45%">
								    <col width="55%">
								    <tr>
								    </tr>
										<%
											rsSub = st.executeQuery("SELECT * FROM ITEM_ADDITIONAL_DESCRIPTION WHERE ITEM_ID = '"+itemIDDB+"' ORDER BY DESCRIPTION_FIELD");
											if (rsSub.isBeforeFirst()) 
											{
												while(rsSub.next())
												{%>
										<tr>
											<td>
												FIELD : <span class="required">*</span>
												<br/>
												<textarea maxlength="100" name="descField" cols="15" rows="3"><%= rsSub.getString("DESCRIPTION_FIELD") %></textarea><br/>
					    						<sub>100 Character Max</sub>
											</td>
											<td>
												VALUE :
												<br/>
												<textarea maxlength="4000" name="descValue" cols="35" rows="3"><%= rsSub.getString("DESCRIPTION_VALUE") %></textarea><br/>
					    						<sub>4000 Character Max</sub>
											</td>
										</tr>			
										
												<%}
											}%>
									</table>
								</td>
							</tr>
									<%}
								}
								catch(Exception e)
								{
									request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
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
							<tr>
								<td colspan="3">
									<input id="modify" name="act" type="submit" class="btnSubmit" value="Modify Item">
								</td>
							</tr>
							</table>
						</td>
					</tr>
					<%
					}
					else if(valid != null && valid.trim().equals("-1"))
					{%>
					<tr>
						<td colspan="4">
							<h4>ITEM <span class="required">'${param.itemModifyId}'</span> MODIFIED SUCSSFULLY</h4>
						</td>
					</tr>
					<%}
					%>
				</table>
			</form>
		</td>
	</tr>
</table>
</body>
</html>