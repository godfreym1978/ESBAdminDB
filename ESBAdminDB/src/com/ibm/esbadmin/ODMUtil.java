package com.ibm.esbadmin;

import ilog.rules.res.model.mbean.IlrJMXRepositoryMBean;
import ilog.rules.res.model.mbean.IlrJMXRuleAppMBean;
import ilog.rules.res.model.mbean.IlrJMXRulesetMBean;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Proxy;
import java.security.Security;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import javax.management.Attribute;
import javax.management.MalformedObjectNameException;
import javax.management.ObjectName;
import javax.management.OperationsException;

//import jmxremote.WebsphereClient.WebsphereHandler;

import com.ibm.websphere.management.AdminClient;
import com.ibm.websphere.management.AdminClientFactory;
import com.ibm.websphere.management.exception.ConnectorException;

public class ODMUtil extends JmxRemoteImpl{

    private static final String RES_MODEL_NAME = "WebSphere:type=IlrJMXRepository,*";

    private AdminClient connection;

    public class WebsphereHandler extends ODMCommonHandler {
        private ObjectName objName;
        private AdminClient client;

        public WebsphereHandler(AdminClient client, ObjectName objName) {
            this.objName = objName;
            this.client = client;
        }

        /**
         * @see jmxremote.CommonHandler#getAttribute(java.lang.String)
         */
        public Object getAttribute(String attributeName) throws Exception {
            return client.getAttribute(objName, attributeName);

        }

        /**
         * @see jmxremote.CommonHandler#setAttribute(javax.management.Attribute)
         */
        public void setAttribute(Attribute attr) throws Exception {
            client.setAttribute(objName, attr);
        }

        /**
         * @see jmxremote.CommonHandler#invoke(java.lang.String,
         *      java.lang.Object[], java.lang.String[])
         */
        public Object invoke(String methodName, Object[] args, String[] parameters) throws Exception {
            return client.invoke(objName, methodName, args, parameters);
        }
    }


    /**
     * @see jmxremote.JmxRemoteBase#createHandler(javax.management.ObjectName)
     */
    public InvocationHandler createHandler(ObjectName name) {
        return new WebsphereHandler(connection, name);
    }

    /**
     * @see jmxremote.JmxRemoteImpl#getModelMBeanName()
     */
    @SuppressWarnings("unchecked")
    public ObjectName getModelMBeanName() {
        try {
            //Query the name of MBeans of type IlrBresModel
            Set mBeans = connection.queryNames(new ObjectName(RES_MODEL_NAME), null);

            //Getting the BresMbeanName
            if (mBeans.iterator().hasNext())
                return (ObjectName) mBeans.iterator().next();
        } catch (MalformedObjectNameException e) {
            System.out.println(e);
        } catch (ConnectorException e) {
        	System.out.println(e);
        }

        return null;
    }

    /**
     * This method allow to instanciate a connection between the client and the
     * server. The properties used to connect to the server are stored in a
     * properties file.
     * @throws ConnectorException
     *          If the connection failed
     * @throws IOException
     *          If an IOException occured
     */
    public void connect() throws ConnectorException, IOException {
        
        // Load a properties file that stored the server information need to
        // connect to the server
 
    	// WebSphere environment using SOAP connector
    	Properties props = new Properties();
        props.setProperty(AdminClient.CONNECTOR_TYPE, AdminClient.CONNECTOR_TYPE_SOAP);
        props.setProperty(AdminClient.CONNECTOR_HOST, "WKR90A2X8R.humad.com");
        props.setProperty(AdminClient.CONNECTOR_PORT, "8880");
        props.setProperty(AdminClient.USERNAME, "humana");
        props.setProperty(AdminClient.PASSWORD, "humana");
        

        // Required for secured connection
        props.setProperty(AdminClient.CONNECTOR_SECURITY_ENABLED, "true");
        
        props.setProperty("javax.net.ssl.trustStore", "C:/Godfrey/JMX/DummyClientTrustFile.jks");
        props.setProperty("javax.net.ssl.keyStore", "C:/Godfrey/JMX/DummyClientKeyFile.jks");
        props.setProperty("javax.net.ssl.trustStorePassword", "WebAS");
        props.setProperty("javax.net.ssl.keyStorePassword", "WebAS");
        
        
        Security.setProperty("ssl.SocketFactory.provider", "com.ibm.jsse2.SSLSocketFactoryImpl");
        Security.setProperty("ssl.ServerSocketFactory.provider", "com.ibm.jsse2.SSLServerSocketFactoryImpl");
        
        // connect
        connection = AdminClientFactory.createAdminClient(props);
        System.out.println("Server connected");
    }

    public static void main(String[] args) throws ConnectorException, IOException {
    	ODMUtil client = new ODMUtil();
    	client.connect();
        //if (args.length == 1 && args[0].equalsIgnoreCase("-displayall")) {
        	System.out.println("main begins");
            client.displayResContent();
        //}
    }
}
