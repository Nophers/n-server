use strict;
use warnings;
use IO::Socket::INET;

my $port = 8080;
my $socket = IO::Socket::INET->new(
    LocalPort => $port,
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
) or die "Can't create socket: $!\n";

print "Listening on port $port...\n";

while (my $client = $socket->accept()) {
    my ($client_address, $client_port) = ($client->peerhost(), $client->peerport());
    print "Accepted connection from $client_address:$client_port\n";
    
    my $request = "";
    while (my $line = <$client>) {
        last if $line =~ /^\r\n$/;
        $request .= $line;
    }
    
    my $response = build_response($request);
    print $client $response;
    
    $client->close();
}

sub build_response {
    my ($request) = @_;
    my ($method, $path, $protocol) = split /\s+/, $request;
    my $content = "";
    my $status = "200 OK";
    my $content_type = "text/html";
    
    if ($method eq "GET") {
        if ($path eq "/") {
            $content = "Accepted from $port!";
        } else {
            $status = "404 Not Found";
            $content = "Not found";
        }
    } else {
        $status = "405 Method Not Allowed";
        $content = "Method not allowed";
    }
    
    my $response = "$protocol $status\r\nContent-Type: $content_type\r\n\r\n$content";
    return $response;
}