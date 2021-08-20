<%@ page contentType="image/jpeg"%>
<%@ page import = "org.jfree.chart.*" %>
<%@ page import ="com.mission.javabeans.*"%>
<%
    ServletOutputStream sos = response.getOutputStream();
    PieChartBean pcb = new PieChartBean(); 
	JFreeChart chart = pcb.getPieChart();
	ChartUtilities.writeChartAsPNG(sos, chart, 450, 450);
%>
