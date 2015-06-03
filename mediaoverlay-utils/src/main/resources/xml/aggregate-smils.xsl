<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/ns/SMIL" xmlns:d="http://www.daisy.org/ns/pipeline/data" xpath-default-namespace="http://www.w3.org/ns/SMIL"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

    <xsl:param name="other-smil" required="no" as="document-node()*" select="collection()[position() &gt; 1]"/>

    <xsl:template match="/*">
        <xsl:call-template name="aggregate-smil">
            <xsl:with-param name="main" select="/*"/>
            <xsl:with-param name="other" select="$other-smil[1]"/>
            <xsl:with-param name="next" select="$other-smil[position() &gt; 1]"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="aggregate-smil">
        <xsl:param name="main" as="element()"/>
        <xsl:param name="other" as="element()?"/>
        <xsl:param name="next" as="element()*"/>
        <xsl:choose>
            <xsl:when test="not($other)">
                <xsl:copy-of select="$main"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="intermediate-result">
                    <xsl:for-each select="$main">

                        <xsl:copy>
                            <xsl:copy-of select="$other/@*"/>
                            <xsl:copy-of select="@*"/>
                            <xsl:for-each select="head">
                                <xsl:copy>
                                    <xsl:copy-of select="$other/head/@*"/>
                                    <xsl:copy-of select="@*"/>

                                    <!-- TODO: merge metadata as well. For now, let's just keep the original metadata and discard the new metadata. -->
                                    <xsl:copy-of select="node()"/>
                                </xsl:copy>
                            </xsl:for-each>
                            <xsl:for-each select="body">
                                <xsl:copy>
                                    <xsl:copy-of select="$other/body/@*"/>
                                    <xsl:copy-of select="@*"/>

                                    <xsl:variable name="main-body" select="if (count(*) = 1 and seq) then seq else ."/>
                                    <xsl:variable name="other-body" select="if (count($other/body/*) = 1 and $other/body/seq) then $other/body/seq else $other/body"/>
                                    <seq>
                                        <!-- as per convention, make sure there's one main wrapper seq -->
                                        <xsl:copy-of select="$other-body[self::seq]/@*"/>
                                        <xsl:copy-of select="$main-body[self::seq]/@*"/>

                                        <xsl:choose>
                                            <xsl:when test="not($main-body//text)">
                                                <xsl:copy-of select="$other-body/*"/>
                                            </xsl:when>
                                            <xsl:otherwise>

                                                <xsl:variable name="main-src" select="$main-body//text/@src"/>
                                                <xsl:variable name="other-groups" as="element()*">
                                                    <xsl:for-each-group select="$other-body//*" group-starting-with="par[text/@src=$main-src]">
                                                        <group>
                                                            <xsl:copy-of select="text/@src[.=$main-src]"/>
                                                            <xsl:copy-of select="current-group()[not(ancestor::* intersect current-group())]"/>
                                                        </group>
                                                    </xsl:for-each-group>
                                                </xsl:variable>

                                                <xsl:copy-of select="$other-groups[not(@src)]/*"/>

                                                <xsl:apply-templates select="$main-body/*">
                                                    <xsl:with-param name="other-groups" tunnel="yes" select="$other-groups"/>
                                                </xsl:apply-templates>

                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </seq>
                                </xsl:copy>
                            </xsl:for-each>
                        </xsl:copy>

                    </xsl:for-each>
                </xsl:variable>
                <xsl:call-template name="aggregate-smil">
                    <xsl:with-param name="main" select="$intermediate-result/*"/>
                    <xsl:with-param name="other" select="$next[1]"/>
                    <xsl:with-param name="next" select="$next[position() &gt; 1]"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="par[text/@src]">
        <xsl:param name="other-groups" tunnel="yes" as="element()*"/>
        <xsl:variable name="other-group" select="$other-groups[@src=current()/text/@src]"/>
        <xsl:variable name="other-par" select="$other-group/*[1]"/>
        <xsl:copy>
            <xsl:copy-of select="$other-par/@*"/>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="text">
                <xsl:copy>
                    <xsl:copy-of select="$other-par/text/@*"/>
                    <xsl:copy-of select="@*"/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="audio">
                <xsl:copy>
                    <xsl:copy-of select="$other-par/audio/@*"/>
                    <xsl:copy-of select="@*"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>

        <xsl:copy-of select="$other-group/node() except $other-group/*[1]"/>
    </xsl:template>

</xsl:stylesheet>
