<!DOCTYPE html>
<html>
<head><#include "../common/common.ftl"> <#include "../common/datatables.ftl">
    <title><@spring.message "agent.table.title"/></title>
</head>
<body>
<#include "../common/navigator.ftl">
<div class="container">
    <fieldSet>
        <legend class="header"> <@spring.message "agent.management.title"/> </legend>
    </fieldSet>
<#include "region_selector.ftl">
    <div class="well search-bar">
        <button class="btn btn-success" id="update_agent_button">
            <i class="icon-thumbs-up"></i> <@spring.message "agent.management.agentUpdate"/>
        </button>
        <button class="btn" id="stop_agent_button">
            <i class="icon-stop"></i> <@spring.message "common.button.stop"/>
        </button>

        <div class="input-prepend pull-right">
            <span class="add-on" style="cursor: default"><@spring.message "agent.management.agentDownload"/> </span>
				<span class="input-xlarge uneditable-input span6" style="cursor: text">
				<#if downloadLink??>
                    <a href="${downloadLink}">${downloadLink}</a>
				<#else>
                    Please select the region in advance to download agent.
				</#if>
                </span>
        </div>

    </div>

    <table class="table table-striped table-bordered ellipsis" id="agent_table">
        <colgroup>
            <col width="30">
            <col width="80">
            <col width="130">
            <col width="60">
            <col width="*">
            <col width="100">
            <col width="150">
            <col width="160">
        </colgroup>
        <thead>
        <tr>
            <th class="no-click"><input type="checkbox" class="checkbox" value=""></th>
            <th><@spring.message "agent.table.state"/></th>
            <th><@spring.message "agent.table.IPAndDns"/></th>
            <th class="no-click"><@spring.message "agent.table.port"/></th>
            <th class="ellipsis"><@spring.message "agent.table.name"/></th>
            <th><@spring.message "agent.table.version"/></th>
            <th><@spring.message "agent.table.region"/></th>
            <th class="no-click"><@spring.message "agent.table.approve"/></th>
        </tr>
        </thead>
        <tbody>
		<@list list_items=agents ; each_item>
            <tr>
                <td class="center"><input type="checkbox" class="agent-state checkbox" status="${(each_item.state)!}"></td>
                <td class="center" id="row_${each_item.id}">
                    <div class="ball" id="ball_${each_item.id}"
                         data-html="true"
                         rel="popover">
                        <img class="status" src="${req.getContextPath()}/img/ball/${each_item.state.iconName}"/>
                    </div>
                </td>
                <td><a href="${req.getContextPath()}/agent/${each_item.id}" target="_self"
                       value="${each_item.ip}">${each_item.ip}</a></td>
                <td id="port_${each_item.id}">${(each_item.port)!}</td>
                <td class="ellipsis agent-name" title="${(each_item.hostName)!}">${(each_item.hostName)!}</td>
                <td class="ellipsis">${(each_item.version)!"Prev 3.3"}</td>
                <td>${(each_item.region)!}</td>
                <td>
                    <div class="btn-group" data-toggle="buttons-radio">
                        <button type="button"
                                class="btn btn-mini btn-primary disapproved <#if each_item.isApproved() == false>active</#if>"
                                sid="${each_item.id}">
							<@spring.message "agent.table.disapproved"/>
                        </button>
                        <button type="button"
                                class="btn btn-mini btn-primary approved <#if each_item.isApproved() == true>active</#if>"
                                sid="${each_item.id}">
							<@spring.message "agent.table.approved"/>
                        </button>
                    </div>
                </td>
            </tr>
		</@list>
        </tbody>
    </table>
<#include "../common/copyright.ftl">
    <!--content-->
</div>
<script>
    $(document).ready(function () {
	<#if agents?has_content>
        var oTable = $("#agent_table").dataTable({
            "bAutoWidth": false,
            "bFilter": false,
            "bLengthChange": false,
            "bInfo": false,
            "iDisplayLength": 10,
            "aaSorting": [
                [2, "asc"]
            ],
            "aoColumns": [null, null, {"asSorting": []}, {"asSorting": []}, null, null, null, {"asSorting": []}],
            "sPaginationType": "bootstrap",
            "oLanguage": {
                "oPaginate": {
                    "sPrevious": "<@spring.message "common.paging.previous"/>",
                    "sNext": "<@spring.message "common.paging.next"/>"
                }
            }
        });

        removeClick();
        enableChkboxSelectAll("agent_table");

        $(".approved").live("click", function () {
            var sid = $(this).attr("sid");
            $.post("${req.getContextPath()}/agent/" + sid + "/approve",
                    {
                        "approve": "true"
                    },
                    function () {
                        showSuccessMsg("<@spring.message "agent.management.toBeApproved"/>");
                    }
            );
        });

        $(".disapproved").live("click", function () {
            var sid = $(this).attr("sid");
            $.post("${req.getContextPath()}/agent/" + sid + "/approve",
                    {
                        "approve": "false"
                    },
                    function () {
                        showSuccessMsg("<@spring.message "agent.management.toBeDisapproved"/>");
                    }
            );
        });
	</#if>

        $("#stop_agent_button").click(function () {
            var ids = "";
            var list = $("td input:checked");
            if (list.length == 0) {
                bootbox.alert("<@spring.message "agent.table.message.alert.stop"/>", "<@spring.message "common.button.ok"/>");
                return;
            }

            var $confirm = bootbox.confirm("<@spring.message "agent.table.message.confirm.stop"/>", "<@spring.message "common.button.cancel"/>", "<@spring.message "common.button.ok"/>", function (result) {
                if (result) {
                    stopAgents(list.map(function () {
                        return $(this).val();
                    }).get().join(","));
                }
            });
            $confirm.children(".modal-body").addClass("error-color");
        });

        $("#update_agent_button").click(function () {
            var ids = "";
            var list = $("td input:checked");
            if (list.length == 0) {
                bootbox.alert("<@spring.message "agent.table.message.error.noAgent"/>", "<@spring.message "common.button.ok"/>");
                return;
            }

            var $confirm = bootbox.confirm("<@spring.message "agent.table.message.confirm.update"/>", "<@spring.message "common.button.cancel"/>", "<@spring.message "common.button.ok"/>", function (result) {
                if (result) {
                    updateAgents(list.map(function () {
                        return $(this).val();
                    }).get().join(","));
                }
            });
            $confirm.children(".modal-body").addClass("error-color");
        });
    });

    function stopAgents(ids) {
        $.ajax({
            url: "${req.getContextPath()}/agent/api/stop",
            type: "POST",
            data: { "ids": ids },
            cache: false,
            dataType: 'json',
            success: function (res) {
                showSuccessMsg("<@spring.message "agent.table.message.success.stop"/>");
                setTimeout(function () {
                    location.reload();
                }, 2000);
            },
            error: function () {
                showErrorMsg("<@spring.message "agent.table.message.error.stop"/>!");
            }
        });
    }

    function updateAgents(ids) {
        $.ajax({
            url: "${req.getContextPath()}/agent/api/update",
            type: "POST",
            cache: false,
            data: {"ids": ids },
            dataType: 'json',
            success: function (res) {
                showSuccessMsg("<@spring.message "agent.table.message.success.update"/>");
            },
            error: function () {
                showErrorMsg("<@spring.message "agent.table.message.error.update"/>");
            }
        });
    }

    (function updateStatuses() {
        var ids = $('input.agent-state').map(function () {
            return this.value;
        }).get();
        $.ajax({
            url: '${req.getContextPath()}/agent/api/states',
            type: 'GET',
            cache: false,
            data: {},
            success: function (data) {
                for (var i = 0; i < data.length; i++) {
                    updateStatus(data[i].id, data[i].icon, data[i].port, data[i].name);
                }

                if (ids.length == 0) {
                    return;
                }

                setTimeout(updateStatuses, 2000);
            }
        });

    })();

    function updateStatus(id, icon, port, state) {
        var $ballImg = $("#ball_" + id + " img");
        if ($ballImg.attr("src") != "${req.getContextPath()}/img/ball/" + icon) {
            $ballImg.attr("src", "${req.getContextPath()}/img/ball/" + icon);
            $("#port_" + id).html(port);
        }
        $("#ball_" + id).attr("data-original-title", state);
    }
</script>
</body>
</html>
