package ClipBoard::DB::Row::Clip;
use strict;
use warnings;
use utf8;
use parent qw(Teng::Row);
use Time::Piece ();

sub fetch_user {
    my $self = shift;
    $self->handle->single('user', { id => $self->user_id });
}
sub created_at_obj {
    Time::Piece->new(shift->created_at);
}


1;
