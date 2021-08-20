<%@ page contentType="image/jpeg"%>
<%@ page import = "org.jfree.chart.*" %>
<%@ page import ="com.mission.javabeans.*"%>
<%
	ServletOutputStream sos = response.getOutputStream();
	BarChartBean bcb = new BarChartBean();
	JFreeChart chart = bcb.getBarChart();
	ChartUtilities.writeChartAsPNG(sos, chart, 450, 450);
%>