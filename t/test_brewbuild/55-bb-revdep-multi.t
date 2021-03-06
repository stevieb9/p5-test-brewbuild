#!/usr/bin/perl
use strict;
use warnings;

use Archive::Extract;
use File::Path qw(remove_tree);
use Test::BrewBuild;
use Test::More;

if (! $ENV{BBDEV_TESTING}){
    plan skip_all => "developer tests only";
    exit;
}

my $dir = 'Mock-Sub-1.06';

{ # revdep single

    $ENV{BBDEV_TESTING} = 0;
    
    my $ae = Archive::Extract->new(archive => 't/modules/mock-sub.tgz');
    $ae->extract(to => '.');

    my $ver = $^O =~ /MSWin/ ? '5.18.4_64' : '5.18.4';

    chdir $dir;
    `brewbuild -r`;
    my $ret = `brewbuild --install $ver --revdep --selftest`;
    chdir '..';

    my @res = split /\n/, $ret;
    @res = grep /\S/, @res;

    print "*$_*\n" for @res;

    if ($^O =~ /MSWin/){
        is (@res > 10, 1, "proper result count");
        like ($res[0], qr/- installing/, "first line is installing");
        like ($res[1], qr/reverse dependencies/, "deps we're working on" );
        like ($res[2], qr/\w+::\w+/, "is a module name");
        like ($res[3], qr/:: \w+/, "is a valid result");
        like ($res[4], qr/:: \w+/, "is a valid result");
        like ($res[5], qr/\w+::\w+/, "is a module name");
        like ($res[6], qr/:: \w+/, "is a valid result");
        like ($res[7], qr/:: \w+/, "is a valid result");
        like ($res[8], qr/\w+::\w+/, "is a module name");
        like ($res[9], qr/:: \w+/, "is a valid result");
        like ($res[10], qr/:: \w+/, "is a valid result");
    }
    else {
        is (@res > 10, 1, "proper result count");
        like ($res[0], qr/- installing/, "installing...");
        like ($res[1], qr/reverse dependencies/, "deps we're operating on" );
        like ($res[2], qr/\w+::\w+/, "is a module name");
        like ($res[3], qr/:: \w+/, "is a valid result");
        like ($res[4], qr/:: \w+/, "is a valid result");
        like ($res[5], qr/\w+::\w+/, "is a module name");
        like ($res[6], qr/:: \w+/, "is a valid result");
        like ($res[7], qr/:: \w+/, "is a valid result");
        like ($res[8], qr/\w+::\w+/, "is a module name");
        like ($res[9], qr/:: \w+/, "is a valid result");
        like ($res[10], qr/:: \w+/, "is a valid result");
    }

    remove_tree($dir);
    is (-d $dir, undef, "$dir removed ok");

    $ENV{BBDEV_TESTING} = 1;
}

done_testing();

