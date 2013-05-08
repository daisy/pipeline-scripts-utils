<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:d="http://www.daisy.org/ns/pipeline/data"
        xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">
    
    <xsl:param name="base"/>
    <xsl:param name="original-base" select="''"/>
    
    <xsl:template match="manifest:manifest">
        <xsl:element name="d:fileset">
            <xsl:attribute name="xml:base" select="$base"/>
            <xsl:apply-templates select="manifest:file-entry"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="manifest:file-entry">
        <xsl:element name="d:file">
            <xsl:attribute name="href" select="@manifest:full-path"/>
            <xsl:if test="$original-base!=''">
                <xsl:attribute name="original-href" select="resolve-uri(@manifest:full-path, $original-base)"/>
            </xsl:if>
            <xsl:attribute name="media-type" select="@manifest:media-type"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="manifest:file-entry[@manifest:full-path='/' and starts-with(@manifest:media-type, 'application/vnd.oasis.opendocument')]">
        <xsl:element name="d:file">
            <xsl:attribute name="href" select="'.'"/>
            <xsl:attribute name="media-type" select="@manifest:media-type"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="manifest:file-entry[ends-with(@manifest:full-path,'/') and not(@manifest:full-path='/')]"/>
    
</xsl:stylesheet>
