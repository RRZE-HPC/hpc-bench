#!/usr/bin/perl -w

package kiviat;

use strict;
use warnings;
use File::Copy;
use constant mm => 25.4 / 72;
use SVG;
use constant PI => 3.14;

my $SYMBOLS = {
	'square'   => {name => 'symbolSquare',
		           draw => 'contour pathSquare scaled 0.2cm'},
	'circle'   => {name => 'symbolCircle',
		           draw =>  'contour pathCircle scaled 0.2cm'},
	'cross'    => {name =>  'symbolCross',
		           draw =>  'contour pathCross1 scaled 0.2cm'},
	'plus'     => {name =>  'symbolPlus',
		           draw =>  'contour pathPlus1 scaled 0.2cm'},
	'diamond'  => {name =>  'symbolDiamond',
		           draw =>  'contour pathDiamond scaled 0.2cm'},
	'triangle' => {name =>  'symbolTriangle',
		           draw =>  'contour pathTriangle scaled 0.2cm'}};

sub new {
	my $self = {};
	my $class = shift;
	$self->{Series} = [];
	$self->{Backend} = 'METAPOST';
	$self->{Title} = 'Kiviat Diagram';
	$self->{Verbose} = 0;
	$self->{File} = 'out';

	my $args = shift;
	$self->{File} = $args->{FILE} if (exists $args->{FILE});
	$self->{Verbose} = $args->{VERBOSE} if (exists $args->{VERBOSE});
	$self->{Title} = $args->{TITLE} if (exists $args->{TITLE});
	my $label_string = $args->{LABELS} if (exists $args->{LABELS});

	$self->{Label} = [ split ',',$label_string ];
	$self->{Number} = $#{ $self->{Label} };
	$self->{Number}++;

	bless($self, $class);
	return $self;
}

sub addSeries {
	my $self = shift;
	my $name = shift;
	my $color = shift;
	my $symbol = shift;
	my $data_ptr = shift;

	if ($#{ $data_ptr } != ($self->{Number}-1) ) {
		print "ERROR Illegal number of data items: $#{ $data_ptr } \n"; 
		return;
	}

	push @{$self->{Series}}, {
		Name  => $name,
		Color => $color,
		Symbol => $symbol,
		Data  => []};

	foreach my $data (@{$data_ptr}) {
		push @{$self->{Series}->[$#{ $self->{Series} }]->{Data}},$data;
	}
}


sub printData {
	my $self = shift;

	my $num_beams = $self->{Number};
	my $num_series = $#{$self->{Series}}+1;
	print "Number of Labels: $num_beams \n";
	print "Number of Series: $num_series\n";
	print "Labels @{$self->{Label}}\n";

	foreach my $series (@{$self->{Series}}) {
		print "Series Name: $series->{Name}\n";
		print "Color: $series->{Color}\n";
		print "Symbol: $series->{Symbol}\n";
		print "Data: ";

		foreach my $data (@{$series->{Data}}) {
			print "$data, ";
		}
		print "\n\n";
	}
}

sub generate {
	my $self = shift;

	$self->prepareData();
	$self->generatePrimitivesSVG();


}

# normalize every beam to max value
sub prepareData {
	my $self = shift;
	my @max = (0 .. $self->{Number});

	foreach (@max) { $_ = 0;}

	# Find maxima
	foreach my $series (@{$self->{Series}}) {
		for (my $i=0; $i<$self->{Number}; $i++) {
			if ($max[$i] < $series->{Data}->[$i]) {
				$max[$i] = $series->{Data}->[$i];
			}
		}
	}

	# Normalize series values
	foreach my $series (@{$self->{Series}}) {
		$series->{NormData} = [];

		for (my $i=0; $i<$self->{Number}; $i++) {
			push @{$series->{NormData}},$series->{Data}->[$i]/$max[$i];
		}
	}

	if ($self->{Verbose}){
		foreach my $series (@{$self->{Series}}) {
			print "Series Name: $series->{Name}\n";
			print "Norm Data: ";
			foreach my $data (@{$series->{NormData}}) {
				print "$data, ";
			}
			print "\n";
			print "Data: ";
			foreach my $data (@{$series->{Data}}) {
				print "$data, ";
			}
			print "\n\n";

		}
	}
}

sub D2R {
    my $angle = shift;

    return  $angle / 180 * PI;
}


sub rotatePoint {
    my $x = shift;
    my $y = shift;
    my $degrees = shift;

    my $x_rot = cos(D2R($degrees)) * $x - sin(D2R($degrees)) * $y;
    my $y_rot = sin(D2R($degrees)) * $x + cos(D2R($degrees)) * $y;

    return ($x_rot, $y_rot);
}



# Handler for SVG backend
sub generatePrimitivesSVG {
    my $self = shift;
    my $num_segments = $self->{Number};
    my $num_steps = 5;
    my @segments = (0 .. $num_segments);
    my $rot_angle = 360/ $num_segments;
    my $radius = 100;

    my $size = 500;
    my $Xsize = 700;
    my $translate = 500/2;
    my $svg = SVG->new(width=>$Xsize,height=>$size);

    my @x;
    my @y;

    foreach ( @segments ) {
        if ($_ == 0) {
            $x[$_] = (0);
            $y[$_] = ($radius);
        } else {
            my $index = $_ - 1;
            ($x[$_],$y[$_]) = rotatePoint($x[$index], $y[$index], $rot_angle);
        }
    }

    my $points = $svg->get_path(
        x=>\@x,
        y=>\@y,
        -type=>'polygon'
    );

    my $ygr = $svg->group(
        id => 'grid',
        style => {stroke=>'black'});

	#draw rings
    foreach my $step (1 .. $num_steps) {
        my $scale = (1.0/$num_steps)*$step;
        my $width = 0.8/$scale;
        $ygr->polygon(%$points, id=>"poly$step",style => {fill=>'none','stroke-width'=>$width},transform => "translate($translate,$translate) scale($scale)");
    }

	#draw beams
    foreach my $step (1 .. $num_segments) {
        my $rotation = $rot_angle*$step;
        $ygr->line(x1=>0, y1=>0, x2=>0, y2=>$radius, id=>"line$step",transform => "translate($translate,$translate) rotate($rotation)");
    }

	#draw series
    foreach my $series (@{$self->{Series}}) {
        @x=();
        @y=();

        for (my $i=0; $i<$self->{Number}; $i++) {
            my $point = $series->{NormData}->[$i] * $radius;
            my $angle = $i * $rot_angle;
            ($x[$i],$y[$i]) = rotatePoint(0, $point, $angle);
        }

        my $spoints = $svg->get_path(
            x=>\@x,
            y=>\@y,
            -type=>'polygon'
        );

        $ygr->polygon(%$spoints, id=>"$series->{Name}",style => {fill=>'none','stroke-width'=>2,'stroke'=>"#$series->{Color}"},
            transform => "translate($translate,$translate)");
    }

	#print labels
    foreach my $step (1 .. $num_segments) {
        my $rotation = $rot_angle*$step;
        my ($anchorX,$anchorY) = rotatePoint(0, $radius+5, $rotation);
        my $align;

        if ($rotation <= 180) {
            $align = 'end';
        } else {
            $align = 'start';
        }

        $ygr->text( id=>"label$step", "font-size" => '8pt', "text-anchor" => $align, x=>$anchorX, y=>$anchorY,
            -cdata=>"$self->{Label}->[$step-1]",transform => "translate($translate,$translate)" );
    }

	#print legend
    my $XCursor = $translate+200;
    my $YCursor = $translate;
    
	foreach my $series (@{$self->{Series}}) {
        $YCursor += 20;
        my $xanch = $XCursor+50;

        $ygr->line(x1=>0, y1=>0, x2=>40, y2=>0, id=>"leg$series->{Name}",
            style => {'stroke-width'=>2,'stroke'=>"#$series->{Color}"},transform => "translate($XCursor,$YCursor)");
        $ygr->text( id=>"label$series->{Name}", "font-size" => '8pt',  x=>$xanch, y=>$YCursor,
            -cdata=>"$series->{Name}");
	}

    open FILE,">$self->{File}.svg";
    print FILE $svg->xmlify();
    close FILE;
}



# Handler for Metapost backend
sub generatePrimitivesMP {
	my $self = shift;
	my $num_segments = $self->{Number};
	my @segments = (0 .. $num_segments);
	my $radius = 40;
	my $index;
	my @pairs = ( 'A' .. 'Z' );

	my $rot_angle = 360/ $num_segments;

	mkdir 'tmp';
	open FILE,">tmp/$self->{File}.mp";
	print FILE "input boxes\n";
	print FILE "beginfig(1)\n";
	print FILE "defaultfont := \"ptmr\";\n";
	print FILE "pair CE;\n";
	print FILE "pair P[];\n";
	print FILE "CE := (0cm,0cm);\n";

	#define points
	foreach ( @segments ) {
		if ($_ == 0) {
			print FILE "P[$_] := (0mm,$radius mm);\n";
		} else {
			$index = $_ - 1;
			print FILE "P[$_] := P[$index] rotated $rot_angle;\n";
		}
	}

print FILE "picture symbolSquare;\n";
print FILE "path pathSquare;\n";
print FILE "pathSquare := (-1,-1)--(-1,1)--(1,1)--(1,-1)--cycle;\n";
print FILE "symbolSquare := nullpicture;\n";

print FILE "picture symbolCircle;\n";
print FILE "path pathCircle;\n";
print FILE "pathCircle := fullcircle;\n";
print FILE "symbolCircle := nullpicture;\n";

print FILE "picture symbolCross;\n";
print FILE "path pathCross;\n";
print FILE "pathCross0 := (-1,0)--(1,0);\n";
print FILE "pathCross1 := (0,-1)--(0,1);\n";
print FILE "symbolCross := nullpicture;\n";

print FILE "picture symbolPlus;\n";
print FILE "path pathPlus;\n";
print FILE "pathPlus0 := (-1,0)--(1,0);\n";
print FILE "pathPlus1 := (0,-1)--(0,1);\n";
print FILE "symbolPlus := nullpicture;\n";

print FILE "picture symbolDiamond;\n";
print FILE "path pathDiamond;\n";
print FILE "pathDiamond := (-1,0)--(0,1)--(1,0)--(0,-1)--cycle ;\n";
print FILE "symbolDiamond := nullpicture;\n";

print FILE "picture symbolTriangle;\n";
print FILE "path pathTriangle;\n";
print FILE "pathTriangle := (-1,-1)--(0,1)--(1,-1)--cycle;\n";
print FILE "symbolTriangle := nullpicture;\n";


	print FILE "picture pic;\n";
	#draw rings
	foreach ( @segments ) {
		if ($_ == 0) {
			print FILE "draw P[$_]";
		}else {
			print FILE "--P[$_]";
		}
	}
	print FILE "--cycle withpen pencircle scaled 1.2;\n";
	print FILE "pic := currentpicture;\n";
	print FILE "draw pic scaled 0.8 withpen pencircle scaled 0.6;\n";
	print FILE "draw pic scaled 0.6 withpen pencircle scaled 0.6;\n";
	print FILE "draw pic scaled 0.4 withpen pencircle scaled 0.6;\n";
	print FILE "draw pic scaled 0.2 withpen pencircle scaled 0.6;\n";
	print FILE "pickup pencircle scaled 1.2;\n";

	#draw beams
	foreach ( @segments ) {
		print FILE "draw CE--P[$_];\n";
	}

	my $pair_index = 0;
	#define points for series points
	foreach my $series (@{$self->{Series}}) {
		my $pair = $pairs[$pair_index++];
		print FILE "pair $pair"."[];\n";
		print FILE "pair Z;\n";
		# define Symbol
		print FILE "addto $SYMBOLS->{$series->{Symbol}}->{name} $SYMBOLS->{$series->{Symbol}}->{draw}  withcolor $series->{Color};\n";

		for (my $i=0; $i<$self->{Number}; $i++) {
			my $point = $series->{NormData}->[$i] * $radius;
			my $angle = $i * $rot_angle;
			print FILE "Z := (0, $point mm);\n";
			print FILE $pair."[$i] := Z rotated $angle;\n";
			print FILE "draw $SYMBOLS->{$series->{Symbol}}->{name} shifted $pair"."[$i];\n";
		}

		for (my $i=0; $i<$self->{Number}; $i++) {
			if ($i == 0) {
				print FILE "draw $pair"."[$i]";
			}else {
				print FILE "--$pair"."[$i]";
			}
		}
		print FILE "--cycle withcolor $series->{Color} withpen pencircle scaled 2;\n";

	}

	#print labels
	for (my $i=0; $i<$self->{Number}; $i++) {
		my $angle = $i * $rot_angle;
		print FILE "%% $angle degrees\n";

		if (($angle >= 337.5) or ($angle <= 22.5)) {
			print FILE "label.top(btex $self->{Label}->[$i] etex, P[$i]);\n";
		} elsif  (($angle >= 22.5) and ($angle <= 67.5)) {
			print FILE "label.ulft(btex $self->{Label}->[$i] etex, P[$i]);\n";
		} elsif  (($angle >= 67.5) and ($angle <= 112.5)) {
			print FILE "label.lft(btex $self->{Label}->[$i] etex, P[$i]);\n";
		} elsif  (($angle >= 112.5) and ($angle <= 157.5)) {
			print FILE "label.llft(btex $self->{Label}->[$i] etex, P[$i]);\n";
		} elsif  (($angle >= 157.5) and ($angle <= 202.5)) {
			print FILE "label.bot(btex $self->{Label}->[$i] etex, P[$i]);\n";
		} elsif  (($angle >= 202.5) and ($angle <= 247.5)) {
			print FILE "label.lrt(btex $self->{Label}->[$i] etex, P[$i]);\n";
		} elsif  (($angle >= 247.5) and ($angle <= 292.5)) {
			print FILE "label.rt(btex $self->{Label}->[$i] etex, P[$i]);\n";
		} elsif   (($angle >= 292.5) and ($angle <= 337.5)) {
			print FILE "label.urt(btex $self->{Label}->[$i] etex, P[$i]);\n";
		}
	}

	#draw bounding box Title and Legend box
	print FILE "pic := currentpicture;\n";
	print FILE "boxit.bound(pic);\n";
	print FILE "drawunboxed(bound);\n";

	print FILE "picture legend;\n";
	print FILE "legend := nullpicture;\n";

	my $cursor = 0;
	foreach my $series (@{$self->{Series}}) {

		print FILE "addto legend doublepath(0,$cursor cm)--(1cm,$cursor cm) withcolor $series->{Color} withpen pencircle scaled 2 ;\n";
		print FILE "addto legend also thelabel(btex $series->{Name} etex scaled 1.2,(3cm,$cursor cm));\n";
		$cursor += 0.5;
	}
	print FILE "boxit.leg(legend);\n";
	print FILE "leg.n=bound.s-(0,1cm);\n";
	print FILE "drawunboxed(leg);\n";
	print FILE "endfig;\n";
	close FILE;

	chdir 'tmp';
#	system ("mptopdf $self->{File}.mp > /dev/null 2>&1");
#    copy ("$self->{File}-1.pdf", "../$self->{File}.pdf");
#    copy ("$self->{File}.mp", "../$self->{File}.mp");
	chdir '../';
#    system ('rm -rf tmp');

}


1;
