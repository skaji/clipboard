package ClipBoard::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;

get '/' => sub {
    my ($c) = @_;
    my $user = $c->user
        or return $c->render_text(500, "ooops missing user");
    my @clip = $c->db->search('clip', {user_id => $user->id});
    @clip = map {+{
        id         => $_->id,
        user_name  => $_->fetch_user->name,
        content    => $_->content,
        created_at => $_->created_at_obj->strftime("%F %T"),
    }} @clip;

    return $c->render('index.tx', {clip => \@clip});
};

post '/reset' => sub {
    my $c = shift;
    my $user = $c->user
        or return $c->render_text(500, "ooops missing user");
    my $count = $c->db->delete('clip', { user_id => $user->id });
    $c->redirect('/');
};

post 'pbcopy' => sub {
    my $c = shift;
    my $user = $c->user
        or return $c->render_text(500, "ooops missing user");

    my $content = $c->req->content;
    chomp $content;
    $c->db->insert('clip', {user_id => $user->id, content => $content, created_at => time});
    $c->render_text(200, "ok\n");
};

get 'pbpaste' => sub {
    my $c = shift;
    my $user = $c->user
        or return $c->render_text(500, "ooops missing user");
    my $clip = $c->db->single('clip', { user_id => $user->id }, { order_by => 'created_at DESC' })
        or return $c->render_text(404, 'oops missing content');
    $c->render_text($clip->content);
};

1;
