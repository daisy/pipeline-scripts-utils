<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-nav-create-toc" name="main" xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    version="1.0">

    <p:input port="source" sequence="true"/>
    <p:output port="result"/>
    <p:option name="base-dir" select="''"/>

    <!--TODO honnor the 'untitled' option-->
    <p:option name="untitled" select="'unwrap'"/>
    <!-- "unwrap" (default) | "include" | "exclude" | "hide" -->
    <!--TODO honnor the 'sidebar' option-->
    <p:option name="sidebars" select="'exclude'"/>
    <!-- "include" | "exclude" (default) | "hide" -->
    <!--TODO honnor the 'visible-depth' option-->
    <p:option name="visible-depth" select="-1"/>
    <!-- integer -->

    <p:for-each name="tocs">
        <p:output port="result"/>
        <p:variable name="base-uri" select="p:base-uri(/*)"/>
        <p:variable name="base-ref"
            select="if (starts-with($base-uri,$base-dir)) 
                    then substring-after($base-uri,$base-dir) 
                    else $base-uri"/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document
                    href="http://www.daisy.org/pipeline/modules/html-utils/html5-outliner.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:filter select="/h:ol/h:li[1]"/>
        <p:string-replace match="//@href">
            <p:with-option name="replace" select="concat('concat(&quot;',$base-ref,'&quot;,.)')"/>
        </p:string-replace>
    </p:for-each>

    <p:insert match="/h:nav/h:ol" position="first-child">
        <p:input port="source">
            <p:inline exclude-inline-prefixes="#all">
                <nav epub:type="toc" xmlns="http://www.w3.org/1999/xhtml"
                    xmlns:epub="http://www.idpf.org/2007/ops">
                    <h1>Table of contents</h1>
                    <ol/>
                </nav>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="tocs"/>
        </p:input>
    </p:insert>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/nav-fixer.xsl"/>
        </p:input>
        <p:with-param name="untitled" select="$untitled"/>
    </p:xslt>

    <!--TODO better handling of duplicate IDs-->
    <p:delete match="@xml:id|@id"/>
</p:declare-step>
