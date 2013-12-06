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
package org.ngrinder.infra.servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Enumeration;
import java.util.EventListener;
import java.util.Map;
import java.util.Set;

import javax.servlet.*;
import javax.servlet.descriptor.JspConfigDescriptor;

/**
 * {@link ServletContext} delegate handler which forwards a request to the passed file path.
 * 
 * @author JunHo Yoon
 * @since 3.2
 */
@SuppressWarnings("deprecation")
public class ServletContextDelegate implements ServletContext {

	private final ServletContext servletContext;
	private final File base;

	/**
	 * Constructor.
	 * 
	 * @param servletContext
	 *            servlet context
	 * @param base
	 *            the base directory to which the request is forwarded.
	 */
	public ServletContextDelegate(ServletContext servletContext, File base) {
		this.servletContext = servletContext;
		this.base = base;
	}

	@Override
	public ServletContext getContext(String uriPath) {
		return servletContext.getContext(uriPath);
	}

	@Override
	public String getContextPath() {
		return servletContext.getContextPath();
	}

	@Override
	public int getMajorVersion() {
		return servletContext.getMajorVersion();
	}

	@Override
	public int getMinorVersion() {
		return servletContext.getMinorVersion();
	}

	@Override
	public int getEffectiveMajorVersion() {
		return servletContext.getEffectiveMajorVersion();
	}

	@Override
	public int getEffectiveMinorVersion() {
		return servletContext.getEffectiveMinorVersion();
	}

	@Override
	public String getMimeType(String file) {
		return servletContext.getMimeType(file);
	}

	@Override
	public URL getResource(String path) throws MalformedURLException {
		return new File(base, hackXBean(path)).toURI().toURL();
	}

	private String hackXBean(String path) {
		if (path.contains("xbean.jar")) {
			path = path.replace("xbean.jar", "xbean-1.0.jar");
		}
		return path;
	}

	@Override
	public InputStream getResourceAsStream(String path) {
		try {
			return new FileInputStream(new File(base, hackXBean(path)));
		} catch (FileNotFoundException e) {
			throw new RuntimeException(e);
		}
	}

	@Override
	public RequestDispatcher getRequestDispatcher(String path) {
		return servletContext.getRequestDispatcher(path);
	}

	@Override
	public RequestDispatcher getNamedDispatcher(String name) {
		return servletContext.getNamedDispatcher(name);
	}

	@Override
	public String getRealPath(String path) {
		return new File(base, hackXBean(path)).getAbsolutePath();
	}

	@Override
	public String getInitParameter(String name) {
		return servletContext.getInitParameter(name);
	}

	@Override
	public Enumeration<String> getInitParameterNames() {
		return servletContext.getInitParameterNames();
	}

	@Override
	public boolean setInitParameter(String s, String s2) {
		return servletContext.setInitParameter(s, s2);
	}

	@Override
	public Object getAttribute(String name) {
		return servletContext.getAttribute(name);
	}

	@Override
	public Enumeration<String> getAttributeNames() {
		return servletContext.getAttributeNames();
	}

	@Override
	public Set<String> getResourcePaths(String arg0) {
		return servletContext.getResourcePaths(arg0);
	}

	@Override
	public Servlet getServlet(String name) throws ServletException {
		return servletContext.getServlet(name);
	}

	@Override
	public Enumeration<Servlet> getServlets() {
		return servletContext.getServlets();
	}

	@Override
	public void log(String msg) {
		servletContext.log(msg);
	}

	@Override
	public void log(Exception exception, String msg) {
		servletContext.log(exception, msg);
	}

	@Override
	public void log(String message, Throwable throwable) {
		servletContext.log(message, throwable);
	}

	@Override
	public String getServerInfo() {
		return servletContext.getServerInfo();
	}

	@Override
	public String getServletContextName() {
		return servletContext.getServletContextName();
	}

	@Override
	public ServletRegistration.Dynamic addServlet(String s, String s2) {
		return servletContext.addServlet(s, s2);
	}

	@Override
	public ServletRegistration.Dynamic addServlet(String s, Servlet servlet) {
		return servletContext.addServlet(s, servlet);
	}

	@Override
	public ServletRegistration.Dynamic addServlet(String s, Class<? extends Servlet> aClass) {
		return servletContext.addServlet(s, aClass);
	}

	@Override
	public <T extends Servlet> T createServlet(Class<T> tClass) throws ServletException {
		return servletContext.createServlet(tClass);
	}

	@Override
	public ServletRegistration getServletRegistration(String s) {
		return servletContext.getServletRegistration(s);
	}

	@Override
	public Map<String, ? extends ServletRegistration> getServletRegistrations() {
		return servletContext.getServletRegistrations();
	}

	@Override
	public FilterRegistration.Dynamic addFilter(String s, String s2) {
		return servletContext.addFilter(s, s2);
	}

	@Override
	public FilterRegistration.Dynamic addFilter(String s, Filter filter) {
		return servletContext.addFilter(s, filter);
	}

	@Override
	public FilterRegistration.Dynamic addFilter(String s, Class<? extends Filter> aClass) {
		return servletContext.addFilter(s, aClass);
	}

	@Override
	public <T extends Filter> T createFilter(Class<T> tClass) throws ServletException {
		return servletContext.createFilter(tClass);
	}

	@Override
	public FilterRegistration getFilterRegistration(String s) {
		return servletContext.getFilterRegistration(s);
	}

	@Override
	public Map<String, ? extends FilterRegistration> getFilterRegistrations() {
		return servletContext.getFilterRegistrations();
	}

	@Override
	public SessionCookieConfig getSessionCookieConfig() {
		return servletContext.getSessionCookieConfig();
	}

	@Override
	public void setSessionTrackingModes(Set<SessionTrackingMode> sessionTrackingModes) throws IllegalStateException, IllegalArgumentException {
		servletContext.setSessionTrackingModes(sessionTrackingModes);
	}

	@Override
	public Set<SessionTrackingMode> getDefaultSessionTrackingModes() {
		return servletContext.getDefaultSessionTrackingModes();
	}

	@Override
	public Set<SessionTrackingMode> getEffectiveSessionTrackingModes() {
		return servletContext.getEffectiveSessionTrackingModes();
	}

	@Override
	public void addListener(String s) {
		servletContext.addListener(s);
	}

	@Override
	public <T extends EventListener> void addListener(T t) {
		servletContext.addListener(t);
	}

	@Override
	public void addListener(Class<? extends EventListener> aClass) {
		servletContext.addListener(aClass);
	}

	@Override
	public <T extends EventListener> T createListener(Class<T> tClass) throws ServletException {
		return servletContext.createListener(tClass);
	}

	@Override
	public void declareRoles(String... strings) {
		servletContext.declareRoles(strings);
	}

	@Override
	public ClassLoader getClassLoader() {
		return servletContext.getClassLoader();
	}

	@Override
	public JspConfigDescriptor getJspConfigDescriptor() {
		return servletContext.getJspConfigDescriptor();
	}

	@Override
	public Enumeration<String> getServletNames() {
		return servletContext.getServletNames();
	}

	@Override
	public void setAttribute(String name, Object object) {
		servletContext.setAttribute(name, object);
	}

	@Override
	public void removeAttribute(String name) {
		servletContext.removeAttribute(name);
	}
}
