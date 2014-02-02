package ClipBoard::DB::Schema;
use strict;
use warnings;
use utf8;

use Teng::Schema::Declare;


table {
    name 'user';
    pk 'id';
    columns qw(id name pass);
    row_class 'ClipBoard::DB::Row::User';
};

table {
    name 'clip';
    pk 'id';
    columns qw(id user_id created_at content);
    row_class 'ClipBoard::DB::Row::Clip';
};

1;
