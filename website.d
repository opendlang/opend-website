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
	"/".serveTemplateDirectory(null, null, "", "html/"),
	"/".serveStaticFileDirectory("assets/"),
);

class MyPresenter : WebPresenterWithTemplateSupport!MyPresenter {}
