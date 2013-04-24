<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    type="pxi:my-fileset-from-zipfile" version="1.0">
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <!-- Directory where the zip should ultimately be extracted -->
    <p:option name="target" required="false" select="''"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="my-fileset-from-zipfile.xsl"/>
        </p:input>
        <p:with-param name="target" select="$target"/>
    </p:xslt>
    
</p:declare-step>
