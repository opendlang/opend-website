// just docs: Interfacing to Objective-C
/++





            D supports interfacing with Objective-C. It supports protocols, classes,
        subclasses, instance variables, instance methods and class methods.
        Platform support might vary between different compilers.
    

            Fully working example is available at
        $(LINK2 #usage-example, the bottom).
    

    $(H3 $(ID classes) Classes)
$(ID classes) Classes

    $(H4 $(ID external-class) Declaring an External Class)
$(ID external-class) Declaring an External Class

---
import core.attribute : selector;

extern (Objective-C)
extern class NSString
{
    const(char)* UTF8String() @selector("UTF8String");
}

---

            All Objective-C classes that should be accessible from within D need to
        be declared with the $(LINK2 #objc-linkage, Objective-C linkage). If the
        class is declared as `extern` (in addition to `extern (Objective-C)`) it
        is expected to be defined externally.
    

            The $(LINK2 #selector-attribute, `@selector`) attribute indicates which
        Objective-C selector should be used when calling this method.
        This attribute needs to be attached to all methods with the
        `Objective-C` linkage.
    

    $(H4 $(ID external-class) Binding to a @property (Accessor Methods))
$(ID external-class) Binding to a @property (Accessor Methods)

---
import core.attribute : selector;

extern (Objective-C)
extern class MTLRenderPipelineDescriptor : NSObject
{
    NSString label() @selector("label");
    NSString label(NSString) @selector("setLabel:");
}

---

            Whenever needing to bind to Objective-C classes `@property`, one must be aware
        that it generates both a getter and setter. The method to get its value (getter)
        is the same name as the property's name. The method to set its value (setter)
        starts with the word "set" and then uses the capitalized property name.
        The setter for the property `label` is `setLabel:`.
    

    $(H4 $(ID defining-class) Defining a Class)
$(ID defining-class) Defining a Class

---
import core.attribute : selector;

// externally defined
extern (Objective-C)
extern class NSObject
{
    static NSObject alloc() @selector("alloc");
    NSObject init() @selector("init");
}

extern (Objective-C)
class Foo : NSObject
{
    override static Foo alloc() @selector("alloc");
    override Foo init() @selector("init");

    final int bar(int a) @selector("bar:")
    {
        return a;
    }
}

void main()
{
    assert(Foo.alloc.init.bar(3) == 3);
}

---

            Defining an Objective-C class is exactly the same as declaring an
        external class but it should not be declared as `extern`.
    

            To match the Objective-C semantics, `static` and `final` methods are
        virtual. `static` methods are overridable as well.
    

    $(H3 $(ID protocols) Protocols)
$(ID protocols) Protocols

    $(H4 $(ID declaring-protocol) Declaring a Protocol)
$(ID declaring-protocol) Declaring a Protocol

---
import core.attribute : selector;
import core.stdc.stdio : printf;

extern (Objective-C)
interface Foo
{
    static void foo() @selector("foo");
    void bar() @selector("bar");
}

extern (Objective-C)
class Bar : Foo
{
    static void foo() @selector("foo")
    {
        printf("foo\n");
    }

    void bar() @selector("bar")
    {
        printf("bar\n");
    }
}

---

            Objective-C protocols are represented as interfaces in D and are
        declared using the `interface` keyword.
    

            All Objective-C protocols that should be accessible from within D need
        to be declared with the $(LINK2 #objc-linkage, Objective-C linkage).
    

            Objective-C protocols support virtual class (static) methods. These
        methods must be implemented by the class that implements the protocol
        (unless they are $(LINK2 #optional-methods, optional)). To match these
        semantics, `static` methods are virtual. That also means that static
        methods with Objective-C linkage, inside an interface cannot have a body.
    

    $(H4 $(ID optional-methods) Optional Methods)
$(ID optional-methods) Optional Methods

---
import core.attribute : optional, selector;
import core.stdc.stdio : printf;

struct objc_selector;
alias SEL = objc_selector*;

extern (C) SEL sel_registerName(in char* str);

extern (Objective-C)
extern class NSObject
{
    static NSObject alloc() @selector("alloc");
    NSObject init() @selector("init");
}

extern (Objective-C)
interface Foo
{
    bool respondsToSelector(SEL sel) @selector("respondsToSelector:");
    void foo() @selector("foo");

    // this is an optional method
    @optional void bar() @selector("bar");
}

extern (Objective-C)
class Bar : NSObject, Foo
{
    override static Bar alloc() @selector("alloc");
    override Bar init() @selector("init");

    bool respondsToSelector(SEL sel) @selector("respondsToSelector:");

    void foo() @selector("foo")
    {
        printf("foo\n");
    }
}

void main()
{
    Foo f = Bar.alloc.init;

    // check, at runtime, if the instance `f` implements the method `bar`
    if (f.respondsToSelector(sel_registerName("bar")))
        f.bar();
    else
        f.foo();
}

---
            Objective-C protocols support optional methods. Optional methods are
        <strong>not</strong> required to be implemented by the class that implements the
        protocol. To safely call an optional method, a runtime check should be
        performed to make sure the receiver implements the method.
    

            In D, optional methods are represented using the
        $(LINK2 #optional-attribute, `@optional`) attribute.
    

    $(H3 $(ID instance-variables) Instance Variables)
$(ID instance-variables) Instance Variables

---
import core.attribute : selector;

// externally defined
extern (Objective-C)
extern class NSObject
{
    static NSObject alloc() @selector("alloc");
    NSObject init() @selector("init");
}

extern (Objective-C)
class Foo : NSObject
{
    int bar_;

    override static Foo alloc() @selector("alloc");
    override Foo init() @selector("init");

    int bar() @selector("bar")
    {
        return bar_;
    }
}

void main()
{
    auto foo = Foo.alloc.init;
    foo.bar_ = 3;
    assert(foo.bar == 3);
}

---

            Declaring an instance variable looks exactly the same as for a regular
        D class.
    

            To solve the fragile base class problem, instance variables in
        Objective-C has a dynamic offset. That means that the base class can
        change (add or remove instance variables) without the subclasses needing
        to recompile or relink. Thanks to this feature it's not necessary to
        declare instance variables when creating bindings to Objective-C classes.
    

    $(H3 $(ID instance-method) Calling an Instance Method)
$(ID instance-method) Calling an Instance Method

            Calling an Objective-C instance method uses the same syntax as calling
        regular D methods:
    

---
const(char)* result = object.UTF8String();

---

            When the compiler sees a call to a method with Objective-C linkage it
        will generate a call similar to how an Objective-C compiler would call
        the method.
    

    $(H3 $(ID selector-attribute) The `@selector` Attribute)
$(ID selector-attribute) The `@selector` Attribute

            The `@selector` attribute is a compiler recognized
        $(LINK2 attribute.html#uda, UDA). It is used to tell the compiler which
        selector to use when calling an Objective-C method.
    

            Selectors in Objective-C can contain the colon character, which is not valid in D
        identifiers. D supports method overloading while Objective-C
        achieves something similar by using different selectors. For these two
        reasons it is better to be able to specify the selectors manually in D,
        instead of trying to infer it. This allows to have a more natural names
        for the methods in D. Example:
    

---
import core.attribute : selector;

extern (Objective-C)
extern class NSString
{
    NSString initWith(in char*) @selector("initWithUTF8String:");
    NSString initWith(NSString) @selector("initWithString:");
}

---

            Here the method `initWith` is overloaded with two versions, one
        accepting `in char*`, the other one `NSString`. These two methods are
        mapped to two different Objective-C selectors, `initWithUTF8String:`
        and `initWithString:`.
    

            The attribute is defined in druntime in
        [phobos/core_attribute.html, `core.attribute`]. The attribute
        is only defined when the version identifier
        $(LINK2 #objc-version-identifier, `D_ObjectiveC`) is enabled.
    

    $(H4 $(ID compiler-checks) Compiler Checks)
$(ID compiler-checks) Compiler Checks

            The compiler performs the following checks to enforce the correct usage
        of the `@selector` attribute:
    

    $(LIST
        *             The attribute can only be attached to methods with Objective-C
            linkage
        

        * The attribute can only be attached once to a method
        * The attribute cannot be attached to a template method

        *             The number of colons in the selector needs to match the number of
            parameters the method is declared with
        
    
)

    If any of the checks fail, a compile error will occur.

    $(H3 $(ID optional-attribute) The `@optional` Attribute)
$(ID optional-attribute) The `@optional` Attribute

            The `@optional` attribute is a compiler recognized
        $(LINK2 attribute.html#uda, UDA). It is used to tell the compiler that a
        method, with Objective-C linkage, declared inside an interface is
        optional. That means that the class that implements the interface does
        <strong>not</strong> have to implement the method.
    

            To safely call an optional method, a runtime check should be performed
        to make sure the receiver implements the method.
    

            The attribute is defined in druntime in
        [phobos/core_attribute.html, `core.attribute`]. The attribute
        is only defined when the version identifier
        $(LINK2 #objc-version-identifier, `D_ObjectiveC`) is enabled.
    

    $(H4 $(ID compiler-checks) Compiler Checks)
$(ID compiler-checks) Compiler Checks

            The compiler performs the following checks to enforce the correct usage
        of the `@optional` attribute:
    

$(LIST
* The attribute can only be attached to methods with Objective-C linkage
* The attribute can only be attached to a method inside an interface
* The attribute can only be attached once to a method
* The attribute cannot be attached to a template method


)
    If any of the checks fail, a compile error will occur.

    $(H3         $(ID objc-version-identifier) The `D_ObjectiveC` Version Identifier
    )
       $(ID objc-version-identifier) The `D_ObjectiveC` Version Identifier
    

            The `D_ObjectiveC` version identifier is a predefined version
        identifier. It is enabled if Objective-C support is available for the
        target.
    

    $(H3 $(ID objc-linkage) Objective-C Linkage)
$(ID objc-linkage) Objective-C Linkage

            Objective-C linkage is achieved by attaching the `extern (Objective-C)`
        attribute to a class. Example:
    

---
import core.attribute : selector;

extern (Objective-C)
extern class NSObject
{
    NSObject init() @selector("init");
}

---

            All methods inside a class declared as `extern (Objective-C)` will
        get implicit Objective-C linkage.
    

            The linkage is recognized on all platforms but will issue a compile
        error if it is used on a platform where Objective-C support is not
        available. This allows to easily hide Objective-C declarations from
        platforms where it is not available using the
        $(LINK2 version.html#version, `version`) statement, without resorting to
        string mixins or other workarounds.
    

    $(H3 $(ID memory-management) Memory Management)
$(ID memory-management) Memory Management

            The preferred way to do memory management in Objective-C is to use
        Automatic Reference Counting, $(LINK2 https://developer.apple.com/library/mac/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html, ARC).
        This is not supported in D, therefore manual memory management is
        required to be used instead. This is achieved by calling $(LINK2 https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSObject_Protocol/index.html#//apple_ref/occ/intfm/NSObject/release, `release`)
        on an Objective-C instance, like in the old days of Objective-C.
    

    $(H3 $(ID frameworks) Frameworks)
$(ID frameworks) Frameworks

            Most Objective-C code is bundled in something called a "Framework".
        This is basically a regular directory, with the `.framework` extension
        and a specific directory layout. A framework contains a dynamic
        library, all public header files and any resources (images, sounds and
        so on) required by the framework.
    

            These directories are recognized by some tools, like the Objective-C
        compiler and linker, to be frameworks. To link with a framework from
        DMD, use the following flags:
    

---
-L-framework -L&lt;Framework&gt;

---

        where `&lt;Framework&gt;` is the name of the framework to link with, without
        the `.framework` extension. The two `-L` flags are required because the
        linker expects a space between the `-framework` flag and the name of
        the framework. DMD cannot handle this and will instead interpret the
        name of the framework as a separate flag.

    $(H4 $(ID framework-paths) Framework Paths)
$(ID framework-paths) Framework Paths

            Using the above flag, the linker will search in the standard framework
        paths. The standard search paths for frameworks are:
    

    $(LIST
        * `/System/Library/Frameworks`
        * `/Library/Frameworks`
    
)

            The following flag from DMD can be used to add a new path in which to
        search for frameworks:
    

---
-L-F&lt;framework_path&gt;

---

            For more information see the $(LINK2 https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPFrameworks/Tasks/IncludingFrameworks.html, reference documentation)
        and the `ld` man page.
    

    $(H3 $(ID usage-example) Full Usage Example)
$(ID usage-example) Full Usage Example

            This example will create an Objective-C string, `NSString`, and log the
        message using `NSLog` to stderr.
    

---
import core.attribute : selector;

extern (Objective-C)
extern class NSString
{
    static NSString alloc() @selector("alloc");
    NSString initWithUTF8String(in char* str) @selector("initWithUTF8String:");
    void release() @selector("release");
}

---

            This is a simplified declaration of the $(LINK2 https://developer.apple.com/documentation/foundation/nsstring?language=objc, `NSString`)
        class. The $(LINK2 https://developer.apple.com/documentation/objectivec/nsobject/1571958-alloc?language=objc, `alloc`)
        method allocates an instance of the class. The $(LINK2 https://developer.apple.com/documentation/foundation/nsstring/1412128-initwithutf8string?language=objc, `initWithUTF8String:`)
        method will be used to convert a C string in UTF-8 to an Objective-C
        string, `NSString`. The $(LINK2 https://developer.apple.com/documentation/objectivec/1418956-nsobject/1571957-release?language=objc, `release`)
        method is used to release an deallocate the string. Since D doesn't
        support $(LINK2 https://developer.apple.com/library/mac/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html, ARC)
        it's needed to manually release Objective-C instances.
    

---
extern (C) void NSLog(NSString, ...);

---

            This $(LINK2 https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Functions/index.html#//apple_ref/c/func/NSLog, `NSLog`)
        function prints a message to the System Log facility, i.e. to stderr
        and Console.
    

---
auto str = NSString.alloc();

---

    Allocate an instance of the class, `NSString`.

---
str = str.initWithUTF8String("Hello World!")

---

    Initialize the Objective-C string using a C string.

---
NSLog(str);

---

            Log the string to stderr, this will print something like this in the
        terminal:
    

---
2015-07-18 13:14:27.978 main[11045:2934950] Hello World!

---

---
str.release();

---

    Release and deallocate the string.

    All steps combined look like this:

---
module main;

import core.attribute : selector;

extern (Objective-C)
extern class NSString
{
    static NSString alloc() @selector("alloc");
    NSString initWithUTF8String(in char* str) @selector("initWithUTF8String:");
    void release() @selector("release");
}

extern (C) void NSLog(NSString, ...);

void main()
{
    auto str = NSString.alloc().initWithUTF8String("Hello World!");
    NSLog(str);
    str.release();
}

---

            When compiling the application remember to link with the required
        libraries, in this case the Foundation framework. Example:
    

---
dmd -L-framework -LFoundation main.d

---
cpp_interface, Interfacing to C++, portability, Portability Guide




Link_References:
	ACC = Associated C Compiler
+/
module objc_interface.dd;