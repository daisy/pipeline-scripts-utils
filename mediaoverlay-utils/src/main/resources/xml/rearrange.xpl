<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="rearrange" type="px:mediaoverlay-rearrange" version="1.0" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:err="http://www.w3.org/ns/xproc-error" xmlns:mo="http://www.w3.org/ns/SMIL"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:cx="http://xmlcalabash.com/ns/extensions">

    <p:input port="mediaoverlay" primary="true" sequence="true"/>
    <p:input port="content" sequence="true"/>
    <p:output port="result" sequence="true" primary="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>
    <p:import href="join.xpl"/>

    <p:group name="rearrange.mediaoverlay-map">
        <p:output port="result"/>
        <!--<px:mediaoverlay-join/>-->
        <!--TODO shouldn't need to rely on @xml:base -->
        <p:for-each>
            <p:add-xml-base all="true" relative="false"/>
        </p:for-each>
        <p:wrap-sequence wrapper="smil-map" wrapper-namespace="http://www.daisy.org/ns/pipeline/tmp"/>
        <p:viewport match="//mo:text" name="rearrange.mediaoverlay-annotated">
            <p:add-attribute attribute-name="fragment" match="/*">
                <p:with-option name="attribute-value" select="if (contains(/*/@src,'#')) then tokenize(/*/@src,'#')[last()] else ''"/>
            </p:add-attribute>
            <p:add-attribute attribute-name="src" match="/*">
                <p:with-option name="attribute-value" select="/*/resolve-uri(tokenize(@src,'#')[1],base-uri(.))"/>
            </p:add-attribute>
        </p:viewport>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="rearrange.prepare.xsl"/>
            </p:input>
        </p:xslt>
        <cx:message message="created annotated mediaoverlay"/>
    </p:group>
    <p:sink/>

    <p:for-each name="rearrange.for-each">
        <p:output port="mediaoverlay" sequence="true" primary="true"/>
        <p:iteration-source>
            <p:pipe port="content" step="rearrange"/>
        </p:iteration-source>
        <p:variable name="content-base" select="base-uri(/*)"/>

        <p:add-attribute match="//*" attribute-name="xml:base" name="rearrange.for-each.content">
            <p:with-option name="attribute-value" select="base-uri(/*)"/>
        </p:add-attribute>
        <p:wrap-sequence wrapper="content-and-mediaoverlay" wrapper-namespace="http://www.daisy.org/ns/pipeline/tmp">
            <p:input port="source">
                <p:pipe port="result" step="rearrange.for-each.content"/>
                <p:pipe port="result" step="rearrange.mediaoverlay-map"/>
            </p:input>
        </p:wrap-sequence>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="rearrange.xsl"/>
            </p:input>
        </p:xslt>
        <p:delete match="//mo:seq[not(descendant::mo:par)]"/>

        <p:documentation>generate ids</p:documentation>
        <p:xslt>
            <p:with-param name="iteration-position" select="p:iteration-position()"/>
            <p:input port="stylesheet">
                <p:document href="generate-ids.xsl"/>
            </p:input>
        </p:xslt>

        <p:documentation>resolve relative uris</p:documentation>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="resolve-relative-uris.xsl"/>
            </p:input>
        </p:xslt>

        <p:documentation>if there is only one top-level seq; turn it into a body element</p:documentation>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="conditionally-join-toplevel-seq-with-body.xsl"/>
            </p:input>
        </p:xslt>

        <cx:message>
            <p:with-option name="message" select="concat('created media overlay for ',$content-base)"/>
        </cx:message>
    </p:for-each>

</p:declare-step>
