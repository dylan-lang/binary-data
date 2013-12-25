Reference
*********

.. current-library:: binary-data
.. current-module:: binary-data

The BINARY-DATA module
======================

.. class:: <1bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <2bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <2byte-big-endian-unsigned-integer>

   :superclasses: :class:`<big-endian-unsigned-integer-byte-frame>`

   :keyword data:

.. class:: <2byte-little-endian-unsigned-integer>

   :superclasses: :class:`<little-endian-unsigned-integer-byte-frame>`

   :keyword data:

.. class:: <3bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <3byte-big-endian-unsigned-integer>

   :superclasses: :class:`<big-endian-unsigned-integer-byte-frame>`

   :keyword data:

.. class:: <3byte-little-endian-unsigned-integer>

   :superclasses: :class:`<little-endian-unsigned-integer-byte-frame>`

   :keyword data:

.. class:: <4bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <5bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <6bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <7bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <9bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <10bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <11bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <12bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <13bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <14bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <15bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <20bit-unsigned-integer>

   :superclasses: :class:`<unsigned-integer-bit-frame>`

   :keyword data:

.. class:: <big-endian-unsigned-integer-4byte>

   :superclasses: :class:`<fixed-size-byte-vector-frame>`


.. class:: <boolean-bit>

   :superclasses: :class:`<fixed-size-translated-leaf-frame>`


.. class:: <container-frame>
   :open:
   :abstract:

   :superclasses: :class:`<variable-size-untranslated-frame>`


.. class:: <externally-delimited-string>

   :superclasses: :class:`<variable-size-byte-vector>`


.. class:: <field>
   :abstract:

   :superclasses: :drm:`<object>`

   :keyword dynamic-end:
   :keyword dynamic-length:
   :keyword dynamic-start:
   :keyword fixup:
   :keyword getter:
   :keyword index:
   :keyword init-value:
   :keyword name:
   :keyword setter:
   :keyword static-end:
   :keyword static-length:
   :keyword static-start:

.. class:: <fixed-size-byte-vector-frame>
   :open:
   :abstract:

   :superclasses: :class:`<fixed-size-untranslated-leaf-frame>`

   :keyword data:

.. class:: <fixed-size-translated-leaf-frame>
   :open:
   :abstract:

   :superclasses: :class:`<leaf-frame>`, :class:`<fixed-size-frame>`, :class:`<translated-frame>`


.. class:: <frame>
   :abstract:

   :superclasses: :drm:`<object>`


.. class:: <header-frame>
   :open:
   :abstract:

   :superclasses: :class:`<container-frame>`


.. class:: <leaf-frame>
   :abstract:

   :superclasses: :class:`<frame>`


.. class:: <little-endian-unsigned-integer-4byte>

   :superclasses: :class:`<fixed-size-byte-vector-frame>`


.. class:: <malformed-data-error>

   :superclasses: :drm:`<error>`


.. class:: <stretchy-byte-vector-subsequence>

   :superclasses: :class:`<stretchy-vector-subsequence>`


.. class:: <stretchy-vector-subsequence>
   :abstract:

   :superclasses: :class:`<vector>`

   :keyword data:
   :keyword end:
   :keyword start:

.. class:: <unsigned-byte>

   :superclasses: :class:`<fixed-size-translated-leaf-frame>`


.. class:: <variable-size-byte-vector>
   :abstract:

   :superclasses: :class:`<variable-size-untranslated-leaf-frame>`

   :keyword data:
   :keyword parent:

.. class:: <variably-typed-container-frame>
   :open:
   :abstract:

   :superclasses: :class:`<container-frame>`


.. generic-function:: assemble-frame

   :signature: assemble-frame (frame) => (packet)

   :parameter frame: An instance of :class:`<frame>`.
   :value packet: An instance of ``<object>``.

.. generic-function:: assemble-frame!

   :signature: assemble-frame! (frame) => (#rest results)

   :parameter frame: An instance of :class:`<frame>`.
   :value #rest results: An instance of ``<object>``.

.. generic-function:: assemble-frame-as

   :signature: assemble-frame-as (frame-type data) => (packet)

   :parameter frame-type: An instance of ``subclass(<frame>)``.
   :parameter data: An instance of ``<object>``.
   :value packet: An instance of ``<object>``.

.. generic-function:: assemble-frame-into
   :open:

   :signature: assemble-frame-into (frame packet) => (length)

   :parameter frame: An instance of :class:`<frame>`.
   :parameter packet: An instance of :class:`<stretchy-vector-subsequence>`.
   :value length: An instance of :drm:`<integer>`.

.. generic-function:: big-endian-unsigned-integer-4byte

   :signature: big-endian-unsigned-integer-4byte (data) => (#rest results)

   :parameter data: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. function:: bit-offset

   :signature: bit-offset (offset) => (res)

   :parameter offset: An instance of ``<integer>``.
   :value res: An instance of ``<integer>``.

.. function:: byte-aligned

   :signature: byte-aligned (offset) => (#rest results)

   :parameter offset: An instance of ``<integer>``.
   :value #rest results: An instance of ``<object>``.

.. function:: byte-offset

   :signature: byte-offset (offset) => (res)

   :parameter offset: An instance of ``<integer>``.
   :value res: An instance of ``<integer>``.

.. function:: byte-vector-to-float-be

   :signature: byte-vector-to-float-be (bv) => (res)

   :parameter bv: An instance of ``<stretchy-byte-vector-subsequence>``.
   :value res: An instance of ``<float>``.

.. function:: byte-vector-to-float-le

   :signature: byte-vector-to-float-le (bv) => (res)

   :parameter bv: An instance of ``<stretchy-byte-vector-subsequence>``.
   :value res: An instance of ``<float>``.

.. generic-function:: container-frame-size
   :open:

   :signature: container-frame-size (frame) => (length)

   :parameter frame: An instance of ``<container-frame>``.
   :value length: An instance of ``false-or(<integer>)``.

.. generic-function:: copy-frame

   :signature: copy-frame (frame) => (#rest results)

   :parameter frame: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. generic-function:: data

   :signature: data (object) => (#rest results)

   :parameter object: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

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

.. generic-function:: field-size
   :open:

   :signature: field-size (frame) => (length)

   :parameter frame: An instance of ``subclass(<frame>)``.
   :value length: An instance of ``<number>``.

.. function:: float-to-byte-vector-be

   :signature: float-to-byte-vector-be (float) => (res)

   :parameter float: An instance of ``<float>``.
   :value res: An instance of ``<byte-vector>``.

.. function:: float-to-byte-vector-le

   :signature: float-to-byte-vector-le (float) => (res)

   :parameter float: An instance of ``<float>``.
   :value res: An instance of ``<byte-vector>``.

.. generic-function:: frame-name
   :open:

   :signature: frame-name (frame) => (res)

   :parameter frame: An instance of ``type-union(subclass(<container-frame>), <container-frame>)``.
   :value res: An instance of ``<string>``.

.. generic-function:: frame-size
   :open:

   :signature: frame-size (frame) => (length)

   :parameter frame: An instance of ``type-union(<frame>, subclass(<fixed-size-frame>))``.
   :value length: An instance of ``<integer>``.

.. generic-function:: hexdump

   :signature: hexdump (stream sequence) => (#rest results)

   :parameter stream: An instance of ``<object>``.
   :parameter sequence: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. generic-function:: high-level-type
   :open:

   :signature: high-level-type (low-level-type) => (res)

   :parameter low-level-type: An instance of ``subclass(<frame>)``.
   :value res: An instance of ``<type>``.

.. generic-function:: little-endian-unsigned-integer-4byte

   :signature: little-endian-unsigned-integer-4byte (data) => (#rest results)

   :parameter data: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. generic-function:: parse-frame
   :open:

   :signature: parse-frame (frame-type packet #rest rest #key #all-keys) => (#rest results)

   :parameter frame-type: An instance of ``subclass(<frame>)``.
   :parameter packet: An instance of ``<sequence>``.
   :parameter #rest rest: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. function:: payload-type

   :signature: payload-type (frame) => (res)

   :parameter frame: An instance of :class:`<container-frame>`.
   :value res: An instance of ``<type>``.

.. generic-function:: read-frame
   :open:

   :signature: read-frame (frame-type string) => (frame)

   :parameter frame-type: An instance of ``subclass(<leaf-frame>)``.
   :parameter string: An instance of ``<string>``.
   :value frame: An instance of ``<object>``.

.. generic-function:: subsequence

   :signature: subsequence (seq) => (#rest results)

   :parameter seq: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

.. generic-function:: summary
   :open:

   :signature: summary (frame) => (summary)

   :parameter frame: An instance of :class:`<frame>`.
   :value summary: An instance of :drm:`<string>`.
