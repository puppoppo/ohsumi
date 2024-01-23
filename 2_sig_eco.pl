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
        $ft_signal = 1;
    }
    elsif ( $readingLine =~ /^\/\// ) {
        if ( $swissoc =~ /Homo/ && $frag == 0 && $ft_signal == 1 )
        {
            for ( $i = 0 ; $i < @all ; $i++ ) {
                print WRITE $all[$i] . "\n";
            }
        }
        $frag     = 0;
        $swissoc  = "";
        $ft_signal = 0;
        $j        = 0;
        @all      = (0);
    }
}

print chr(7);    #終了時に音が鳴ります
