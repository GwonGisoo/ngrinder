/* 
 * Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. 
 */
package org.ngrinder.agent.controller;

import com.google.common.base.Predicate;
import com.google.common.collect.Collections2;
import org.apache.commons.lang.StringUtils;
import org.ngrinder.agent.service.AgentManagerService;
import org.ngrinder.common.controller.NGrinderBaseController;
import org.ngrinder.common.util.HttpContainerContext;
import org.ngrinder.infra.config.Config;
import org.ngrinder.model.AgentInfo;
import org.ngrinder.region.service.RegionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.List;

import static org.ngrinder.common.util.CollectionUtils.buildMap;

/**
 * Agent management controller.
 * 
 * @author JunHo Yoon
 * @since 3.1
 */
@Controller
@RequestMapping("/agent")
@PreAuthorize("hasAnyRole('A', 'S')")
public class AgentManagerController extends NGrinderBaseController {

	@Autowired
	private AgentManagerService agentManagerService;

	@Autowired
	private Config config;

	@Autowired
	private HttpContainerContext httpContainerContext;

	@Autowired
	private RegionService regionService;

	/**
	 * Get the agent list.
	 * 
	 * @param region
	 *            the region to search. If null, it returns all the attached
	 *            agents.
	 * @param model
	 *            model
	 * @return agent/list
	 */
	@RequestMapping({ "", "/", "/list" })
	public String getAgentList(@RequestParam(value = "region", required = false) final String region, ModelMap model) {
		List<AgentInfo> agents = agentManagerService.getAllVisibleAgentInfoFromDB();

		model.addAttribute("agents", Collections2.filter(agents, new Predicate<AgentInfo>() {
			@Override
			public boolean apply(AgentInfo agentInfo) {
				if (StringUtils.equals(region, "all") || StringUtils.isEmpty(region)) {
					return true;
				}
				if (agentInfo.getRegion().startsWith(region)) {
					return true;
				}
				return false;
			}
		}));
		model.addAttribute("region", region);
		model.addAttribute("regions", regionService.getRegions().keySet());
		File directory = config.getHome().getDownloadDirectory();
		final String contextPath = httpContainerContext.getCurrentContextUrlFromUserRequest();
		final List<String> downloads = new ArrayList<String>();
		directory.list(new FilenameFilter() {
			@Override
			public boolean accept(File dir, String name) {
				if (name.startsWith("ngrinder")) {
					StringBuilder url = new StringBuilder(config.getSystemProperties().getProperty("http.url",
							contextPath));
					url.append("/agent/download/" + name);
					downloads.add(url.toString());
				}
				return true;
			}
		});
		model.addAttribute("downloadLinks", downloads);
		return "agent/list";
	}

	/**
	 * Approve or disapprove agents, so that it can be assigned when a test is
	 * executed.
	 * 
	 * @param id
	 *            agent id to be processed
	 * @param approve
	 *            approve or not
	 * @param region
	 *            current region
	 * @param model
	 *            model
	 * @return agent/agentList
	 */
	@RequestMapping(value = "/{id}/approve", method = RequestMethod.POST)
	public String approveAgent(@PathVariable("id") Long id,
			@RequestParam(value = "approve", defaultValue = "true", required = false) boolean approve,
			@RequestParam(value = "region", required = false) final String region, ModelMap model) {
		agentManagerService.approve(id, approve);
		model.addAttribute("region", region);
		model.addAttribute("regions", regionService.getRegions().keySet());
		return "agent/list";
	}

	/**
	 * Stop the given agent.
	 * 
	 * @param ids
	 *            comma separated agent id list
	 * @return agent/agentList
	 */
	@RequestMapping(value = "stop", method = RequestMethod.POST)
	@ResponseBody
	public String stopAgent(@RequestParam("ids") String ids) {
		String[] split = StringUtils.split(ids, ",");
		for (String each : split) {
			agentManagerService.stopAgent(Long.parseLong(each));
		}
		return returnSuccess();
	}

	/**
	 * Get the agent detail info for the given agent id.
	 * 
	 * @param model
	 *            model
	 * @param id
	 *            agent id
	 * @return agent/agentDetail
	 */
	@RequestMapping("/{id}")
	public String getAgent(@PathVariable Long id, ModelMap model) {
		model.addAttribute("agent", agentManagerService.getAgent(id, false));
		return "agent/detail";
	}

	/**
	 * Get the current performance of the given agent.
	 * 
	 * @param model
	 *            model
	 * @param id
	 *            agent id
	 * @param ip
	 *            agent ip
	 * @param name
	 *            agent name
	 * @return json message
	 */
	@RequestMapping("/{id}/status")
	@ResponseBody
	public String getCurrentMonitorData(@PathVariable Long id, @RequestParam String ip, @RequestParam String name,
			ModelMap model) {
		agentManagerService.requestShareAgentSystemDataModel(id);
		return toJson(buildMap(JSON_SUCCESS, true, //
				"systemData", agentManagerService.getAgentSystemDataModel(ip, name)));
	}

    /**
     * Send update message to agent side
     *
     * @return json message
     */
    @RequestMapping("/update")
    @ResponseBody
    public String updateAgent() {
        agentManagerService.updateAgent(httpContainerContext.getCurrentContextUrlFromUserRequest() + "/agent/download_new_agent");
        return toJson(buildMap(JSON_SUCCESS, true));
    }
}
