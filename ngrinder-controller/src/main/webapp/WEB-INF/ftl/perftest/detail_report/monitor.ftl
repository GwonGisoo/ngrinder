<div class="page-header page-header">
	<h4>Monitor</h4>
</div>
<h6>CPU</h6>
<div class="chart" id="cpu_usage_chart"></div>
<h6>Used Memory</h6>
<div class="chart" id="mem_usage_chart"></div>
<h6 id="received_byte_per_sec_chart_header">Received Byte Per Second</h6>
<div class="chart" id="received_byte_per_sec_chart"></div>
<h6 id="sent_byte_per_sec_chart_header">Sent Per Second</h6>
<div class="chart" id="sent_byte_per_sec_chart"></div>
<h6 id="custom_monitor_chart_1_header">Custom Monitor Chart 1</h6>
<div class="chart" id="custom_monitor_chart_1"></div>
<h6 id="custom_monitor_chart_2_header">Custom Monitor Chart 2</h6>
<div class="chart" id="custom_monitor_chart_2"></div>
<h6 id="custom_monitor_chart_3_header">Custom Monitor Chart 3</h6>
<div class="chart" id="custom_monitor_chart_3"></div>
<h6 id="custom_monitor_chart_4_header">Custom Monitor Chart 4</h6>
<div class="chart" id="custom_monitor_chart_4"></div>
<h6 id="custom_monitor_chart_5_header">Custom Monitor Chart 5</h6>
<div class="chart" id="custom_monitor_chart_5"></div>

<script>
	function getMonitorDataAndDraw(testId, targetIP) {
		var ajaxObj = new AjaxObj("/perftest/api/" + testId + "/monitor");
		ajaxObj.params = {'targetIP': targetIP, 'imgWidth': 700};
		ajaxObj.success = function (data) {
			var interval = data.chartInterval;
			drawChart('cpu_usage_chart', [data.cpu], formatPercentage, interval);
			drawChart('mem_usage_chart', [data.memory], formatMemory, interval);
			drawChart("received_byte_per_sec_chart", [data.received], formatNetwork, interval);
			drawChart("sent_byte_per_sec_chart", [data.sent], formatNetwork, interval);
			drawOptionalChart("custom_monitor_chart_1", [data.customData1], formatNetwork, interval);
			drawOptionalChart("custom_monitor_chart_2", [data.customData2], formatNetwork, interval);
			drawOptionalChart("custom_monitor_chart_3", [data.customData3], formatNetwork, interval);
			drawOptionalChart("custom_monitor_chart_4", [data.customData4], formatNetwork, interval);
			drawOptionalChart("custom_monitor_chart_5", [data.customData5], formatNetwork, interval);
		};
		ajaxObj.call();
	}
	function drawChart(id, data, yFormat, interval) {
		var result = new Chart(id, data, null, yFormat, interval);
		return result.plot();
	}

	function drawOptionalChart(id, data, interval, lables) {
		var result = drawChart(id, data, interval, lables);
		if (result.isEmpty()) {
			$("#" + id).hide();
			$("#" + id + "_header").hide();
		}
	}

	getMonitorDataAndDraw(${id}, "${targetIP}");
</script>