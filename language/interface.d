// just docs: Interfaces
/++





$(H2 $(ID declarations) Interface Declarations)

    An $(I Interface) describes a list of functions that a class which inherits
    from the interface must implement.

$(PRE $(CLASS GRAMMAR)
$(B $(ID InterfaceDeclaration) InterfaceDeclaration):
    `interface` $(LINK2 lex#Identifier, Identifier) `;`
    `interface` $(LINK2 lex#Identifier, Identifier) [#BaseInterfaceList|BaseInterfaceList]$(SUBSCRIPT opt) [struct#AggregateBody|struct, AggregateBody]
    [template#InterfaceTemplateDeclaration|template, InterfaceTemplateDeclaration]

$(B $(ID BaseInterfaceList) BaseInterfaceList):
    `:` [class#Interfaces|class, Interfaces]

)

    $(WARNING Specialized interfaces may be supported:

    $(NUMBERED_LIST
    * [#com-interfaces|$(I COM Interfaces)]
    are binary compatible with COM/OLE/ActiveX objects for Windows.
    

    * [#cpp-interfaces|$(I C++ Interfaces)]
    are binary compatible with C++ abstract classes.
    

    * $(LINK2 objc_interface.html#protocols, Objective-C Interfaces)
    are binary compatible with Objective-C protocols.
    
    
)
    )


    A class that implements an interface can be implicitly converted to a reference
    to that interface.

    Interfaces cannot derive from classes; only from other interfaces.
    Classes cannot derive from an interface multiple times.
    

---
interface I
{
    void foo();
}

class A : I, I  // error, duplicate interface
{
}

---

An instance of an interface cannot be created.

---
interface I
{
    void foo();
}

...

I iface = new I();  // error, cannot create instance of interface

---

$(H3 $(ID method-bodies) Interface Method Bodies)

    Virtual interface member functions do not have implementations.
    Interfaces are expected to implement static or final functions.
    

---
interface I
{
    void bar() { }  // error, implementation not allowed
    static void foo() { } // ok
    final void abc() { } // ok
}

---

     Interfaces can have function templates in the members.
         All instantiated functions are implicitly `final`.
     

---
interface I
{
    void foo(T)() { }  // ok, it's implicitly final
}

---

    Classes that inherit from an interface may not override final or
    static interface member functions.

---
interface I
{
    void bar();
    static void foo() { }
    final void abc() { }
}

class C : I
{
    void bar() { } // ok
    void foo() { } // error, cannot override static I.foo()
    void abc() { } // error, cannot override final I.abc()
}

---

$(H3 $(ID implementing-interfaces) Implementing Interfaces)

    All virtual interface functions must be defined in a class that inherits
    from that interface:
    
---
interface I
{
    void foo();
}

class A : I
{
    void foo() { }  // ok, provides implementation
}

class B : I
{
    int foo() { }   // error, no `void foo()` implementation
}

---

Interfaces can be inherited from a base class, and interface functions overridden:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
interface I
{
    int foo();
}

class A : I
{
    int foo() { return 1; }
}

class B : A
{
    override int foo() { return 2; }
}

B b = new B();
assert(b.foo() == 2);

I i = b;    // ok since B inherits A's I implementation
assert(i.foo() == 2);

---

)

$(H4 $(ID reimplementing-interfaces) Reimplementing Interfaces)

    Interfaces can be reimplemented in derived classes:

$(DIV $(CLASS SPEC_RUNNABLE_EXAMPLE_RUN)
---
interface I
{
    int foo();
}

class A : I
{
    int foo() { return 1; }
}

class B : A, I
{
    override int foo() { return 2; }
}

B b = new B();
assert(b.foo() == 2);
I i = b;
assert(i.foo() == 2);

A a = b;
I i2 = a;
assert(i2.foo() == 2); // i2 has A's virtual pointer for foo which points to B.foo

---

)

    A reimplemented interface must implement all the interface
    functions, it does not inherit them from a super class:
    

---
interface I
{
    int foo();
}

class A : I
{
    int foo() { return 1; }
}

class B : A, I
{
}       // error, no foo() for interface I

---

$(H4 $(ID interface-contracts)Interface Method Contracts)

    Interface member functions can have contracts even though there
    is no body for the function. The contracts are inherited by any
    class member function that implements that interface member function.
    

---
interface I
{
    int foo(int i)
    in { assert(i &gt; 7); }
    out (result) { assert(result &amp; 1); }

    void bar();
}

---


$(H4 $(ID const-interface)Const and Immutable Interfaces)
    If an interface has `const` or `immutable` storage
    class, then all members of the interface are
    `const` or `immutable`.
    This storage class is not inherited.
    



$(H3 $(ID com-interfaces)COM Interfaces)

    A variant on interfaces is the COM interface. A COM interface is
    designed to map directly onto a Windows COM object. Any COM object
    can be represented by a COM interface, and any D object with
    a COM interface can be used by external COM clients.
    

    A COM interface is defined as one that derives from the interface
    `core.sys.win``dows.com.IUnknown`. A COM interface differs from
    a regular D interface in that:
    

    $(LIST
    * It derives from the interface `core.sys.windows.com.IUnknown`.
    * It cannot be the argument to [object.destroy|destroy].
    * References cannot be upcast to the enclosing class object, nor
    can they be downcast to a derived interface.
    Implement `QueryInterface()`
    for that interface in standard COM fashion to convert to another COM interface.
    * Classes derived from COM interfaces are COM classes.
    * The default linkage for member functions of COM classes
    is `extern(System)`.

    Note: To implement or override any base-class methods of
    D interfaces or classes (ones which do not inherit from `IUnknown`),
    explicitly mark them as having the `extern(D)` linkage.

---
import core.sys.windows.windows;
import core.sys.windows.com;

interface IText
{
    void write();
}

abstract class Printer : IText
{
    void print() { }
}

class C : Printer, IUnknown
{
    // Implements the IText `write` class method.
    extern(D) void write() { }

    // Overrides the Printer `print` class method.
    extern(D) override void print() { }

    // Overrides the Object base class `toString` method.
    extern(D) override string toString() { return "Class C"; }

    // Methods of class implementing the IUnknown interface have
    // the extern(System) calling convention by default.
    HRESULT QueryInterface(const(IID)*, void**);
    uint AddRef();
    uint Release();
}

---

    The same applies to other `Object` methods such as `opCmp`, `toHash`, etc.

    
    * The first member of the COM `vtbl[]` is not the pointer
    to the InterfaceInfo, but the first virtual function pointer.
    
)

    See also
    $(LINK2 http://www.lunesu.com/uploads/ModernCOMProgramminginD.pdf, Modern COM Programming in D)
    



$(H3 $(ID cpp-interfaces)C++ Interfaces)

    C++ interfaces are interfaces declared with C++ linkage:
    

---
extern (C++) interface Ifoo
{
    void foo();
    void bar();
}

---

which is meant to correspond with the following C++ declaration:

```cpp
class Ifoo
{
    virtual void foo();
    virtual void bar();
};

```

    Any interface that derives from a C++ interface is also
    a C++ interface.
    A C++ interface differs from a D interface in that:
    

    $(LIST
    * It cannot be the argument to [object.destroy|destroy].
    * References cannot be upcast to the enclosing class object, nor
    can they be downcast to a derived interface.
    * The C++ calling convention is the default convention
    for its member functions, rather than the D calling convention.
    * The first member of the `vtbl[]` is not the pointer
    to the `Interface`, but the first virtual function pointer.
    
)



class, Classes, enum, Enums




Link_References:
	ACC = Associated C Compiler
+/
module interface.dd;