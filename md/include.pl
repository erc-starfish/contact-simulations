# include files in markdown
#
# from https://github.com/jgm/pandoc/issues/553#issuecomment-21068189


while(<>) {
    if (/^`([^`]+)`\{\.include\}\s*$/) {
        if (-e $1 && open my $fh, '<', $1) {
            local $/;
            print <$fh>;
            close $fh;
        } else {
            print STDERR "failed to include file $1\n";
        }
    } else {
        print $_;
    }
}
