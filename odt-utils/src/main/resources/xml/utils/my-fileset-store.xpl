<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all"
    type="pxi:my-fileset-store" name="my-fileset-store" version="1.0">
    
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>
    
    <p:import href="my-fileset-load.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    
    <pxi:my-fileset-load name="fileset-load">
        <p:input port="fileset.in">
            <p:pipe step="my-fileset-store" port="fileset.in"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe step="my-fileset-store" port="in-memory.in"/>
        </p:input>
    </pxi:my-fileset-load>
    
    <px:fileset-store name="fileset-store">
        <p:input port="fileset.in">
            <p:pipe step="my-fileset-store" port="fileset.in"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe step="fileset-load" port="in-memory.out"/>
        </p:input>
    </px:fileset-store>
    
</p:declare-step>
