<cfcomponent>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	<cffunction name="init">
		<cfset this.version = "1.1.3">
		<cfreturn this>
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	<cffunction name="$addToCache" returntype="void" access="public" output="false">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="any" required="true">
		<cfargument name="time" type="numeric" required="false" default="#application.wheels.defaultCacheTime#">
		<cfargument name="category" type="string" required="false" default="main">
		<cfscript>
			var loc = {};
			loc.agent = application.wheels.cache[arguments.category];
			loc.agent.set(arguments.key,duplicate(arguments.value));
		</cfscript>
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	<cffunction name="$getFromCache" returntype="any" access="public" output="false">
		<cfargument name="key" type="string" required="true">
		<cfargument name="category" type="string" required="false" default="main">
		<cfscript>
			var loc = {};
			loc.returnValue = false;
			loc.cache = application.wheels.cache[arguments.category].get(key);
			if (isDefined("loc.cache")) {
				// we found cache and it's still valid
				loc.returnValue = duplicate(loc.cache); // if it's a struct or object, we don't want to make changes to the cache after returning it
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	<cffunction name="$removeFromCache" returntype="void" access="public" output="false">
		<cfargument name="key" type="string" required="true">
		<cfargument name="category" type="string" required="false" default="main">
		<cfset application.wheels.cache[arguments.category].clear(key) />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	<cffunction name="$clearCache" returntype="void" access="public" output="false">
		<cfargument name="category" type="string" required="false" default="#structKeyList(application.wheels.cache)#">
		<cfscript>
			var loc = {};
			var agent = listToArray(category);
			var i = 0;

			for (i = 1; i lte arrayLen(agent); i = i + 1) {
				application.wheels.cache[agent[i]].clearAll();
			}
		</cfscript>

	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	<cffunction name="$getCachedKeys" hint="I return all or selected keys from the cache of a given category. This is quite handy if you want to say store session specific info for different users in application scope. For example, create a key like 'users-cfid.keyname'. Once caching has occured, you can get all the keys for the users by passing in the 'key' argument as 'users-cfid', and you will get all keys that start with that.">
		<cfargument name="key" 			required="false"	type="string" default="" hint="Returns all cached keys in a given category">
		<cfargument name="category"		required="true"		type="string">
		<cfargument name="returnType" 	required="false"	type="string" default="list" hint="query or list"/>

		<cfset var qReturn	= queryNew("key")>
		<cfset var aKeys	= application.wheels.cache["#arguments.category#"].getKeys()>
		<cfset var i		= "">

		<cfloop from="1" to="#arrayLen(aKeys)#" index="i">
			<cfset queryAddRow(qReturn,1)>
			<cfset querySetCell(qReturn,"key",aKeys[i])>
		</cfloop>

		<cfif len(trim(arguments.key))>

			<cfquery name="qReturn" dbtype="query">
				SELECT	*
				FROM	qReturn
				Where	key like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#arguments.key#%">
			</cfquery>

		</cfif>

		<cfif arguments.returnType eq "list">
			<cfset qReturn = valuelist(qReturn.key)>
		</cfif>

		<cfreturn qReturn />
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	<cffunction name="$removeCachedKeys" returnType="boolean" access="public" output="false" hint="I clear only the specified keys from the cache.">
		<cfargument name="keys"			required="true" type="string" hint="A comma-separated list of all the keys to clear">
		<cfargument name="category"		required="true" type="string" hint="">

		<cfset application.wheels.cache[arguments.category].clearMulti(arguments.keys)>

		<cfreturn true>
	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

</cfcomponent>