<!DOCTYPE html>
<html>
	<head>
		<#include "../common/common.ftl">
		<#include "../common/datatables.ftl">
		<#include "../common/jqplot.ftl">
		<title><@spring.message "perfTest.table.title"/></title>
		<style>
			td.today {
				background-image: url('${req.getContextPath()}/img/icon_today.png');
				background-repeat:no-repeat;
				background-position:left top;
			}
			td.yesterday {
				background-image: url('${req.getContextPath()}/img/icon_yesterday.png');
				background-repeat:no-repeat;
				background-position:left top;
			}
			.popover {
				width:auto;
				min-width:300px;
				max-width:600px;
			}
			.popover-content {
				white-space: nowrap;
				overflow: hidden;
				text-overflow: ellipsis;
			}
			div.smallChart {
				border: 1px solid #878988;
				height: 150px;
				min-width: 290px;
			}
            td.no-padding {
                padding: 0px;
            }

			td.jqplot-table-legend {
				padding-bottom: 0px;
			}

		</style>
	</head>

	<body>
    	<#include "../common/navigator.ftl">

		<div class="container">
			<img src="${req.getContextPath()}/img/bg_perftest_banner_en.png?${nGrinderVersion}"
				 class="img-responsive" style="width:100%"/>
			<div class="pull-right" I>
				<code id="current_running_status" style="width:300px"></code>
			</div>
			<div class="well" style="margin-top:0px">
				<form id="test_list_form" class="form-inline"
				  action="${req.getContextPath()}/perftest/list" method="POST" role="form">
					<input type="hidden" id="sort_column" name="page.sort" value="${sortColumn!'lastModifiedDate'}">
					<input type="hidden" id="sort_direction" name="page.sort.dir" value="${sortDirection!'desc'}">
					<div class="col-md-2">
						<select id="tag" name="tag" style="width:100%">
							<option value=""></option>
							<@list list_items = availTags  ; eachTag >
							<option value="${eachTag}" <#if tag?? && eachTag == tag>selected</#if> >${eachTag}</option>
							</@list>
						</select>
					</div>
					<div class="col-md-2">
						<input type="text" class="form-control input-sm" placeholder="Keywords"
							   name="query"	id="query" value="${query!}">
					</div>
					<button type="submit" class="btn"	id="search_btn">
						<i class="icon-search"></i> <@spring.message "common.button.search"/>
					</button>
					<label class="checkbox" style="position:relative; margin-left:5px">
						<input class="checkbox" type="checkbox" id="running_only_checkbox" name="queryFilter" <#if
						queryFilter??
							&& queryFilter == 'R'>checked</#if> value="R">
							<@spring.message "perfTest.formInline.running"/>
					</label>
					<label class="checkbox" style="position:relative; margin-left:5px">
					<input class="checkbox" type="checkbox" id="scheduled_only_checkbox" name="queryFilter"
						<#if queryFilter?? && queryFilter == 'S'>checked</#if> value="S">
						<@spring.message "perfTest.formInline.scheduled"/>
					</label>

					<form-group class="right-float">
						<a class="btn btn-primary" href="${req.getContextPath()}/perftest/new" id="create_btn">
						<i class="icon-file icon-white"></i>
							<@spring.message "perfTest.formInline.createTest"/>
						</a>
						<a class="pointer-cursor btn btn-danger" id="delete_btn">
						<i class="icon-remove icon-white"></i>
							<@spring.message "perfTest.formInline.deletetSelectedTest"/>
						</a>
					</form-group>
					<INPUT type="hidden" id="page_number" name="page.page" value="${page.pageNumber + 1}">
					<INPUT type="hidden" id="page_size" name="page.size" value="${page.pageSize}">
				</form>
			</div>
			<@security.authorize ifAnyGranted="A, S">
				<#assign isAdmin = true />
			</@security.authorize>
			<div class="table-responsive">
			<table class="table table-striped table-bordered ellipsis" id="test_table">
				<colgroup>
					<col width="30">
					<col width="50">
					<col>
					<col>
					<col width="70">
					<#if clustered>
						<col width="70">
					</#if>
					<col width="120">
					<col width="80">
					<col width="65">
					<col width="65">
					<col width="70">
					<col width="70">
					<col width="50">
				</colgroup>
				<thead>
					<tr id="head_tr_id">
						<th class="nothing"><input id="chkboxAll" type="checkbox" class="checkbox" value=""></th>
						<th class="center nothing" style="padding-left:3px"><@spring.message "common.label.status"/></th>
						<th id="test_name" name="testName"><div class="ellipsis"><@spring.message "perfTest.table.testName"/></div></th>
						<th id="script_name" name="scriptName"><div class="ellipsis"><@spring.message "perfTest.table.scriptName"/></div></th>
						<th class="nothing"><#if isAdmin??><@spring.message "perfTest.table.owner"/><#else><@spring.message "perfTest.table.modifier.oneline"/></#if></th>
						<#if clustered>
						<th id="region" name="region"><@spring.message "agent.table.region"/></th>
						</#if>
						<th id="start_time" name="startTime"><@spring.message "perfTest.table.startTime"/></th>
						<th class="nothing"><@spring.message "perfTest.table.threshold"/></th>
						<th id="tps" name="tps"><@spring.message "perfTest.table.tps"/></th>
						<th id="mean_test_time" name="meanTestTime" title='<@spring.message "perfTest.table.meantime"/>' >MTT</th>
						<th id="errors" class="ellipsis" name="errors"><@spring.message "perfTest.table.errorRate"/></th>
						<th class="nothing"><@spring.message "perfTest.table.vusers"/></th>
						<th class="nothing"><@spring.message "common.label.actions"/></th>
					</tr>
				</thead>
				<tbody>
					<#assign testList = testListPage.content/>
					<@list list_items=testList colspan="12"; test, test_index>
							<#assign totalVuser = (test.vuserPerAgent) * (test.agentCount) />
							<#assign deletable = !(test.status.deletable) />
							<#assign stoppable = !(test.status.stoppable) />
							<tr id="tr${test.id}" class='${["odd", ""][test_index%2]}'>
								<td class="center">
									<input id="check_${test.id}" type="checkbox" class="perf_test checkbox" value="${test.id}" status="${test.status}" <#if deletable>disabled</#if>>
								</td>
								<td class="center"  id="row_${test.id}">
									<div class="ball" id="ball_${test.id}"
													data-html="true"
													data-content="${"${test.progressMessage}<br/><b>${test.lastProgressMessage}</b>"?replace('\n', '<br>')?html}"
													title="<@spring.message "${test.status.springMessageKey}"/>"
													rel="popover">
										<img class="status" src="${req.getContextPath()}/img/ball/${test.status.iconName}"  />
									</div>
								</td>
								<td class="ellipsis ${test.dateString!""}">
									<div class="ellipsis"
										 rel="popover"
										 data-html="true"
										 data-content="${((test.description!"")?html)?replace("\n", "<br/>")} <p>${test.testComment?js_string?replace("\n", "<br/>")}</p><#if test.scheduledTime?exists><@spring.message "perfTest.table.scheduledTime"/> : ${test.scheduledTime?string('yyyy-MM-dd HH:mm')}<br/></#if><@spring.message "perfTest.table.modifiedTime"/> : <#if test.lastModifiedDate?exists>${test.lastModifiedDate?string("yyyy-MM-dd HH:mm")}</#if><br/><#if test.tagString?has_content><@spring.message "perfTest.configuration.tags"/> : ${test.tagString}<br/></#if><@spring.message "perfTest.table.owner"/> : ${test.createdUser.userName} (${test.createdUser.userId})<br/> <@spring.message "perfTest.table.modifier.oneline"/> : ${test.lastModifiedUser.userName} (${test.lastModifiedUser.userId})"
										 data-title="${test.testName!""}">
										<a href="${req.getContextPath()}/perftest/${test.id}" target="_self">${test.testName!""}</a>
									</div>
								</td>
								<td class="ellipsis">
									<div class="ellipsis"
										rel="popover"
										data-html="true"
										data-content="${test.scriptName}<br/> - <@spring.message "script.list.table.revision"/> : ${(test.scriptRevision)!'HEAD'}"
										title="<@spring.message "perfTest.table.scriptName"/>">
										<#if isAdmin??>
											<a href="${req.getContextPath()}/script/detail/${test.scriptName}?r=${(test.scriptRevision)!-1}&ownerId=${(test.createdUser.userId)!}">${test.scriptName}</a>
										<#else>
											<a href="${req.getContextPath()}/script/detail/${test.scriptName}?r=${(test.scriptRevision)!-1}">${test.scriptName}</a>
										</#if>
									</div>
								</td>
		            			<td>
		            				<div class="ellipsis"
										rel="popover"
		            					title="<@spring.message "perfTest.table.participants"/>"
		            					data-html="true"
		            					data-content="<@spring.message "perfTest.table.owner"/> : ${test.createdUser.userName} (${test.createdUser.userId})<br/> <@spring.message "perfTest.table.modifier.oneline"/> : ${test.lastModifiedUser.userName} (${test.lastModifiedUser.userId})">
		            				<#if isAdmin??>
		            					${test.createdUser.userName}
		            				<#else>
		            					${test.lastModifiedUser.userName}
		            				</#if>
		            				</div>
		            			</td>
								<#if clustered>
								<td class="ellipsis" title="<@spring.message "agent.table.region"/>" data-html="true" data-content="<#if test.region?has_content><@spring.message "${test.region}"/></#if>"> <#if test.region?has_content><@spring.message "${test.region}"/></#if>
								</td>
								</#if>
								<td>
									<#if test.startTime??>${test.startTime?string('yyyy-MM-dd HH:mm')}</#if>
								</td>
								<td
									<#if test.threshhold?? && test.threshold == "D">	>
									${(test.durationStr)!}
									<#else>
									title="<@spring.message "perfTest.configuration.runCount"/>" >
									${(test.runCount)!}
									</#if>
								</td>
								<td><#if test.tps??>${(test.tps)?string(",##0.#")}</#if></td>
								<td><#if test.meanTestTime??>${(test.meanTestTime)?string("0.##")}</#if></td>
								<td>
									<div class="ellipsis"
										rel="popover"
		            					data-html="true"
		            					data-placement="top"
		            					data-content="<@spring.message "perfTest.table.totaltests"/> : ${((test.tests + test.errors)?string(",##0"))!""}<br/><@spring.message "perfTest.table.successfultests"/> : ${(test.tests?string(",##0"))!""}<br/><@spring.message "perfTest.table.errors"/> : ${(test.errors?string(",##0"))!""}<br/>">
		            					<#if test.tests?? && test.tests != 0>${(test.errors/(test.tests + test.errors) * 100)?string("0.##")}%</#if></td>
		            				</div>
								<td>
									<div class="ellipsis"
										rel="popover"
		            					data-html="true"
		            					data-placement="left"
		            					data-content="<@spring.message "perfTest.report.agent"/> : ${test.agentCount!"0"}<br/><@spring.message "perfTest.report.process"/>  : ${test.processes!"0"}<br/><@spring.message "perfTest.report.thread"/> : ${test.threads!"0"}">
		            				${totalVuser}
		            				<div>
		            			</td>
								<td class="center">
									<a class="pointer-cursor" style="<#if test.status != 'FINISHED'>display: none;</#if>"><i class="icon-download test-display" sid="${test.id}"></i></a>
									<a class="pointer-cursor" style="<#if deletable>display: none;</#if>"><i title="<@spring.message "common.button.delete"/>" id="delete_${test.id}" class="icon-remove test-remove" sid="${test.id}"></i></a>
									<a class="pointer-cursor" style="<#if stoppable>display: none;</#if>"><i title="<@spring.message "common.button.stop"/>" id="stop_${test.id}" class="icon-stop test-stop" sid="${test.id}"></i></a>
								</td>
							</tr>
					</@list>
				</tbody>
			</table>
			</div>
			<#if testList?has_content>
				<#include "../common/paging.ftl">
				<@paging  testListPage.totalElements testListPage.number+1 testListPage.size 10 ""/>
				<script type="text/javascript">
					function doSubmit(page) {
						getList(page);
					}
				</script>
			</#if>
			<#include "../common/copyright.ftl">
		</div>
	<script>
		$(document).ready(function() {

			var columnCount = $('#head_tr_id th').length;

			$("#tag").select2({
				placeholder: '<@spring.message "perfTest.table.selectATag"/>',
				allowClear: true
			}).change(function() {
				document.forms.test_list_form.submit();
			});

			$("#nav_test").addClass("active");

			enableChkboxSelectAll("test_table");

			$("#delete_btn").click(function() {
				var list = $("td input:checked");
				if(list.length == 0) {
					bootbox.alert("<@spring.message "perfTest.table.message.alert.delete"/>", "<@spring.message "common.button.ok"/>");
					return;
				}

				bootbox.confirm("<@spring.message "perfTest.table.message.confirm.delete"/>", "<@spring.message "common.button.cancel"/>", "<@spring.message "common.button.ok"/>", function(result) {
					if (result) {
						var ids = list.map(function() {
							return $(this).val();
						}).get().join(",");

						deleteTests(ids);
					}
				});
			});

			$("i.test-remove").click(function() {
				var id = $(this).attr("sid");
				bootbox.confirm("<@spring.message "perfTest.table.message.confirm.delete"/>", "<@spring.message "common.button.cancel"/>", "<@spring.message "common.button.ok"/>", function(result) {
					if (result) {
						deleteTests(id);
					}
				});
			});

			$("i.test-display").click(function() {
				var id = $(this).attr("sid");
				var perftestChartTrId = "test_tr_" + id;
				var tpsId = "tps_chart" + id;
				var meanTimeChartId = "mean_time_chart" + id;
				var errorChartId = "error_chart" + id;
				if(!$(this).closest('tr').next('#'+perftestChartTrId).length){
					var testInfoTr = $("<tr id='"+perftestChartTrId+"' style='display:none'><td colspan='" +
							columnCount +"' class='no-padding'><table style='width:100%'><tr><td><div " +
							"class='smallChart' id="+ tpsId +"></div></td> <td><div class='smallChart' id="+ meanTimeChartId +"></div></td> <td><div class='smallChart' id="+ errorChartId +"></div></td></tr></table></td></tr><tr></tr>");
					$(this).closest('tr').after(testInfoTr);

					var ajaxObj = new AjaxObj("/perftest/api/"+ id +"/graph");
					ajaxObj.params = {'dataType':'TPS,Errors,Mean_Test_Time_(ms),Mean_time_to_first_byte,User_defined','imgWidth':700};
					ajaxObj.success = function(res) {
						drawListPlotChart(tpsId, res.TPS.data , ["Tps"], res.chartInterval);
						drawListPlotChart(meanTimeChartId , res.Mean_Test_Time_ms.data, ["Mean Test Time"], res.chartInterval);
						drawListPlotChart(errorChartId , res.Errors.data, ["Errors"], res.chartInterval);
						return true;
					};
                    ajaxObj.call();
					testInfoTr.show("slow");
				}else{
					$("#"+perftestChartTrId).next('tr').remove();
					$("#"+perftestChartTrId).remove();
				}

			});

			$("i.test-stop").click(function() {
				var id = $(this).attr("sid");
				bootbox.confirm("<@spring.message "perfTest.table.message.confirm.stop"/>", "<@spring.message "common.button.cancel"/>", "<@spring.message "common.button.ok"/>", function(result) {
					if (result) {
						stopTests(id);
					}
				});
			});

			<#if testList?has_content>
			$("th").each(function() {
				var $this = $(this);
				if (!$this.hasClass("nothing")) {
					$this.addClass("sorting");
				}
			});

			var sortColumn = $("#sort_column").val();
			var sortDir = $("#sort_direction").val().toLowerCase();

			$("th[name='" + sortColumn + "']").addClass("sorting_" + sortDir);

			$("th.sorting").click(function() {
				var $currObj = $(this);
				var sortDirection = "ASC";
				if ($currObj.hasClass("sorting_asc")) {
					sortDirection = "DESC";
				}

				$("#sort_column").val($currObj.attr('name'));
				$("#sort_direction").val(sortDirection);

				getList(1);
			});
			</#if>

			$("#current_running_status").click(function() {
				$("#current_running_status_div").toggle();
			});

			$("#scheduled_only_checkbox, #running_only_checkbox").click(function() {
				var $this = $(this);
				var $temp;
				var checkId = $this.attr("id");
				if (checkId == "scheduled_only_checkbox") {
					checkboxReject($this, $("#running_only_checkbox"));
				} else if (checkId == "running_only_checkbox") {
					checkboxReject($this, $("#scheduled_only_checkbox"));
				}
				document.forms.test_list_form.submit();
			});
		});

		function checkboxReject(obj1, obj2) {
			if (obj1.attr("checked") == "checked" && obj2.attr("checked") == "checked") {
				obj2.attr("checked", false);
			}
		}

		function deleteTests(ids) {
			var ajaxObj = new AjaxPostObj("/perftest/api/delete",
                    { "ids" : ids },
					"<@spring.message "perfTest.table.message.success.delete"/>",
					"<@spring.message "perfTest.table.message.error.delete"/>");
			ajaxObj.success = function(res) {
				setTimeout(function() {
					getList(1);
				}, 500);
			};
            ajaxObj.call();
		}

		function stopTests(ids) {
			var ajaxObj = new AjaxObj("${req.getContextPath()}/perftest/api/stop",
                    "<@spring.message "perfTest.table.message.success.stop"/>",
					"<@spring.message "perfTest.table.message.error.stop"/>");
			ajaxObj.type = "POST";
			ajaxObj.params = { "ids" : ids };
			ajaxObj.call();
		}

		function getSortColumn(colNum) {
			return perfTestSortColumnMap[colNum];
		}

		function getList(page) {
			$("#page_number").val(page);
			document.forms.test_list_form.submit();
		}

		function updateStatus(id, status, icon, stoppable, deletable, message) {
			var $ballImg = $("#ball_" + id + " img");
			if ($ballImg.attr("src") != "${req.getContextPath()}/img/ball/" + icon) {
				$ballImg.attr("src", "${req.getContextPath()}/img/ball/" + icon);
				$(".icon-remove[sid=" + id + "]").remove();
			}

			$("#ball_" + id).attr("data-original-title", status);
			$("#ball_" + id).data('popover').options.content = message;

			if (stoppable == true) {
				$("#stop_" + id).parent().show();
			} else {
				$("#stop_" + id).parent().hide();
			}
			if (deletable == true) {
				$("#delete_" + id).parent().show();
			} else {
				$("#check_" + id).attr("disabled", true);
				$("#delete_" + id).parent().hide();
			}
		}
		// Wrap this function in a closure so we don't pollute the namespace
		(function updateStatuses() {
			var ids = $('input.perf_test').map(function() {
		    	var perTestStatus = $(this).attr("status");
				if(!(perTestStatus == "FINISHED" || perTestStatus == "STOP_BY_ERROR"|| perTestStatus == "STOP_ON_ERROR" || perTestStatus == "CANCELED"))
					return this.value;
		  	}).get();

			var ajaxObj = new AjaxObj("${req.getContextPath()}/perftest/api/status");
			ajaxObj.type = "POST";
			ajaxObj.params = {"ids": ids.join(",")};
			ajaxObj.success = function (data) {
				data = eval(data);
				var status = data.status;
				var perfTest = data.perfTestInfo;
				var springMessage = perfTest.length + " <@spring.message "perfTest.currentRunning.summary"/>";
				$("#current_running_status").text(springMessage);
				for (var i = 0; i < status.length; i++) {
					var each = status[i];
					var statusId = each.status_id;
					$("#check_" + each.id).attr("status", statusId);

					if (statusId == "FINISHED" || statusId == "STOP_BY_ERROR" || statusId == "STOP_ON_ERROR" || statusId == "CANCELED") {
						location.reload();
					}
					updateStatus(each.id, each.name, each.icon, each.stoppable, each.deletable, each.message);
				}
				if (ids.length == 0) {
					return;
				}
				setTimeout(updateStatuses, 2000);
			};
			ajaxObj.error = function () {
				var springMessage = "0 <@spring.message "perfTest.currentRunning.summary"/>";
				$("#current_running_status").text(springMessage);
			};
            ajaxObj.call();
		})();
	</script>
	</body>
</html>
