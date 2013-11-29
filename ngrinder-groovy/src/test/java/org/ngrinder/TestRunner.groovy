package org.ngrinder;

import static net.grinder.script.Grinder.grinder
import static org.junit.Assert.*
import net.grinder.plugin.http.HTTPRequest
import net.grinder.script.GTest
import net.grinder.script.Grinder
import net.grinder.scriptengine.groovy.junit.GrinderRunner
import net.grinder.scriptengine.groovy.junit.annotation.BeforeProcess;
import net.grinder.scriptengine.groovy.junit.annotation.BeforeThread

import org.hamcrest.Matchers;
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import HTTPClient.HTTPResponse

@RunWith(GrinderRunner)
class TestRunner
{
	public static GTest test;
	public HTTPRequest request;

	@BeforeProcess
	public static void beforeProcess() {
		test = new GTest(1, "Hello");
	}

	@BeforeThread
	public void beforeThread() {
		grinder.statistics.delayReports=true
		grinder.getLogger().info("before thread in MyTest.");
        request = new HTTPRequest();
        test.record(request);
	}

	@Before
	public void before() {
		grinder.getLogger().info("before in MyTest.");
	}

	@Test
	public void testHello(){
		grinder.getLogger().info("testHello.");
		HTTPResponse result = request.GET("http://www.google.com/q?=" + "Hangul");
		if (result.statusCode != 200) {
			grinder.statistics.forLastTest.success = 0
		} else {
			grinder.statistics.forLastTest.success = 1
		}
	}
	@Test
	public void testHello2() {
		grinder.getLogger().info("testHello2.");
		def result = request.GET("http://se.naver.com/");
		grinder.getLogger().debug("code: {}", result.statusCode);
		if (result.getStatusCode() != 200) {
			grinder.statistics.forLastTest.success = 0
		} else {
			grinder.statistics.forLastTest.success = 1
		}
	}
}
