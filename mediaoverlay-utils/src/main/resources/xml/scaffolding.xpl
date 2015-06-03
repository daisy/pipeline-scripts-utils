<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" type="px:mediaoverlay-create-scaffolding"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1>px:mediaoverlay-create-scaffolding</h1>
        <p>Populates a SMIL file with text references. Merges in existing pre-existing SMIL clips.
            Assumes that (X)HTML documents as well as any pre-existing SMIL files in the fileset are
            in reading order.</p>
    </p:documentation>

    <p:input port="fileset.in" primary="true"/>
    <p:input port="in-memory.in" sequence="true"/>

    <p:output port="fileset.out" primary="true">
        <p:pipe port="result" step="result.fileset"/>
    </p:output>
    <p:output port="in-memory.out" sequence="true">
        <p:pipe port="result" step="result.in-memory.smil"/>
        <p:pipe port="result" step="result.in-memory.xhtml"/>
        <p:pipe port="result" step="result.in-memory.opf"/>
        <p:pipe port="result" step="result.in-memory.other"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>

    <px:fileset-filter media-types="application/xhtml+xml text/html" name="content-fileset"/>
    <px:fileset-load>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:for-each>
        <px:message severity="DEBUG" message="Adding IDs to $1...">
            <p:with-option name="param1" select="replace(base-uri(/*),'.*/','')"/>
        </px:message>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="generate-ids.html.xsl"/>
            </p:input>
        </p:xslt>
    </p:for-each>
    <p:identity name="result.in-memory.xhtml"/>

    <p:identity>
        <p:input port="source">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
    </p:identity>
    <px:message severity="DEBUG"
        message="Loading all SMIL files (assumed to be in reading order)..."/>
    <px:fileset-load media-types="application/smil+xml">
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <px:message severity="DEBUG" message="Joining SMIL files into one..."/>
    <px:mediaoverlay-join/>
    <p:identity name="one-big-smil"/>
    <px:message severity="DEBUG"
        message="Splitting SMIL file where possible (ideally one per content document)..."/>
    <p:xslt>
        <p:input port="source">
            <p:pipe port="result" step="one-big-smil"/>
            <p:pipe port="result" step="content-fileset"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="split-according-to-fileset.xsl"/>
        </p:input>
    </p:xslt>
    <p:for-each>
        <p:iteration-source select="/*/*"/>
        <p:identity name="preexisting-smil"/>

        <px:message severity="DEBUG" message="Loading content documents to be referenced from $1...">
            <p:with-option name="param1" select="replace(base-uri(/*),'.*/','')"/>
        </px:message>
        <px:fileset-load>
            <p:input port="fileset.in" select="/*/*[1]"/>
            <p:input port="in-memory.in">
                <p:pipe port="result" step="result.in-memory.xhtml"/>
            </p:input>
        </px:fileset-load>
        <p:for-each>
            <px:message severity="DEBUG" message="Constructing SMIL based on $1...">
                <p:with-option name="param1" select="replace(base-uri(/*),'.*/','')"/>
            </px:message>
            <p:xslt>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="html-to-smil.xsl"/>
                </p:input>
            </p:xslt>
        </p:for-each>
        <p:identity name="xhtml-smils"/>

        <p:identity>
            <p:input port="source">
                <p:pipe step="preexisting-smil" port="result"/>
            </p:input>
        </p:identity>
        <p:delete match="/*/d:fileset"/>
        <px:message severity="DEBUG"
            message="Merging generated SMIL into pre-existing SMIL clips: $1">
            <p:with-option name="param1" select="replace(base-uri(/*),'.*/','')"/>
        </px:message>
        <p:xslt>
            <p:input port="source">
                <p:pipe port="result" step="preexisting-smil"/>
                <p:pipe port="result" step="xhtml-smils"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="aggregate-smils.xsl"/>
            </p:input>
        </p:xslt>
    </p:for-each>

    <p:identity name="result.in-memory.smil"/>

    <p:wrap-sequence wrapper="wrapper">
        <p:input port="source">
            <p:pipe port="result" step="clips-from-xhtml"/>
            <p:pipe port="result" step="clips-from-smil"/>
        </p:input>
    </p:wrap-sequence>
    <p:xslt>
        <!-- TODO: merge clips from xhtml and clips from smil so that they are in the optimal order -->
    </p:xslt>
    <p:filter select="/*/*"/>
    <p:identity name="result.in-memory.smil"/>
    <p:count name="result-smil-count"/>
    <p:sink/>

    <px:fileset-load media-types="application/oebps-package+xml">
        <p:input port="fileset.in">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:for-each>
        <!-- if fileset contains opf; update it -->
        <p:choose>
            <p:xpath-context>
                <p:pipe port="result" step="result-smil-count"/>
            </p:xpath-context>
            <p:when test="/*/text() = 1">
                <!-- one SMIL for everything -->
                <p:xslt>
                    <!-- TODO: update opf -->
                </p:xslt>
            </p:when>
            <p:otherwise>
                <!-- one SMIL per content document -->
                <p:xslt>
                    <!-- TODO: update opf -->
                </p:xslt>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:identity name="result.in-memory.opf"/>
    <p:sink/>

    <!-- TODO: get in-memory stuff that's not html/smil/opf -->
    <px:fileset-load
        not-media-types="application/xhtml+xml text/html application/smil+xml application/oebps-package+xml"
        load-if-not-in-memory="false">
        <p:input port="fileset.in">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
        <p:input port="in-memory.in">
            <p:pipe port="in-memory.in" step="main"/>
        </p:input>
    </px:fileset-load>
    <p:identity name="result.in-memory.other"/>
    <p:sink/>

    <p:identity>
        <p:input port="source">
            <p:pipe step="result.in-memory.smil" port="result"/>
        </p:input>
    </p:identity>
    <!-- TODO: create fileset from in-memory smils -->
    <p:identity name="result-smil-fileset"/>

    <px:fileset-filter not-media-type="application/smil+xml" name="result-non-smil-fileset">
        <p:input port="source">
            <p:pipe port="fileset.in" step="main"/>
        </p:input>
    </px:fileset-filter>

    <px:fileset-join>
        <p:input port="source">
            <p:pipe step="result-smil-fileset" port="result"/>
            <p:pipe step="result-non-smil-fileset" port="result"/>
        </p:input>
    </px:fileset-join>
    <p:identity name="result.fileset"/>

</p:declare-step>
