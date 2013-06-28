<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-pub-enhance" name="main" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:epub="http://www.idpf.org/2007/ops" xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions" xmlns:cx="http://xmlcalabash.com/ns/extensions" version="1.0">
    
    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>
    
    <p:output port="fileset.out" primary="true">
        <p:pipe port="result" step="result.fileset"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="result" step="result.in-memory"/>
    </p:output>
    
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/mediatype-utils/mediatype.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/logging-library.xpl"/>
    
    <px:message message="Enhancing EPUB..." name="start-message"/>
    <p:sink/>
    <p:for-each cx:depends-on="start-message">
        <p:iteration-source>
            <p:pipe port="in-memory.in" step="main"/>
        </p:iteration-source>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <!-- annotate with xml:base due to issue with p:xslt: http://lists.w3.org/Archives/Public/xproc-dev/2013Mar/0013.html -->
            <p:with-option name="attribute-value" select="base-uri(/*)"/>
        </p:add-attribute>
        <p:choose>
            <p:when test="namespace-uri(/*)='http://www.w3.org/1999/xhtml'">
                <px:message>
                    <p:with-option name="message" select="concat('annotating all HTML elements with IDs in ',replace(base-uri(/*),'^.*/([^/]*)$','$1'))"/>
                </px:message>
                <p:xslt>
                    <p:with-option name="output-base-uri" select="base-uri(/*)"/>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="annotate-with-ids.xsl"/>
                    </p:input>
                </p:xslt>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
        <p:identity/>
    </p:for-each>
    <p:identity name="in-memory.in"/>
    <p:sink/>
    
    <px:mediatype-detect>
        <p:input port="source">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe step="in-memory.in" port="result"/>
        </p:input>
    </px:mediatype-detect>
    <p:identity name="fileset.in"/>
    
    <!-- use EPUB vocab semantics on tables in SMIL -->
    <p:group name="smil-table-semantics">
        <p:output port="fileset.out" primary="true">
            <p:pipe port="result" step="fileset.in"/>
        </p:output>
        <p:output port="in-memory.out" sequence="true">
            <p:pipe port="result" step="smil-table-semantics.result.in-memory"/>
        </p:output>
        
        <p:choose>
            <p:when test="//@media-type='application/smil+xml'">
                <px:fileset-load media-types="application/oebps-package+xml">
                    <p:input port="fileset">
                        <p:pipe port="result" step="fileset.in"/>
                    </p:input>
                    <p:input port="in-memory">
                        <p:pipe port="result" step="in-memory.in"/>
                    </p:input>
                </px:fileset-load>
                <px:assert test-count="1" message="there must be exactly one package document in the EPUB fileset"/>
                <p:identity name="smil-table-semantics.opf"/>
                
                <p:for-each>
                    <p:iteration-source select="/opf:package/opf:manifest/opf:item[@media-overlay]"/>
                    <p:variable name="media-overlay-id" select="replace(/*/@media-overlay,'#','')"/>
                    <p:variable name="html-href" select="/*/@href"/>
                    <px:fileset-load>
                        <p:with-option name="href" select="resolve-uri($html-href,base-uri(/*))"/>
                        <p:input port="fileset">
                            <p:pipe port="result" step="fileset.in"/>
                        </p:input>
                        <p:input port="in-memory">
                            <p:pipe port="result" step="in-memory.in"/>
                        </p:input>
                    </px:fileset-load>
                    <px:assert test-count="1">
                        <p:with-option name="message" select="concat('there must be exactly one HTML document in the EPUB fileset at ',resolve-uri($html-href,base-uri(/*)))">
                            <p:pipe port="result" step="smil-table-semantics.opf"/>
                        </p:with-option>
                    </px:assert>
                    <p:identity name="smil-table-semantics.html"/>
                    
                    <px:fileset-load>
                        <p:with-option name="href" select="resolve-uri(/opf:package/opf:manifest/opf:item[@id=$media-overlay-id]/@href,base-uri(/*))">
                            <p:pipe port="result" step="smil-table-semantics.opf"/>
                        </p:with-option>
                        <p:input port="fileset">
                            <p:pipe port="result" step="fileset.in"/>
                        </p:input>
                        <p:input port="in-memory">
                            <p:pipe port="result" step="in-memory.in"/>
                        </p:input>
                    </px:fileset-load>
                    <px:assert test-count="1">
                        <p:with-option name="message" select="concat('there must be exactly one SMIL document in the EPUB fileset at ',resolve-uri(/opf:package/opf:manifest/opf:item[@id=$media-overlay-id]/@href,base-uri(/*)))">
                            <p:pipe port="result" step="smil-table-semantics.opf"/>
                        </p:with-option>
                    </px:assert>
                    <p:identity name="smil-table-semantics.smil"/>
                    
                    <p:insert match="/*" position="last-child">
                        <p:input port="insertion">
                            <p:pipe port="result" step="smil-table-semantics.html"/>
                        </p:input>
                    </p:insert>
                    <p:xslt>
                        <p:with-option name="output-base-uri" select="base-uri(/*)"/>
                        <p:input port="parameters">
                            <p:empty/>
                        </p:input>
                        <p:input port="stylesheet">
                            <p:document href="enhance.smil-table-semantics.xsl"/>
                        </p:input>
                    </p:xslt>
                    <px:message>
                        <p:with-option name="message" select="concat('added table semantics to ',replace(base-uri(/*),'^.*/([^/]*)$','$1'))"/>
                    </px:message>
                </p:for-each>
                <px:fileset-in-memory-update>
                    <p:input port="source">
                        <p:pipe port="result" step="in-memory.in"/>
                    </p:input>
                </px:fileset-in-memory-update>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="result" step="in-memory.in"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:identity name="smil-table-semantics.result.in-memory"/>
    </p:group>
    
    
    <!-- more enhancements can be added here -->
    
    
    <px:message message="EPUB enhancement done."/>
    <p:identity name="result.fileset"/>
    <p:sink/>
    
    <p:identity>
        <p:input port="source">
            <p:pipe port="in-memory.out" step="smil-table-semantics"/>
        </p:input>
    </p:identity>
    <p:for-each>
        <p:delete match="/*/@xml:base"/>
    </p:for-each>
    <p:identity name="result.in-memory"/>
    <p:sink/>

</p:declare-step>
