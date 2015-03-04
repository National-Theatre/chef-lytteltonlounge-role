name             'lytteltonlounge'
maintainer       'National Theatre'
maintainer_email 'jpdrawneek@nationaltheatre.org.uk'
license          'All rights reserved'
description      'Installs/Configures lytteltonlounge'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

%w( debian ubuntu redhat centos fedora scientific amazon windows smartos ).each do |os|
  supports os
end

recommends "iis", "> 1.0"
recommends "nginx", "> 1.0"

depends    "aws", ">= 2.5.0"