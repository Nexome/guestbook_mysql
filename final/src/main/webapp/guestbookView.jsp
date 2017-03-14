<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
    <title>Guestbook</title>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
        google.charts.load('current', {'packages': ['corechart']});
        google.charts.setOnLoadCallback(drawChart);

        function drawChart() {

            var data = google.visualization.arrayToDataTable(
                [
                    <c:forEach var="entry" varStatus="status" items="${statistics}">
                        <c:if test="${status.first}">
                            ['Guestbook', '# of messages'],
                        </c:if>
                        ['${entry.key}', ${entry.value}]
                        <c:if test="${not status.last}">
                        ,
                        </c:if>
                    </c:forEach>
                ]
            );

            var options = {
                title: 'Messages in guestbooks',
                is3D: true
            };

            var chart = new google.visualization.PieChart(document.getElementById('piechart'));

            chart.draw(data, options);
        }
    </script>

</head>

<body>
<c:if test="${empty user}">
    <p>Hello! please
        <a href="${loginURL}">Sign in</a>
        to include your name with greetings you post.</p>
</c:if>
<c:if test="${not empty user}">
    <p>Hello, ${fn:escapeXml(user.nickname)}! (You can
        <a href="${logoutURL}">sign out</a>.)</p>
</c:if>

<form method="post">
    <!-- l'action est utilisée par le contrôleur -->
    <input type="hidden" name="action" value="addGreeting">
    <div><textarea name="content" rows="3" cols="60"></textarea></div>
    <div><input type="submit" value="Post Greeting"/></div>
    <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
</form>

<form method="post">
    <!-- l'action est utilisée par le contrôleur -->
    <input type="hidden" name="action" value="changeGuestBook">
    <div><input type="text" name="guestbookName" value="${fn:escapeXml(guestbookName)}" list="books"/></div>
    <datalist id="books">
        <c:forEach var="book" items="${books}" varStatus="status">
            <option>${fn:escapeXml(book)}</option>
        </c:forEach>
    </datalist>
    <div><input type="submit" value="Switch Guestbook"/></div>
</form>

<c:if test="${empty greetings}">
    <p>Guestbook '${fn:escapeXml(guestbookName)}' has no messages.</p>
</c:if>
<c:if test="${not empty greetings}">
    <p>Messages in Guestbook '${fn:escapeXml(guestbookName)}'
    <hr>
    </p>
    <c:forEach var="greeting" items="${greetings}" varStatus="status">
        <b>
            <c:if test="${empty greeting.authorEmail}">
                An anonymous person
            </c:if>
            <c:if test="${not empty greeting.authorEmail}">
                ${fn:escapeXml(greeting.authorEmail)}
                <c:if test="${not empty user and user.userId eq greeting.authorId }">
                    (You)
                </c:if>
            </c:if>
        </b> wrote: (<fmt:formatDate value="${greeting.created}" type="both"/>)<br>
        <blockquote>${fn:escapeXml(greeting.content)}</blockquote>
    </c:forEach>
</c:if>

<div id="piechart" style="width: 500px; height: 300px;"></div>
</body>

</html>
