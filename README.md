flac2opus
=========

Batch, multithreaded converter of flac files to opus format.  I use this for getting my FLAC (and cover.jpg) files onto my portable player, which plays opus files.  It's pretty well tested (I have a fairly large collection, with several non-ascii filenames), and does a great job of doing what opusenc should probably do already.

Usage:
------

    flac2opus.pl -source <dir(s) where flacs are> -dest <dir where opuses go> [-bitrate <number 6-256>] [-tmp <tmp dir>] [-processes #] [-help]

    -source <dir(s) where flacs are>: You can specify multiple source directories, using either space or comma separation
    -dest <dir where opuses go>:      Only one destination is supported
    -bitrate <number 6-256>:          Default: 64 -- The range is limited by the opusenc encoder
    -tmp <tmp dir>:                   Default: /tmp -- This is meant to save writes on your portable device
    -processes #:                     Default: 6 -- Specify how many threads to run concurrently
    -help:                            Prints a short help message

Dependencies:
-------------

You will need perl >= 5.10, the flac decoder and opusenc encoder installed in your executable search path.  The following Perl modules are used (most were installed as part of perl Core, but if you get errors saying you're missing something, you'll want to search CPAN):

    use Getopt::Long;
    use File::Path qw(make_path);
    use File::Basename;
    use File::Spec::Functions qw(splitdir);
    use File::Copy;
    use Cwd;
    use v5.10;
    use Encode;
    use Parallel::ForkManager;
