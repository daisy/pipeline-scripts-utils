<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:d="http://www.daisy.org/ns/pipeline/data"
	xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	exclude-inline-prefixes="#all"
	type="odt:update-files"
	name="update-files">
	
	<p:input port="source" sequence="true"/>
	<p:input port="fileset.in"/>
	<p:input port="in-memory.in" sequence="true"/>
	<p:output port="fileset.out">
		<p:pipe step="update-files" port="fileset.in"/>
	</p:output>
	<p:output port="in-memory.out" sequence="true">
		<p:pipe step="other-files" port="matched"/>
		<p:pipe step="updated-files" port="result"/>
	</p:output>
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	
	<p:for-each name="updated-files">
		<p:iteration-source>
			<p:pipe step="update-files" port="source"/>
		</p:iteration-source>
		<p:output port="result" primary="true" sequence="true"/>
		<p:variable name="base" select="base-uri(/*)"/>
		<p:choose>
			<p:xpath-context>
				<p:pipe step="update-files" port="fileset.in"/>
			</p:xpath-context>
			<p:when test="/*/d:file[resolve-uri(@href, base-uri())=$base]">
				<cx:message>
					<p:with-option name="message" select="concat('[ODT] updating file: ', $base)"/>
				</cx:message>
				<p:identity/>
			</p:when>
			<p:otherwise>
				<cx:message>
					<p:with-option name="message" select="concat('[ODT] WARNING: unknown file: ', $base, ', will not be updated')"/>
				</cx:message>
				<p:identity>
					<p:input port="source">
						<p:empty/>
					</p:input>
				</p:identity>
			</p:otherwise>
		</p:choose>
	</p:for-each>
	
	<p:wrap-sequence wrapper="wrap"/>
	
	<p:split-sequence name="other-files">
		<p:input port="source">
			<p:pipe step="update-files" port="in-memory.in"/>
		</p:input>
		<p:with-option name="test" select="concat('not(base-uri(/*)=(&quot;', string-join(/*/*/base-uri(.), '&quot;,&quot;'), '&quot;))')"/>
	</p:split-sequence>
	
</p:declare-step>
