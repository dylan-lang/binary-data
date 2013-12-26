Usage
*****

.. current-library:: binary-data
.. current-module:: binary-data

.. contents::
   :local:

Terminology
===========

A vector of bytes that has an associated definition for
its interpretation is a *frame*. These come in two variants: some
cannot be broken down further structurally, we call those
*leaf frames*. The others have a composite structure, those
are *container frames*. They consist of a number of *fields*,
which are the named components of that frame. Every field
in a container frame is a frame in itself, leading to a recursive
definition of frames.  The description of the structure of a
container frame in our DSL is referred to as a *binary data
definition*.

Representation in Dylan
=======================

The binary-data library provides an extension to Dylan for manipulating frames,
with a representation of frames as Dylan objects, and a set of functions on
these objects to perform the manipulation. The representation used
introduces a class hierarchy rooted at the abstract superclass :class:`<frame>`,
with the two disjoint abstract subclasses :class:`<leaf-frame>` and
:class:`<container-frame>`. Every type of frame in the system is represented
as a concrete subclass of either one, and actual frames are instances of
these classes. A pair of generic functions, :class:`parse-frame` and
:gf:`assemble-frame`, convert a given byte vector into the appropriate
high-level instance of :class:`<frame>`, or vice versa.

Typical code that handles a frame then looks like this:

.. code-block:: dylan

    let frame = parse-frame(<ethernet-frame>, some-byte-vector);
    format-out("This packet goes from %= to %=\n\",
               frame.source-address,
               frame.destination-address);

The first line binds the variable frame to an instance of some subclass of
``<ethernet-frame>``. This instance is created from the vector of bytes
passed to the call of :gf:`parse-frame`. Then, the value of the source and
destination address fields in the Ethernet frame are extracted and printed.

The appropriate classes and accessor functions are not written directly for
container frames. Rather, they are created by invocation of the ``define
binary-data`` macro. This serves two purposes: it allows a more compact
representation, eliminating the need to write boilerplate code over and
over again, and it hides implementation details from the user of the DSL.

Some frames are translated into Dylan objects. An example of this is the
leaf frame type :class:`<2byte-big-endian-unsigned-integer>` which is
translated into a Dylan :drm:`<integer>`. This is referred to as a
*translated frame* while frames without a matching Dylan type are known
as *untranslated frames*.

Frame Types
===========

Container Frame
---------------

...

Header Frame
------------

...

Variably Typed Container Frame
------------------------------

The :class:`<variably-typed-container-frame>` class is used in container
frames which have the type information encoded in the frame. Parsing of
the layering field of these container frames is needed to find out the
actual type.

For example:

.. code-block:: dylan

    define abstract binary-data ip-option-frame (variably-typed-container-frame)
      field copy-flag :: <1bit-unsigned-integer>;
      layering field option-type :: <7bit-unsigned-integer>;
    end;

    define binary-data end-of-option-ip-option (ip-option-frame)
      over <ip-option-frame> 0;
    end;

This defines the ``<end-of-option-ip-option>`` which has the ``option-type``
field in the ip-option frame set to ``0``. An ``<end-of-option-ip-option>``
does not contain any further fields, thus only has the two fields inherited from
the ``<ip-option-frame>``.

Field Types
===========

Normal Fields
-------------

...

Enumerated Fields
-----------------

An enumerated field provides a set of mappings from the binary value
to a high level Dylan value.

In this example, accessing the value of the field would return one
of the symbols rather than the value of the :class:`<unsigned-byte>`:

.. code-block:: dylan

    enum field command :: <unsigned-byte> = 0,
        mappings: { 1 <=> #"connect",
                    2 <=> #"bind",
                    3 <=> #"udp associate" };

Layering Fields
---------------

A layering field provides the information that the value of this field
controls the type of the payload, and introduces a registry for field
values and matching payload types.

See `Variably Typed Container Frame`_ for an example of how this is
used.

Repeated Fields
---------------

Repeated fields have a list of values of the field type, instead of just
a single one. We support multiple typed of repeated fields, which differ
by the way the compute the number of elements in a repeated field. Choices
are: self-delimited (some magic end of list value present) or count (some
other field specifies a count of elements in the repeated field).

A self-delimited field definition uses an expression to evaluate whether
or not the end has been reached, usually by checking for a magic value.
This expression should return ``#t`` when the field is fully parsed:

.. code-block:: dylan

    repeated field options :: <ip-option-frame>,
      reached-end?:
        instance?(frame, <end-of-option-ip-option>);

Counted field definitions use another field in the frame to determine
how many elements are in the field:

.. code-block:: dylan

    field number-methods :: <unsigned-byte>,
      fixup: frame.methods.size;
    repeated field methods :: <unsigned-byte>,
      count: frame.number-methods;

Note the use of the ``fixup`` keyword on the ``number-methods`` field to
calculate a value for use by :gf:`assemble-frame` if the value is not
otherwise specified.

Variably Typed Fields
---------------------

Most fields have the same type in all frame instances, these are statically
typed. Some fields depend on the value of another field of the same protocol,
these are variably typed. To figure out the type, a type function has to be
provided for the variably typed field using the ``type-function:``.
