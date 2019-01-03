import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.mavenBundle;

import org.ops4j.pax.exam.Configuration;
import static org.ops4j.pax.exam.CoreOptions.composite;
import static org.ops4j.pax.exam.CoreOptions.options;
import org.ops4j.pax.exam.Option;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	protected String[] testDependencies() {
		return new String[] {
			"org.daisy.pipeline:calabash-adapter:?",
			"org.idpf:epubcheck:?"
		};
	}
	
	@Override @Configuration
	public Option[] config() {
		return options(
			// FIXME: epubcheck needs older version of guava
			mavenBundle("com.google.guava:guava:14.0.1"),
			// FIXME: epubcheck needs older version of jing
			mavenBundle("org.daisy.libs:jing:20120724.0.0"),
			// FIXME: epubcheck needs older version of saxon
			mavenBundle("org.daisy.libs:saxon-he:9.5.1.5"),
			composite(super.config()));
	}
}