Internals
*********

.. current-library:: binary-data
.. current-module:: binary-data

.. note:: just a collection of random things.. not very useful at the moment

Internal API
============

sorted-frame-fields,
get-frame-field,
.. generic-function:: parent-setter
field-count
fields-initializer
unparsed-class
decoded-class
fixup-protocol-magic

.. generic-function:: layer-magic
   :open:

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
