package ClipBoard::Web;
use strict;
use warnings;
use utf8;
use parent qw/ClipBoard Amon2::Web/;
use File::Spec;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);

# dispatcher
use ClipBoard::Web::Dispatcher;
sub dispatch {
    return (ClipBoard::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::JSON',
    '+ClipBoard::Web::Plugin::Session',
);

# setup view
use ClipBoard::Web::View;
{
    sub create_view {
        my $view = ClipBoard::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *ClipBoard::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

sub user {
    my $c = shift;
    my $user = $c->db->single('user', {name => $c->req->user || ''});
    return $user ? $user : undef;
}

sub render_text {
    my $c = shift;
    my ($code, $body) = @_ == 2 ? @_ : (200, $_[0]);
    my $res = $c->create_response($code);
    $res->content_type('text/plain; charset=utf-8');
    $res->content_length(length $body);
    $res->body($body);
    $res;
}

sub unauthorized {
    my $self = shift;
    my $res  = $self->render_text(401, 'Authorization required');
    $res->header('WWW-Authenticate' => 'Basic realm="restricted area"');
    $res;
}
sub authenticate {
    my ($self, $user, $pass) = @_;
    my $try = $self->db->single('user' => {name => $user}) or return;
    return $try->pass eq md5_hex( "$user$pass" );
}

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my $c = shift;
        my $auth = $c->req->env->{HTTP_AUTHORIZATION}
            or return $c->unauthorized;
        if ($auth =~ /^Basic (.*)$/i) {
            my($user, $pass) = split /:/, (MIME::Base64::decode($1) || ":"), 2;
            $pass = '' unless defined $pass;
            if ($c->authenticate($user, $pass)) {
                $c->req->env->{REMOTE_USER} = $user;
                return 1;
            }
        }
        return $c->unauthorized;
    },
);


# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

1;
