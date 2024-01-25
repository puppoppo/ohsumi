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

$,   = ",";
$\   = "\n";
@all = (0);

while (<SWISS>) {
    chomp;

    $all[$j] = substr( $_, 0, 1000 );
    $j += 1;

    $readingLine = $_ . " ";

    if ( $readingLine =~ /^ID   / ) {
        $swissID = substr( $readingLine, 5, 12 );
        $swissID =~ s/\s//g;
    }
    elsif ( $readingLine =~ /^DE/ ) {
        if ( $readingLine =~ /Fragment/ ) {
            $frag = 1;
        }
    }
    elsif ( $readingLine =~ /^OC   / ) {
        $swissoc .= substr( $readingLine, 5, 100 );
    }
    elsif ( $readingLine =~ /^FT   SIGNAL          / ) {
        $ft_switch       = 1;
        $ft_signal       = 1;
        $ft_signal_range = substr( $readingLine, 21, 100 );
    }
    elsif ( $ft_switch == 1 ) {
        $ft_switch = 0;
        if ( $readingLine =~ /^FT                   / ) {
            $ft_eco = substr( $readingLine, 40, 3 );
        }
        else {
            $ft_eco = "0";
        }
    }
    elsif ( $readingLine =~ /^     / ) {
        $sequence .= substr( $_, 5, 1000 );
    }
    elsif ( $readingLine =~ /^\/\// ) {
        ( $signal_start, $signal_end ) = $ft_signal_range =~ /(\d+)\.\.(\d+)/;
        $sequence =~ s/\s+//g;
        @seq_list = split( //, $sequence );
        print WRITE ">" . $swissID . "," . $ft_eco;

        # for ( $i = $signal_start - 1 ; $i < $signal_end ; $i++ ) {
        #     printf WRITE $seq_list[$i];
        # }
        # printf WRITE "\n";

        $sequence     = "";
        $swissID      = "";
        $frag         = 0;
        $swissoc      = "";
        $ft_signal    = 0;
        $j            = 0;
        @all          = (0);
        $ft_eco       = "";
        $ft_switch    = 0;
        $signal_start = 0;
        $signal_end   = 0;
        @seq_list     = (0);

    }
}

print chr(7);    #終了時に音が鳴ります
