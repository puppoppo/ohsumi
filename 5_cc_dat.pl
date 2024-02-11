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

    if ( $readingLine =~ /^ID   / ) {
        $swissID = substr( $readingLine, 5, 12 );
        $swissID =~ s/\s//g;
        push @all, $append_line;
    }
    elsif ( $readingLine =~ /^DE/ ) {
        if ( $readingLine =~ /Fragment/ ) {
            $frag = 1;
        }
    }
    elsif ( $readingLine =~ /^CC   -!- SUBCELLULAR LOCATION:/ ) {
        push @all, $append_line;
        $subcell_frag = 1;

        #　$subcell_noteに格納
        $subcell_note .= substr( $readingLine, 31, 100 );
    }
    elsif ( $subcell_frag == 1 && $readingLine =~ /^CC   -!- / ) {
        $subcell_frag = 0;
    }
    elsif ( $subcell_frag == 1 && $readingLine =~ /^CC       / ) {
        push @all, $append_line;

        #　$subcell_noteに格納
        $subcell_note .= substr( $readingLine, 9, 100 );
    }
    elsif ( $readingLine =~ /^OC   / ) {
        $swissoc .= substr( $readingLine, 5, 100 );
    }
    elsif ( $readingLine =~ /^FT   SIGNAL          / ) {
        push @all, $append_line;
        $ft_switch       = 1;
        $ft_signal       = 1;
        $ft_signal_range = substr( $readingLine, 21, 100 );
    }
    elsif ( $ft_switch == 1 ) {
        $ft_switch = 0;
        if ( $readingLine =~ /^FT                   \/note=/ ) {
            push @all, $append_line;
            $note = substr( $readingLine, 27, 100 );
        }
        elsif ( $readingLine =~ /^FT                   / ) {
            push @all, $append_line;
            $ft_evi = substr( $readingLine, 21, 100 );
        }
        else {
            $ft_switch = 0;
        }
    }
    elsif ( $readingLine =~ /^SQ   / ) {
        push @all, $append_line;
    }
    elsif ( $readingLine =~ /^     / ) {
        push @all, $append_line;
        $sequence .= substr( $_, 5, 1000 );
    }
    elsif ( $readingLine =~ /^\/\// ) {
        if ( $ft_evi =~ /ECO:(.{7})/ ) {
            $ft_eco = $1;
        }
        else {
            $ft_eco = 0;
        }

        $or_frag = 0;
        if ( $note =~ /Or/ ) {
            $or_frag = 1;
        }

        if ( $subcell_note =~ /ECO:0000269/ ) {
            $sub_eco = 269;
        }
        elsif ( $subcell_note =~ /ECO:0000303/ ) {
            $sub_eco = 303;
        }
        elsif ( $subcell_note =~ /ECO:0000305/ ) {
            $sub_eco = 305;
        }
        elsif ( $subcell_note =~ /ECO:0000250/ ) {
            $sub_eco = 250;
        }
        elsif ( $subcell_note =~ /ECO:0007744/ ) {
            $sub_eco = 7744;
        }
        elsif ( $subcell_note =~ /ECO:0007829/ ) {
            $sub_eco = 7829;
        }
        elsif ( $subcell_note =~ /ECO:0000255/ ) {
            $sub_eco = 255;
        }
        elsif ( $subcell_note =~ /ECO:0000256/ ) {
            $sub_eco = 256;
        }
        elsif ( $subcell_note =~ /ECO:0000312/ ) {
            $sub_eco = 312;
        }
        elsif ( $subcell_note =~ /ECO:0000313/ ) {
            $sub_eco = 313;
        }
        else {
            $sub_eco = 0;
        }

        $eco_frag = 0;
        if (   $ft_eco =~ /0000269/
            || $ft_eco =~ /0000303/
            || $ft_eco =~ /0000305/
            || $ft_eco =~ /0000250/
            || $ft_eco =~ /0007744/ )
        {
            $eco_frag = 1;
        }

        if (   $or_frag == 0
            && $eco_frag == 1
            && $sub_eco != 0
            && $sub_eco != 255 )
        {
            ( $signal_start, $signal_end ) =
              $ft_signal_range =~ /(\d+)\.\.(\d+)/;
            $sequence =~ s/\s+//g;
            @seq_list = split( //, $sequence );

            foreach my $element (@all) {
                if ( $element =~ /^SQ   / ) {
                    printf WRITE "FT                   ";
                    for ( $i = $signal_start - 1 ; $i < $signal_end ; $i++ ) {
                        printf WRITE $seq_list[$i];
                    }
                    printf WRITE "\n";
                }
                print WRITE $element;
            }
            printf WRITE "\/\/";
        }

        $sequence     = "";
        $swissID      = "";
        $frag         = 0;
        $swissoc      = "";
        $ft_signal    = 0;
        @all          = ("\n");
        $ft_evi       = "";
        $ft_eco       = "";
        $ft_switch    = 0;
        $signal_start = 0;
        $signal_end   = 0;
        @seq_list     = (0);
        $note         = "";
        $or_frag      = 0;
        $subcell_frag = 0;
        $subcell_note = "";
        $sub_eco      = 0;
    }
}

print chr(7);    #終了時に音が鳴ります
