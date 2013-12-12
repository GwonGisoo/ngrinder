
<#if resultsub?exists>
	<script>
			curPeakTps = ${(resultsub.peakTpsForGraph!0)?c};
	  		curTps = ${(resultsub.tpsChartData!0)?c};
	  		curRunningTime = ${(resultsub.testTime!0)?c};
	  		curRunningProcesses = ${(resultsub.process!0)?c};
	  		curRunningThreads = ${(resultsub.thread!0)?c};
	  		curStatus = <#if resultsub.success?? && resultsub.success>true<#else>false</#if>
	  		<#if resultsub.totalStatistics?exists>
	  		curRunningCount = ${((resultsub.totalStatistics.Tests!0)+(resultsub.totalStatistics.Errors!0))?c};
	  		</#if>
	  		curAgentStat = [
	  			${agentStat}
	  		];
	  		curMonitorStat = [
	  		    ${monitorStat}
	  		];
	</script>
	<#function bytesFormatter bytes>
		<#local kilo=1024 />
		<#local mega=kilo*kilo />
		<#local giga=mega*kilo />
		<#local tera=giga*kilo />
		<#if bytes == 0>
			<#return "-">
		</#if>
		<#if (bytes / tera > 1)>
			<#return (bytes/tera)?string("0.#")+"TB">
		</#if>
		<#if (bytes / giga > 1)>
			<#return (bytes/giga)?string("0.#")+"GB">
		</#if>
		<#if (bytes / mega > 1)>
			<#return (bytes/mega)?string("0.#")+"MB">
		</#if>
		<#if (bytes / kilo > 1)>
			<#return (bytes/kilo)?string("0.#")+"KB">
		</#if>
		<#return bytes?string("0")+"B">
	</#function>
	<table >
		<tbody>	 
		    <#list resultsub?keys as mKey>
				<#if mKey=='lastSampleStatistics'>
						<#assign item = resultsub[mKey]>   
						<#list item as statistics>
						<tr id="last_sample_table_item">
							<td>${statistics.testNumber!'&nbsp;'}</td>
							<td class="ellipsis">${statistics.testDescription!'&nbsp;'}</td>
							<td>${statistics.Tests!'&nbsp;'}</td>
							<td>${statistics.Errors!'&nbsp;'}</td>
							<td>${(statistics['Mean_Test_Time_(ms)']!0)?string("0.##")}</td>
							<td>${(statistics.TPS!0)?string("0.##")}</td>
							<td>${bytesFormatter(((statistics['Response_bytes_per_second']!0)?c)?number)}</td>
							<td>${(statistics['Mean_time_to_first_byte']!0)?string("0.##")}</td>
						</tr>
						</#list>
				</#if>
				<#if mKey=='cumulativeStatistics'>
						<#assign item = resultsub[mKey]>   
						<#list item as statistics>
						<tr id="accumulated_sample_table_item">
							<td>${statistics.testNumber!'&nbsp;'}</td>
							<td class="ellipsis">${statistics.testDescription!'&nbsp;'}</td>
							<td>${statistics.Tests!'&nbsp;'}</td>
							<td>${statistics.Errors!'&nbsp;'}</td>
							<td>${(statistics['Mean_Test_Time_(ms)']!0)?string("0.##")}</td>
							<td>${(statistics.TPS!0)?string("0.##")}</td>
							<td>${statistics.Peak_TPS!'-'}</td>
							<td>${(statistics['Test_Time_Standard_Deviation_(ms)']!0)?string("0.##")}</td>
						</tr>
						</#list>
				</#if>
			</#list>
		</tbody>
	</table>
</#if>