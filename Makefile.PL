use inc::Module::Install;
all_from 'lib/MIME/Visitor.pm';

requires 'Encode';

test_requires 'File::Temp';
test_requires 'MIME::Entity';
test_requires 'MIME::Parser';

extra_tests;

WriteAll;
