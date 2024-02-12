import arsd.cgi;
import arsd.webtemplate;

shared static this() {
	import std.file;
	import std.path;
	chdir(thisExePath.dirName);
}

mixin DispatcherMain!(
	MyPresenter,
	"/".serveRedirect("index.html"),
	"/library/".serveStaticFileDirectory("../docgen/generated-docs/"),
	"/".serveTemplateDirectory!wtrFactory(null, null, "", "html/"),
	"/".serveStaticFileDirectory("assets/"),
);

WebTemplateRenderer wtrFactory(TemplateLoader loader) {
	return new WebTemplateRenderer(loader, [
		"plaintext": function(string content, string[string] attributes) {
			import arsd.dom;
			return WebTemplateRenderer.EmbeddedTagResult(new TextNode(content));
		},
		"markdown": function(string content, string[string] attributes) {
			import commonmarkd;
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
