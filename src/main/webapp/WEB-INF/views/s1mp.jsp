<%@ page session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Invoice Statement</title>
    <meta name="viewport" content="width=device-width, minimum-scale=1, maximum-scale=1">
    <link rel="stylesheet" href="<c:url value="/resources/blueprint/screen.css" />" type="text/css" media="screen, projection">
    <%--<link rel="stylesheet" href="<c:url value="/resources/blueprint/print.css" />" type="text/css" media="print">--%>
    <!--[if lt IE 8]>
    <link rel="stylesheet" href="<c:url value="/resources/blueprint/ie.css" />" type="text/css" media="screen, projection">
    <![endif]-->
    <%--<link rel="stylesheet" href="<c:url value="/resources/popup.css" />" type="text/css" media="screen, projection">--%>
    <script type="text/javascript" src="<c:url value="/resources/jquery-1.4.min.js" /> "></script>
    <script type="text/javascript" src="<c:url value="/resources/json.min.js" /> "></script>
    <script type="text/javascript" src="<c:url value="/resources/canvas-all.js" /> "></script>
    <script>
        var sr =  JSON.parse('${not empty signedRequestJson?signedRequestJson:"{}"}');
        Sfdc.canvas(function() {
            // Setup the finalize
            if (sr.client.oauthToken){
                $('#finalizeButton').click(finalizeHandler);
                $('#finalizeButton').show();
            }
            else{
                $('#finalizeButton').click(null);
                $('#finalizeButton').hide();
            }
            Sfdc.canvas.client.autogrow(sr.client, true);
        });

        function finalizeHandler(){
            var namespace = (!!sr.context.application.namespace) ? (sr.context.application.namespace + "__") : "";
            var invoiceUri=sr.context.links.sobjectUrl + namespace + "Invoice_Statement__c/${order.id}";
            var status = namespace + "Status__c";
            var body={};
            body[status]="Shipped";
            Sfdc.canvas.client.ajax(invoiceUri,{
                client : sr.client,
                method: 'PATCH',
                contentType: "application/json",
                data: JSON.stringify(body),
                success : localUpdateHandler
            });
        }

        function localUpdateHandler(data){
            console.log("Status from remote salesforce call:", data);
            if (data.status === 200 || data.status === 204){
                // Update local Order status.
                $.ajax({
                    url : "/order/${order.id}",
                    type: "PUT",
                    data: JSON.stringify({status:"Shipped", orderId:"${order.orderId}", total:"${order.total}"}),
                    success: function() {
                        var site = (!!sr.context.user.siteUrlPrefix) ? (sr.context.user.siteUrlPrefix) : "";
                        window.top.location.href = sr.client.targetOrigin + site + "/${order.id}";// getRoot() + "/${order.id}";
                    },
                    error: function(){
                        alert("Error occurred updating local status.");
                    },
                    contentType:"application/json"
                });
            }
            else{
                alert("Remote call to salesforce failed. Status: "+data.status+", Text: " + data.statusText);
            }
        }

        function getRoot() {
            return sr.client.instanceUrl;
        }
    </script>

    <style>
        #myTable {
            padding: 0px 0px 4px 0px;
        }

        #myTable td {
            border-bottom: 1px solid #CCCCCC;
        }

        .myCol {
            text-align: left;
            color: #4a4f5b;
            font-weight: bold;
        }

        .valueCol {
            padding-left:10px;
        }

        #bodyDiv {
            padding:0px;
            padding-top: 0px;
        }

        #lineItemTitle {
            font-size: 1.2em;
            font-weight: bold;
            padding-right: 10px;
        }

        #myPageBlockTable {
            padding:5px;
            background: #F8F8F8;
            border: 1px solid #CDCDCD;
            border-radius: 6px;
            border-top: 3px solid #998c7c;
        }

        #lineItemTable {
            border-right: 1px solid #CDCDCD;
            border-left: 1px solid #CDCDCD;
        }

        #lineItemTable th {
            background: #f2f3f3;
            border: 1px solid #CDCDCD;
            border-left: 0px;
            position: relative;
            bottom: 2px;
            padding-right: 5px;
            padding-left: 4px;
        }

        .span-12 {
            width:700px;
        }

        .myLineItemTableRow {
            background: white;
            border-bottom: 1px solid #CCCCCC;
        }

        .myLineItemTableRow td {
            padding: 4px 0px 4px 8px;
            border-bottom: 1px solid #CCCCCC;
        }
    </style>

</head>
<body>
    <div id="bodyDiv" style="width:inherit;opacity=0.7">
        <div class="container">
            <div>
                <div id="myPageBlockTable">
                    <h4 color=#4a4f5b" font-weight="bold">Mobile Card Preview - Click to Open</h4>
                    <table id="myTable" width="100%">
                        <col width="40%">
                        <tr><td class="myCol">Invoice Order Total:</td><td class="valueCol"><c:out value="${order.total}"/></td></tr>
                        <tr><td class="myCol">Number of Items:</td><td class="valueCol"><c:out value="${fn:length(order.lineItems)}"/></td></tr>
                        <tr><td class="myCol">Shipment Status:</td><td class="valueCol" valign="center"><c:out value="${order.status}"/>
                            <c:choose>
                                <c:when test="${order.status == 'Shipped'}">
                                    <img src="/resources/images/shipped.png" />
                                </c:when>
                                <c:otherwise>
                                    <img src="/resources/images/pending.png" />
                                </c:otherwise>
                            </c:choose>
                        </td></tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
