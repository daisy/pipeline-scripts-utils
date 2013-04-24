<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    exclude-inline-prefixes="#all"
    type="odt:store" name="store" version="1.0">
    
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>
    
    <p:option name="href" required="true"/>
    
    <p:import href="utils/normalize-uri.xpl"/>
    <p:import href="utils/my-fileset-store.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/xproc/zip-library.xpl"/>
    
    <pxi:normalize-uri name="href">
        <p:with-option name="href" select="$href"/>
    </pxi:normalize-uri>
    <p:sink/>
    
    <!-- =================== -->
    <!-- Store files to disk -->
    <!-- =================== -->
    
    <pxi:my-fileset-store name="fileset-store">
        <p:input port="fileset.in">
            <p:pipe step="store" port="fileset.in"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe step="store" port="in-memory.in"/>
        </p:input>
    </pxi:my-fileset-store>
    
    <!-- =========================== -->
    <!-- Put mimetype as first entry -->
    <!-- =========================== -->
    
    <px:fileset-filter name="mimetype">
        <p:input port="source">
            <p:pipe step="store" port="fileset.in"/>
        </p:input>
        <p:with-option name="href" select="//d:file[ends-with(resolve-uri(@href,base-uri(.)),'/mimetype')]/resolve-uri(@href,base-uri(.))">
            <p:pipe step="store" port="fileset.in"/>
        </p:with-option>
    </px:fileset-filter>
    
    <px:fileset-join>
        <p:input port="source">
            <p:pipe step="mimetype" port="result"/>
            <p:pipe step="store" port="fileset.in"/>
        </p:input>
    </px:fileset-join>
    
    <!-- ====== -->
    <!-- Zip up -->
    <!-- ====== -->
    
    <px:zip-manifest-from-fileset/>
    
    <p:add-attribute name="manifest" match="c:entry[@name='mimetype']" attribute-name="compression-method" attribute-value="stored"/>
    
    <px:zip compression-method="deflated">
        <p:input port="source">
            <p:empty/>
        </p:input>
        <p:input port="manifest">
            <p:pipe port="result" step="manifest"/>
        </p:input>
        <p:with-option name="href" select="/c:result/string()">
            <p:pipe step="href" port="result"/>
        </p:with-option>
    </px:zip>
    <p:sink/>
    
</p:declare-step>
