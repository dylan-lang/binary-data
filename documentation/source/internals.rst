Internals
*********

.. current-library:: binary-data
.. current-module:: binary-data

Internal API
============

sorted-frame-fields,
get-frame-field,
.. generic-function:: parent-setter
field-count
fields-initializer
unparsed-class
decoded-class

.. generic-function:: layer-magic
   :open:

.. generic-function:: fixup


.. generic-function:: container-frame-size
   :open:

   :signature: container-frame-size (frame) => (length)

   :parameter frame: An instance of ``<container-frame>``.
   :value length: An instance of ``false-or(<integer>)``.


.. generic-function:: copy-frame

   :signature: copy-frame (frame) => (#rest results)

   :parameter frame: An instance of ``<object>``.
   :value #rest results: An instance of ``<object>``.

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


   * :gf:`copy-frame` returns a copy of the frame

Container Frame Internals
=========================

 Due to the two disjoint activities: parse a byte vector into a
 high-level frame, and assemble a high-level frame into a byte vector,
 there are two direct subclasses, a
 :class:`<decoded-container-frame>`, which only has the high-level
 objects, and a :class:`<unparsed-container-frame>` which keeps an
 underlying byte vector and an instance of
 :class:`<decoded-container-frame>`.

 Parsing strategy and length information (which can be contradictionary).
