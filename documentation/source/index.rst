Binary Data
===========

The binary data library provides a domain specific language for manipulation
of binary data, or structured byte sequences, as they appear in everyday
applications such as networking or graphics file manipulation. The DSL is
implemented as an extension of the Dylan language, making use of Dylan's macro
facility.

The design goals are manifold: concise expressive syntax, efficient
conversion between byte vectors and high level objects (in both
directions, by using zerocopy and lazy parsing
technology). Inspiration for this library is taken among others from
the defstorage macro (from Genera, the LISP machine) and the tool
`scapy <http://bb.secdev.org/scapy/wiki/Home>`__.

A large body of implemented binary data formats using this library can
be found at `GitHub
<https://github.com/dylan-hackers/network-night-vision/tree/master/protocols>`__.

For further information, you might want to read our published papers
about a TCP/IP stack written entirely in Dylan:

.. hlist::

   * `A domain-specific language for manipulation of binary data in Dylan <http://www.itu.dk/people/hame/ilc07-final.pdf>`__ (by Hannes Mehnert and Andreas Bogk at ILC 2007)
   * `Secure Networking <http://www.itu.dk/people/hame/secure-networking.pdf>`__ (by Andreas Bogk and Hannes Mehnert in 2006)

.. toctree::
   :maxdepth: 3

   usage
   efficiency
   reference
   internals
