package ClipBoard;
use strict;
use warnings;
use utf8;
our $VERSION='0.01';
use 5.008001;
use ClipBoard::DB::Schema;
use ClipBoard::DB;

use parent qw/Amon2/;
# Enable project local mode.
__PACKAGE__->make_local_context();

my $schema = ClipBoard::DB::Schema->instance;

sub db {
    my $c = shift;
    if (!exists $c->{db}) {
        my $conf = $c->config->{DBI}
            or die "Missing configuration about DBI";
        my $on_connect_do = ['PRAGMA foreign_keys = ON;'];
        $c->{db} = ClipBoard::DB->new(
            schema       => $schema,
            connect_info => [@$conf],
            on_connect_do => $on_connect_do,
        );
    }
    $c->{db};
}

1;
__END__

=head1 NAME

ClipBoard - ClipBoard

=head1 DESCRIPTION

This is a main context class for ClipBoard

=head1 AUTHOR

ClipBoard authors.

