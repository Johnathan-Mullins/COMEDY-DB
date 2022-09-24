package COMEDY::DB;

require XML::Twig;
require Exporter;
@ISA = (Exporter);
@EXPORT = qw(new add_joke test get_name export_to_file);

use vars qw($VERSION $SUBVERSION $type $debug);
$VERSION = 2022.0923;
$SUBVERSION = 'modern';

use strict;

BEGIN {
	$type = 'XML';
	$debug = 0;
}

my $XML_SCHEMA = <<END_OF_SCHEMA;
<?xml version = "1.0" encoding = "UTF-8"?>
<xs:schema xmlns:xs = "http://www.w3.org/2001/XMLSchema">
   <xs:element name = "COMEDY_DB">
      <xs:complexType>
         <xs:sequence>
            <xs:element name = "Jokes">
				<xs:complexType>
					<xs:sequence>
						<xs:element name = "Joke">
						<xs:attribute name = "joke_id" type = "xs:string"/>
					</xs:sequence>
				</xs:complexType>
			  <xs:attribute name = "x" type = "y"/>
            <xs:element name = "company" type = "xs:string" />
            <xs:element name = "phone" type = "xs:int" />
         </xs:sequence>
      </xs:complexType>
   </xs:element>
</xs:schema

END_OF_SCHEMA
my $XML_head = '<?xml version = "1.0" encoding = "UTF-8" standalone = "yes" ?>';
my $ROOT_ELT = 'COMEDY_DB';
my @ELEMENTS = ['Jokes', 'Versions', 'Tags', 'Joke_Tags',];
my %JOKE = (
	# 'joke_id' => '', #pk #att
	'j_title'	=> '',
	'j_length' => 0,
	'j_times_performed' => 0,
	'j_personal_rating' => 0,
	'j_audience_rating' => 0,
	'j_edgy_rating' => 0,
	# 'text' => '',
);

my %VERSION = (
	# 'version_id' => '',#pk #att
	'v_joke_id' => '', #fk
	'v_date' => '',
	'v_text' => '',
);

my %TAG = (
	# 'tag_id' => '', #pk #att
	't_text' => '',
);

my %JOKE_TAGS = (
	# 'joke_tag_id' => '', #pk #att
	'jt_joke_id' => '', #fk
	'jt_tag_id' => '', #fk
);

my $EMPTY_DB = <<EOF;
<COMEDY_DB>
	<Jokes>
	</Jokes>
	<Versions>
	</Versions>
	<Tags>
	</Tags>
	<Joke_Tags>
	</Joke_Tags>
</COMEDY_DB>
EOF

sub new{
    my ($class,$args) = @_;
	my $name = 'undefined';
	my $twig = get_new_twig();
	my $joke_id_counter = 0;
	my $version_id_counter = 0;
	my $tag_id_counter = 0;
	my $joke_tag_id_counter = 0;
	
########################################
### Argument Handling
########################################
	#input database provided
	if((exists $args->{'input_file'}) and (-f $args->{'input_file'})){
		$twig->parsefile($args->{'input_file'});
	}
	
	#name provided
	if(exists $args->{'name'}){
		$name = $args->{'name'};
	}

########################################
### Constructor
########################################
    my $self = bless { 'name' => $args->{'name'},
						'twig' => $twig,
						'joke_id_counter' => $joke_id_counter,
						'version_id_counter' => $version_id_counter,
						'tag_id_counter' => $tag_id_counter,
						'joke_tag_id_counter' => $joke_tag_id_counter,
                     }, $class;
	return $self;
}

sub get_new_twig{
	my $twig = XML::Twig->new();
	$twig->parse($EMPTY_DB);
	return $twig;
}

sub get_name{
	my $self = shift;
	return $self->{'name'};
}

 
sub add_joke{
	my ($self, $args) = @_;
	
	my $root = $self->{'twig'}->root();
	
	if(exists $args->{'text'}){
		$args->{'v_text'} = $args->{'text'};
	}
	
	#update jokes table
	my $jokes = $root->first_child('Jokes');
	my $joke_id = 'joke_' . $self->{'joke_id_counter'}++;
	my $new_joke = get_new_joke($args);
	$new_joke->set_att('joke_id',$joke_id);
	$new_joke->paste('last_child',$jokes);
	
	#update versions table
	$args->{'v_joke_id'} = $joke_id;
	my $versions = $root->first_child('Versions');
	my $new_version = get_new_version($args);
	$new_version->set_att('version_id','version_' . $self->{'version_id_counter'}++);
	$new_version->paste('last_child',$versions);
	
	return 1;
}

sub get_new_joke{
	my ($args) = @_;
	my $new_joke = XML::Twig::Elt->new('Joke');
	foreach my $field (sort keys %JOKE){
		my $field_elt;
		if(exists $args->{$field}){
			$field_elt = XML::Twig::Elt->new($field, $args->{$field});
		}else{
			$field_elt = XML::Twig::Elt->new($field, $JOKE{$field});
		}
		$field_elt->paste('last_child',$new_joke);
	}
	return $new_joke;
}

sub get_new_version{
	my ($args) = @_;
	my $new_version = XML::Twig::Elt->new('Version');
	foreach my $field (sort keys %VERSION){
		my $field_elt;
		if(exists $args->{$field}){
			$field_elt = XML::Twig::Elt->new($field, $args->{$field});
		}else{
			$field_elt = XML::Twig::Elt->new($field, $VERSION{$field});
		}
		$field_elt->paste('last_child',$new_version);
	}
	return $new_version;
}

sub test{
	my ($input) = @_;
	return uc($input);
}

sub export_to_file{
   my ($self, $filename, $pretty) = @_;
   open(my $OUT, '>', $filename) or die "can't create $filename $!";
   
   #pretty print must be set each time, value is global
   if(defined $pretty){
	   print "$pretty\n";
		$self->{'twig'}->set_pretty_print('record');
   }else{
	   $self->{'twig'}->set_pretty_print('none'); #setting is global
   }
   
   my $ret = $self->{'twig'}->print($OUT);
   close($OUT);
   return $ret;
}


1;