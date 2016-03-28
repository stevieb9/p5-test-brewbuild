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

{ # --version

    my $ae = Archive::Extract->new(archive => 't/modules/bb-pass.zip');
    $ae->extract(to => '.');

    my $new_ver = $^O =~ /MSWin/
        ? '5.20.3_64'
        : '5.20.3';

    chdir 'BB-Pass';
    `brewbuild -r`;
    my $ret = `brewbuild --version $new_ver`;
    chdir '..';

    my @res = split /\n/, $ret;
    @res = grep /\S/, @res;

    if ($^O =~ /MSWin/) {
        is ( @res, 2, "proper result count with --version" );
        like ( $res[0], qr/\d\.\d{2}\.\d :: PASS/, "--version ok $res[0]" );
        like ( $res[1], qr/\d\.\d{2}\.\d :: PASS/, "--version ok $res[1]" );
    }
    else {
        is ( @res, 3, "proper result count with --version" );
        is ( $res[0], "- installing $new_ver...", "--version ok" );
        like ( $res[1], qr/\d\.\d{2}\.\d :: PASS/, "--version ok $res[1]" );
        like ( $res[2], qr/\d\.\d{2}\.\d :: PASS/, "--version ok $res[2]" );
    }

    remove_tree('BB-Pass');
    is (-d 'BB-Pass', undef, "--version pass dir removed ok");
}

done_testing();

