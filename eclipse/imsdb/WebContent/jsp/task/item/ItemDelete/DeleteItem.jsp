<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Item Delete IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.elevatezoom.js"></script>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	String valid2 = request.getAttribute("valid") != null ? request.getAttribute("valid").toString() : "";
	%>
	
	<script type="text/javascript">
	$(document).ready(function(){
		$(".itemImage").elevateZoom();
		
		//toggle search textbox readonly or editeble
		var text_box = document.getElementById('itemDeleteId');
		if(<%= valid2 %> != null && <%= valid2.trim() %> == "1")
		{       
	        text_box.setAttribute('readonly', 'readonly'); 
	    }
		else
		{       
			text_box.removeAttribute('readonly');
	    }
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
			<h4>You are in Delete Item Form</h4>
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
						<form action="${pageContext.request.contextPath}/Item_Modify" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Modify Item">
						</form>
					</td>
				</tr>
			</table>
		</td>
		 <td id = "workingBar" colspan="3">
		 <form method="post" action="${pageContext.request.contextPath}/Item_Delete_Servlet">
			<table>
			<colgroup>
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			</colgroup>
				<tr>
					<td colspan="4">
						<h3>ITEM DELETE FORM</h3>
						<h4>Fields marked with an <span class="required">*</span> are required.</h4>
						You can scan an ITEM Bar code or type in ITEM ID manually.
					</td>
				</tr>
				<tr>
					<td colspan="1" class="field">
						ITEM ID : <span class="required">*</span>
					</td>
					<td colspan="3">
						<input type="text" name="itemDeleteId" id="itemDeleteId" value="${param.itemDeleteId}" />
						<br/>
						<span class="error">${messages.itemDeleteId}</span>
					</td>
				</tr>
				<tr>
					<td >
						<input id="display" name="act" type="submit" class="btnSubmit" value="Display Item">
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
								
							    itemID = session.getAttribute("itemDeleteId").toString().trim();
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
								<td colspan="3">
									<input id="delete" name="act" type="submit" class="btnSubmit" value="Delete Item">
								</td>
							</tr>
							<tr>
								<td>
									<div id="imageItem">
										<img class="itemImage" 
										src="${pageContext.request.contextPath}/ItemDisplay_ItemCreated?itemID=<%= session.getAttribute("itemDeleteId") %>" 
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
								</td>
							</tr>				
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
									ITEM ID: <%= barcodeID2 %>
								</td>
							</tr>							
													<% 
													}
												
													%>								
												<%
												}
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
									CONTAINER CODE :
								</td>
								<td colspan="2">
									<%= containerCode.toUpperCase() %>
								</td>
							</tr>	
							<tr>
								<td class="field">
									QUANTITY :
								</td>
								<td colspan="2">
									<%= quantity %>
								</td>
							</tr>	
							<tr>
								<td class="field">
									MIN QUANTITY :
								</td>
								<td colspan="2">
									<%= minQuantity %>
								</td>
							</tr>	
							<tr>
								<td class="field">
									STATUS :
								</td>
								<td colspan="2">
									<%= status %>
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
									WARRANTY :
								</td>
								<td colspan="2">
									<%= warranty.trim() %>
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
									PRICE :
								</td>
								<td colspan="2">
									<%= "$ "+price.trim() %>
								</td>
							</tr>
							<tr>
								<td class="field">
									PURCHASE DATE :
								</td>
								<td colspan="2">
									<%= purDate.trim() %>
								</td>
							</tr>
							<tr>
								<td class="field">
									EXPIRY DATE :
								</td>
								<td colspan="2">
									<%= expDate.trim() %>
								</td>
							</tr>
										<%
										}
										%>		
							<tr>
								<td class="field">
									DESCRIPTION :
								</td>
								<td colspan="2">
									<%= description.trim() %>
								</td>
							</tr>		
										<%
											rsSub = st.executeQuery("SELECT * FROM ITEM_ADDITIONAL_DESCRIPTION WHERE ITEM_ID = '"+itemIDDB+"' ORDER BY DESCRIPTION_FIELD");
											if (rsSub.isBeforeFirst()) 
											{%>
							<tr>
								<td colspan="3" class="field">
										ITEM ADDITIONAL INFORMATION :
								</td>
							</tr>
												<%while(rsSub.next())
												{%>
							<tr>
								<td class="field">
									<%= rsSub.getString("DESCRIPTION_FIELD") %> :
								</td>
								<td colspan="2">
									<%= rsSub.getString("DESCRIPTION_VALUE") %>
								</td>
							</tr>			
										
												<%}
											}
											
										%>			
								  <% }
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
						</table>
					</td>
				</tr>
				<%
				}
				else if(valid != null && valid.trim().equals("-1"))
				{%>
				<tr>
					<td colspan="4">
						<h4>ITEM <span class="required">'${param.itemDeleteId}'</span> DELETED SUCSSFULLY</h4>
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