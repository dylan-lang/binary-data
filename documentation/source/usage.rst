Usage
*****

.. current-library:: binary-data
.. current-module:: binary-data

.. contents::
   :local:

Terminology
===========

A vector of bytes that has an associated definition for its
interpretation is a *frame*. These come in two variants: some cannot
be broken down further structurally, we call those *leaf frames*. The
others have a composite structure, those are *container frames*. They
consist of a number of *fields*, which are the named components of
that frame. Every field in a container frame is a frame in itself,
leading to a recursive definition of frames.  The description of the
structure of a container frame in our domain-specific language
:macro:`define binary-data` is referred to as a *binary data
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

The class :class:`<frame>` defines several generic functions:

.. hlist::

   * :gf:`parse-frame` instantiates a :class:`<frame>` with the value taken from a given byte-vector
   * :gf:`assemble-frame` encodes a :class:`<frame>` instance into its byte-vector
   * :gf:`frame-size` returns the size (in bit) of the given frame
   * :gf:`summary` prints a human-readable summary of the given frame

Some properties are mixed in into our class hierarchy by introducing
the direct subclasses of :class:`<frame>`:

For efficiency reasons, there is a distinction between frames that
have a static (compile-time) size (:class:`<fixed-size-frame>`) and
frames of dynamic size (:class:`<variable-size-frame>`).

Another property is translation of the value into a Dylan object of
the standard library. An example of such a :class:`<translated-frame>`
is the (fixed size) type :class:`<2byte-big-endian-unsigned-integer>`
which is translated into a Dylan :drm:`<integer>`. This is referred to
as a *translated frame* while frames without a matching Dylan type are
known as *untranslated frames* (:class:`<untranslated-frame>`).

The appropriate classes and accessor functions are not written
directly for container frames. Rather, they are created by invocation
of the macro :macro:`define binary-data`. This serves two purposes: it
allows a more compact representation, eliminating the need to write
boilerplate code over and over again, and it hides implementation
details from the user of the DSL.

Frame Types
===========

Leaf Frames
-----------

A leaf frame can be fixed or variable size, and translated or
untranslated. Examples are:

.. hlist::

   * :class:`<raw-frame>` has a variable size and no translation
   * :class:`<fixed-size-byte-vector-frame>` (e.g. an IPv4 address) has a fixed size and no translation
   * :class:`<2byte-big-endian-unsigned-integer>` has a fixed size of 16 bits, and its translation is a Dylan :drm:`<integer>`.

FIXME: :class:`<externally-delimited-string>` is variable size and
untranslated, though :drm:`as` in both directions with :drm:`<string>`
is provided (should inherit from translated frame)

The generic function :gf:`read-frame` is used to convert a
:drm:`<string>` into an instance of a `<leaf-frame>`.

FIXME: why is read-frame not defined on container-frame?

The running example in this guide will be an ``<ethernet-frame>``,
which contains the mac address of the source and a mac-address of the
destination. A mac address is the unique address of each network
interface, assigned by the IEEE. It consists of 6 bytes and is usually
printed in hexadecimal, each byte separated by ``:``.

The definition of the ``<mac-address>`` in Dylan is:

.. code-block:: dylan

    define class <mac-address> (<fixed-size-byte-vector-frame>)
    end;

    define inline method field-size (type == <mac-address>)
     => (length :: <integer>)
      6 * 8
    end;

    define method mac-address (data :: <byte-vector>)
     => (res :: <mac-address>);
      parse-frame(<mac-address>, data)
    end;

    define method mac-address (data :: <string>)
     => (res :: <mac-address>);
      read-frame(<mac-address>, data)
    end;

    define method read-frame(type == <mac-address>, string :: <string>)
     => (res)
      let res = as-lowercase(string);
      if (any?(method(x) x = ':' end, res))
        //input: 00:de:ad:be:ef:00
        let fields = split(res, ':');
        unless(fields.size = 6)
         signal(make(<parse-error>))
        end;
        make(<mac-address>,
             data: map-as(<stretchy-vector-subsequence>,
                          rcurry(string-to-integer, base: 16),
                          fields));
      else
        //input: 00deadbeef00
        ...
      end;
    end;

    define method as (class == <string>, frame :: <mac-address>)
     => (string :: <string>);
      reduce1(method(a, b) concatenate(a, ":", b) end,
              map-as(<stretchy-vector>,
                     rcurry(integer-to-string, base: 16, size: 2),
                     frame.data))
    end;

The data is stored in the ``data`` slot of the
:class:`<fixed-size-byte-vector-frame>`, the ``field-size`` method
returns statically 48 bit, syntax sugar for constructing
``<mac-address>`` instances are provided, ``read-frame`` converts a
``<string>``, whereas ``as`` converts a ``<mac-address>`` into human
readable output.

A leaf frame on its own is not very useful, but it is the building
block for the composed container frames.


Container Frame
---------------

The container frame class inherits from :class:`<variable-size-frame>`
and :class:`<untranslated-frame>`.

A container frame consists of a sequence of fields. A field represents
the static information about a protocol: the name of the field, the
frame type, possibly a start and length offset, a length, a method for
fixing the byte vector, ...

The list of fields for a given :class:`<container-frame>` persists
only once in memory, the dynamic values are represented by
:class:`<frame-field>` objects.

Methods defined on :class:`<container-frame>`:

.. hlist::
   * :gf:`fields` returns the list of :class:`<field>` instances
   * :gf:`field-count` returns the size of the list
   * :gf:`frame-name` returns a short identifier of the frame

The definer macro :macro:`define binary-data` translates the
binary-data DSL into a class definition which is a subclass of
:class:`<container-frame>` (and other useful stuff).

The class :class:`<header-frame>` is a direct subclass of
:class:`<container-frame>` which is used for container frames which
consist of a header (addressing, etc) and some payload, which might
also be a container-frame of variable type.

The running example is an ``<ethernet-frame>``, which is shown as
binary data definition.

.. code-block:: dylan

    define binary-data <ethernet-frame> (<header-frame>)
      summary "ETH %= -> %=", source-address, destination-address;
      field destination-address :: <mac-address>;
      field source-address :: <mac-address>;
      layering field type-code :: <2byte-big-endian-unsigned-integer>;
      variably-typed field payload, type-function: frame.payload-type;
    end;

FIXME: why is payload-type not the default type-function of a variable-typed field?

The first line specifies the name ``<ethernet-frame>``, and its
superclass, :class:`<header-frame>`.

The second line specialises the method :gf:`summary` on an
``<ethernet-frame>`` to print ``ETH``, the source address and the
destination address.

The remaining lines represent each one field in the ethernet frame
structure. The ``source-address`` and ``destination-address`` are each
of type ``<mac-address>``.

The ``type-code`` field is a 16 bit integer, and it is a ``layering``
field (:class:`<layering-field>`). This means that its value is used
to determine the type of its payload! Also, when assembling such a
frame, the layering field will be filled out automatically depending
on the payload type.  There can be at most one ``layering`` field in a
binary data definition.

The last field is the payload, whose type is variable and given by
applying the function ``payload-type`` to the concrete frame instance.

A payload for an ``<ethernet-frame>`` might be a ``<vlan-tag>``, if
the ``type-code`` is ``#x8100`` (the keyword ``over`` does the hairy
details).

.. code-block:: dylan

    define binary-data <vlan-tag> (<header-frame>)
      over <ethernet-frame> #x8100;
      summary "VLAN: %=", vlan-id;
      field priority :: <3bit-unsigned-integer> = 0;
      field canonical-format-indicator :: <1bit-unsigned-integer> = 0;
      field vlan-id :: <12bit-unsigned-integer>;
      layering field type-code :: <2byte-big-endian-unsigned-integer>;
      variably-typed field payload, type-function: frame.payload-type;
    end;

Default values for fields can be provided, similar to Dylan class
definitions, after the equal sign (``=``) after the field type.

A more detailed description of the binary data language can be found
in its reference :macro:`define binary-data`.

Inheritance: Variably Typed Container Frames
--------------------------------------------

A container frame can inherit from another container frame which
already has some field structure. The
:class:`<variably-typed-container-frame>` class is used in container
frames which have the type information encoded in the frame. Parsing
of the layering field (:class:`<layering-field>`) of these container
frames is needed to find out the actual type.

The running example are the `options of a IPv4 packet
<https://en.wikipedia.org/wiki/IPv4#Options>`__. These share a common
header (``copy-flag`` and ``option-type``), but a concrete option
might have additional fields. The end of the option is determined by
the ``header-length`` field of an IPv4 packet and by the
``<end-option>`` (which ``option-type`` is 0).

.. code-block:: dylan

    define abstract binary-data <ip-option-frame> (<variably-typed-container-frame>)
      field copy-flag :: <1bit-unsigned-integer>;
      layering field option-type :: <7bit-unsigned-integer>;
    end;

    define binary-data <end-option> (<ip-option-frame>)
      over <ip-option-frame> 0;
    end;

    define binary-data <router-alert> (<ip-option-frame>)
      over <ip-option-frame> 20;
      field router-alert-length :: <unsigned-byte> = 4;
      field router-alert-value :: <2byte-big-endian-unsigned-integer>;
    end;

This defines the ``<end-option>`` which has the ``option-type`` field
in the ip-option frame set to ``0``. An ``<end-option>`` does not
contain any further fields, thus only has the two fields inherited
from the ``<ip-option-frame>``.

The ``<router-alert>`` specifies two more fields, which are
appended to the inherited fields.


Fields
======

The domain-specific language :macro:`define binary-data` provides
syntactic sugar to create :class:`<field>` instances. A client should
not need to instantiate these directly. A field contains the static
information (such as type, length, default value) of a sequence of
bits inside of a :class:`<container-frame>`.

Binary data formats have some common patterns which are directly
integrated into this library:

* *variably-typed* fields for payloads
* *layering* of protocols in the OSI network stack
* *enumeration* where the bit value has a direct correspondence to a :drm:`<symbol>`
* *repeating* occurences of a field, such as key-value pairs

.. note:: There might be more patterns, if you find any, please tell us!

Variably-typed
--------------

Most fields have the same type in all frame instances, these are
statically typed. But the type of a field can depend on the value of
another field in the same :class:`<container-frame>`. This library
provides direct support for this demand, by introducing
:class:`<variably-typed-field>` which does not have a static type, but
an expression determining the type for a concrete frame object.

This example uses the ``variably-typed field`` syntax. The
``type-function`` keyword has ``frame`` bound to the concrete frame
object.


.. code-block:: dylan

    field length-type :: <2bit-unsigned-integer>;
    variably-typed field body-length,
      type-function: select (frame.length-type)
                       0 => <unsigned-byte>;
                       1 => <2byte-big-endian-unsigned-integer>;
                       2 => <4byte-big-endian-unsigned-integer>;
                       3 => <null-frame>;
                     end;

Layering
--------

Binary data format stacking is omnipresent in network protocols. An
ethernet frame can contain different types of payload, amongst others
ARP frames, IPv4 frames. This library provides syntactic sugar
``layering`` to define which field in a frame determines the type of
the payload. A binary data definition can also specify which value is
used to be the payload of another binary data format.

A layering field (:class:`<layering-field>`) provides the information
that the value of this field controls the type of the payload, and
establishes a registry for field values and matching payload types.

The registry can be extended with the ``over`` syntax of
:macro:`define binary-data`, and it can be queried using the
convinience function :func:`payload-type`, or :gf:`lookup-layer` and
:gf:`reverse-lookup-layer`.


Enumeration
-----------

An enumerated field (:class:`<enum-field>`) provides a set of mappings
from the binary value to a Dylan :drm:`<symbol>`. Note that the binary
value must be a numerical type so that the mapping is from an integer
to a symbol.

In this example, accessing the value of the field would return one of
the symbols rather than the value of the :class:`<unsigned-byte>`. For
mappings not specified, the integer value is used:

.. code-block:: dylan

    enum field command :: <unsigned-byte> = 0,
        mappings: { 1 <=> #"connect",
                    2 <=> #"bind",
                    3 <=> #"udp associate" };

Repeating
---------

Repeated fields (:class:`<repeated-field>`) have a list of values of
the field type, instead of just a single one. We support multiple
typed of repeated fields, which differ by the way the compute the
number of elements in a repeated field. Choices are: self-delimited
(:class:`<self-delimited-repeated-field>`, some magic end of list
value present) or count (:class:`<count-repeated-field>`), some other
field specifies a number of elements in the repeated field).

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

Adding a New Leaf Frame Type
----------------------------




Efficiency Considerations
=========================

The design goal of this library is, as usual in object-centered
programming, that the time and space overhead are minimal (the
compiler should remove all the indirections!).

This library is carefully designed to achieve this goal, while not
limiting the expressiveness, sacrificing the safety, or burdening the
developer with inconvenient syntactic noise. A story about binary data
is that there are often big chunks of data, and deeply nested pieces
of data. The good news is that most applications do not need all
binary data.

The binary data library was designed with lazy parsing in mind: if a
byte vector is received, the high-level object does not parse the byte
vector completely, but only the requested fields. To achieve this, we
gather information about each field, specifically its start and end
offset, and also its length, already at compile time, using a number
system consisting of the type union between :drm:`<integer>` and
:const:`$unknown-at-compile-time`, for which basic arithmetics is
defined.

For fixed sized fields, meaning single fields with a static and fixed
size frame type, their length is propagated while the DSL iterates
over the fields. All field offsets for the ``<ethernet-frame>`` are
known at compile time. Accessing the ``payload`` is a subsequence
operation (performing zerocopy) starting at bit 112 (or byte 15) of
the binary vector.

While at the user level arithmetics is on the bit level, accesses at
byte boundaries are done directly into the byte vector. This is
encapsulated in the class :class:`<stretchy-byte-vector-subsequence>`

FIXME: move <stretchy-byte-vector-subsequence> to a separate module

Each binary data macro call defines a container class with two direct
subclasses, a high-level decoded class
(:class:`<decoded-container-frame>`) and a partially parsed one with
an attached byte-vector (:class:`<unparsed-container-frame>`).  The
decoded class has a list of :class:`<frame-field>` instances, which
contain the metadata (size, fixup function, reference to the field,
etc.) of each field. The partially parsed class reuses this class in
its ``cache`` slot, and keeps a reference to its byte vector in
another slot.


