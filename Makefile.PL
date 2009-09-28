use inc::Module::Install;

name 'Net-Zuora';
all_from 'lib/Net-Zuora.pm';

build_requires 'Catalyst::Runtime';
build_requires 'Test::WWW::Mechanize::Catalyst';
build_requires 'Test::More';
build_requires 'ok';

WriteAll();
