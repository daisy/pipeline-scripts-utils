package org.daisy.pipeline.odt.calabash;

import java.io.File;
import java.net.URI;

import com.xmlcalabash.core.XProcConstants;
import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;

import org.artofsolving.jodconverter.document.DocumentFormat;
import org.artofsolving.jodconverter.office.ExternalOfficeManagerConfiguration;
import org.artofsolving.jodconverter.office.OfficeManager;
import org.artofsolving.jodconverter.OfficeDocumentConverter;
import org.artofsolving.jodconverter.StandardConversionTask;

import org.daisy.common.xproc.calabash.XProcStepProvider;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SaveAsProvider implements XProcStepProvider {
	
	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new SaveAs(runtime, step);
	}
	
	private static class SaveAs extends DefaultStep {
		
		private static final Logger logger = LoggerFactory.getLogger(SaveAs.class);
		
		private static final int OFFICE_PORT = 8100;
		
		private static final QName _href = new QName("href");
		private static final QName _target = new QName("target");
		
		private static OfficeManager officeManager = null;
		
		private WritablePipe result;
		
		private SaveAs(XProcRuntime runtime, XAtomicStep step) {
			super(runtime, step);
		}
		
		@Override
		public void setOutput(String port, WritablePipe pipe) {
			result = pipe;
		}
		
		@Override
		public void reset() {
			result.resetWriter();
		}
	
		@Override
		public void run() throws SaxonApiException {
			super.run();
			try {
				File href = asFile(getOption(_href), "href");
				File target = asFile(getOption(_target), "target");
				if (officeManager == null) {
					try {
						ExternalOfficeManagerConfiguration config = new ExternalOfficeManagerConfiguration();
						config.setPortNumber(OFFICE_PORT);
						officeManager = config.buildOfficeManager();
						officeManager.start(); }
					catch (Exception e) {
						throw new RuntimeException("Could not connect to OpenOffice/LibreOffice server. "
							+ "Launch it with `soffice --headless --accept=\"socket,host=127.0.0.1,port=" + OFFICE_PORT
							+ ";urp;\" --nofirststartwizard`"); }}
				OfficeDocumentConverter converter = new OfficeDocumentConverter(officeManager);
				converter.convert(href, target);
				TreeWriter treeWriter = new TreeWriter(runtime);
				treeWriter.startDocument(step.getNode().getBaseURI());
				treeWriter.addStartElement(XProcConstants.c_result);
				treeWriter.startContent();
				treeWriter.addText(target.toURI().toASCIIString());
				treeWriter.addEndElement();
				treeWriter.endDocument();
				result.write(treeWriter.getResult()); }
			catch (Exception e) {
				logger.error("odt:save-as failed", e);
				throw new XProcException(step.getNode(), e); }
		}
	}
	
	private static File asFile(RuntimeValue value, String optionName) {
		URI uri = value.getBaseURI().resolve(value.getString());
		try { return new File(uri); }
		catch (Exception e) {}
		throw new RuntimeException("Option " + optionName + " must be a \"file:\" scheme URI. Got " + uri);
	}
}
