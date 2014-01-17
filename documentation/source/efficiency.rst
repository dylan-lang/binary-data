Efficiency
**********

.. current-library:: binary-data
.. current-module:: binary-data

.. contents::
   :local:

Considerations
==============

The design goal is, as usual in object-centered programming, that the
time and space overhead are minimal (the compiler should remove all
the indirections!).

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
known at compile time. Accessing the ``payload`` is an subsequence
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


