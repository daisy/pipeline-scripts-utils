<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:epub3-nav-create-page-list"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" version="1.0">


    <p:input port="source" sequence="true"/>
    <p:output port="result"/>
    <p:option name="hidden" select="'true'"/>

    <p:for-each name="page-lists">
        <p:output port="result"/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/html5-to-page-list.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:filter select="(//h:ol)[1]"/>
    </p:for-each>

    <p:insert match="/h:nav/h:ol" position="first-child">
        <p:input port="source">
            <p:inline exclude-inline-prefixes="#all">
                <nav epub:type="page-list"
                    xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
                    <h1>List of pages</h1>
                    <ol/>
                </nav>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="page-lists"/>
        </p:input>
    </p:insert>

    <p:unwrap match="/h:nav/h:ol/h:ol"/>

    <!--TODO better handling of duplicate IDs-->
    <p:delete match="@xml:id|@id"/>
    
    <p:choose>
        <p:when test="$hidden='true'">
            <p:add-attribute attribute-name="hidden" attribute-value="" match="/h:nav"/>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
</p:declare-step>
