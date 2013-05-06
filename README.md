flac2opus
=========

Batch, multithreaded converter of flac files to opus format.  I use this for getting my FLAC files onto my portable player, which runs rockbox and plays opus-encoded files.

Usage:
------

  flac2opus.pl -source <dir(s) where flacs are> -dest <dir where opuses go> [-bitrate <number 6-256>] [-tmp <tmp dir>] [-processes #] [-help]

  -source <dir(s) where flacs are>: You can specify multiple source directories, using either space or comma separation
  -dest <dir where opuses go>:      Only one destination is allowed
  -bitrate <number 6-256>:          Default: 64 The range is limited by the opusenc encoder
  -tmp <tmp dir>:                   Default: /tmp This is meant to save writes on your portable device
  -processes #:                     Default: 6 Specify how many threads to run concurrently
  -help:                            Prints a short help message
