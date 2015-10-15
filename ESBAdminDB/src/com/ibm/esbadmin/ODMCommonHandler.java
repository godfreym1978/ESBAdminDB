package com.ibm.esbadmin;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;

import javax.management.Attribute;

/**
 * This class allow to use Proxy class. 
 */
public abstract class ODMCommonHandler implements InvocationHandler {

    /**
     * Gets the value of a specific attribute of a named MBean. The MBean is
     * identified by its object name.
     * 
     * @see javax.management.MBeanServer#getAttribute(ObjectName name, String
     *      attribute)
     * @param attributeName
     *            A String specifying the name of the attribute to be retrieved.
     * @return The value of the retrieved attribute.
     * @throws Exception 
     *            If an error occured
     */
    public abstract Object getAttribute(String attributeName) throws Exception;

    /**
     * Sets the value of a specific attribute of a named MBean. The MBean is
     * identified by its object name.
     * 
     * @param attr
     *            The identification of the attribute to be set and the value it
     *            is to be set to.
     * @throws Exception 
     *            If an error occured
     */
    public abstract void setAttribute(Attribute attr) throws Exception;

    /**
     * Invokes an operation on an MBean.
     * 
     * @param methodName
     *            The name of the operation to be invoked.
     * @param args
     *            An array containing the parameters to be set when the
     *            operation is invoked
     * @param parameters
     *            An array containing the signature of the operation. The class
     *            objects will be loaded using the same class loader as the one
     *            used for loading the MBean on which the operation was invoked.
     * @return The object returned by the operation, which represents the result
     *         ofinvoking the operation on the MBean specified.
     * @throws Exception 
     *            If an error occured
     */
    public abstract Object invoke(String methodName, Object[] args, String[] parameters) throws Exception;

    /**
     * @see java.lang.reflect.InvocationHandler#invoke(java.lang.Object,
     *      java.lang.reflect.Method, java.lang.Object[])
     */
    @SuppressWarnings("rawtypes")
	public Object invoke(Object proxy, Method method, Object[] args) throws Exception {
        Class[] parametersTypes = method.getParameterTypes();
        String[] parameters = new String[parametersTypes.length];
        for (int i = 0; i < parametersTypes.length; i++)
            parameters[i] = parametersTypes[i].getName();

        String methodName = method.getName();

        if (methodName.startsWith("get") && parametersTypes.length == 0) {
            String attributeName = methodName.substring(3);
            return getAttribute(attributeName);
        } else if (methodName.startsWith("set") && parametersTypes.length == 1) {
            String attributeName = methodName.substring(3);
            setAttribute(new Attribute(attributeName, args[0]));
        } else {
            return invoke(methodName, args, parameters);
        }
        return null;
    }
}
