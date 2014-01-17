module: binary-data
author: Andreas Bogk and Hannes Mehnert
copyright: 2005-2011 Andreas Bogk and Hannes Mehnert. All rights reserved.
license: see LICENSE.txt in this distribution

define class <unknown-at-compile-time> (<number>)
end;

define constant $unknown-at-compile-time = make(<unknown-at-compile-time>);

define constant <integer-or-unknown> =
  type-union(<integer>, singleton($unknown-at-compile-time));

define sealed domain \+ (<integer>, <unknown-at-compile-time>);
define sealed domain \+ (<unknown-at-compile-time>, <integer>);
define sealed domain \+ (<unknown-at-compile-time>, <unknown-at-compile-time>);

define method \+ (a :: <integer>, b :: <unknown-at-compile-time>)
 => (res :: singleton($unknown-at-compile-time))
  $unknown-at-compile-time
end;

define method \+ (a :: <unknown-at-compile-time>, b :: <integer>)
 => (res :: singleton($unknown-at-compile-time))
  $unknown-at-compile-time
end;

define method \+ (a :: <unknown-at-compile-time>, b :: <unknown-at-compile-time>)
 => (res :: singleton($unknown-at-compile-time))
  $unknown-at-compile-time
end;
