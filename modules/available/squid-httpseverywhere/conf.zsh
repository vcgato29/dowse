#!/bin/zsh

# name of this module
THIS=`basename $PWD`

cat <<EOF > $DOWSE/run/$THIS.pl
#!/usr/bin/perl
use strict;
use warnings;
use lib '$PWD';
use HTTPSEverywhere;

\$|=1;

my \$he      = new HTTPSEverywhere( rulesets => ["$PWD/https-everywhere/src/chrome/content/rules"] );
my \$updated = time;

while(<>){
   my( \$url ) = /^(\S+)/;

   ## Re-read the rulesets if it has been more than an hour
     if( \$updated < time-3600 ){
	\$he->read();
	\$updated = time;
     }

   ## Converted version of the url
     my \$newurl = \$he->convert( \$url );

   if( \$url eq \$newurl ){
      print "\$url\n";
   } else {
      print "301:\$newurl\n";
   }
}


EOF

cat <<EOF >> $DOWSE/run/squid.conf
redirect_program $DOWSE/run/$THIS.pl
url_rewrite_children 40
EOF

return 0
