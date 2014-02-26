<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" version="1.0">

    <p:declare-step type="px:epubcheck">
        <!-- anyFileURI to the epub -->
        <p:option name="epub" required="true"/>

        <!-- One of: "epub" (the entire epub), "opf" (the package file), "xhtml" (the content files), "svg" (vector graphics), "mo" (media overlays), "nav" (the navigation document). -->
        <p:option name="mode" required="false"/>

        <!-- The EPUB version to validate against. Default is "3". Values allowed are: "2" and "3". -->
        <p:option name="version" required="false"/>

        <!-- The epubcheck XML report. See Java implementation for more details about the grammar: https://github.com/IDPF/epubcheck/blob/master/src/main/java/com/adobe/epubcheck/util/XmlReportImpl.java#L176 -->
        <p:output port="result" sequence="true"/>
    </p:declare-step>

</p:library>
