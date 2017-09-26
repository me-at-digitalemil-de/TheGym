package de.digitalemil.mesonautsgym;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Writer;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.FileHandler;
import java.util.logging.Handler;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.xml.bind.JAXBException;

import org.dmg.pmml.*;
import org.jpmml.evaluator.*;
import org.jpmml.evaluator.ModelEvaluator;
import org.jpmml.evaluator.ModelEvaluatorFactory;
import org.jpmml.model.PMMLUtil;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.xml.sax.SAXException;
import java.net.URLDecoder;
import java.io.PrintWriter;

/**
 */
public class MesonautsGym extends HttpServlet {
	private static final long serialVersionUID = 1L;
	String pivotfieldname= "";
	JSONArray fields;
	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public MesonautsGym() {
		super();
	}

	@Override
	public void init(ServletConfig cfg) throws ServletException {
		super.init(cfg);
		System.out.println("Pivot field: "+pivotfieldname);
		String appdef= "";
		Map<String, String> env = System.getenv();
        for (String envName : env.keySet()) {
			if(envName.equals("APPDEF"))
				appdef= env.get(envName);
		}
		String json= appdef.replaceAll("'", "\"");
		JSONObject jobj = null;
		jobj = new JSONObject(json);
		fields= jobj.getJSONArray("fields");
		for (int i = 0; i < fields.length(); i++) {
			JSONObject field= fields.getJSONObject(i);	
			System.out.println(field);
			System.out.println(field.get("pivot"));
			
			if(field.get("pivot").toString().toLowerCase().equals("true")) {
				pivotfieldname= field.getString("name");
				System.out.println("Pivot field: "+pivotfieldname);
			}
		}

	}

	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
	}


	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		BufferedReader reader = request.getReader();
		PrintWriter writer = response.getWriter();

		StringBuffer json = new StringBuffer();
		JSONObject jobj = null;

		do {
			String line = reader.readLine();
			if (line == null)
				break;
			json.append(line + "\n");
		} while (true);
		String jsonstring= json.toString();
	//	System.out.println("JSON predecode: "+jsonstring);
		jsonstring= URLDecoder.decode(jsonstring.replace("+", "%2B"), "UTF-8").replace("%2B", "+");
	//	System.out.println("JSON after decode: "+jsonstring);
	//	System.out.println("JSON after decode: "+pivotfieldname);
	

		String ret= "0";
		try {
			jobj = new JSONObject(jsonstring);
			System.out.println("Value: "+jobj.get(pivotfieldname));
	
			Object modelobj= jobj.get("model");
			
			if(modelobj!= null) {
				String model= modelobj.toString();
				model= model.replace("'", "\"");
		
				ModelEvaluator m= setModelString(model);
				ret= getResult(m, model, jobj);
			}
		} catch (Exception e) {	
			e.printStackTrace();
			System.out.println("Error: "+e);
		}
		writer.print(ret);
	}

	// Needed to run without Hadoop
	//
	private static ModelEvaluator createModelEvaluator(String modelString)
			throws SAXException, JAXBException {

				if(modelString.length()< 8)
					return null;
				ModelEvaluator<?> m = null;
				try {
		InputStream is = new ByteArrayInputStream(modelString.getBytes());

	
		PMML pmml = PMMLUtil.unmarshal(is);
		ModelEvaluatorFactory modelEvaluatorFactory = ModelEvaluatorFactory.newInstance();
 
		m= modelEvaluatorFactory.newModelEvaluator(pmml);
				}
	catch(Exception e) {
		e.printStackTrace();
	}
		return m;

	//	System.out.println("New model created for: " + modelEvaluator);
	}

	public String getResult(ModelEvaluator<?> modelEvaluator, String modelString, JSONObject jobj) {
		if (modelString == null || modelString.length() <= 0
				|| modelEvaluator == null)
			return "-1";
		Map<FieldName, FieldValue> arguments = new LinkedHashMap<FieldName, FieldValue>();
		List<InputField> inputFields = modelEvaluator.getInputFields();

		for (InputField inputField : inputFields) {
			FieldName inputFieldName = inputField.getName();
			Object rawValue = jobj.get(inputFieldName.toString()).toString();	
		//	System.out.println("InputField: "+inputFieldName.toString()+ " "+" "+ rawValue);
			FieldValue inputFieldValue = inputField.prepare(rawValue);
			arguments.put(inputFieldName, inputFieldValue);
		}
		String ret="";
		Map<FieldName, ?> results = modelEvaluator.evaluate(arguments);
		List<TargetField> targetFields = modelEvaluator.getTargetFields();
		for(TargetField targetField : targetFields){
			FieldName targetFieldName = targetField.getName();
			Object targetFieldValue = results.get(targetFieldName);
		//System.out.println("TargetField: "+targetField+ " "+ results.get(targetFieldName).toString());
			if(targetFieldValue instanceof Computable){
	Computable computable = (Computable)targetFieldValue;

	Object unboxedTargetFieldValue = computable.getResult();
			ret+= unboxedTargetFieldValue.toString();
	
}
else
			ret+=targetFieldName .toString();
		}
		return ret;
	}

	public static ModelEvaluator setModelString(String s) {
		try {
			return createModelEvaluator(s);
		} catch (SAXException e) {
			e.printStackTrace();
		} catch (JAXBException e) {
			e.printStackTrace();
		}
		return null;
	}
}
