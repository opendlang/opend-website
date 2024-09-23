import arsd.cgi;
import arsd.webtemplate;
import arsd.archive;

shared static this() {
	import std.file;
	import std.path;
	chdir(thisExePath.dirName);
}

bool libraryHandler(DD)(DD dd) {
	auto path = dd.cgi.pathInfo[dd.pathInfoStart + 1 .. $]; // slice off the starting /

	if(path == "style.css") {
		import std.file;
		auto ls = readText("library-style.css");

		dd.cgi.setResponseExpiresRelative(60 * 5, true);
		dd.cgi.setResponseContentType("text/css");
		dd.cgi.gzipResponse = true;
		dd.cgi.write(ls[], true);
		return true;
	}

	try {
		auto arcz = new ArzArchive();
		arcz.openArchive("generated.arcz");
		auto fl = arcz.open(path);
		auto buf = new char[](fl.size);
		fl.rawRead(buf[]);
		dd.cgi.setResponseExpiresRelative(60 * 5, true);
		dd.cgi.gzipResponse = true;
		dd.cgi.write(buf[], true);
		return true;
	} catch(Exception e) {
		return false;
	}
}

bool languageHandler(DD)(DD dd) {
	auto path = dd.cgi.pathInfo[dd.pathInfoStart + 1 .. $]; // slice off the starting /

	if(path == "style.css") {
		import std.file;
		auto ls = readText("library-style.css");

		dd.cgi.setResponseExpiresRelative(60 * 5, true);
		dd.cgi.setResponseContentType("text/css");
		dd.cgi.gzipResponse = true;
		dd.cgi.write(ls[], true);
		return true;
	}

	try {
		auto arcz = new ArzArchive();
		arcz.openArchive("generated-language.arcz");
		auto fl = arcz.open(path);
		auto buf = new char[](fl.size);
		fl.rawRead(buf[]);
		dd.cgi.setResponseExpiresRelative(60 * 5, true);
		dd.cgi.gzipResponse = true;
		dd.cgi.write(buf[], true);
		return true;
	} catch(Exception e) {
		return false;
	}
}


mixin DispatcherMain!(
	MyPresenter,
	"/".serveRedirect("index.html"),
	"/library".dispatchTo!libraryHandler,
	"/language".dispatchTo!languageHandler,
	"/".serveTemplateDirectory!wtrFactory(extension: "", templateDirectory: "html/"),
	"/".serveStaticFileDirectory("assets/"),
);

WebTemplateRenderer wtrFactory(TemplateLoader loader) {
	import arsd.dom;
	return new WebTemplateRenderer(loader, [
		"plaintext": function(string content, AttributesHolder attributes) {
			import arsd.dom;
			return WebTemplateRenderer.EmbeddedTagResult(new TextNode(content));
		},
		"markdown": function(string content, AttributesHolder attributes) {
			import arsd.markdown;
			import arsd.dom;
			return WebTemplateRenderer.EmbeddedTagResult(
				new Document("<div>" ~ convertMarkdownToHTML(content) ~ "</div>").root
			);
		}
	]);
}

class MyPresenter : WebPresenterWithTemplateSupport!MyPresenter {
	override WebTemplateRenderer webTemplateRenderer() {
		return wtrFactory(templateLoader());
	}
}
