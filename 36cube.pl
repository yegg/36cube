#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

my @board = ([1, 3, 6, 5, 4, 2], 
             [4, 2, 5, 1, 6, 3], 
             [5, 6, 3, 4, 2, 1], 
             [3, 1, 4, 2, 5, 6], 
             [2, 4, 1, 6, 3, 5], 
             [6, 5, 2, 3, 1, 4]);

my @pieces = ('r1','r2','r3','r4','r5','r6',
              'o1','o2','o3','o4','o5','o6',
              'y1','y2','y3','y4','y5','y6',
              'b1','b2','b3','b4','b5','b6',
              'g1','g2','g3','g4','g5','g6',
              'i1','i2','i3','i4','i5','i6');

my @solution = (['x1','x2','x3','x4','x5','x6'],
                ['x1','x2','x3','y2','x5','x6'],
                ['x1','x2','x3','x4','x5','x6'],
                ['x1','x2','x3','o1','x5','x6'],
                ['x1','x2','x3','x4','x5','x6'],
                ['x1','x2','x3','x4','x5','x6']);

my %seen = ();
my %used = ();

my $num_bad_solutions = 0;

for (my $rows=0; $rows<6; $rows++) {
    for (my $cols=0; $cols<6; $cols++) {

        my $is_print = 0;
        $is_print = 1 if $rows==5;

        print qq(\nAT: $rows, $cols\n) if $is_print;
        #die if $rows==5 && $cols==2;

        my $is_fit = get_piece_that_fits($rows,$cols);

        if (!$is_fit) {
            $num_bad_solutions++;
            print qq(BAD SOLUTION $num_bad_solutions AT: $rows, $cols\n) if $is_print;
            print_solution() if $is_print;

            $seen{$rows}{$cols} = ();
#            print qq(BLOWING AWAY SEEN AT: $rows, $cols\n) if $is_print;
#            print Dumper(\%seen) if $is_print;

            if ($cols==0) {
                $rows--;
                $cols=5;
                clear_solution($rows,$cols,$is_print);
                $cols-=1;
            } else {
                $cols-=1;
                clear_solution($rows,$cols,$is_print);
                $cols-=1;
            }
            
        }
    }
}

print qq(\n\nBUST A MOVE:\n);
print_solution();

sub clear_solution {
    my ($rows,$cols,$is_print) = @_;

    print qq(UNUSED ), $solution[$rows][$cols], qq( AT: $rows, $cols\n) if $is_print;
    $used{$solution[$rows][$cols]} = 0;
#    print scalar(keys %used), "\n";
#    print Dumper(\%used) if $is_print;
    $solution[$rows][$cols] = qq(x$cols);

}

sub get_piece_that_fits {
    my ($rows,$cols) = @_;

    my $is_fit = 0;

    PIECE: foreach my $piece (@pieces) {
#          print qq(trying piece: $piece\n);

          next PIECE if $seen{$rows}{$cols}{$piece};
          next PIECE if is_piece_used($piece);
          next PIECE if !does_piece_fit($piece,$rows,$cols);
          #        print qq(found piece: $piece\n);        
 
          $solution[$rows][$cols] = $piece;
          $used{$piece} = 1;
          $seen{$rows}{$cols}{$piece} = 1;
          $is_fit = 1;
          last PIECE;

#          die Dumper(\%seen);
#          print_solution();
  }

    return $is_fit;
}

sub print_solution {
#    print qq(SOLUTION:\n);
  for (my $rows=0; $rows<6; $rows++) {
      print qq(ROW $rows: );
      for (my $cols=0; $cols<6; $cols++) {
          print $solution[$rows][$cols], qq( );
      }
      print qq(\n);
  }
}


sub does_piece_fit {
    my ($piece, $rows, $cols) = @_;

    my $size = $board[$rows][$cols];
#    print qq(size: $size\n);

    my ($piece_color,$piece_size) = get_color_size($piece);
#    print qq(color: $piece_color\n);
#    print qq(size: $piece_size\n);
    my $is_size_override = 0;
    $is_size_override = 1 if $piece eq 'y2' && $rows==1 && $cols==3;
    $is_size_override = 1 if $piece eq 'o1' && $rows==3 && $cols==3;
    return 0 if !$is_size_override && $size ne $piece_size;

    ROW: for (my $rows2=0; $rows2<6; $rows2++) {
        COL: for (my $cols2=0; $cols2<6; $cols2++) {
              if (($rows2==$rows && $cols2<$cols)
                       || ($cols2==$cols && $rows2<$rows)
                   ) {
                  my ($color2) = get_color_size($solution[$rows2][$cols2]);
#                  print qq(color2: $color2\n);
                  return 0 if $color2 eq $piece_color;
              }
          }
      }
    
    return 1;
}

sub is_piece_used {
    my ($piece) = @_;

    return $used{$piece} ? 1 : 0;

    for (my $rows=0; $rows<6; $rows++) {
        for (my $cols=0; $cols<6; $cols++) {
 
            my $place = $solution[$rows][$cols];
#            print qq(place: $place\n);

            return 1 if $piece eq $place;
        }
    }

    return 0;
}


sub get_color_size {
    my ($piece) = @_;
    my ($color,$size) = $piece =~ /^(.)(.)$/;
    return ($color,$size);
}
