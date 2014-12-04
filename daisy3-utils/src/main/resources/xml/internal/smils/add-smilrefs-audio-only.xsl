<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:d="http://www.daisy.org/ns/pipeline/data"
		xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
		exclude-result-prefixes="#all" version="2.0">

  <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>

  <xsl:param name="no-smilref"/>
  <xsl:param name="mo-dir"/>
  <xsl:param name="output-dir"/>

  <xsl:variable name="mo-dir-rel" select="pf:relativize-uri($mo-dir, $output-dir)"/>

  <!-- pagenums and noterefs are also linked by the NCX but they can't
       be SMIL seq (they have no children), so there is no need to
       make a special case of them.-->
  <xsl:variable name="ncx-linked" select="' levelhd hd h1 h2 h3 h4 h5 h6 note '"/>

  <xsl:key name="clips" match="*[@idref]" use="@idref"/>


  <!-- TODO: make sure noterefs and their corresponding notes are
       close to each other in the same SMIL file. -->

  <xsl:template match="/*">
    <xsl:copy>
      <xsl:for-each-group group-by="(position() - 1) idiv 200"
			  select="//*[@id and key('clips', @id, collection()[/d:audio-clips])]">
	<xsl:variable name="smilfile" select="concat($mo-dir-rel, 'mo', position(), '.smil')"/>
	<xsl:for-each select="current-group()">

	  <xsl:variable name="ncx-parent"
			select="ancestor-or-self::*[contains($ncx-linked, concat(' ', local-name(), ' '))]"/>
	  <xsl:choose>
	    <xsl:when test="not($ncx-parent)">
	      <xsl:copy>
		<xsl:copy-of select="@* except @smilref"/>
		<xsl:attribute name="smilref">
		  <xsl:value-of select="concat($smilfile, '#s', current()/@id)"/>
		</xsl:attribute>
	      </xsl:copy>
	    </xsl:when>
	    <xsl:otherwise>
	      <!-- hd, h1, h2 etc. must have a @smilref as the NCX
	           must refer to them and they can't arbitrarily refer
	           to one of the header's children because headers can
	           be composed of multiple sentence children. -->
	      <!-- Warning: this script won't work well with pagenums
	           inside headers! -->
	      <xsl:variable name="children"
			    select="$ncx-parent/descendant-or-self::*[@id and key('clips', @id, collection()[/d:audio-clips])]"/>
	      <xsl:if test="not($children) or $children[1] is current()">
		<xsl:element name="{local-name($ncx-parent)}" namespace="{namespace-uri($ncx-parent)}">
		  <xsl:copy-of select="$ncx-parent/@* except $ncx-parent/@smilref"/>
		  <xsl:attribute name="smilref">
		    <xsl:value-of select="concat($smilfile, '#s', $ncx-parent/@id)"/>
		  </xsl:attribute>
		  <xsl:for-each select="$children">
		    <xsl:copy>
		      <xsl:copy-of select="@* except @smilref"/>
		      <xsl:attribute name="smilref">
			<xsl:value-of select="concat($smilfile, '#s', current()/@id)"/>
		      </xsl:attribute>
		  </xsl:copy>
		  </xsl:for-each>
		</xsl:element>
	      </xsl:if>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
