use strict;
use warnings;
# use Module::Starter;

# module-starter --module=COMEDY::DB --author="Johnathan Mullins" --email=johnathan.mullins@gmail.com

use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';

use COMEDY::DB;

my $db1 = COMEDY::DB->new( { 'name' => 'test db1' } );
my $db2 = COMEDY::DB->new( { 'name' => 'test db2', 'input_file' => 'sample.xml' } );
print test('test');
print "\n";
print $db2->get_name();
print "\n";

my $added = $db1->add_joke({'text' => 'test'});
my $added2 = $db1->add_joke({'text' => 'test2'});
my $ret1 = $db1->export_to_file('test1.xml', 'pretty');
my $ret2 = $db2->export_to_file('test.xml');

# my $ret2 = $db2->export_to_file('test.xml');
print "$ret1\n";
print "$ret2\n";