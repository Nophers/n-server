#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use MIME::Base64;

my $username = "vKxni";
my $repository = "vKxni";

my $repos_endpoint = "https://api.github.com/users/$username/repos";
my $languages_endpoint = "https://api.github.com/users/$username/repos?per_page=1000";
my $latest_update_endpoint = "https://api.github.com/users/$username/repos?sort=updated&per_page=1";
my $readme_endpoint = "https://api.github.com/repos/$username/$repository/contents/README.md";

my $access_token = "not this time, buddy.";

my $ua = LWP::UserAgent->new;

$ua->default_header('Authorization' => "token $access_token");

my $response = $ua->get($repos_endpoint);
my $repos = decode_json($response->decoded_content);

my $num_repos = scalar(@$repos);

$response = $ua->get($languages_endpoint);
my $languages = decode_json($response->decoded_content);
my %language_count;
foreach my $repo (@$languages) {
    if ($repo->{language}) {
        $language_count{$repo->{language}}++;
    }
}
my $most_used_language = (sort {$language_count{$b} <=> $language_count{$a}} keys %language_count)[0];

$response = $ua->get($latest_update_endpoint);
my $latest_update = decode_json($response->decoded_content);
my $latest_update_date = $latest_update->[0]->{updated_at};

$response = $ua->get($readme_endpoint);
my $readme = decode_json($response->decoded_content);
my $current_readme_content = decode_base64($readme->{content});

my $new_readme_content = "I have $num_repos repositories on GitHub, and my most used language is $most_used_language. The date of the latest update is $latest_update_date.";

my $encoded_new_readme_content = encode_base64($new_readme_content);

if ($encoded_new_readme_content ne $readme->{content}) {
    my $response = $ua->put($readme_endpoint, Content => "{\"message\":\"Update README.md\",\"content\":\"$encoded_new_readme_content\",\"sha\":\"$readme->{sha}\"}");
    if ($response->is_success) {
        print "README file updated successfully.\n";
    } else {
        print "Failed to update README file: " . $response->status_line . "\n";
    }
} else {
    print "README file is already up to date.\n";
}