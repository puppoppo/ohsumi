# ヒト・sp・完全長のタンパクを集める

use Getopt::Long;

my $input_file_path;
my $output_file_path;

# オプションの定義
GetOptions(
    'input=s'  => \$input_file_path,     # --input オプションとその値
    'output=s' => \$output_file_path,    # --output オプションとその値
);

open( SWISS, $input_file_path )
  or die "Cannot open input file: $!";
open( WRITE, '>', $output_file_path )
  or die "Cannot open output file: $!";

$, = ",";
$\ = "\n";
my @all;

while (<SWISS>) {
    chomp;

    $append_line = substr( $_, 0, 1000 );

    $readingLine = $_ . " ";

    if ( $append_line =~ /^ID   / ) {
        $swissID = substr( $append_line, 5, 12 );
        $swissID =~ s/\s//g;
    }
    elsif ( $append_line =~ /^DE/ && $DE_frag == 0 ) {
        $swissDE = substr( $append_line, 5, 1000 );
        $DE_frag = 1;
    }
    elsif ( $append_line =~ /^CC   -!- SUBCELLULAR LOCATION:/ ) {
        $subcell_frag = 1;

        #　$subcell_noteに格納
        $subcell_note .= substr( $readingLine, 31, 1000 );
    }
    elsif ( $subcell_frag == 1 && $readingLine =~ /^CC       / ) {

        #　$subcell_noteに格納
        $subcell_note .= substr( $readingLine, 9, 1000 );
    }
    elsif ( $subcell_frag == 1 && $readingLine =~ /^CC   -!- / ) {
        $subcell_frag = 0;
    }
    elsif ( $readingLine =~ /^FT   TRANSMEM/ ) {
        $ft_transmem_count = $ft_transmem_count + 1;
    }
    elsif ( $readingLine =~ /^FT   SIGNAL          / ) {
        $ft_signal_range = substr( $readingLine, 21, 100 );

    }

    elsif ( $readingLine =~ /^     / ) {
        $sequence .= substr( $_, 5, 1000 );
        $sequence =~ s/\s//g;
    }
    elsif ( $readingLine =~ /^\/\// ) {

        ( $signal_start, $signal_end ) = $ft_signal_range =~ /(\d+)\.\.(\d+)/;
        my @seq_list = split( //, $sequence );

        print WRITE ">"
          . $swissID . "\t"
          . $swissDE . "\t"
          . $ft_transmem_count . "\t"
          . $subcell_note;

        for ( $i = $signal_start - 1 ; $i < $signal_end ; $i++ ) {
            printf WRITE $seq_list[$i];
        }
        printf WRITE "\n";

        $sequence          = "";
        $swissID           = "";
        $swissDE           = "";
        $ft_transmem_count = 0;
        $subcell_frag      = 0;
        $subcell_note      = "";
        $ft_signal_range   = "";
        $signal_start      = 0;
        $signal_end        = 0;
        $DE_frag           = 0;
    }
}

print chr(7);    #終了時に音が鳴ります
