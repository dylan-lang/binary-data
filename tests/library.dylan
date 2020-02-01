Module:    dylan-user
Synopsis:  Test library for binary-data
author: Andreas Bogk and Hannes Mehnert
copyright: 2005-2011 Andreas Bogk and Hannes Mehnert. All rights reserved.
license: see LICENSE.txt in this distribution

define library binary-data-test
  use common-dylan;
  use testworks;
  use binary-data;
end library binary-data-test;

define module binary-data-test
  use common-dylan;
  use binary-data, exclude: { type-code, data };
  use simple-format,
    import: { format-to-string  };
  use testworks;
end module binary-data-test;
