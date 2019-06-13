use IO::Socket;

my $port=$ARGV[0];
print "LOLA-->$port \n";
my $sock = IO::Socket::INET->new(
            LocalPort => $ARGV[0],
            Proto => 'tcp',
            Timeout => 0.1,
        );

print "Sock:: $sock \n";
