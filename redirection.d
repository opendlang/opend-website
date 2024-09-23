import arsd.cgi;

void handler(Cgi cgi) {
	cgi.setResponseLocation("https://opendlang.org" ~ cgi.pathInfo);
}

mixin GenericMain!handler;
