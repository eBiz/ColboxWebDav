<cfcomponent>

  <cffunction name="formatResult" returntype="XML">
    <cfargument name="result">
    <cfset xmlObject = {
      "multistatus" = result
    }>
    <cfset resp = toXML(data=xmlObject,rootName="d:multistatus")>
    <cfset resp = replace(resp,"<d:multistatus>","<d:multistatus xmlns:d=""DAV:"">")>
    <cfreturn resp>
  </cffunction>

	<cffunction name="lockResult" returntype="XML">
		<cfargument name="result">
		<cfset xmlObject = {
			"prop" = result
		}>
		<cfset resp = toXML(data=xmlObject,rootName="d:prop")>
		<cfset resp = replace(resp,"<d:prop>","<d:prop xmlns:d=""DAV:"" >")>
		<cfreturn resp>
	</cffunction>

  <cffunction name="toXML" access="public" returntype="string" hint="Convert any type of data to XML. This method will auto-discover the type. Valid types are array,query,struct" output="false" >
		<cfargument name="data" 		type="any"  	required="true" hint="The data to convert to xml">
		<cfargument name="columnlist"   type="string"   required="false" hint="Choose which columns to inspect, by default it uses all the columns in the query, if using a query">
		<cfargument name="useCDATA"  	type="boolean"  required="false" default="false" hint="Use CDATA content for ALL values. The default is false">
		<cfargument name="addHeader"  	type="boolean"  required="false" default="true" hint="Add an xml header to the packet returned.">
		<cfargument name="encoding" 	type="string" 	required="true"  default="UTF-8" hint="The character encoding of the header. UTF-8 is the default"/>
		<cfargument name="delimiter" 	type="string" 	required="false" default="," hint="The delimiter in the list. Comma by default">
		<cfargument name="rootName"     type="string"   required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>
		<cfscript>
			var buffer = createObject("java","java.lang.StringBuffer").init('');

			// Header
			if( arguments.addHeader ){
				buffer.append('<?xml version="1.0" encoding="#arguments.encoding#"?>#chr(10)#');
			}

			// Object Check
			if( isObject(arguments.data) ){
				buffer.append( objectToXML(argumentCollection=arguments) );
			}
			// Struct Check?
			else if( isStruct(arguments.data) ){
				buffer.append( structToXML(argumentCollection=arguments) );
			}
			// Query Check?
			else if( isQuery(arguments.data) ){
				buffer.append( queryToXML(argumentCollection=arguments) );
			}
			// Array Check?
			else if( isArray(arguments.data) ){
				buffer.append( arrayToXML(argumentCollection=arguments) );
			}
			// Simple Value Check, treated as a simple array list?
			else if( isSimpleValue(arguments.data) ){
				arguments.data = listToArray(arguments.data,arguments.delimiter);
				buffer.append( arrayToXML(argumentCollection=arguments) );
			}

			return buffer.toString();
		</cfscript>
	</cffunction>

	<cffunction name="arrayToXML" returnType="string" access="public" output="false" hint="Converts an array into XML with no headers.">
		<cfargument name="data" 		type="array"    required="true" hint="The array to convert">
		<cfargument name="useCDATA"  	type="boolean"  required="false" default="false" hint="Use CDATA content for ALL values. False by default">
		<cfargument name="rootName"     type="string"   required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>

		<cfscript>
		var buffer = createObject('java','java.lang.StringBuffer').init('');
		var target = arguments.data;
		var x = 1;
		var dataLen = arrayLen(target);
		var thisValue = "";
		var rootElement = "array";
		var itemElement = "item";

		// Root Name
		if( len(arguments.rootName) ){ rootElement = arguments.rootName; }

		//Create Root
		// buffer.append("<#rootElement#>");
		</cfscript>

		<cfloop from="1" to="#dataLen#" index="x">

			<cfparam name="target[x]" default="_INVALID_">

			<cfif isSimpleValue(target[x]) AND target[x] EQ "_INVALID_">
				<cfset thisValue = "NULL">
			<cfelse>
				<cfset thisValue = target[x]>
			</cfif>

			<cfif NOT isSimpleValue(thisValue)>
        <cfset buffer.append(translateValue(arguments, thisValue))>
			<cfelse>
        <cfset buffer.append(safeText(thisValue,arguments.useCDATA))>
			</cfif>


		</cfloop>

		<!---<cfset buffer.append("</#rootElement#>")>--->

		<cfreturn buffer.toString()>
	</cffunction>

	<cffunction name="structToXML" returnType="string" access="public" output="false" hint="Converts a struct into XML with no headers.">
		<cfargument name="data" 		type="any" 		required="true" hint="The structure, object, any to convert.">
		<cfargument name="useCDATA"  	type="boolean"  required="false"  default="false" hint="Use CDATA content for ALL values">
		<cfargument name="rootName"     type="string"   required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>
		<cfscript>
		var target = arguments.data;
		var buffer = createObject("java","java.lang.StringBuffer").init('');
		var key = 0;
		var thisValue = "";
		var args = structnew();
		var rootElement = "struct";
		var objectType = "";

		// Root Element
		if( len(arguments.rootName) ){ rootElement = arguments.rootName; }

		// Declare Root
		if( isObject(arguments.data) ){
			rootElement = "object";
			buffer.append('<d:#rootElement# type="#getMetadata(arguments.data).name#">');
		}
		else{
			// buffer.append("<#rootElement#>");
		}

		// Content
		for(key in target){
			// Null Checks
			if( NOT structKeyExists(target, key) ){
				target[key] = 'NULL';
			}
			// Translate Value
			if( NOT isSimpleValue(target[key]) ){
				thisValue = translateValue(arguments,target[key]);
			}
			else{
				thisValue = safeText(target[key],arguments.useCDATA);
			}
			buffer.append("<d:#lcase(key)#>#thisValue#</d:#lcase(key)#>");
		}

		// End Root
		// buffer.append("</#rootElement#>");

		return buffer.toString();
		</cfscript>
	</cffunction>



<!------------------------------------------- PRIVATE ------------------------------------------>

	<cffunction name="translateValue" access="private" returntype="any" hint="Translate a value into XML" output="false" >
		<cfargument name="args"  		type="struct" 	required="true" hint="The original argument collection">
		<cfargument name="targetValue"  type="any" 		required="true" hint="The value to translate">
		<cfscript>
			var newArgs = structnew();
			newArgs.data = arguments.targetValue;
			newArgs.useCDATA = arguments.args.useCDATA;
			newArgs.addHeader = false;
			return toXML(argumentCollection=newArgs);
		</cfscript>
	</cffunction>

	<!--- This line taken from Nathan Dintenfas' SafeText UDF --->
	<!--- www.cflib.org/udf.cfm/safetext --->
	<cffunction name="safeText" returnType="string" access="private" output="false" hint="Create a safe xml text">
		<cfargument name="txt" 		type="string" required="true">
		<cfargument name="useCDATA" type="boolean" required="false" default="false" hint="Use CDATA content for ALL values">
		<cfset var newTxt = xmlFormat(unicodeWin1252(trim(arguments.txt)))>
		<cfif arguments.useCDATA>
			<cfreturn "<![CDATA[" & newTxt & "]]" & ">">
		<cfelse>
			<cfreturn newTxt>
		</cfif>
	</cffunction>

	<!--- This method written by Ben Garret (http://www.civbox.com/) --->
	<cffunction name="unicodeWin1252" output="false" access="private" hint="Converts MS-Windows superset characters (Windows-1252) into their XML friendly unicode counterparts" returntype="string">
		<cfargument name="value" type="string" required="yes">
		<cfscript>
			var string = arguments.value;
			string = replaceNoCase(string,chr(8218),'&##8218;','all');	// �
			string = replaceNoCase(string,chr(402),'&##402;','all');		// �
			string = replaceNoCase(string,chr(8222),'&##8222;','all');	// �
			string = replaceNoCase(string,chr(8230),'&##8230;','all');	// �
			string = replaceNoCase(string,chr(8224),'&##8224;','all');	// �
			string = replaceNoCase(string,chr(8225),'&##8225;','all');	// �
			string = replaceNoCase(string,chr(710),'&##710;','all');		// �
			string = replaceNoCase(string,chr(8240),'&##8240;','all');	// �
			string = replaceNoCase(string,chr(352),'&##352;','all');		// �
			string = replaceNoCase(string,chr(8249),'&##8249;','all');	// �
			string = replaceNoCase(string,chr(338),'&##338;','all');		// �
			string = replaceNoCase(string,chr(8216),'&##8216;','all');	// �
			string = replaceNoCase(string,chr(8217),'&##8217;','all');	// �
			string = replaceNoCase(string,chr(8220),'&##8220;','all');	// �
			string = replaceNoCase(string,chr(8221),'&##8221;','all');	// �
			string = replaceNoCase(string,chr(8226),'&##8226;','all');	// �
			string = replaceNoCase(string,chr(8211),'&##8211;','all');	// �
			string = replaceNoCase(string,chr(8212),'&##8212;','all');	// �
			string = replaceNoCase(string,chr(732),'&##732;','all');		// �
			string = replaceNoCase(string,chr(8482),'&##8482;','all');	// �
			string = replaceNoCase(string,chr(353),'&##353;','all');		// �
			string = replaceNoCase(string,chr(8250),'&##8250;','all');	// �
			string = replaceNoCase(string,chr(339),'&##339;','all');		// �
			string = replaceNoCase(string,chr(376),'&##376;','all');		// �
			string = replaceNoCase(string,chr(376),'&##376;','all');		// �
			string = replaceNoCase(string,chr(8364),'&##8364','all');		// �
			return string;
		</cfscript>
	</cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
</cfcomponent>