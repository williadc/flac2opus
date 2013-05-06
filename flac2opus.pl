#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Path qw(make_path);
use File::Basename;
use File::Spec::Functions qw(splitdir);
use File::Copy;
use Cwd;
use v5.10;
use Parallel::ForkManager;

# Process cmdline options
my (@sources, $dest, $help);
my $bitrate = 64;
my $tmpdir = '/tmp';
my $processes = 6;
GetOptions ("s|sources=s{,}" => \@sources,
            "d|dest=s"       => \$dest,
            "b|bitrate=s"    => \$bitrate,
            "p|processes=s"  => \$processes,
            "t|tmp=s"        => \$tmpdir,
            "h|help"         => \$help);

if ($help) {
    say basename($0) . " -sources <dir where flacs are> -dest <dir where opuses go> [-bitrate <number 6-256>] [-tmp <tmp dir>] [-processes #] [-help]";
    exit;
}
# in case users give comma-separated options instead of space separation
@sources = split(/,/,join(',',@sources));

# verify that the directories specified in -sources and -dest are actually directories
map {check_dir(\$_, '-sources')} @sources;
check_dir(\$dest, '-dest');

# Look for flac files
my @src_files = map {find_files ($_)} @sources;

my $pm = new Parallel::ForkManager($processes);

# encode/copy each flac file
for my $src (@src_files) {
    $pm->start and next; # do the fork
    my @srcdirs = splitdir(dirname($src));
    my $opusdir = "$dest/$srcdirs[-2]/$srcdirs[-1]";
    make_path ($opusdir) unless (-d $opusdir);
    my $basename = basename($src, '.flac');
    if ($basename eq 'cover.jpg') {
        say "Copying Album Art: $srcdirs[-2] - $srcdirs[-1]";
        system "cp \"$src\" \"$opusdir\"";
    } else {
        my $opusfile =  "$basename.opus";
        my @meta = `metaflac --show-tag=artist --show-tag=title "$src"`;
        chomp @meta;
        map {s/\"/\\\"/g} @meta; # escape " in any metadata
        map {s/(\w+)=(.*)/\L--$1\E="$2"/} @meta; # \L makes the characters lower case until \E, which ends case conversion
        say "Encoding $basename";
        my $command = "/usr/bin/flac -scd \"$src\" | /usr/bin/opusenc --quiet --bitrate $bitrate " . join(' ', @meta ) . " - \"$tmpdir/$opusfile\"";
        system $command;
        move ("$tmpdir/$opusfile", $opusdir);
    }
    $pm->finish; # do the exit in the child process
}
$pm->wait_all_children;

#subs

sub check_dir {
    my ($dir_ref, $option) = @_;
    $$dir_ref =~ s{([^/]+)/$}{$1};
    if (defined $$dir_ref) {
        if (substr($$dir_ref, 0,1) ne '/') {
            $$dir_ref = cwd() . "/$$dir_ref";
        }
        die "$option is not a valid directory" unless (-d $$dir_ref);
    } else {
        die "Please specify $option";
    }
}

sub find_files {
    my ($path) = @_;
    my (@files, $found_flac, $cover);
    opendir (my $path_h, $path);
    while (my $file = readdir $path_h){
        next if ($file eq '.' or $file eq '..');
        my $full_path = "$path/$file";
        if ($file eq 'cover.jpg') {
            $cover = $full_path;
        } elsif (-d $full_path) {
            push (@files, find_files($full_path));
        } else {
            my @fn = split(/\./, basename($file));
            if (defined $fn[-1] and $fn[-1] eq 'flac') {
                push(@files, $full_path);
                $found_flac = 1;
            }
        }
    }
    if ($cover and $found_flac) {
        push(@files, $cover);
    }
    closedir $path_h;
    return @files;
}
