<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Checkout Item IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.elevatezoom.js"></script>
	<script src="${pageContext.request.contextPath}/jQuery/paging.js"></script>
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
			<h4>You are in Item Checkout</h4>
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
		<form method="post" action="${pageContext.request.contextPath}/Item_Checkout_Servlet">
			<table>
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
				ResultSet rsSub2 = null;
				
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
			<colgroup>
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			</colgroup>
			<tr>
				<td colspan="4">
					<h3>CHECKOUT ITEM FORM</h3>
					<h4>Fields marked with an <span class="required">*</span> are required.</h4>
				</td>
			</tr>
			<tr>
				<td colspan="2" class="field">
					USER ID : <span class="required">*</span>
				</td>
				<td colspan="2">
					<input type="text" name="userID" id="userID" value="${param.userID}" />
					<br/>
					<span class="error">${messages.userID}</span>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<input id="submit" name="act" type="submit" class="btnSubmit" value="Items on Hold">
				</td>
				<td colspan="2">
					<input id="submit" name="act" type="submit" class="btnSubmit" value="Checkout New Item">
				</td>
			</tr>
			<%
				String valid = request.getAttribute("valid") != null ? request.getAttribute("valid").toString() : "";
				//for items on hold by user
				if(valid != null && valid.trim().equals("1"))
				{
					String userID = session.getAttribute("userID").toString();
					try
					{
						rs = st.executeQuery("SELECT * FROM ITEM_HOLD WHERE USER_ID = '"+userID+"' ORDER BY DATE_OF_HOLD");
						if(!rs.isBeforeFirst())
						{
			%>
			<tr>
				<td colspan="4">
					<span class="error">
						<strong>No Items were put on hold by <%=userID %></strong>
					</span>
				</td>
			</tr>
			<% 
						}
						else
						{
							while(rs.next())
							{
								String itemID = rs.getString("ITEM_ID");
								rsSub = st1.executeQuery("SELECT * FROM ITEM WHERE ITEM_ID = '"+itemID+"'");
								
								if(rsSub.next())
								{
									String campusID = rsSub.getString("CAMPUS_ID").trim();
									String labID = rsSub.getString("LAB_ID").trim();
									String containerCode = rsSub.getString("CONTAINER_CODE").trim();
									String categoryID = rsSub.getString("CATEGORY_ID").trim();
									
									String barcodeID = campusID + labID + containerCode + categoryID + itemID;
			%>
			<tr class="itemCheckoutShowTableRow">
				<td colspan="4">
					<table width="100%" border="1">
					<colgroup>
					    <col width="45%">
					    <col width="20%">
					    <col width="40%">
					</colgroup>
						<tr>
							<td class="field">
								ITEM ID :
							</td>
							<td colspan="2">
								<%= barcodeID %>
							</td>
						</tr>
						<tr>
							<td class="field">
								DATE OF HOLD :
							</td>
							<td colspan="2">
								<%= rs.getString("DATE_OF_HOLD") %>
							</td>
						</tr>
						<tr>
							<td class="field">
								CAMPUS ID :
							</td>
							<td colspan="2">
								<%= campusID %>
							</td>
						</tr>
						<tr>
							<td class="field">
								LAB ID :
							</td>
							<td colspan="2">
								<%= labID %>
							</td>
						</tr>
						<tr>
							<td class="field">
								CATEGORY ID :
							</td>
							<td colspan="2">
								<%= categoryID %>
							</td>
						</tr>
						<tr>
							<td class="field">
								CONTAINER CODE :
							</td>
							<td colspan="2">
								<%= containerCode %>
							</td>
						</tr>
						<tr>
							<td class="field">
								QUANTITY ON HOLD : <span class="required">*</span>
							</td>
							<td colspan="2">
								<input type="text" name="bookID<%= itemID %>" value="<%= rs.getString("QUANTITY_HOLD") %>" size="5" maxlength="3" value="0"  onkeypress='validate(event)' />
								<sub>999 Max</sub>
							</td>
						</tr>
						<tr>
							<td colspan="3">
								<button id="releaseItem" name="act" type="submit" class="btnSubmit" value="<%= itemID %>">RELEASE</button>
							</td>
						</tr>
							<% 
								} //ending if for rsSub  
							%>
					</table>
				</td>
			</tr>
			<% 			
							}//ending while for rs
						}
					}
					catch(Exception e)
					{
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
				}
				//for checkout new items
				else if(valid != null && valid.trim().equals("2"))
				{
			%>
			<tr>
				<td colspan="4">
					You can scan or type in ITEM ID manually.
				</td>
			</tr>
			<tr>
				<td colspan="2" class="field">
					ITEM ID : <span class="required">*</span>
				</td>
				<td colspan="2">
					<input type="text" name="itemID" id="itemID" value="${param.itemID}" />
				</td>
			</tr>
			<tr>
				<td colspan="2" class="field">
					DATE :
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
				<td colspan="2" class="field">
					QUANTITY : <span class="required">*</span> 
				</td>
				<td colspan="2">
					<input type="text" name="rentQuantity" value="0" size="5" maxlength="3" onkeypress='validate(event)' />
					<sub>999 Max</sub>
				</td>
			</tr>
			<tr>
				<td colspan="4">
					<input id="submit" name="act" type="submit" class="btnSubmit" value="Rent Out">
				</td>
			</tr>
			<%	
				}
				//for error
				else if(valid != null && valid.trim().equals("3"))
				{
			%>
			<tr>
				<td colspan="4">
					<span class="error">
					<strong>ERROR:</strong>
					<br/>
					${messages.error}
					</span>
				</td>
			</tr>
			<%		
				}
				//for available quantity less than quantity asked
				else if(valid != null && valid.trim().equals("4"))
				{
			%>
			<tr>
				<td colspan="4">
					<span class="error">
					<strong>ERROR:</strong>
					<br/>
					${messages.error}
					<br/>
					<strong>
					ASKED QUANTITY : <%= session.getAttribute("askedQuantity") %>
					</strong>
					<br/>
					<strong>
					AVAILABLE QUANTITY : <%= session.getAttribute("quantityAvalable") %>
					</strong>
					</span>
				</td>
			</tr>
			<tr>
				<td colspan="4">
					Rent Available Quantity?
				</td>
			</tr>
			<tr>
				<td>
					<input id="yesBorrow" name="act" type="submit" class="btnSubmit" value="Yes Rent">
				</td>
				<td>
					<input id="noBorrow" name="act" type="submit" class="btnSubmit" value="No Thanks">
				</td>
			</tr>
			<%
				}
				//for successful item rented message
				else if(valid != null && valid.trim().equals("5"))
				{
			%>
			<tr>
				<td colspan="4">
					<span class="error">
					<strong>SUCCESSFUL:</strong>
					<br/>
					${messages.rented}
					</span>
				</td>
			</tr>
			<%
				}
				//for checkout new item with quantity less than asked quantity
				else if(valid != null && valid.trim().equals("6"))
				{
			%>
			<tr>
				<td colspan="4">
					<span class="error">
					<strong>ERROR:</strong>
					<br/>
					${messages.error}
					<br/>
					<strong>
					ASKED QUANTITY : <%= session.getAttribute("askedQuantity") %>
					</strong>
					<br/>
					<strong>
					AVAILABLE QUANTITY : <%= session.getAttribute("quantityAvalable") %>
					</strong>
					</span>
				</td>
			</tr>
			<tr>
				<td colspan="4">
					Rent Available Quantity?
				</td>
			</tr>
			<tr>
				<td>
					<input id="yesBorrow" name="act" type="submit" class="btnSubmit" value="Yes Rent Item">
				</td>
				<td>
				</td>
			</tr>
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
			</table> 
		</form>
		</td>
	</tr>
</table>
</body>
</html>