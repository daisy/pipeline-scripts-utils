<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0"
    xmlns:html="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:smil="http://www.w3.org/ns/SMIL" xmlns="http://www.w3.org/ns/SMIL"
    xmlns:epub="http://www.idpf.org/2007/ops">

    <!-- create text-only SMIL -->

    <xsl:template match="/*">
        <xsl:variable name="filename" select="replace(base-uri(),'.*/','')"/>
        <smil xmlns="http://www.w3.org/ns/SMIL" version="3.0"
            xml:base="{replace(base-uri(),'\.[^/\.]+$','')}.smil">
            <xsl:namespace name="epub" select="'http://www.idpf.org/2007/ops'"/>
            <body>
                <xsl:variable name="first-pass">
                    <xsl:apply-templates select="html:body">
                        <xsl:with-param name="filename" select="$filename" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:for-each select="$first-pass/*">
                    <xsl:copy>
                        <xsl:copy-of select="@* except @was"/>
                        <xsl:variable name="second-pass">
                            <xsl:for-each select="*">
                                <xsl:call-template name="second-pass"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:copy-of select="$second-pass/*[string(@id)!='']"/>
                    </xsl:copy>
                </xsl:for-each>
            </body>
        </smil>
    </xsl:template>

    <xsl:template match="*">
        <xsl:param name="filename" tunnel="yes" required="yes"/>
        <xsl:choose>
            <xsl:when test="text()">
                <par id="{@id}" was="{local-name()}">
                    <xsl:call-template name="types"/>
                    <text src="{$filename}#{@id}"/>
                    <xsl:apply-templates select="*"/>
                </par>
            </xsl:when>
            <xsl:when test="self::html:img and string(@alt)=''"/>
            <xsl:otherwise>
                <seq id="{@id}" epub:textref="{$filename}#{@id}" was="{local-name()}">
                    <xsl:call-template name="types"/>
                    <xsl:apply-templates select="*"/>
                </seq>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="types">
        <xsl:variable name="types"
            select="distinct-values((tokenize(@epub:type,'\s+'), (
            if (self::html:table) then 'table'
                                       else if (self::html:tr) then 'table-row'
                                       else if (self::html:th or self::html:td) then 'table-cell'
                                       else if (self::html:ol or self::html:ul) then 'list'
                                       else if (self::html:li) then 'list-item'
                                       else if (self::html:figure) then 'figure'
                                       else ()
                                    )))"/>
        <xsl:if test="count($types)">
            <xsl:attribute name="epub:type" select="string-join($types,' ')"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="second-pass">
        <xsl:choose>
            <xsl:when test="self::smil:par">
                <xsl:copy>
                    <xsl:copy-of select="@* except @was"/>
                    <xsl:copy-of select="smil:text"/>
                </xsl:copy>
                <xsl:choose>
                    <xsl:when test="string(@id)=''">
                        <xsl:for-each select="* except smil:text">
                            <xsl:call-template name="second-pass"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each
                            select="*[tokenize(@epub:type,'\s+') = 'pagebreak' or @was = 'img']">
                            <xsl:call-template name="second-pass"/>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:when test="self::smil:seq">
                <xsl:variable name="children">
                    <xsl:for-each select="*">
                        <xsl:call-template name="second-pass"/>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when
                        test="tokenize(@epub:type,'\s+') = 'pagebreak' or @was = 'img' or $children/smil:par[@id='']">
                        <par>
                            <xsl:copy-of select="@id | @epub:type"/>
                            <text src="{@epub:textref}"/>
                        </par>
                        <xsl:copy-of select="$children/*[@id!='']"/>
                    </xsl:when>
                    <xsl:when test="self::smil:seq and not(@epub:type)">
                        <xsl:copy-of select="$children"/>
                    </xsl:when>
                    <xsl:when test="self::smil:seq">
                        <xsl:copy>
                            <xsl:copy-of select="@* except @was"/>
                            <xsl:copy-of select="$children"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:copy-of select="@id | @epub:*"/>
                            <xsl:copy-of select="$children"/>
                            <xsl:comment select="concat('deleteme: ',name())"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
