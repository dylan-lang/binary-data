Binary Data
===========

The binary data library provides a domain-specific language for
manipulation of binary data, or structured byte sequences, as they
appear in everyday software such as networking tools or graphics file
manipulation. The binary data domain-specific language uses the
metaprogramming features of Dylan to a large extent.

The design goals are manifold: concise expressive syntax, efficient
conversion between byte vectors and high level objects (in both
directions, by using zerocopy and lazy parsing technology). The source
code of this library is available under a MIT license at `GitHub
<https://github.com/dylan-lang/binary-data>`__. A large body of
implemented binary data formats using this library is also available
at `GitHub
<https://github.com/dylan-hackers/network-night-vision/tree/master/protocols>`__.

Inspiration for this library is taken among others from the defstorage
system available as part of the `Genera Common Lisp operating system
<https://en.wikipedia.org/wiki/Genera_%28operating_system%29>`_ and the
swiss-army knife for interactive packet manipulation `scapy (Web archive)
<http://web.archive.org/web/20131217022133/http://bb.secdev.org/scapy/wiki/Home>`__.

For further information, you might want to read our published papers
about a TCP/IP stack written entirely in Dylan:

* :download:`A domain-specific language for manipulation of binary data in Dylan <../papers/a-DSL-for-manipulation-of-binary-data.pdf>` (by Hannes Mehnert and Andreas Bogk at ILC 2007)
* :download:`Secure Networking <../papers/secure-networking.pdf>` (by Andreas Bogk and Hannes Mehnert in 2006)

.. toctree::
   :maxdepth: 3

   usage
   reference
   internals
