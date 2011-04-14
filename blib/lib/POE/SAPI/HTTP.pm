package POE::SAPI::HTTP;

use 5.010001;
use strict;
use warnings;

our $VERSION = '0.03';

use POE qw(Component::Server::TCP Filter::HTTPD);
use HTTP::Response;
use Template;

sub new {
        my $package = shift;
        my %opts    = %{$_[0]} if ($_[0]);
        $opts{ lc $_ } = delete $opts{$_} for keys %opts;       # convert opts to lower case
        my $self = bless \%opts, $package;

        $self->{start} = time;
        $self->{cycles} = 0;

        $self->{me} = POE::Session->create(
                object_states => [
                        $self => {
                                _start          =>      'initLauncher',
                                loop            =>      'keepAlive',
                                _stop           =>      'killLauncher',
                        },
                        $self => [ qw (   ) ],
                ],
        );

	$self->{template} = Template->new({
		INCLUDE_PATH => [$self->{base}],	# or list ref
		INTERPOLATE  => 1,			# expand "$var" in plain text
		EVAL_PERL    => 1,			# evaluate Perl code blocks
	});

	$self->{webvars} = {
		var1  => "stub",
	};

}

sub keepAlive {
        my ($kernel,$session)   = @_[KERNEL,SESSION];
        my $self = shift;
        $kernel->delay('loop' => 1);
        $self->{cycles}++;
}
sub killLauncher { warn "Session halting"; }
sub initLauncher {
	my ($self,$kernel) = @_[OBJECT,KERNEL];
	$self->{httpd} = POE::Component::Server::TCP->new(
		Alias        => "web_server",
		Port         => 8088,
		ClientFilter => 'POE::Filter::HTTPD',
		ClientInput => sub {
			my ($kernel, $heap, $request) = @_[KERNEL, HEAP, ARG0];

			if ($request->isa("HTTP::Response")) {
				$heap->{client}->put($request);
				$kernel->yield("shutdown");
				return;
			}

			my $request_fields = '';
			$request->headers()->scan(
				sub {
					my ($header, $value) = @_;
					$request_fields .= "<tr><td>$header</td><td>$value</td></tr>";
				}
			);

			my $response = HTTP::Response->new(200);
			$response->push_header('Content-type', 'text/html');

			my $content;
			$self->{template}->process('index.tpl', $self->{webvars}, \$content);
			$response->content($content);
			$heap->{client}->put($response);
			$kernel->yield("shutdown");
		}
	);
	$kernel->yield('loop'); 
	$kernel->post($self->{parent},'register',{ name=>'HTTP', type=>'local' });
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

POE::SAPI::HTTP - Perl extension for blah blah blah

=head1 SYNOPSIS

  use POE::SAPI::HTTP;

=head1 DESCRIPTION

This is a CORE module of L<POE::SAPI> and should not be called directly.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Paul G Webster, E<lt>paul@daemonrage.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul G Webster

All rights reserved.

Redistribution and use in source and binary forms are permitted
provided that the above copyright notice and this paragraph are
duplicated in all such forms and that any documentation,
advertising materials, and other materials related to such
distribution and use acknowledge that the software was developed
by the 'blank files'.  The name of the
University may not be used to endorse or promote products derived
from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.


=cut
