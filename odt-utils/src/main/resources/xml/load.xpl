<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
    exclude-inline-prefixes="#all"
    type="odt:load" version="1.0">
    
    <!-- The .odt or .ott file. Should be a file: URI -->
    <p:option name="href" required="true"/>
    
    <!-- Directory where the fileset will ultimately be stored -->
    <p:option name="target" required="false" select="''"/>
    
    <p:output port="fileset.out" primary="true">
        <p:pipe step="fileset" port="result"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe step="new-mimetype" port="result"/>
        <p:pipe step="new-manifest" port="result"/>
        <p:pipe step="manifest" port="not-matched"/>
    </p:output>
    
    <p:import href="utils/my-fileset-from-zipfile.xpl"/>
    <p:import href="utils/my-fileset-load.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/xproc/zip-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    
    <!-- ===== -->
    <!-- Unzip -->
    <!-- ===== -->
    
    <px:unzip>
        <p:with-option name="href" select="$href"/>
    </px:unzip>
    
    <pxi:my-fileset-from-zipfile name="zipfile">
        <p:with-option name="target" select="$target"/>
    </pxi:my-fileset-from-zipfile>
    
    <!-- ============ -->
    <!-- New mimetype -->
    <!-- ============ -->
    
    <p:string-replace match="text()" replace="normalize-space()">
        <p:input port="source">
            <p:inline>
                <c:data content-type="text/plain">application/vnd.oasis.opendocument.text</c:data>
            </p:inline>
        </p:input>
    </p:string-replace>
    
    <p:add-attribute match="/*" attribute-name="xml:base" name="new-mimetype">
        <p:with-option name="attribute-value" select="resolve-uri('mimetype', $target)"/>
    </p:add-attribute>
    <p:sink/>
    
    <p:delete match="//d:file[@href='mimetype']">
        <p:input port="source">
            <p:pipe step="zipfile" port="result"/>
        </p:input>
    </p:delete>
    
    <px:fileset-add-entry first="true" media-type="text/plain" href="mimetype"/>
    
    <!-- ========================= -->
    <!-- Add media-type attributes -->
    <!-- ========================= -->
    
    <p:add-attribute match="//d:file[@href=('content.xml','styles.xml','meta.xml','settings.xml','META-INF/manifest.xml')]"
                     attribute-name="media-type" attribute-value="application/xml"/>
    
    <p:add-attribute match="//d:file[@href='manifest.rdf']"
                     attribute-name="media-type" attribute-value="application/rdf+xml"/>
    
    <p:identity name="fileset"/>
    
    <!-- ========================== -->
    <!-- Load xml files into memory -->
    <!-- ========================== -->
    
    <px:fileset-filter media-types="application/xml application/rdf+xml"/>
    
    <pxi:my-fileset-load>
        <p:input port="in-memory.in">
            <p:empty/>
        </p:input>
    </pxi:my-fileset-load>
    
    <!-- =============== -->
    <!-- Update manifest -->
    <!-- =============== -->
    
    <p:split-sequence test="ends-with(base-uri(/*), '/META-INF/manifest.xml')" name="manifest"/>
    
    <p:add-attribute match="//manifest:file-entry[@manifest:full-path='/']"
                     attribute-name="manifest:media-type" attribute-value="application/vnd.oasis.opendocument.text"
                     name="new-manifest"/>
    
</p:declare-step>
