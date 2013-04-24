<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:c="http://www.w3.org/ns/xproc-step"
        xmlns:d="http://www.daisy.org/ns/pipeline/data">
    
    <!-- Directory where the zip should ultimately be extracted -->
    <xsl:param name="target" select="''"/>
    
    <xsl:variable name="original-base" select="concat(/c:zipfile/@href, '!/')"/>
    
    <xsl:template match="c:zipfile">
        <xsl:element name="d:fileset">
            <xsl:attribute name="xml:base" select="if ($target!='') then $target else $original-base"/>
            <xsl:apply-templates select="c:file"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="c:file">
        <xsl:element name="d:file">
            <xsl:attribute name="href" select="@name"/>
            <xsl:if test="$target!=''">
                <xsl:attribute name="original-href" select="resolve-uri(@name, $original-base)"/>
            </xsl:if>
            <xsl:attribute name="media-type" select="'binary/octet-stream'"/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
