<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:html="http://www.w3.org/1999/xhtml" xmlns="http://www.daisy.org/z3986/2005/ncx/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops"
    exclude-result-prefixes="#all" version="2.0" xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions" xmlns:d="http://www.daisy.org/ns/pipeline/data">

    <!-- Creates a text-only NCX based on a EPUB3 Navigation Document -->
    <!-- TODO: pages and landmarks will not be in reading order. to determine their reading order, the content documents would have to be inspected. -->

    <xsl:output indent="yes"/>

    <xsl:template match="@*|node()">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="html:html">
        <ncx version="2005-1">
            <xsl:apply-templates select="html:head"/>
            <xsl:if test="html:head/html:title">
                <docTitle>
                    <text>
                        <xsl:value-of select="html:head/html:title"/>
                    </text>
                </docTitle>
            </xsl:if>
            <!-- NOTE: docAuthor should be added afterwards, since it usually isn't available from the Navigation Document, and there can be mulitple authors. -->
            <xsl:apply-templates select="html:body"/>
        </ncx>
    </xsl:template>

    <xsl:template match="html:head">
        <head>
            <meta name="dtb:uid" content="{html:meta[@name='dc:identifier']}"/>
            <meta name="dtb:depth" content="{max(//html:li/count(ancestor::html:li))+1}"/>
            <meta name="dtb:generator" content="DAISY Pipeline 2"/>
            <xsl:variable name="totalPageCount" select="count(//html:nav[@*[name()='epub:type']='page-list']/html:ol/html:li)"/>
            <meta name="dtb:totalPageCount" content="{$totalPageCount}"/>
            <!-- TODO: parse roman numerals? -->
            <xsl:variable name="maxPageNumber" select="number((//html:nav[@*[name()='epub:type']='page-list']/html:ol/html:li)[last()])"/>
            <meta name="dtb:maxPageNumber" content="{if (string($maxPageNumber)='NaN') then $totalPageCount else $maxPageNumber}"/>
            <xsl:apply-templates select="html:meta[not(@name='dc:identifier')]"/>
        </head>
    </xsl:template>

    <xsl:template match="html:body">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="html:nav">
        <xsl:choose>
            <xsl:when test="@*[name()='epub:type']='toc'">
                <navMap>
                    <xsl:call-template name="make-label"/>
                    <xsl:apply-templates/>
                </navMap>
            </xsl:when>
            <xsl:when test="@*[name()='epub:type']='page-list'">
                <pageList>
                    <xsl:call-template name="make-label"/>
                    <xsl:apply-templates/>
                </pageList>
            </xsl:when>
            <xsl:otherwise>
                <navList>
                    <xsl:call-template name="make-label"/>
                    <xsl:apply-templates/>
                </navList>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="html:ol">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="html:li">
        <xsl:choose>
            <xsl:when test="ancestor::html:nav/@*[name()='epub:type']='toc'">
                <xsl:choose>
                    <xsl:when test="html:a">
                        <navPoint id="navPoint-{count(preceding::html:li | ancestor::html:li)+1}" playOrder="{count(preceding::html:a/@href)+1}">
                            <xsl:call-template name="make-label"/>
                            <xsl:call-template name="make-content"/>
                            <xsl:apply-templates/>
                        </navPoint>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="ancestor::html:nav/@*[name()='epub:type']='page-list'">
                <xsl:if test="html:a">
                    <pageTarget id="pageTarget-{count(preceding::html:li | ancestor::html:li)+1}" playOrder="{count(preceding::html:a/@href)+1}">
                        <xsl:choose>
                            <xsl:when test="string(number(.))=normalize-space(.)">
                                <xsl:attribute name="type" select="'normal'"/>
                            </xsl:when>
                            <!-- TODO: page-type could be retrieved from the content documents -->
                            <xsl:otherwise>
                                <xsl:attribute name="type" select="'special'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:call-template name="make-label"/>
                        <xsl:call-template name="make-content"/>
                    </pageTarget>
                </xsl:if>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="html:a">
                    <navTarget id="navTarget-{count(preceding::html:li | ancestor::html:li)+1}" playOrder="{count(preceding::html:a/@href)+1}">
                        <xsl:call-template name="make-label"/>
                        <xsl:call-template name="make-content"/>
                    </navTarget>
                </xsl:if>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="make-label">
        <xsl:if test="html:a | html:span | html:hgroup | html:h1 | html:h2 | html:h3 | html:h3 | html:h4 | html:h5 | html:h6">
            <navLabel>
                <text>
                    <xsl:value-of select="normalize-space(string-join((html:a | html:span | html:hgroup | html:h1 | html:h2 | html:h3 | html:h3 | html:h4 | html:h5 | html:h6)/descendant::text(),' '))"
                    />
                </text>
            </navLabel>
        </xsl:if>
    </xsl:template>

    <xsl:template name="make-content">
        <xsl:if test="html:a">
            <content src="{if (starts-with(html:a/@href,'#')) then concat(replace(base-uri(/*),'^.*/([^/]*)$','$1'),html:a/@href) else html:a/@href}"/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
