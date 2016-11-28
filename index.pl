#!C:/Perl64/bin/perl

use strict;
use warnings;

use Penguin::Avatar;
use CGI;
use CGI::Carp 'fatalsToBrowser';

my $resHTML = CGI->new;
my $intDefaultSize = 300;

if ($resHTML->param('items')) {
    my $strItems = $resHTML->param('items');
    my $intSize = $resHTML->param('size');
    my $resAvatar = Avatar->new("http://mobcdn.clubpenguin.com/game/items/images/paper/image/");
    $resAvatar->constructAvatar($strItems, ($intSize ? $intSize : $intDefaultSize));
}

1;
