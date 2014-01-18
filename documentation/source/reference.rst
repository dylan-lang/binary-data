API Reference
*************

.. current-library:: binary-data
.. current-module:: binary-data

Overview
========

This describes the API available from binary-data. It is organized in
the following sections, depending on different demands: using binary
data in a tool, extending with a custom binary format, and the
internal API.

Class hierarchy
===============

The class hierarchy is rooted in ``<frame>``. Several direct
subclasses exist, some are ``open`` and may be subclassed. Only those
combinations of direct subclasses which were needed until now are
defined (there might be need for other combinations in the future).

.. class:: <frame>
   :abstract:

   :description:

     The abstract superclass of all frames, several generic functions
     are defined on this class.

   :superclasses: :drm:`<object>`

   :operations:

      - :gf:`parse-frame`
      - :gf:`assemble-frame`
      - :gf:`summary`

.. class:: <leaf-frame>
   :abstract:

   :description:

      The abstract superclass of all frames without any further structure.

   :superclasses: :class:`<frame>`

   :operations:

      - :gf:`read-frame`

.. class:: <fixed-size-frame>
   :abstract:

   :description:

      The abstract superclass of all frames with a static length. The
      specialization of :gf:`frame-size` calls :gf:`field-size` on the
      object class of the given instance.

   :superclasses: :class:`<frame>`

.. class:: <variable-size-frame>
   :abstract:

   :description:

      The abstract superclass of all frames with a variable length.

   :superclasses: :class:`<frame>`

.. class:: <translated-frame>
   :abstract:

   :description:

      The abstract superclass of all frames with a conversion into a
      native Dylan type.

   :superclasses: :class:`<frame>`


.. class:: <untranslated-frame>
   :abstract:

   :description:

      Abstract superclass of all frames with a custom class instance.

   :superclasses: :class:`<frame>`


.. class:: <fixed-size-untranslated-frame>
   :abstract:

   :description:

      Abstract superclass for fixed sized frames without a translation

   :superclasses: :class:`<fixed-size-frame>`, :class:`<untranslated-frame>`

.. class:: <variable-size-untranslated-frame>
   :abstract:

   :description:

      Abstract superclass for variable sized frames without a
      translation. This is the direct superclass of
      :class:`<container-frame>`.

   :superclasses: :class:`<variable-size-frame>`, :class:`<untranslated-frame>`


.. class:: <fixed-size-translated-leaf-frame>
   :abstract:
   :open:

   :description:

      Superclass of all fixed size leaf frames with a translation,
      mainly used for bit vectors represented as Dylan :drm:`<integer>`

   :superclasses: :class:`<leaf-frame>`, :class:`<fixed-size-frame>`, :class:`<translated-frame>`


.. class:: <variable-size-translated-leaf-frame>
   :abstract:
   :open:

   :description:

      Superclass of all variable size leaf frames with a translation
      (currently unused)

   :superclasses: :class:`<leaf-frame>`, :class:`<variable-size-frame>`, :class:`<translated-frame>`

.. class:: <fixed-size-untranslated-leaf-frame>
   :abstract:
   :open:

   :description:

      Superclass of all fixed size leaf frames without a translation,
      mainly used for byte vectors (IP addresses, MAC address, ...),
      see its subclass :class:`<fixed-size-byte-vector-frame>`.

   :superclasses: :class:`<leaf-frame>`, :class:`<fixed-size-untranslated-frame>`


.. class:: <variable-size-untranslated-leaf-frame>
   :abstract:
   :open:

   :description:

      Superclass of all variable size leaf frames without a
      translation (for example class :class:`<raw-frame>` and class
      :class:`<externally-delimited-string>`)

   :superclasses: :class:`<leaf-frame>`, :class:`<variable-size-untranslated-frame>`

.. class:: <container-frame>
   :abstract:
   :open:

   Superclass of all binary data definitions using the :macro:`define
   binary-data` macro.

   :superclasses: :class:`<variable-size-untranslated-frame>`

   :operations:

      - :gf:`frame-name`
      - :gf:`fields`
      - :gf:`field-count`
      - :gf:`packet`

.. class:: <header-frame>
   :open:
   :abstract:

   Superclass of all binary data definitions which support layering,
   thus have a header and payload.

   :superclasses: :class:`<container-frame>`

.. class:: <variably-typed-container-frame>
   :open:
   :abstract:

   Superclass of all binary data definitions which have an abstract
   header followed by more fields. In the header a specific
   :class:`<layering-field>` determines which subclass to instantiate.

   :superclasses: :class:`<container-frame>`


Tool API
========

Parsing Frames
--------------

.. generic-function:: parse-frame
   :open:

   Parses the given binary packet as frame-type, resulting in an
   instance of the frame-type and the number of consumed bits.

   :signature: parse-frame *frame-type* *packet* #rest *rest* #key #all-keys => *result* *consumed-bits*

   :parameter frame-type: Any subclass of ``<frame>``.
   :parameter packet: The byte vector as ``<sequence>``.
   :parameter #rest rest: An instance of ``<object>``.
   :value result: An instance of the given frame-type.
   :value consumed-bits: The number of bits consumed as ``<integer>``

.. generic-function:: read-frame
   :open:

   Converts a given string to an instance of the given leaf frame type.

   :signature: read-frame *frame-type* *string* => *frame*

   :parameter frame-type: An instance of ``subclass(<leaf-frame>)``.
   :parameter string: An instance of ``<string>``.
   :value frame: An instance of ``<object>``.

Assembling Frames
-----------------

.. generic-function:: assemble-frame

   Produces a binary vector representing this frame. All field fixup
   functions are called.

   :signature: assemble-frame *frame* => *packet*

   :parameter frame: An instance of :class:`<frame>`.
   :value packet: An instance of ``<object>``.

Information about Frames
------------------------

.. generic-function:: frame-size
   :open:

   Returns the length in bits for the given frame.

   :signature: frame-size *frame* => *length*

   :parameter frame: An instance of ``<frame>``.
   :value length: The size in bits, an instance of ``<integer>``.

.. generic-function:: summary
   :open:

   Returns a human-readable customizable (in binary-data-definer)
   string, which summarizes the frame.

   :signature: summary *frame* => *summary*

   :parameter frame: An instance of :class:`<frame>`.
   :value summary: An instance of :drm:`<string>`.

.. generic-function:: packet
   :open:

   Underlying byte vector of the given :class:`<container-frame>`.

   :signature: packet *frame* => *byte-vector*

   :parameter frame: An instance of :class:`<container-frame>`.
   :value byte-vector: An instance of :class:`<byte-sequence>`.

.. generic-function:: parent
   :sealed:

   If the frame is a payload of another layer, returns the frame of
   the upper layer, false otherwise.

   :signature: parent *frame* => *parent-frame*

   :parameter frame: An instance of :class:`<container-frame>` or :class:`<variable-size-byte-vector-frame>`
   :value parent-frame: Either the :class:`<container-frame>` of the upper layer or ``#f``

Information about Frame Types
-----------------------------

.. generic-function:: fields
   :open:

   Returns a vector of :class:`<field>` for the given :class:`<container-frame>`

   :signature: fields *frame-type* => *fields*

   :parameter frame-type: Any subclass of :class:`<container-frame>`.
   :value fields: A :drm:`<simple-vector>` containing all fields.

.. note:: Current API also allows instances of ``<container-frame>``, should be revised

.. generic-function:: frame-name
   :open:

   Returns the name of the frame type.

   :signature: frame-name *frame-type* => *name*

   :parameter frame-type: Any subclass of :class:`<container-frame>`.
   :value name: A :drm:`<string>` with the human-readable frame name.

.. note:: Current API also allows instances of ``<container-frame>``, should be revised

Fields
------

Syntactic sugar in the :macro:`define binary-data` domain-specific
language instantiates these fields.

.. class:: <field>
   :abstract:

   The abstract superclass of all fields.

   :superclasses: :drm:`<object>`

   :keyword name: The name of this field.
   :keyword fixup: A unary Dylan function computing the value of this field, used if no default is supplied and none provided by the client, defaults to ``#f``.
   :keyword init-value: The default value if the client did not provide any, default :drm:`$unsupplied`.
   :keyword static-end: A Dylan expression determining the end, defaults to :const:`$unknown-at-compile-time`.
   :keyword static-length: A Dylan expression determining the length, defaults to :const:`$unknown-at-compile-time`.
   :keyword static-start: A Dylan expression determining the start, defaults to :const:`$unknown-at-compile-time`.
   :keyword dynamic-end: A unary Dylan function computing the end, defaults to ``#f``.
   :keyword dynamic-length: A unary Dylan function computing the length, defaults to ``#f``.
   :keyword dynamic-start: A unary Dylan function computing the start, defaults to ``#f``.
   :keyword getter: The getter method to extract this fields value out of a concrete frame.
   :keyword setter: The setter method to set this fields to a concrete value in a concrete frame.
   :keyword index: An :drm:`<integer>` which is an index of this field in its :class:`<container-frame>`.

   :description:

      All keyword arguments correspond to a slot, which can be
      accessed.

   :operations:

      - :meth:`field-name(<field>)`
      - :meth:`fixup-function(<field>)`
      - :meth:`init-value(<field>)`
      - :meth:`static-start(<field>)`
      - :meth:`static-length(<field>)`
      - :meth:`static-end(<field>)`
      - :meth:`getter(<field>)`
      - :meth:`setter(<field>)`

   See also

   * :macro:`define binary-data`
   * :gf:`fields`

.. class:: <variably-typed-field>

   The class for fields of dynamic type.

   :superclasses: :class:`<field>`

   :keyword type-function: A unary Dylan function computing the type.

   See also

   * :func:`payload-type`
   * :gf:`lookup-layer`
   * :gf:`reverse-lookup-layer`

.. class:: <statically-typed-field>
   :abstract:

   The abstract superclass of all statically typed fields.

   :superclasses: :class:`<field>`

   :keyword type: The static type, a subclass of :class:`<frame>`.

   :operations:

      - :meth:`type(<statically-typed-field>)`

.. note:: restrict type in source code!

.. class:: <single-field>

   The common field. Nothing interesting going on here.

   :superclasses: :class:`<statically-typed-field>`

.. class:: <enum-field>

   An enumeration field to map :drm:`<integer>` to :drm:`<symbol>`.

   :superclasses: :class:`<single-field>`

   :keyword mapping: A mapping from keys to values as :drm:`<collection>`.

.. class:: <layering-field>

   The layering field is used in :class:`<header-frame>` and
   :class:`<variably-typed-container-frame>` to determine the concrete
   type of the payload or which subclass to use.

   :superclasses: :class:`<single-field>`

   :description:

   The ``fixup-function`` slot is bound to :gf:`fixup-protocol-magic`.

.. class:: <repeated-field>
   :abstract:

   Abstract superclass of repeated fields. The ``init-value`` slot is
   bound to ``#()``.

   :superclasses: :class:`<statically-typed-field>`

.. class:: <count-repeated-field>

   A repeated field which number of repetitions is determined
   externally.

   :superclasses: :class:`<repeated-field>`

   :keyword count: A unary function returning the number of occurences.

.. class:: <self-delimited-repeated-field>

   A repeated field which end is determined internally.

   :superclasses: :class:`<repeated-field>`

   :keyword reached-end?: A unary function returning a :drm:`<boolean>`.


Layering of frames
------------------

.. function:: payload-type

   The type of the payload, It is just a wrapper around
   :gf:`lookup-layer`, which returns :class:`<raw-frame>` if
   ``lookup-layer`` returned false.

   :signature: payload-type *frame* => *payload-type*

   :parameter frame: An instance of :class:`<container-frame>`.
   :value payload-type: An instance of ``<type>``.


.. generic-function:: lookup-layer
   :open:

   Given a frame type and a key, returns the type of the payload.

   :signature: lookup-layer *frame-type* *key* => *payload-type*

   :parameter frame-type: Any subclass of ``<frame>``.
   :parameter key: Any ``<integer>``.
   :value payload-type: The resulting type, an instance of ``false-or(<class>)``.

.. generic-function:: reverse-lookup-layer



.. note:: Check whether it only works with integers, or any type


Database of Binary Data Formats
-------------------------------

.. note:: Rename to ``$binary-data-registry`` or similar. Also, narrow types for the functions in this section.

.. constant:: $protocols

   A hash table with all defined binary formats. Insertion is done by
   a call of :macro:`define binary-data`.

   :type: :drm:`<table>`
   :value: Mapping of :drm:`<symbol>` to subclasses of :class:`<container-frame>`.

.. function:: find-protocol

   Looks for the given name in the hashtable
   :const:`$protocols`. Signals an error if no protocol with the given
   name can be found.

   :signature: find-protocol *frame-name* => *frame-type* *frame-name*

   :parameter frame-name: An instance of :drm:`<string>`.
   :value frame-type: The frame type for the requested frame name, an instance of :drm:`<class>`.
   :value frame-name: The name under which the frame is known in the registry, an instance of :drm:`<string>`.

.. function:: find-protocol-field

   Queries a field by name in a given binary data format. Errors if no
   such field is known in the binary data format.

   :signature: find-protocol-field *frame-type* *field-name* => *field*

   :parameter frame-type: The type of a frame, an instance of :drm:`<class>`.
   :parameter field-name: The name of a field, an instance of :drm:`<string>`.
   :value field: An instance of :class:`<field>`.


Utilities
---------

.. generic-function:: hexdump

   Prints the given *data* in hexadecimal on the given *stream*.

   :signature: hexdump *stream* *data* => ()

   :parameter stream: An instance of ``<stream>``.
   :parameter data: An instance of ``<sequence>``.

   :description:

      Prints 8 bytes separated by a whitespace in hexadecimal,
      followed by two whitespaces, and another 8 bytes.

      If the given *data* has more than 16 elements, it prints
      multiple lines, and prefix each with a line number (as 16 bit
      hexadecimal).

.. function:: byte-offset

   Computes the number of bytes for a given number of bits. A synonym
   for ``rcurry(ash, 3)``.

   :signature: byte-offset *bits* => *bytes*

   :parameter bits: An :drm:`<integer>`.
   :value bytes: An :drm:`<integer>`.

.. function:: bit-offset

   Computes the number of bits which do not fit into a byte for a
   given number of bits. A synonym for ``curry(logand, 7)``.

   :signature: bit-offset *bits* => *bits-not-in-byte*

   :parameter bits: An :drm:`<integer>`.
   :value bits-not-in-byte: An :drm:`<integer>` between 0 and 7.

.. function:: byte-aligned

   Checks that the given number of bits can be represented in full
   bytes, otherwise signals an :class:`<alignment-error>`.

   :signature: byte-aligned *bits*

   :parameter bits: An instance of ``<integer>``.

.. generic-function:: data

   Returns the underlying byte vector of a wrapper object, used for
   several untranslated leaf frames.

   :signature: data (object) => (#rest results)

   :parameter object: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. note:: should be removed from the API, or become internal

Errors
------

.. class:: <out-of-bound-error>

   :superclasses: :drm:`<error>`

.. class:: <out-of-range-error>

   :superclasses: :drm:`<error>`

.. class:: <malformed-data-error>

   :superclasses: :drm:`<error>`

.. class:: <parse-error>

   :superclasses: :drm:`<error>`

.. class:: <inline-layering-error>

   :superclasses: :drm:`<error>`

.. class:: <missing-inline-layering-error>

   :superclasses: :drm:`<error>`


Extension API
=============

Extending Binary Data Formats
-----------------------------

This domain-specific language defines a subclass of
:class:`<container-frame>`, and all required boilerplate.

.. macro:: define binary-data
   :defining:

   :macrocall:
      .. code-block:: dylan

         define [abstract] binary-data *binary-format-name* ([*super-binary-format*])
           [summary *summary*] [;]
           [over *over-spec* *] [;]
           [length *length-expression*] [;]
           [*field-spec*] [;]
         end

   :parameter binary-format-name: The name of the defined class will surrounded by angle brackets.
   :parameter super-binary-format: The superprotocol name without surrounding angle brackets.
   :parameter summary: A Dylan expression consisting of a format-string and a list of arguments.
   :parameter over-spec: A pair of binary format and value.
   :parameter length-expression: A Dylan expression computing the length of a frame instance.
   :parameter field-spec: A list of fields for this binary format.


   :description:

      Defines the binary data class *binary-data-name*, which is a
      subclass of *super-binary-format*. In the body some syntactic
      sugar for specializing the pretty printer (*summary* specializes
      :gf:`summary`), providing a custom length implementation
      (*length* specializes :gf:`container-frame-size`), and provide
      binary format layering information via *over-spec*
      (:class:`<layering-field>`). The remaining body is a list of
      *field-spec*. Each *field-spec* line corresponds to a slot in
      the defined class. Additionally, each *field-spec* instantiates
      an object of :class:`<field>` to store the static metadata. The
      vector of fields is available via the method :gf:`fields`.

      .. code-block:: dylan

         summary: *format-string* *format-arguments*

      This generates a method implementation for :gf:`summary`. Each
      *format-arguments* is applied to the frame instance.

      .. code-block:: dylan

         over-spec: *over-binary-format* *layering-value*

      The *over-binary-format* should be a subclass of
      :class:`<header-frame>` or
      :class:`<variably-typed-container-frame>`. The *layering-value*
      will be registered for the specified *over-binary-format*.


      .. code-block:: dylan

         field-spec: [*field-attribute*] field *field-name* [:: *field-type*] [= *default-value*], [*keyword-arguments* *] [;]

         field-attribute: variably-typed | layering | repeated | enum

         mapping: { *key* <=> *value* }

      * *field-name*: Each field has a unique *field-name*, which is used as name for the getter and setter methods
      * *field-type*: The *field-type* can be any subclass of :class:`<frame>`, required unless ``variably-typed`` attribute provided.
      * *default-value*: The *default-value* should be an instance of the given *field-type*.
      * *field-attribute*: Syntactic sugar for some common patterns is available via attributes.

        - ``variably-typed`` instantiates a :class:`<variably-typed-field>`.
        - ``layering`` instantiates a :class:`<layering-field>`.
        - ``repeated`` instantiates a :class:`<repeated-field>`.
        - ``enum`` instantiates a :class:`<enum-field>`.

      * *keyword-arguments*: Depending on the field type, various keywords are supported. Lots of values are standard Dylan expressions, where the current frame object is implicitly bound to ``frame``, indicated by *frame-expression*.

        - fixup: A *frame-expression* computing the field value if no default was supplied, and the client didn't provide one (handy for length fields).
        - start: A *frame-expression* computing the start bit of the field in the frame.
        - end: A *frame-expression* computing the end bit of the field in the frame.
        - length: A *frame-expression* computing the length of the field.
        - static-start: A Dylan *expression* stating the start of the field in the frame.
        - static-end: A Dylan *expression* stating the end of the field in the frame.
        - static-length: A Dylan *expression* stating the length of the field.
        - type-function: A *frame-expression* computing the type of this :class:`<variably-typed-field>`.
        - count: A *frame-expression* computing the amount of repetitions of this :class:`<count-repeated-field>`.
        - reached-end?: A *frame-expression* returning a :drm:`<boolean>` whether this :class:`<self-delimited-repeated-field>` has reached its end.
        - mappings: A *mapping* for :class:`<enum-field>` between values and :drm:`<symbol>`

      The list of fields is instantiated once for each binary data
      definition. If a static start offset, length, and end offset can
      be trivially computed (using constant folding), this is done
      during macro processing.

.. note:: rename start, end, length to dynamic-start, dynamic-end, dynamic-length

.. note:: Check whether those field attributes compose in some way



Defining a Custom Leaf Frame
----------------------------

A common structure in binary data formats are subsequent ranges of
bits or bytes, each with a different meaning. There are some macros
available to define frame types of common patterns.

.. generic-function:: field-size
   :open:

   Returns the static size of a given frame type. Should be
   specialized for custom fixed sized frames.

   :signature: field-size *frame* => *length*

   :parameter frame: Any subclass of :class:`<frame>`.
   :value length: The bit size of the frame type :drm:`<number>`.

.. generic-function:: high-level-type
   :open:

   For translated frames, return the native Dylan type. Otherwise
   identity.

   :signature: high-level-type *frame-type* => *type*

   :parameter frame-type: An instance of ``subclass(<frame>)``.
   :value type: An instance of ``<type>``.

.. macro:: define n-bit-unsigned-integer
   :defining:

   Describes an :drm:`<integer>` represented by a bit vector of
   arbitrary size.

   :macrocall:
      .. code-block:: dylan

         define n-bit-unsigned-integer (*class-name* ; *bits* )
         end

   :parameter class-name: A Dylan class name which is defined by this macro.
   :parameter bits: The number of bits represented by this frame.

   :description:

      Defines the class *class-name* with
      :class:`<unsigned-integer-bit-frame>` as its superclass.

      Predefined are several class of the form
      ``<Kbit-unsigned-integer>`` with *K* between 1 and 15, and 20.

   :operations:

      - :gf:`high-level-type` returns ``limited(<integer>, min: 0, max: 2 ^ bits -1)``.
      - :gf:`field-size` returns *bits*.

.. macro:: define n-byte-unsigned-integer
   :defining:

   Describes an :drm:`<integer>` represented by a byte vector of
   arbitrary size and encoding (little or big endian).

   :macrocall:
      .. code-block:: dylan

         define n-byte-unsigned-integer (*class-name-prefix* ; *bytes*)
         end

   :parameter class-name-prefix: A prefix for the class name which is defined by this macro.
   :parameter bytes: The number of bytes represented by this frame.

   :description:

      Defines the classes *class-name-prefix*
      ``-big-endian-unsigned-integer>`` (superclass
      :class:`<big-endian-unsigned-integer-byte-frame>` and
      *class-name-prefix* ``-little-endian-unsigned-integer>``
      (superclass :class:`<little-endian-unsigned-integer-byte-frame>`.

      Predefined are ``<2byte-big-endian-unsigned-integer>``,
      ``<2byte-little-endian-unsigned-integer>``,
      ``<3byte-big-endian-unsigned-integer>``, and
      ``<3byte-little-endian-unsigned-integer>``.

   :operations:

      - :gf:`high-level-type` returns ``limited(<integer>, min: 0, max: 2 ^ (8 * *bytes*) - 1``.
      - :gf:`field-size` returns *bytes* * 8.


.. macro:: define n-byte-vector
   :defining:

   Defines a class with an underlying fixed size byte vector.

   :macrocall:
      .. code-block:: dylan

         define n-byte-vector (*class-name* , *bytes*)
         end

   :parameter class-name: A Dylan class name without the angle brackets, which is defined by this macro.
   :parameter bytes: The number of bytes represented by this frame.

   :description:

      Defines the class ``<`` *class-name* ``>``, as subclass of
      :class:`<fixed-size-byte-vector-frame>`. Calls
      :macro:`define leaf-frame-constructor` with the given *class-name*

   :operations:

      - :gf:`field-size` returns *bytes* * 8.

.. macro:: define leaf-frame-constructor
   :defining:

   Defines constructors for a given name.

   :macrocall:
      .. code-block:: dylan

         define leaf-frame-constructor (*constructor-name*)
         end

   :parameter constructor-name: name of the constructor.

   :description:

      Defines the generic function *constructor-name* and
      three specializations:

   :operations:

      - *constructor-name* :class:`<byte-vector>` calls :gf:`parse-frame`
      - *constructor-name* :drm:`<collection>`, converts the ``<collection>`` into a ``<byte-vector>`` and calls *constructor-name*.
      - *constructor-name* :drm:`<string>`, which calls :gf:`read-frame`.


Predefined Leaf Frames
----------------------

.. class:: <unsigned-integer-bit-frame>
   :abstract:

   The superclass of all bit frame, concrete classes are defined with
   the :macro:`define n-bit-unsigned-integer`.

   :superclasses: :class:`<fixed-size-translated-leaf-frame>`

   :operations:

      - :drm:`as` :drm:`<string>`
      - :gf:`assemble-frame`
      - :gf:`parse-frame`
      - :gf:`read-frame`

   See also

   * :macro:`define n-bit-unsigned-integer`

.. class:: <boolean-bit>

   A single bit, at the Dylan level a :drm:`<boolean>`.

   The :gf:`high-level-type` returns :drm:`<boolean>`.
   The :gf:`field-size` returns 1.

   :superclasses: :class:`<fixed-size-translated-leaf-frame>`

.. class:: <unsigned-byte>

   A single byte, represented as a :drm:`<byte>`.

   :operations:

      - :gf:`high-level-type` returns :drm:`<byte>`.
      - :gf:`field-size` returns 8.

   :superclasses: :class:`<fixed-size-translated-leaf-frame>`

.. class:: <variable-size-byte-vector>
   :abstract:

   A byte vector of arbitrary size, provided externally.

   :superclasses: :class:`<variable-size-untranslated-leaf-frame>`

.. class:: <externally-delimited-string>

   A :drm:`<string>` of a certain length, externally delimited. The
   conversion method :drm:`as` is specialised on :drm:`<string>` and
   ``<externally-delimited-string>``.

   :superclasses: :class:`<variable-size-byte-vector>`

.. note:: should be a variable-size translated leaf frame, if that is possible.

.. class:: <raw-frame>

   The bottom of the type hierarchy: if nothing is known, a
   ``<raw-frame>`` is all you can have. At least :gf:`hexdump` is
   defined on raw frames to investigate further.

   :superclasses: :class:`<variable-size-byte-vector>`

.. class:: <fixed-size-byte-vector-frame>
   :open:
   :abstract:

   A vector of any amount of bytes with a custom representation. Used
   amongst others for IP addresses, MAC addresses

   :superclasses: :class:`<fixed-size-untranslated-leaf-frame>`

   :keyword data: The underlying byte vector.

   :operations:

      - :drm:`as` :drm:`<string>`
      - :gf:`assemble-frame`
      - :gf:`parse-frame`
      - :gf:`read-frame`

   See also

   * :macro:`define n-byte-vector`

.. class:: <big-endian-unsigned-integer-byte-frame>
   :abstract:

   A frame representing a :drm:`<integer>` of a certain size,
   depending on the size of the underlyaing byte vector.

   The macro :macro:`define n-byte-unsigned-integer-definer` defines
   subclasses with a certain size.

   :superclasses: :class:`<fixed-size-translated-leaf-frame>`

   :operations:

      - :drm:`as` :drm:`<string>`
      - :gf:`assemble-frame`
      - :gf:`parse-frame`
      - :gf:`read-frame`

   See also

   * :macro:`define n-byte-unsigned-integer`
   * :class:`<little-endian-unsigned-integer-byte-frame>`

.. class:: <little-endian-unsigned-integer-byte-frame>
   :abstract:

   A frame representing a :drm:`<integer>` of a certain size,
   depending on the size of the underlyaing byte vector.

   The macro :macro:`define n-byte-unsigned-integer-definer` defines
   subclasses with a certain size.

   :superclasses: :class:`<fixed-size-translated-leaf-frame>`

   :operations:

      - :drm:`as` :drm:`<string>`
      - :gf:`assemble-frame`
      - :gf:`parse-frame`
      - :gf:`read-frame`

   See also

   * :macro:`define n-byte-unsigned-integer`
   * :class:`<big-endian-unsigned-integer-byte-frame>`

32 Bit Frames
-------------

Story is that the :drm:`<integer>` representation in Dylan is only 30
bits, thus we have some hacks around 32 bit frames which should be
represented as a :drm:`<number>`. This workaround consists of using
:class:`<fixed-size-byte-vector-frame>` and converting to
:drm:`<double-float>` values.

.. note:: This hack is awful and should be replaced by native 32 bit integers, or machine words.

.. class:: <big-endian-unsigned-integer-4byte>

   :superclasses: :class:`<fixed-size-byte-vector-frame>`


.. class:: <little-endian-unsigned-integer-4byte>

   :superclasses: :class:`<fixed-size-byte-vector-frame>`

.. generic-function:: big-endian-unsigned-integer-4byte

   :signature: big-endian-unsigned-integer-4byte (data) => (#rest results)

   :parameter data: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. generic-function:: little-endian-unsigned-integer-4byte

   :signature: little-endian-unsigned-integer-4byte (data) => (#rest results)

   :parameter data: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. function:: byte-vector-to-float-be

   :signature: byte-vector-to-float-be (bv) => (res)

   :parameter bv: An instance of ``<stretchy-byte-vector-subsequence>``.
   :value res: An instance of ``<float>``.

.. function:: byte-vector-to-float-le

   :signature: byte-vector-to-float-le (bv) => (res)

   :parameter bv: An instance of ``<stretchy-byte-vector-subsequence>``.
   :value res: An instance of ``<float>``.

.. function:: float-to-byte-vector-be

   :signature: float-to-byte-vector-be (float) => (res)

   :parameter float: An instance of ``<float>``.
   :value res: An instance of ``<byte-vector>``.

.. function:: float-to-byte-vector-le

   :signature: float-to-byte-vector-le (float) => (res)

   :parameter float: An instance of ``<float>``.
   :value res: An instance of ``<byte-vector>``.


Stretchy Vector Subsequences
============================

The underlying byte vector which is used in binary data is a
:const:`<stretchy-byte-vector>`. To allow zerocopy while parsing, and
providing each frame parser only with a byte vector of the required
size for the type, there is a :class:`<stretchy-vector-subsequence>`
which tracks the byte-vector together with a start and end index.

.. note:: Should live in a separate module and types can be narrowed a bit further.

.. constant:: <stretchy-byte-vector>

   :type: :drm:`<type>`
   :value: ``limited(<stretchy-vector>, of: <byte>)``

.. class:: <stretchy-vector-subsequence>
   :abstract:

   :superclasses: :class:`<vector>`

   :keyword data:
   :keyword end:
   :keyword start:

.. generic-function:: subsequence

   :signature: subsequence (seq) => (#rest results)

   :parameter seq: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. class:: <stretchy-byte-vector-subsequence>

   :superclasses: :class:`<stretchy-vector-subsequence>`

.. generic-function:: decode-integer

   :signature: decode-integer (seq count) => (#rest results)

   :parameter seq: An instance of ``<object>``.
   :parameter count: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. generic-function:: encode-integer

   :signature: encode-integer (value seq count) => (#rest results)

   :parameter value: An instance of ``<object>``.
   :parameter seq: An instance of ``<object>``.
   :parameter count: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.



