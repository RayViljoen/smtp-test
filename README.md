# Node SMTP-Test

**CLI tool for testing SMTP over Telnet.**

---

**smtp-test** is a very crude testing tool to save the hassle of using Telnet or Netcat manually.

To install the tool run `npm install -g smtp-test`.

### Running test

The tool makes available the `smtptest` command and requires a test file as the first parameter.

e.g. `smtptest localmail.test.json`

To generate a sample test file simply run `smtptest -c filename.json`

The test file format is as follows:

	{
	  "server": "localhost",
	  "port": 3000,
	  "from": "user@localhost",
	  "to": "user@destination.com",
	  "data": "Hello from smtp-test..!",
	  "header": {
	    "From": "user@localhost",
	    "To": "user@destination.com",
	    "Reply-To": "user@localhost",
	    "Date": "2013-02-13T23:06:14.507Z",
	    "Subject": "SMTP Test",
	    "Content-Type": "plain/text"
	  }
	}
	
***Additional headers can also be specified.**

**Note:**

The `.json` test file is simply being included with the standard `require` method, so you could also use a `.js` or `.coffee` file to include dynamic parameters like `new Date()` for the date header.
