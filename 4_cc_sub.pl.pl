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
@all = ("");

my @master_array;

my @count_array;

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
    elsif ( $readingLine =~ /^CC   -!- SUBCELLULAR LOCATION:/ ) {
        $subcell_frag = 1;

        #　$subcell_noteに格納
        $subcell_note .= substr( $readingLine, 31, 100 );
    }
    elsif ( $subcell_frag == 1 && $readingLine =~ /^CC   -!- / ) {
        $subcell_frag = 0;
    }
    elsif ( $subcell_frag == 1 && $readingLine =~ /^CC       / ) {

        #　$subcell_noteに格納
        $subcell_note .= substr( $readingLine, 9, 100 );
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
        if ( $readingLine =~ /^FT                   \/note=/ ) {
            $note = substr( $readingLine, 27, 100 );
        }
        elsif ( $readingLine =~ /^FT                   / ) {
            $ft_evi = substr( $readingLine, 21, 100 );
        }
        else {
            $ft_switch = 0;
        }
    }
    elsif ( $readingLine =~ /^     / ) {
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

            # "Note=" 以降を削除
            $subcell_note =~ s/Note=.*//;

            # カンマ区切りで配列にする
            @subcell_list = split( /\./, $subcell_note );

            # " {" と "}" に囲まれた部分を消す
            foreach my $v (@subcell_list) {
                $v =~ s/{.*?}//g;
            }

            # ":"が含まれている場合はそれ以前を消す
            foreach my $v (@subcell_list) {
                $v =~ s/.*://;
            }

            # 最初の1文字がスペースなら、それを削除する
            foreach my $v (@subcell_list) {
                $v =~ s/^\s//;
            }

            # 最後の1文字がスペースなら、それを削除する
            foreach my $v (@subcell_list) {
                $v =~ s/\s$//;
            }

            # 文字列からスペースを削除する
            foreach my $v (@subcell_list) {
                $v =~ s/\s//g;
            }

            # 空文字列を削除する
            @subcell_list = grep { $_ ne "" } @subcell_list;

            # subcell_listの各要素に対して処理
            foreach my $sub_element (@subcell_list) {

                # 同じ文字列がmaster_arrayに既に格納されている場合
                if ( grep { $_ eq $sub_element } @master_array ) {
                    my $index = 0;

                    # 対応する要素のカウントを加算
                    foreach my $master_element (@master_array) {
                        if ( $master_element eq $sub_element ) {
                            $count_array[$index]++;
                            last;    # 一致したらループを終了
                        }
                        $index++;
                    }
                }
                else {
                    # 同じ文字列がmaster_arrayに格納されていない場合は追加
                    push @master_array, $sub_element;

                    # カウント配列に新しい要素の初期値1を追加
                    push @count_array, 1;
                }
            }

            # ( $signal_start, $signal_end ) =
            #   $ft_signal_range =~ /(\d+)\.\.(\d+)/;
            # $sequence =~ s/\s+//g;
            # @seq_list = split( //, $sequence );
            # print WRITE ">" . $swissID . "," . $ft_eco . "," . $or_frag . ","
            #   . $sub_eco;

            # for ( $i = $signal_start - 1 ; $i < $signal_end ; $i++ ) {
            #     printf WRITE $seq_list[$i];
            # }
            # printf WRITE "\n";
        }

        $sequence     = "";
        $swissID      = "";
        $frag         = 0;
        $swissoc      = "";
        $ft_signal    = 0;
        $j            = 0;
        @all          = ("");
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
        @subcell_list = (0);
    }
}

my $index = 0;

foreach my $element (@master_array) {
    print WRITE "$element" . "\t" . $count_array[$index];
    $index++;
}
print chr(7);    #終了時に音が鳴ります
