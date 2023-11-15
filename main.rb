require 'net/ssh'
require 'yaml'
require 'optparse'
require 'terminal-table'

options = {}
profile_alias = ""

OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"
  opts.on("-f", "--file FILEPATH", "Path to YAML config") { |file| options[:file] = file }
  opts.on("-p", "--profile STRING", "Profile alias") { |profile| profile_alias = profile }
end.parse!

abort "Missing --file option" unless options[:file]

begin
  profiles = YAML.load_file(options[:file])
rescue Errno::ENOENT
  abort "Could not find config: #{options[:file]}"
rescue Psych::SyntaxError => e
  abort "YAML syntax error: #{e.message}"
end

selected_profile = profile_alias ? profiles.find { |prf| prf['alias'].casecmp(profile_alias).zero? } : profiles.first
abort "Unknown profile: #{profile_alias}" unless selected_profile

options[:profile] = selected_profile

Net::SSH.start(
  selected_profile['host'],
  selected_profile['user'],
  password: selected_profile['password'],
  keys: [selected_profile['private_key']].compact,
  port: selected_profile['port'] || 22
) do |ssh|
  rows = selected_profile.fetch('pairs', []).map do |pair|
    direction = pair['direction'] == 'L' ? '→' : '←'
    pair['direction'] == 'L' ? ssh.forward.local(pair['local'], selected_profile['host'], pair['remote']) : ssh.forward.remote(pair['local'], "", pair['remote'], selected_profile['host'])
    [pair['remote'], direction, pair['local']]
  end

  puts Terminal::Table.new(headings: ['Remote', "↔", 'Local'], rows: rows)
  puts "Connection will remain open until you hit Ctrl+C"

  Signal.trap("SIGINT") do
    puts "\nClosing ssh tunnel, exiting..."
    ssh.shutdown!
    exit
  end
  ssh.loop { true }
end
