// just docs: Garbage Collection
/++





        D is a systems programming language with support for garbage collection.
        Usually it is not necessary
        to free memory explicitly. Just allocate as needed, and the garbage collector will
        periodically return all unused memory to the pool of available memory.
        

        D also provides the mechanisms to write code where the garbage collector
        is $(B not involved). More information is provided below.
        

        Programmers accustomed to explicitly managing memory
        allocation and
        deallocation will likely be skeptical of the benefits and efficacy of
        garbage collection. Experience both with new projects written with
        garbage collection in mind, and converting existing projects to garbage
        collection shows that:
        

        $(LIST

        * Garbage collected programs are often faster. This is
        counterintuitive, but the reasons are:

        $(LIST
            * Reference counting is a common solution to solve explicit
            memory allocation problems. The code to implement the increment and
            decrement operations whenever assignments are made is one source
            of slowdown. Hiding it behind smart pointer classes doesn't help
            the speed. (Reference counting methods are not a general solution
            anyway, as circular references never get deleted.)
            

            * Destructors are used to deallocate resources acquired by an object.
            For most classes, this resource is allocated memory.
            With garbage collection, most destructors then become empty and
            can be discarded entirely.
            

            * All those destructors freeing memory can become significant when
            objects are allocated on the stack. For each one, some mechanism must
            be established so that if an exception happens, the destructors all
            get called in each frame to release any memory they hold. If the
            destructors become irrelevant, then there's no need to set up special
            stack frames to handle exceptions, and the code runs faster.
            

            * Garbage collection kicks in only when memory gets tight. When
            memory is not tight, the program runs at full speed and does not
            spend any time tracing and freeing memory.
            

            * Garbage collected programs do not suffer from gradual deterioration
            due to an accumulation of memory leaks.
            
        
)
        

        * Garbage collectors reclaim unused memory, therefore they do not suffer
        from "memory leaks" which can cause long running applications to gradually
        consume more and more memory until they bring down the system. GC programs
        have longer term stability.
        

        * Garbage collected programs have fewer hard-to-find pointer bugs. This
        is because there are no dangling references to freed memory. There is no
        code to explicitly manage memory, hence no bugs in such code.
        

        * Garbage collected programs are faster to develop and debug, because
        there's no need for developing, debugging, testing, or maintaining the
        explicit deallocation code.
        

        
)

        Garbage collection is not a panacea. There are some downsides:
        

        $(LIST

        * It is not always obvious when the GC allocates memory, which in
        turn can trigger a collection, so the program can pause unexpectedly.
        

        * The time it takes for a collection to complete is not bounded.
        While in practice it is very quick, this cannot normally be guaranteed.
        

        * Normally, all threads other than the collector thread must be
        halted while the collection is in progress.
        

        * Garbage collectors can keep around some memory that an explicit
        deallocator would not.
        

        * Garbage collection should be implemented as a basic operating
        system
        kernel service. But since it is not, garbage collecting programs must
        carry around with them the garbage collection implementation. While this
        can be a shared library, it is still there.
        
        
)

        These constraints are addressed by techniques outlined
        in $(LINK2 https://wiki.dlang.org/Memory_Management, Memory Management), including the mechanisms provided by
        D to control allocations outside the GC heap.
        

        There is currently work in progress to make the runtime library free of GC heap allocations,
        to allow its use in scenarios where the use of GC infrastructure is not possible.
        

$(H2 $(ID how_gc_works) How Garbage Collection Works)

        The GC works by:

        $(NUMBERED_LIST
        * Stopping all other threads than the thread currently trying to
        allocate GC memory.

        * 'Hijacking' the current thread for GC work.

        * Scanning all 'root' memory ranges for pointers into
        GC allocated memory.

        * Recursively scanning all allocated memory pointed to by
        roots looking for more pointers into GC allocated memory.

        * Freeing all GC allocated memory that has no active pointers
        to it and do not need destructors to run.

        * Queueing all unreachable memory that needs destructors to run.

        * Resuming all other threads.

        * Running destructors for all queued memory.

        * Freeing any remaining unreachable memory.

        * Returning the current thread to whatever work it was doing.
        
)

$(H2 $(ID gc_foreign_obj) Interfacing Garbage Collected Objects With Foreign Code)

        The garbage collector looks for roots in:
        $(NUMBERED_LIST
        * the static data segment
        * the stacks and register contents of each thread
        * the TLS (thread-local storage) areas of each thread
        * any roots added by core.memory.GC.addRoot() or core.memory.GC.addRange()
        
)

        If the only pointer to an object
        is held outside of these areas, then the collector will miss it and free the
        memory.
        

        To avoid this from happening, either

        $(LIST
        * maintain a pointer to the object in an area the collector does scan
        for pointers;

        * add a root where a pointer to the object is stored using core.memory.GC.addRoot()
        or core.memory.GC.addRange().

        * reallocate and copy the object using the foreign code's storage
        allocator
        or using the C runtime library's malloc/free.
        
        
)

$(H2 $(ID pointers_and_gc) Pointers and the Garbage Collector)

        Pointers in D can be broadly divided into two categories: Those that
        point to garbage collected memory, and those that do not. Examples
        of the latter are pointers created by calls to C's malloc(), pointers
        received from C library routines, pointers to static data,
        pointers to objects on the stack, etc. For those pointers, anything
        that is legal in C can be done with them.
        

        For garbage collected pointers and references, however, there are
        some
        restrictions. These restrictions are minor, but they are intended
        to enable the maximum flexibility in garbage collector design.
        

        $(PITFALL 
        $(LIST

        * Do not xor pointers with other values, like the
        xor pointer linked list trick used in C.
        

        * Do not use the xor trick to swap two pointer values.
        

        * Do not store pointers into non-pointer variables using casts and
        other tricks.

---
void* p;
...
int x = cast(int)p;   // error: undefined behavior

---

        The garbage collector does not scan non-pointer fields for GC pointers.
        

        * Do not take advantage of alignment of pointers to store bit flags
        in the low order bits:

---
p = cast(void*)(cast(int)p | 1);  // error: undefined behavior

---
        

        * Do not store into pointers values that may point into the
        garbage collected heap:

---
p = cast(void*)12345678;   // error: undefined behavior

---

        A copying garbage collector may change this value.
        

        * Do not store magic values into pointers, other than `null`.
        

        * Do not write pointer values out to disk and read them back in
        again.
        

        * Do not use pointer values to compute a hash function. A copying
        garbage collector can arbitrarily move objects around in memory,
        thus invalidating
        the computed hash value.
        

        * Do not depend on the ordering of pointers:

---
if (p1 &lt; p2)  // error: undefined behavior
    ...

---
        since, again, the garbage collector can move objects around in
        memory.
        

        * Do not add or subtract an offset to a pointer such that the result
        points outside of the bounds of the garbage collected object originally
        allocated.

---
char* p = new char[10];
char* q = p + 6; // ok
q = p + 11;      // error: undefined behavior
q = p - 1;       // error: undefined behavior

---
        

        * Do not misalign pointers if those pointers may
        point into the GC heap, such as:

---
struct Foo
{
  align (1):
    byte b;
    char* p;  // misaligned pointer
}

---

        Misaligned pointers may be used if the underlying hardware
        supports them $(B and) the pointer is never used to point
        into the GC heap.
        

        * Do not use byte-by-byte memory copies to copy pointer values.
        This may result in intermediate conditions where there is
        not a valid pointer, and if the GC pauses the thread in such a
        condition, it can corrupt memory.
        Most implementations of `memcpy()` will work since the
        internal implementation of it does the copy in aligned chunks
        greater than or equal to the pointer size, but since this kind of
        implementation is not guaranteed by the C standard, use
        `memcpy()` only with extreme caution.
        

        * Do not have pointers in a struct instance that point back
        to the same instance. The trouble with this is if the instance
        gets moved in memory, the pointer will point back to where it
        came from, with likely disastrous results.
        

        
)
        )

        Things that are reliable and can be done:

        $(LIST

        * Use a union to share storage with a pointer:

---
union U { void* ptr; int value }

---
        

        * A pointer to the start of a garbage collected object need not
        be maintained if a pointer to the interior of the object exists.

---
char[] p = new char[10];
char[] q = p[3..6];
// q is enough to hold on to the object, don't need to keep
// p as well.

---
        
        
)

        One can avoid using pointers anyway for most tasks. D provides
        features
        rendering most explicit pointer uses obsolete, such as reference
        objects,
        dynamic arrays, and garbage collection. Pointers
        are provided in order to interface successfully with C APIs and for
        some low level work.
        

$(H2 $(ID working_with_the_gc) Working with the Garbage Collector)

        Garbage collection doesn't solve every memory deallocation problem.
        For
        example, if a pointer to a large data structure is kept, the garbage
        collector cannot reclaim it, even if it is never referred to again. To
        eliminate this problem, it is good practice to set a reference or
        pointer to an object to null when no longer needed.
        

        This advice applies only to static references or references embedded
        inside other objects. There is not much point for such stored on the
        stack to be nulled because new stack frames are initialized anyway.
        

$(H2 $(ID obj_pinning_and_gc) Object Pinning and a Moving Garbage Collector)

        Although D does not currently use a moving garbage collector, by following
        the rules listed above one can be implemented. No special action is required
        to pin objects. A moving collector will only move objects for which there
        are no ambiguous references, and for which it can update those references.
        All other objects will be automatically pinned.
        

$(H2 D $(ID op_involving_gc) Operations That Involve the Garbage Collector)

        Some sections of code may need to avoid using the garbage collector.
        The following constructs may allocate memory using the garbage collector:
        

        $(LIST
        * [expression#NewExpression|expression, NewExpression]
        * Array appending
        * Array concatenation
        * Array literals (except when used to initialize static data)
        * Associative array literals
        * Any insertion or removal in an associative array
        * Extracting keys or values from an associative array
                * Taking the address of (i.e. making a delegate to) a nested function that
         accesses variables in an outer scope
        * A function literal that accesses variables in an outer scope

        * An [expression#AssertExpression|expression, AssertExpression] that fails its condition
        
)

$(H2 $(ID gc_config) Configuring the Garbage Collector)

    Since version 2.067, The garbage collector can now be configured
        through the command line, the environment or by options embedded
        into the executable.
    

    By default, GC options can only be passed on the command line of the program
        to run, e.g.

---
app "--DRT-gcopt=profile:1 minPoolSize:16" arguments to app

---

    Available GC options are:
        $(LIST
        * disable:0|1    - start disabled
        * profile:0|1    - enable profiling with summary when terminating program
        * gc:conservative|precise|manual - select GC implementation (default = conservative)
        * initReserve:N  - initial memory to reserve in MB
        * minPoolSize:N  - initial and minimum pool size in MB
        * maxPoolSize:N  - maximum pool size in MB
        * incPoolSize:N  - pool size increment MB
        * parallel:N     - number of additional threads for marking
        * heapSizeFactor:N - targeted heap size to used memory ratio
        * cleanup:none|collect|finalize - how to treat live objects when terminating
          $(LIST
            * collect: run a collection (the default for backward compatibility)
            * none: do nothing
            * finalize: all live objects are finalized unconditionally
          
)
        
)


    In addition, --DRT-gcopt=help will show the list of options and their current settings.
    
    Command line options starting with "--DRT-" are filtered out before calling main,
        so the program will not see them. They are still available via `rt_args`.
    
    Configuration via the command line can be disabled by declaring a variable for the
        linker to pick up before using its default from the runtime:
---
extern(C) __gshared bool rt_cmdline_enabled = false;

---

    Likewise, declare a boolean `rt_envvars_enabled` to enable configuration via the
        environment variable `DRT_GCOPT`:
---
extern(C) __gshared bool rt_envvars_enabled = true;

---

    Setting default configuration properties in the executable can be done by specifying an
        array of options named `rt_options`:
---
extern(C) __gshared string[] rt_options = [ "gcopt=initReserve:100 profile:1" ];

---

    Evaluation order of options is `rt_options`, then environment variables, then command
        line arguments, i.e. if command line arguments are not disabled, they can override
        options specified through the environment or embedded in the executable.
    

$(H2 $(ID precise_gc) Precise Heap Scanning)

    Selecting `precise` as the garbage collector via the options above means type
        information will be used to identify actual or possible pointers or
        references within heap allocated data objects. Non-pointer data will not
        be interpreted as a reference to other memory as a "false pointer". The collector
        has to make pessimistic assumptions if a memory slot can contain both a pointer or
        an integer value, it will still be scanned (e.g. in a `union`).
    

    To use the GC memory functions from `core.memory`
        for data with a mixture of pointers and non-pointer data, pass the
        TypeInfo of the allocated struct, class, or type as the optional parameter.
        The default `null` is interpreted as memory that might contain pointers everywhere.
---
struct S { size_t hash; Data* data; }
S* s = cast(S*)GC.malloc(S.sizeof, 0, typeid(S));

---

    Attention: Enabling precise scanning needs slightly more caution with
        type declarations. For example, when reserving a buffer as part of a struct and later
        emplacing an object instance with references to other allocations into this memory,
        do not use basic integer types to reserve the space. Doing so will cause the
        garbage collector not to detect the references. Instead, use an array type that
        will scan this area conservatively. Using `void*` is usually the best option as it also
        ensures proper alignment for pointers being scanned by the GC.
    

$(H2 $(ID precise_dataseg) Precise Scanning of the DATA and TLS segment)

    $(B Windows only:) As of version 2.075, the DATA (global shared data)
        and TLS segment (thread local data) of an executable
        or DLL can be configured to be scanned precisely by the garbage collector
        instead of conservatively. This takes
        advantage of information emitted by the compiler to
        identify possible mutable pointers inside these segments. Immutable pointers
        $(LINK2 spec/const3#immutable_storage_class,with initializers)
        are excluded from scanning, too, as they can only point to preallocated memory.
    

    Precise scanning can be enabled with the D runtime option "scanDataSeg". Possible option
        values are "conservative" (default) and "precise". As with the GC options, it can be
        specified on the command line, in the environment or embedded into the executable, e.g.
---
extern(C) __gshared string[] rt_options = [ "scanDataSeg=precise" ];

---


    Attention: Enabling precise scanning needs slightly more caution typing
        global memory. For example, to pre-allocate memory in the DATA/TLS segment and later
        emplace an object instance with references to other allocations into this memory,
        do not use basic integer types to reserve the space. Doing so will cause the
        garbage collector not to detect the references. Instead, use an array type that
        will scan this area conservatively. Using `void*` is usually the best option as it also
        ensures proper alignment for pointers being scanned by the GC.
---
class Singleton { void[] mem; }
align(__traits(classInstanceAlignment, Singleton))
    void*[(__traits(classInstanceSize, Singleton) - 1) / (void*).sizeof + 1]
    singleton_store;
static this()
{
    emplace!Singleton(singleton_store).mem = allocateMem();
}
Singleton singleton() { return cast(Singleton)singleton_store.ptr; }

---
        For precise typing of that area, let the compiler generate the class
        instance into the DATA segment:
---
class Singleton { void[] mem; }
shared(Singleton) singleton = new Singleton;
shared static this() { singleton.mem = allocateSharedMem(); }

---
        This doesn't work for TLS memory, though.

$(H2 $(ID gc_parallel) Parallel marking)

    By default the garbage collector uses all available CPU cores to mark the heap.

    This might affect your application if it has threads that are not suspended
        during the mark phase of the collection. Configure the number of
        additional threads used for marking by GC option `parallel`,
        e.g. by passing `--DRT-gcopt=parallel:2` on the command
        line or embedding the option into the binary via `rt_options`.
        The number of threads actually created is limited to
        $(LINK2 library/core/cpuid/threads_per_cpu.html, `core.cpuid.threadsPerCPU-1`).
        A value of `0` disables parallel marking completely.

$(H2 $(ID gc_registry) Adding your own Garbage Collector)

    GC implementations are added to a registry that allows to supply
        more implementations by just linking them into
        the binary. To do so add a function that is executed before the
        D runtime initialization using `pragma(crt_constructor)`:
---
import core.gc.gcinterface, core.gc.registry;
extern (C) pragma(crt_constructor) void registerMyGC()
{
    registerGCFactory("mygc", &amp;createMyGC);
}

GC createMyGC()
{
    __gshared instance = new MyGC;
    instance.initialize();
    return instance;
}

class MyGC : GC { /*...*/ }

---

    [The GC modules defining the interface (gc.interface) and registration
        (gc.registry) are currently not public and are subject to
        change from version to version. Add an import search path to the
        druntime/src path to compile the example.]

    The new GC is added to the list of available garbage collectors that
        can be selected via the usual configuration options, e.g. by embedding
        `rt_options` into the binary:
---
extern (C) __gshared string[] rt_options = ["gcopt=gc:mygc"];

---

    The standard GC implementation from a statically
        linked binary can be removed by redefining the function `extern(C) void* register_default_gcs()`.
        If no custom garbage collector has been registered
        all attempts to allocate GC managed memory will terminate
        the application with an appropriate message.

$(H2 $(ID references) References)

        $(LIST
        * $(LINK2 https://en.wikipedia.org/wiki/Garbage_collection_%28computer_science%29, Wikipedia)
        * $(LINK2 http://www.iecc.com/gclist/GC-faq.html, GC FAQ)
        * $(LINK2 ftp://ftp.cs.utexas.edu/pub/garbage/gcsurvey.ps, Uniprocessor Garbage Collector Techniques)
        * 0471941484, Garbage Collection: Algorithms for Automatic Dynamic Memory Management
        
)

unittest, Unit Tests, float, Floating Point




Link_References:
	ACC = Associated C Compiler
+/
module garbage.dd;