<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="px:create-daisy3-smils" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:smil="http://www.w3.org/2001/SMIL20/"
    version="1.0">

    <p:input port="content" primary="true" sequence="false">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	 <p>DTBook file. Its URI does no matter.</p>
      </p:documentation>
    </p:input>

    <p:input port="audio-map">
       <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	 <p>The clipBegin and clipEnd attributes must be compliant
	 with the XML time data type and not be greater than 24
	 hours. See pipeline-mod-tts's documentation for more
	 details.</p>
       </p:documentation>
    </p:input>

    <p:output port="fileset.out">
      <p:pipe port="result" step="smil-in-fileset"/>
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	 <p>Fileset entries for the SMIL files.</p>
      </p:documentation>
    </p:output>

    <p:output port="smil.out" sequence="true">
      <p:pipe port="result" step="smil-with-durations"/>
    </p:output>

    <p:output port="updated-content" primary="true">
      <p:pipe port="result" step="add-smilrefs"/>
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	 <p>Content document with smilref attributes.</p>
      </p:documentation>
    </p:output>

    <p:output port="duration">
      <p:pipe port="result" step="total-duration"/>
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>Total duration.</p>
      </p:documentation>
    </p:output>

    <p:option name="root-dir">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>Root directory of the DAISY 3 files.</p>
      </p:documentation>
    </p:option>

    <p:option name="audio-dir">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>Parent directory URI of the audio files.</p>
      </p:documentation>
    </p:option>

    <p:option name="smil-dir">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>Directory URI which the URI of the output SMIL files will be based on.</p>
      </p:documentation>
    </p:option>

    <p:option name="daisy3-dtbook-uri">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>Expected URI of the final DTBook document.</p>
      </p:documentation>
    </p:option>

    <p:option name="uid">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>UID of the DTBook (in the meta elements)</p>
      </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:xslt name="add-smilrefs">
      <p:input port="source">
	<p:pipe port="content" step="main"/>
	<p:pipe port="audio-map" step="main"/>
      </p:input>
      <p:input port="stylesheet">
	<p:document href="add-smilrefs.xsl"/>
      </p:input>
      <p:with-param name="granularity" select="'level'"/>
      <p:with-param name="mo-dir" select="$smil-dir"/>
      <p:with-param name="output-dir" select="$root-dir"/>
    </p:xslt>
    <cx:message message="Smilref attributes added."/>
    <p:sink/>

    <p:xslt name="create-mo">
      <p:input port="source">
	<p:pipe port="result" step="add-smilrefs"/>
	<p:pipe port="audio-map" step="main"/>
      </p:input>
      <p:input port="stylesheet">
	<p:document href="create-smils.xsl"/>
      </p:input>
      <p:with-param name="uid" select="$uid"/>
      <p:with-param name="mo-dir" select="$smil-dir"/>
      <p:with-param name="audio-dir" select="$audio-dir"/>
      <p:with-param name="content-uri" select="$daisy3-dtbook-uri"/>
      <p:with-param name="content-dir" select="$root-dir"/>
    </p:xslt>
    <cx:message message="SMIL files generated."/><p:sink/>

    <p:xslt name="compute-durations">
      <p:input port="source">
	<p:pipe port="secondary" step="create-mo"/>
      </p:input>
      <p:input port="stylesheet">
	<p:document href="compute-durations.xsl"/>
      </p:input>
      <p:input port="parameters">
	<p:empty/>
      </p:input>
    </p:xslt>
    <p:delete match="d:duration" name="total-duration"/>
    <cx:message message="Durations computed."/><p:sink/>

    <p:for-each name="smil-with-durations">
      <p:output port="result"/>
      <p:iteration-source>
	<p:pipe port="secondary" step="create-mo"/>
      </p:iteration-source>
      <p:variable name="doc-uri" select="base-uri(/*)"/>
      <p:viewport match="smil:head/smil:meta[@name='dtb:totalElapsedTime']">
	<p:add-attribute attribute-name="content" match="/*">
	  <p:with-option name="attribute-value" select="//*[@doc=$doc-uri]/@duration">
	    <p:pipe port="result" step="compute-durations"/>
	  </p:with-option>
	</p:add-attribute>
      </p:viewport>
    </p:for-each>

    <p:for-each>
      <p:iteration-source>
	<p:pipe port="secondary" step="create-mo"/>
      </p:iteration-source>
      <p:output port="result" sequence="true"/>
      <p:variable name="mo-uri" select="base-uri(/*)"/>
      <px:fileset-create>
	<p:with-option name="base" select="$smil-dir"/>
      </px:fileset-create>
      <px:fileset-add-entry media-type="application/smil">
	<p:with-option name="href" select="$mo-uri"/>
      </px:fileset-add-entry>
    </p:for-each>
    <px:fileset-join name="smil-in-fileset"/>

    <cx:message message="SMIL fileset created."/><p:sink/>

</p:declare-step>