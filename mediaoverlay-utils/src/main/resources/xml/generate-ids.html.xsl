<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all" version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="iteration-position" required="yes"/>

    <xsl:template match="@*|node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="body">
        <xsl:apply-templates select="." mode="add-id"/>
    </xsl:template>

    <xsl:template match="*" mode="add-id" priority="10">
        <xsl:param name="id"/>
        <xsl:variable name="id"
            select=" 
            if (self::body) then concat('doc',$iteration-position)
            else concat($id, '_', local-name(), count(preceding-sibling::*) + 1 )"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(@id)">
                <xsl:attribute name="id" select="$id"/>
            </xsl:if>
            <xsl:apply-templates mode="add-id">
                <xsl:with-param name="id" select="$id"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
