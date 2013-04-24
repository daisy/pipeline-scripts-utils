<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all"
    type="pxi:my-fileset-load" name="my-fileset-load" version="1.0">
    
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>
    <p:output port="in-memory.out" sequence="true"/>
    
    <p:import href="my-fileset-from-in-memory.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/xproc/zip-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <!-- ============================= -->
    <!-- Load zipped files into memory -->
    <!-- ============================= -->
    
    <pxi:my-fileset-from-in-memory name="fileset.in-memory.in">
        <p:input port="source">
            <p:pipe step="my-fileset-load" port="in-memory.in"/>
        </p:input>
    </pxi:my-fileset-from-in-memory>
    <p:sink/>
    
    <p:delete match="//d:file[not(contains(resolve-uri((@original-href, @href)[1], base-uri(.)), '!/'))]">
        <p:input port="source">
            <p:pipe step="my-fileset-load" port="fileset.in"/>
        </p:input>
    </p:delete>
    
    <px:fileset-diff>
        <p:input port="secondary">
            <p:pipe step="fileset.in-memory.in" port="result"/>
        </p:input>
    </px:fileset-diff>
    
    <p:for-each name="in-memory.unzipped">
        <p:iteration-source select="//d:file"/>
        <p:output port="result" sequence="true"/>
        <p:variable name="target" select="/*/resolve-uri(@href, base-uri(.))"/>
        <p:variable name="on-disk" select="/*/resolve-uri((@original-href,@href)[1], base-uri(.))"/>
        <p:variable name="media-type" select="/*/@media-type"/>
        <cx:message>
            <p:with-option name="message" select="replace($on-disk, '^([^!]+)!/(.+)$', 'Loading $2 from zip $1')"/>
        </cx:message>
        <p:sink/>
        <p:try>
            <p:group>
                <px:unzip>
                    <p:with-option name="href" select="replace($on-disk, '^([^!]+)!/(.+)$', '$1')"/>
                    <p:with-option name="file" select="replace($on-disk, '^([^!]+)!/(.+)$', '$2')"/>
                    <p:with-option name="content-type" select="$media-type"/>
                </px:unzip>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="$target"/>
                </p:add-attribute>
            </p:group>
            <p:catch>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:catch>
        </p:try>
    </p:for-each>
    
    <!-- ================================ -->
    <!-- Load remaining files into memory -->
    <!-- ================================ -->
    
    <px:fileset-load>
        <p:input port="fileset">
            <p:pipe step="my-fileset-load" port="fileset.in"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe step="my-fileset-load" port="in-memory.in"/>
            <p:pipe step="in-memory.unzipped" port="result"/>
        </p:input>
    </px:fileset-load>
    
</p:declare-step>
