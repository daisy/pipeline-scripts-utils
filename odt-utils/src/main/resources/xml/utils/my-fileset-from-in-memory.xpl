<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    type="pxi:my-fileset-from-in-memory" name="fileset-from-in-memory" version="1.0">
    
    <p:input port="source" sequence="true"/>
    <p:output port="result"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    
    <px:fileset-create name="base" base="/"/>
    <p:sink/>
    
    <p:for-each>
        <p:iteration-source>
            <p:pipe step="fileset-from-in-memory" port="source"/>
        </p:iteration-source>
        <px:fileset-add-entry>
            <p:with-option name="href" select="base-uri(/*)"/>
            <p:input port="source">
                <p:pipe step="base" port="result"/>
            </p:input>
        </px:fileset-add-entry>
    </p:for-each>
    
    <px:fileset-join/>
    
</p:declare-step>
