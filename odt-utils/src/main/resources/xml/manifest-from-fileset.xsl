<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:d="http://www.daisy.org/ns/pipeline/data"
        xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
        xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">
    
    <xsl:variable name="base" select="//d:file[starts-with(@media-type,'application/vnd.oasis.opendocument')]
                                      /resolve-uri(@href, base-uri(.))"/>
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/file-utils/xslt/uri-functions.xsl"/>
    
    <xsl:template match="d:fileset">
        <xsl:element name="manifest:manifest">
            <xsl:attribute name="manifest:version" select="'1.2'"/>
            <xsl:attribute name="xml:base" select="resolve-uri('META-INF/manifest.xml', $base)"/>
            <xsl:apply-templates select="d:file"/>
            <xsl:if test="d:file[starts-with(pf:relativize-uri(resolve-uri(@href, base-uri(.)), $base), 'Configuration2/')]">
                <xsl:element name="manifest:file-entry">
                    <xsl:attribute name="manifest:full-path" select="'Configurations2/'"/>
                    <xsl:attribute name="manifest:media-type" select="'application/vnd.sun.xml.ui.configuration'"/>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="d:file[resolve-uri(@href,base-uri(.))=$base]">
        <xsl:element name="manifest:file-entry">
            <xsl:attribute name="manifest:full-path" select="'/'"/>
            <xsl:attribute name="manifest:version" select="'1.2'"/>
            <xsl:attribute name="manifest:media-type" select="@media-type"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="d:file">
        <xsl:variable name="relative-uri" select="pf:relativize-uri(resolve-uri(@href,base-uri(.)), $base)"/>
        <xsl:if test="not(pf:is-absolute($relative-uri))">
            <xsl:element name="manifest:file-entry">
                <xsl:attribute name="manifest:full-path" select="$relative-uri"/>
                <xsl:attribute name="manifest:media-type" select="@media-type"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
