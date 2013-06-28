<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:smil="http://www.w3.org/ns/SMIL" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    
    <xsl:variable name="table-ids" select="/*/html:*//html:table/@id"/>
    <xsl:variable name="table-row-ids" select="/*/html:*//html:tr/@id"/>
    <xsl:variable name="table-cell-ids" select="/*/html:*//html:th/@id | /*/html:*//html:td/@id"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="smil:*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Note: in this stylesheet, it is assumed that all the text elements refer to the same content document; the one provided as /*/*[last()] -->
    
    <xsl:template match="smil:seq[tokenize(smil:text/@src,'#')[last()]=$table-ids]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="epub:type" select="'table'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="smil:par[tokenize(smil:text/@src,'#')[last()]=$table-ids]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="epub:type" select="'table'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="smil:seq[tokenize(smil:text/@src,'#')[last()]=$table-row-ids]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="epub:type" select="'table-row'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="smil:par[tokenize(smil:text/@src,'#')[last()]=$table-row-ids]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="epub:type" select="'table-row'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="smil:seq[tokenize(smil:text/@src,'#')[last()]=$table-cell-ids]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="epub:type" select="'table-cell'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="smil:par[tokenize(smil:text/@src,'#')[last()]=$table-cell-ids]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="epub:type" select="'table-cell'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
