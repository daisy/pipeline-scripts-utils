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
    
    <p:import href="my-fileset-from-in-memory.xpl"/>
    <p:import href="my-fileset-load.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    
    <!-- ============================= -->
    <!-- Load zipped files into memory -->
    <!-- ============================= -->
    
    <pxi:my-fileset-from-in-memory name="fileset.in-memory.in">
        <p:input port="source">
            <p:pipe step="my-fileset-store" port="in-memory.in"/>
        </p:input>
    </pxi:my-fileset-from-in-memory>
    <p:sink/>
    
    <p:delete match="//d:file[not(contains(resolve-uri((@original-href, @href)[1], base-uri(.)), '!/'))]">
        <p:input port="source">
            <p:pipe step="my-fileset-store" port="fileset.in"/>
        </p:input>
    </p:delete>
    
    <px:fileset-diff>
        <p:input port="secondary">
            <p:pipe step="fileset.in-memory.in" port="result"/>
        </p:input>
    </px:fileset-diff>
    
    <pxi:my-fileset-load name="in-memory.unzip">
        <p:input port="in-memory.in">
            <p:pipe step="my-fileset-store" port="in-memory.in"/>
        </p:input>
    </pxi:my-fileset-load>
    
    <!-- =================== -->
    <!-- Store files to disk -->
    <!-- =================== -->
    
    <px:fileset-store name="fileset-store">
        <p:input port="fileset.in">
            <p:pipe step="my-fileset-store" port="fileset.in"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe step="my-fileset-store" port="in-memory.in"/>
            <p:pipe step="in-memory.unzip" port="in-memory.out"/>
        </p:input>
    </px:fileset-store>
    
</p:declare-step>
