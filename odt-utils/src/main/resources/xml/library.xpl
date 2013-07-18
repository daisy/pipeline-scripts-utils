<?xml version="1.0" encoding="UTF-8"?>
<p:library version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:odt="urn:oasis:names:tc:opendocument:xmlns:text:1.0">
  
  <p:import href="store.xpl"/>
  <p:import href="load.xpl"/>
  <p:import href="get-file.xpl"/>
  <p:import href="update-files.xpl"/>
  <p:import href="embed-images.xpl"/>
  <p:import href="separate-mathml.xpl"/>
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Exports the OpenDocument Text file represented by <code>href</code> to a
    file specified by <code>target</code>.
    The <code>href</code> and <code>target</code> options must be "file:" scheme URIs.
    Returns a <code>&lt;c:result></code> containing the absolute URI of the target.
    A headless instance of LibreOffice must be running (launch it with <kbd>soffice
    --headless --accept="socket,host=127.0.0.1,port=8100;urp;" --nofirststartwizard</kbd>).</p>
  </p:documentation>
  
  <p:declare-step type="odt:save-as">
    <p:output port="result" primary="false"/>
    <p:option name="href" required="true"/>
    <p:option name="target" required="true"/>
  </p:declare-step>
  
</p:library>
