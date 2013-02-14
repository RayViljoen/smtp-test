
pkg   = require './package'
os    = require 'os'
fs    = require 'fs'
path  = require 'path'
cli   = require 'commander'
clc   = require 'cli-color'
child = require 'child_process'

# Log methods
log =
	ok: (m) -> console.log clc.green(m)
	err: (m) -> console.log clc.red(m)
	cmd: (m) -> console.log "• #{m}"
	info: (m) -> console.log m

# Configure Commander
cli
	.version(pkg.version)
	.usage('[options] <file>')
	.option('-c, --create [destination]', 'create sample test file')
	.parse(process.argv)

# Get machine hostname
domain = do os.hostname

# Default smtp
smtp =
	server: 'localhost'
	port: 2525
	from: "user@#{domain}"
	to: 'user@localhost'
	data: 'Hello from smtp-test..!'
	header:
		'From': "user@#{domain}"
		'To': 'user@localhost'
		'Reply-To': "user@#{domain}"
		'Date': new Date()
		'Subject': 'SMTP Test'
		'Content-Type': 'plain/text'

# ----------------------------------
# Check if sample file needs saving
# ----------------------------------
if cli.create
	
	# Get destination dir
	if cli.create.length then destination = cli.create
	else destination = 'sample.smtp.json'

	data = JSON.stringify smtp, null, 2
	try
		fs.writeFileSync destination, data
		log.ok "Test file create at #{destination}"
	catch e then log.err e

	# Exit
	do process.kill

# -----------------------------
# Else continue with test file
# -----------------------------

# Try and include test file
try
	# Get relative path
	path = path.resolve process.cwd(), cli.args[0]
	smtp = require path
	log.ok "Using test file: #{path}"
catch e
	log.err 'Invalid test file.'
	do process.kill

# Confirm connection attempt
log.ok "Connecting to #{smtp.server} on port #{smtp.port}"

# Create telnet child process
telnet = child.spawn 'telnet', [smtp.server, smtp.port]

# Set encoding
telnet.stdout.setEncoding 'utf8'
telnet.stderr.setEncoding 'utf8'
telnet.stdin.setEncoding 'utf8'

# SMTP protocol steps
protocol = ['HELO', 'MAIL FROM', 'RCPT TO', 'DATA', 'QUIT']

# Telnet command write alias
say = (message = '') -> telnet.stdin.write "#{message}\n"

# Calls smtp protocol cammands
talk = ->

	# Get current command
	return unless cmd = do protocol.shift

	# Log current command
	log.cmd cmd

	# Apply individula protocol commands
	switch cmd

		when 'HELO' then say "#{cmd} #{smtp.domain}"
		
		when 'MAIL FROM' then say "#{cmd}: <#{smtp.from}>"
		
		when 'RCPT TO' then say "#{cmd}: <#{smtp.to}>"
		
		when 'QUIT' then say "#{cmd}"
		
		# On DATA also write headers
		when 'DATA'

			say "#{cmd}"

			# Write headers
			for header, value of smtp.headers
				say "#{header}: #{value}"
			
			# Close headers
			do say
			
			# Write DATA body
			say "#{smtp.data}"
			
			# End DATA
			say "."

# Listen for telnet stdout
telnet.stdout.on 'data', (data) ->
	
	# Kill telnet if QUIT confirmed
	# if data.match /221/ then do telnet.kill

	# Check for 2xx response and call next command
	if data.match /2[0-9]{2}/
		log.ok data
		do talk

	else if data.match /[345]{1}[0-9]{2}/
		do telnet.kill
		log.err data

	# Log anything
	else log.info data

# Log any percieved errors red
telnet.stderr.on 'data', (data) -> log.info data


