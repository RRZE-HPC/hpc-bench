#!/usr/bin/perl -w

my $RRZE_PIN = '/apps/rrze/bin/pin_omp';

sub mpi_init 
{

}

sub mpi_run 
{
	my $num_proc = shift;
	my $command = shift;
	my $type = shift;

	if ($type eq 'SOCKET') {
		system ("mpirun -np $num_proc -pin 0_2 $command");
	}elsif ($type eq 'PALLAS') {
		system ("mpirun -np $num_proc -pernode  $command");
	}else {
		system ("mpirun -np $num_proc  $command");
	}
}


sub mpi_done 
{

}

sub omp_pin 
{
	my $num_proc = shift;
	my $exe = shift;
	my $opts = shift;
	my $time = shift;
	my $type = shift;

	$ENV{'KMP_AFFINITY'} = 'disabled';
	$ENV{'OMP_NUM_THREADS'} = $num_proc;
	my $max_id = $num_proc-1;

	if ($type eq 'SOCKET') {
		$ENV{'PINOMP_CPUS'} = '0,2';
		system("$time \"$RRZE_PIN -c 0-$max_id $exe\" $opts");
	}else {
		system("$time \"$RRZE_PIN -c 0-$max_id $exe\" $opts");
	}
}



1;
