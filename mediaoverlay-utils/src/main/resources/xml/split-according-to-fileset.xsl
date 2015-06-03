<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/ns/SMIL"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xpath-default-namespace="http://www.w3.org/ns/SMIL" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="2.0">

    <xsl:param name="fileset" required="no" as="document-node()" select="collection()[2]"/>

    <xsl:template match="/*">
        <xsl:variable name="smil">
            <xsl:apply-templates select="/*" mode="relative-to-fileset-base">
                <xsl:with-param name="subdir" tunnel="yes"
                    select="substring-after(replace(base-uri(/*), '[^/]+$',''), $fileset/base-uri())"
                />
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="smil-spine" as="xs:string*">
            <xsl:for-each-group select="$smil//text" group-adjacent="substring-before(@src,'#')">
                <xsl:value-of select="substring-before(@src,'#')"/>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="one-big-smil-hrefs"
            select="for $value in distinct-values($smil-spine) return if (count($smil-spine[.=$value]) &gt; 1) then $value else ()"/>

        <smil xmlns="http://www.w3.org/ns/SMIL">

            <xsl:for-each select="$fileset/*">
                <xsl:if test="not(@href = $one-big-smil-hrefs)">
                    <smil xmlns="http://www.w3.org/ns/SMIL"
                        xmlns:epub="http://www.idpf.org/2007/ops" version="3.0"
                        xml:base="{replace(resolve-uri(@href,base-uri()),'\.[^\./]*$','.smil')}">

                        <xsl:variable name="href" select="@href"/>
                        <xsl:for-each select="$fileset">
                            <xsl:copy>
                                <xsl:copy-of select="@*"/>
                                <xsl:copy-of select="*[@href=$href]"/>
                            </xsl:copy>
                        </xsl:for-each>

                        <xsl:call-template name="construct-smil">
                            <xsl:with-param name="href" select="@href" tunnel="yes"/>
                            <xsl:with-param name="one-big-smil-hrefs" select="$one-big-smil-hrefs"
                                tunnel="yes"/>
                            <xsl:with-param name="smil" select="$smil/*" tunnel="yes"/>
                        </xsl:call-template>
                    </smil>
                </xsl:if>

            </xsl:for-each>

            <xsl:if test="count($one-big-smil-hrefs) &gt; 0">
                <xsl:variable name="one-big-smil-filename"
                    select="concat(
                                    if (not($fileset/*[contains(@href,'common')])) then 'common'
                                    else if (not($fileset/*[contains(@href,'common-smil')])) then 'common-smil'
                                    else $fileset/*[1]/@href,
                                    '.smil')"/>
                <smil xmlns="http://www.w3.org/ns/SMIL" xmlns:epub="http://www.idpf.org/2007/ops"
                    version="3.0"
                    xml:base="{resolve-uri($one-big-smil-filename, $fileset/base-uri())}">

                    <xsl:for-each select="$fileset">
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:copy-of select="*[@href=$one-big-smil-hrefs]"/>
                        </xsl:copy>
                    </xsl:for-each>

                    <xsl:call-template name="construct-smil">
                        <xsl:with-param name="href" select="$one-big-smil-filename" tunnel="yes"/>
                        <xsl:with-param name="one-big-smil-hrefs" select="$one-big-smil-hrefs"
                            tunnel="yes"/>
                        <xsl:with-param name="smil" select="$smil/*" tunnel="yes"/>
                    </xsl:call-template>
                </smil>
            </xsl:if>

        </smil>
    </xsl:template>

    <xsl:template match="@* | node()" mode="relative-to-fileset-base">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="relative-to-fileset-base"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="smil" mode="relative-to-fileset-base">
        <xsl:param name="subdir" tunnel="yes"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:base" select="$fileset/base-uri()"/>
            <xsl:apply-templates select="node()" mode="relative-to-fileset-base"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text" mode="relative-to-fileset-base">
        <xsl:param name="subdir" tunnel="yes"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="src" select="concat($subdir,@src)"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="construct-smil">
        <xsl:param name="smil" tunnel="yes" as="element()"/>
        <xsl:for-each select="$smil/body">
            <xsl:copy>
                <xsl:apply-templates select="@* | node()" mode="construct-smil"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="par" mode="construct-smil">
        <xsl:param name="href" tunnel="yes"/>
        <xsl:param name="one-big-smil-hrefs" tunnel="yes"/>
        <xsl:variable name="text-href" select="text/substring-before(@src,'#')"/>
        <xsl:if
            test="$text-href = $href and not($text-href = $one-big-smil-hrefs) or $text-href = $one-big-smil-hrefs and ends-with($href,'.smil')">
            <xsl:copy>
                <xsl:apply-templates select="@* | node()" mode="construct-smil"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text" mode="construct-smil">
        <xsl:param name="href" tunnel="yes"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="src"
                select="if (ends-with($href,'.smil')) then @src else replace(@src,'.*/','')"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@* | node()" mode="construct-smil">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="construct-smil"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
