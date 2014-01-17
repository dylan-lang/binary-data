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

The appropriate classes and accessor functions are not written directly for
container frames. Rather, they are created by invocation of the ``define
binary-data`` macro. This serves two purposes: it allows a more compact
representation, eliminating the need to write boilerplate code over and
over again, and it hides implementation details from the user of the DSL.

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

FIXME: some defer to methods defined on the class, not on instances!

The definer macro :macro:`binary-data-definer` translates the
binary-data DSL into a class definition which is a subclass of
:class:`<container-frame>` (and other useful stuff).

The class :class:`<header-frame>` is a direct subclass of
:class:`<container-frame>` which is used for container frames which
consist of a header (addressing, etc) and some payload, which might
also be a container-frame of variable type.

The running example is an ``<ethernet-frame>``, which is shown as
binary-data definition.

.. code-block:: dylan

    define binary-data ethernet-frame (header-frame)
      summary "ETH %= -> %=", source-address, destination-address;
      field destination-address :: <mac-address>;
      field source-address :: <mac-address>;
      layering field type-code :: <2byte-big-endian-unsigned-integer>;
      variably-typed field payload, type-function: frame.payload-type;
    end;

FIXME: why is payload-type not the default type-function of a variable-typed field?

The first line specifies the name ``ethernet-frame``, and its
superframe, ``header-frame``. We support inheritance of binary data,
the fields in the superframe are prepended to the list of given
fields.

The second line specialises the method :gf:`summary` on an
``<ethernet-frame>`` to print ``ETH``, the source address and the
destination address.

The remaining lines represent each one field in the ethernet frame
structure. The ``source-address`` and ``destination-address`` are each
of type ``<mac-address>``. The ``type-code`` field is a 16 bit
integer, and it is a ``layering`` field. This means that its value is
used to determine the type of its payload! Also, when assembling such
a frame, the layering field will be filled out automatically depending
on the payload type.  There can be at most one ``layering`` field in a
binary-data definition.

The last field is the payload, whose type is variable and given by
applying the function ``payload-type`` to the concrete frame instance.

A payload for an ``<ethernet-frame>`` might be a ``<vlan-tag>``, if
the ``type-code`` is ``#x8100`` (the keyword ``over`` does the hairy
details).

.. code-block:: dylan

    define binary-data vlan-tag (header-frame)
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

Inheritance: Variably Typed Container Frames
--------------------------------------------

A container frame can inherit from another container frame which
already has some field structure. The
:class:`<variably-typed-container-frame>` class is used in container
frames which have the type information encoded in the frame. Parsing
of the layering field of these container frames is needed to find out
the actual type.

For example:

.. code-block:: dylan

    define abstract binary-data ip-option-frame (variably-typed-container-frame)
      field copy-flag :: <1bit-unsigned-integer>;
      layering field option-type :: <7bit-unsigned-integer>;
    end;

    define binary-data end-of-option-ip-option (ip-option-frame)
      over <ip-option-frame> 0;
    end;

    define binary-data router-alert-ip-option (ip-option-frame)
      over <ip-option-frame> 20;
      field router-alert-length :: <unsigned-byte> = 4;
      field router-alert-value :: <2byte-big-endian-unsigned-integer>;
    end;

This defines the ``<end-of-option-ip-option>`` which has the ``option-type``
field in the ip-option frame set to ``0``. An ``<end-of-option-ip-option>``
does not contain any further fields, thus only has the two fields inherited from
the ``<ip-option-frame>``.

The ``<router-alert-ip-option>`` specifies two more fields, which are
appended to the inherited fields.

Container Frame Options
-----------------------

``length`` *expression*:
   A Dylan expression which emits the length of the frame. A binding
   to the frame instance is available as the local variable ``frame``.

``over`` *binary-data-type* *value*:
   This frame can be stacked as payload to *binary-data-type* with the
   *value* in the layering field.

``summary`` *format-string*, *arguments*:
   The generic function :gf:`summary` is specialized using
   :gf:`format-to-string` on the *format-string*, applying the frame
   instance to all *arguments*, which should be unary functions.



Fields
======

The instantiation of fields is encapsulated into the binary data DSL,
there is no need to instantiate any of these classes directly, but
instead the DSL provides syntactic sugar for these fields.

There are two disjoint classes of the abstract superclass
:class:`<field>`: normal fields with a static type,
:class:`<statically-typed-field>`, and fields with a variable type :class:`<variably-typed-field>` (``variably-typed`` syntax).

Further class hierarchy distinguishes between fields which occur once
in a frame (class :class:`<single-field>`) and fields occuring
multiple times (class :class:`<repeated-field>`).

We already came across fields used for layering, these are represented
by the class :class:`<layering-field>` (``layering`` syntax).

It is common for binary data formats to contain enumeration fields: in
binary they are only a sequence of bits, but in the binary data
specification there are symbols available for each different bit
sequence. These are represented by :class:`<enum-fields>` .

There are two types of :class:`<repeated-field>`: those which occur a
specified number of times (class :class:`<count-repeated-field>`), and
those which occur until a special token (e.g. a zero byte) is read
(class :class:`<self-delimited-repeated-field>`).

Normal Fields
-------------

Fields can have the following parameters specified:

``static-start:`` *expression*:
   A Dylan expression returning the static offset of this field into
   the bit-vector, if known and not trivial.

``static-length:`` *expression*:
   A Dylan expression returning the static size of this field, if
   known and not trivial.

``static-end:`` *expression*:
   A Dylan expression returning the static offset of the end of this
   field into the bit-vector, if known and not trivial.

``start:`` *expression*:
   A Dylan expression where ``frame`` is bound to the concrete
   instance. The expected return value is the offset of this field
   into the bit-vector.

``length:`` *expression*;
   A Dylan expression where ``frame`` is bound to the concrete
   instance. The expected return value is the bit length this field.

``end:``
   A Dylan expression where ``frame`` is bound to the concrete
   instance. The expected return value is the offset of this field
   end into the bit-vector.

``fixup:`` *expression*:
   A Dylan expression where ``frame`` is bound to the concrete
   instance. When assembling a frame into a byte vector, if the value
   of a field has not been specified, the fixup expression will be
   evaluated and its return value will be used.


Enumerated Fields
-----------------

An enumerated field provides a set of mappings from the binary value
to a Dylan symbol. Note that the binary value must be a numerical
type so that the mapping is from an integer to a symbol.

In this example, accessing the value of the field would return one of
the symbols rather than the value of the :class:`<unsigned-byte>`. For
mappings not specified, the integer value is used:

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

The registry can be extended with the ``over`` syntax of the DSL, and
it can be queried using the method :gf:`lookup-layer` (or the
convinience function :func:`payload-type`).

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
provided for the variably typed field using the ``type-function:``:

.. code-block:: dylan

    field length-type :: <2bit-unsigned-integer>;
    variably-typed field body-length,
      type-function: select (frame.length-type)
                       0 => <unsigned-byte>;
                       1 => <2byte-big-endian-unsigned-integer>;
                       2 => <4byte-big-endian-unsigned-integer>;
                       3 => <null-frame>;
                     end;

Extending binary-data
=====================

Adding a New Leaf Frame Type
----------------------------

...
