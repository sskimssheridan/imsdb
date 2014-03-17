<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Search Item IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.elevatezoom.js"></script>
	<script src="${pageContext.request.contextPath}/jQuery/paging.js"></script>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !session.getAttribute("role").equals("STUDENT"))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
	<style type="text/css">    
         .pg-normal {
             color: black;
             font-weight: normal;
             text-decoration: none;    
             cursor: pointer;    
         }
         .pg-selected {
             color: black;
             font-weight: bold;        
             text-decoration: underline;
             cursor: pointer;
         }
    </style>
    
    <style type="text/css" media='print' >
	@page
    {
        size: auto;   /* auto is the initial value */
        margin: 0mm;  /* this affects the margin in the printer settings */
    }
	body {visibility: hidden;}
	#itemSerachTable 
	{
		visibility: visible;
        position: absolute;
        top: 0;
	}
	.itemSearchRows 
	{
		display:block!important;	
		page-break-inside:avoid;
		page-break-after:auto;
		
	}
	</style>
	
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
	
	$(document).ready(function(){
		//for image zooming
		$(".itemImage").elevateZoom();

	})
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
			<h4>You are in Item Search</h4>
		</td>
	</tr>
	<tr>
		<td id = "menuBar" colspan="1">
			<table>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Student_BackToMain" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Back To Main">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Student_Item_Booked" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Items On Hold">
						</form>
					</td>
				</tr>
			</table>
		</td>
		 <td id = "workingBar" colspan="3">
		 <form method="post" action="${pageContext.request.contextPath}/Student_Item_Search_Servlet">
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
						<h3>ITEM SEARCH</h3>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<input type="text" name="itemDesc" id="itemDesc" value="${param.itemDesc}" />
					</td>
					<td>
						<input id="search" name="act" type="submit" class="btnSubmit" value="Search Item">
					</td>
				</tr>
				<tr>
					<td colspan="4" class="field">
						ADVANCE SEARCH OPTIONS :
					</td>
				</tr>
				<tr>
					<td colspan="1" class="field">
						CAMPUS:
					</td>
					<td colspan="3">
						<!-- Populating Campus from Database -->
						<select name="campusID" id="campusID">
						<option value="ALL">ALL</option>
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
						CATEGORY:
					</td>
					<td colspan="3">
						<!-- Populating Category from Database -->
						<select name="categoryID" id="categoryID" >
						<option value="ALL">ALL</option>
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
				<tr>
					<td colspan="1" class="field">
						LAB ID: 
					</td>
					<td colspan="3">
						<!-- Populating Lab from Database -->
						<select name="labID" id="labID">
						<option value="ALL">ALL</option>
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
						QUANTITY:
					</td>
					<td colspan="2">
						<input maxlength="5" type='text' name="quantity" id="quantity" onkeypress='validate(event)' size="7"
							value="${param.quantity}"/>
							<sub> 5 Max</sub>
					</td>
					<td>
						<select name="qtyDetail" id="qtyDetail">
							<option value="above">AND ABOVE</option>
							<option value="below">AND BELOW</option>
							<option value="equal">EQUAL</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="3" class="field">
					</td>
					<td>
						<input id="search" name="act" type="submit" class="btnSubmit" value="Advance Item Search">
					</td>
				</tr>
				<% 
				String valid = request.getAttribute("valid") != null ? request.getAttribute("valid").toString() : "";
				if(valid != null && valid.trim().equals("1"))
				{
					    String itemDesc = null;
						itemDesc = session.getAttribute("itemDesc").toString().trim();
						
						String categoryIDSearch = request.getParameter("categoryID");
						String labIDSearch = request.getParameter("labID");
						String campusIDSearch = request.getParameter("campusID");
						String quantitySearch = request.getParameter("quantity");
						String quantityDetail = request.getParameter("qtyDetail");
				%>
				<tr>
					<td colspan="4">
						<table width="100%" id="itemSerachTable">
							<tr>
								<td>
									<h4>SEARCH RESULT</h4>
									<strong>CATEGORY ID: </strong><%= categoryIDSearch %>
									<br/>
									<strong>LAB ID: </strong><%= labIDSearch %>
									<br/>
									<strong>CAMPUS ID: </strong><%= campusIDSearch %>
									<br/>
									<strong>QUANTITY: </strong><%= (quantitySearch.toString().length() > 0) ? quantitySearch.toString()+" and "+ quantityDetail : "ALL" %>
								</td>
							</tr>
						<%
							try
							{
								String sql = "SELECT * FROM ITEM WHERE 1=1 ";
								
								//adding desc to select
								if(itemDesc != null || itemDesc != "")
								{
									sql += "AND UPPER(DESCRIPTION) LIKE '%"+itemDesc.trim().toUpperCase()+"%' ";
								}
								if(!categoryIDSearch.toUpperCase().equals("ALL"))
								{
									sql += "AND CATEGORY_ID = '"+categoryIDSearch.trim().toUpperCase()+"' ";
								}
								if(!labIDSearch.toUpperCase().equals("ALL"))
								{
									sql += "AND LAB_ID = '"+labIDSearch.trim().toUpperCase()+"' ";
								}
								if(!campusIDSearch.toUpperCase().equals("ALL"))
								{
									sql += "AND CAMPUS_ID = '"+campusIDSearch.trim().toUpperCase()+"' ";
								}
								if(!quantitySearch.toUpperCase().equals(""))
								{
									if(quantityDetail.trim().toUpperCase().equals("EQUAL"))
									{
										sql += "AND QUANTITY = "+Integer.parseInt(quantitySearch)+" ";
									}
									else if(quantityDetail.trim().toUpperCase().equals("ABOVE"))
									{
										sql += "AND QUANTITY >= "+Integer.parseInt(quantitySearch)+" ";
									}
									else if(quantityDetail.trim().toUpperCase().equals("BELOW"))
									{
										sql += "AND QUANTITY <= "+Integer.parseInt(quantitySearch)+" ";
									}
								}
								sql += "AND ITEM_ID NOT IN (SELECT DISTINCT MACHINERY_CONTAINING_ITEM_ID FROM MACHINERY) ";
								sql += "ORDER BY ITEM_ID";
								rs = st.executeQuery(sql);
								
								while(rs.next())
								{
									
									String bookItem = rs.getString("ITEM_ID").trim();
									String barcodeID = null;
						
									String campusID = rs.getString("CAMPUS_ID").trim();
									String labID = rs.getString("LAB_ID").trim();
									String containerCode = rs.getString("CONTAINER_CODE").trim();
									String categoryID = rs.getString("CATEGORY_ID").trim();
									String quantity = String.valueOf(rs.getInt("QUANTITY"));
									String minQuantity = String.valueOf(rs.getInt("MIN_QUANTITY"));
									String status = rs.getString("STATUS").toUpperCase();
									String description = rs.getString("DESCRIPTION");
									
									barcodeID = campusID + labID + containerCode + categoryID + bookItem;
									
								%>
								<tr class="itemSearchRows">
									<td>
										<div class="itemSerachDiv">
											<table width="100%" border="1">
											<colgroup>
											    <col width="35%">
											    <col width="25%">
											    <col width="40%">
											</colgroup>
												<tr>
													<td>
														<div id="imageItem">
															<img class="itemImage" 
															src="${pageContext.request.contextPath}/ItemDisplay_ItemCreated?itemID=<%= bookItem %>" 
															width="90" height="90" alt="no image" onerror="this.src='${pageContext.request.contextPath}/images/no-photo.jpg';"/>
														</div>
													</td>
													<td colspan="2"  class="field">
														<%= barcodeID%>
													</td>
												</tr>
												<tr>
													<td class="field">
														CAMPUS :
													</td>
													<td colspan="2">
														<%
															rsSub = st1.executeQuery("SELECT * FROM CAMPUS WHERE CAMPUS_ID ='"+campusID+"'");
															if (rsSub.next())
															{%>
																<%= rsSub.getString("CNAME").trim() %>
															<%}
														%>
													</td>
												</tr>
												<tr>
													<td class="field">
														CATEGORY :
													</td>
													<td colspan="2">
														<%
															rsSub = st1.executeQuery("SELECT * FROM CATEGORY WHERE CATEGORY_ID ='"+categoryID+"'");
															if (rsSub.next())
															{%>
																<%= rsSub.getString("CATEGORY_TYPE").trim() %>
															<%}
														%>
													</td>
												</tr>
												<tr>
													<td class="field">
														LAB ID :
													</td>
													<td colspan="2">
														<%=  labID %>
													</td>
												</tr>
												<tr>
													<td class="field">
														CONTAINER :
													</td>
													<td colspan="2">
														<%=  containerCode %>
													</td>
												</tr>
												<tr>
													<td class="field">
														DESCRIPTION :
													</td>
													<td colspan="2">
														<%=  description.trim() %>
													</td>
												</tr>
												<tr>
													<td class="field">
														QUANTITY :
													</td>
													<td colspan="2">
														<%=  quantity %>
													</td>
												</tr>
												<%
													if(!categoryID.trim().toUpperCase().equals("M"))
													{%>
												<tr>
													<td class="field">
														QUANTITY TO BORROW : <span class="required">*</span>
													</td>
													<td>
														<input type="text" name="quantityBorrow<%= bookItem %>" size="5" maxlength="3" value="0"  onkeypress='validate(event)'/>
														<sub>999 Max</sub>
													</td>
													<td>
														<button id="bookItem" name="act" type="submit" class="btnSubmit" value="<%= bookItem %>">Book Item</button>
													</td>
												</tr>	
													<%}
												%>
											</table>
										</div>	
									</td>
								</tr>
									
							  		<%	
							  	}
							}
							catch(Exception e)
							{
								request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
							}
						
						%>
						
						</table>
						<div id="pageNavPosition"></div>
						 <script type="text/javascript">
					        var pager = new Pager('itemSerachTable', 5); 
					        pager.init(); 
					        pager.showPageNav('pager', 'pageNavPosition'); 
					        pager.showPage(1);
    					</script>
    					<br/>
    					<input type='button' class="btnSubmit" value='Print' onclick='window.print()'/>
					</td>
				</tr>
				<%
				}//ending if for hidden table
				else if(valid != null && valid.trim().equals("2"))
				{%>
				<tr>
					<td colspan="4">
						<span class="error">
						<strong>ERROR:</strong>
						<br/>
						${messages.error}
						</span>
					</td>
				</tr>
			  <%}//ending if for 0 quantity
			  	else if(valid != null && valid.trim().equals("3"))
				{%>
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
						Do you want to borrow item for <span class="error"><%= session.getAttribute("quantityAvalable") %></span> quantity?
					</td>
				</tr>
				<tr>
					<td>
						<input id="yesBorrow" name="act" type="submit" class="btnSubmit" value="Yes Borrow">
					</td>
					<td>
						<input id="noBorrow" name="act" type="submit" class="btnSubmit" value="No Thanks">
					</td>
				</tr>
			  <%}//ending if for asked quantity greater than quantity
			  else if(valid != null && valid.trim().equals("4"))
			  {%>
				<tr>
					<td colspan="4">
						<span class="error">
						<strong>ERROR:</strong>
						<br/>
						${messages.askLabRep}
						</span>
					</td>
				</tr>  
			  <%}//ending if for quantity equal to 0 and asking user to meet lab representative
			  else if(valid != null && valid.trim().equals("5"))
			  {%>
				<tr>
					<td colspan="4">
						<span class="error">${messages.searchResult}</span>
					</td>
				</tr>
			  <%}// ending if of displaying what user did with search
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