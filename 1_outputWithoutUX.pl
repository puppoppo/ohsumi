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

$,   = ",";
$\   = "\n";
$U   = 0;      #配列にU,Xが含まれているかフラグ化
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
        $ft_switch = 1;
        $ft_signal = 1;
        $ft_signal_range = substr( $readingLine, 21, 100 );
    }
    elsif ( $ft_switch == 1 ){
        $ft_eco = substr( $readingLine, 21, 100 );
        $ft_switch = 0;
    }
    elsif ( $readingLine =~ /^     / ) { 
        $sequence .= substr($_, 5, 1000);
        if ( $readingLine =~ /U|X/ ) {
            $U = 1;
        }
    }
    elsif ( $readingLine =~ /^\/\// ) {
        if ( $swissoc =~ /Homo/ && $frag == 0 && $ft_signal == 1 )
        {
            ($signal_start, $signal_end) = $ft_signal_range =~ /(\d+)\.\.(\d+)/;
            $sequence =~ s/\s+//g;
            @seq_list = split( //, $sequence );

            for ( $i =  $signal_start - 1; $i < $signal_end ; $i++){
                #signal内に"U","Xを含まないことを確認"
                if ($seq_list[$i] =~ /U|X/){
                    print $all[1]. " contains U or X in " .$i. " signal";
                    print $signal_start.",".$signal_end;
                }
            }
        }
        @seq_list=(0);
        $ft_signal_range="";
        $ft_eco="";
        $frag     = 0;
        $swissoc  = "";
        $U        = 0;
        $ft_signal = 0;
        $j        = 0;
        @all      = (0);
    }
}

print chr(7);    #終了時に音が鳴ります
