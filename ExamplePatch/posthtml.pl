# perl -pf ./posthtml.pl <patch.html
s/_br_/<br>/g;
s/_markstart_/<mark>/g;
s{_markend_}{</mark>}g;
