#!/usr/bin/expect -f

spawn ./ssl-q.sh
expect -exact "Country Name (2 letter code) \[AU\]:"
send -- "MA\n"
expect -exact "State or Province Name (full name) \[Some-State\]:"
send -- "KH\n"
expect -exact "Locality Name (eg, city) \[\]:"
send -- "KH\n"
expect -exact "Organization Name (eg, company) \[Internet Widgits Pty Ltd\]:"
send -- "1337\n"
expect -exact "Organizational Unit Name (eg, section) \[\]:"
send -- "1337-kh\n"
expect -exact "Common Name (e.g. server FQDN or YOUR name) \[\]:"
send -- "ft_server\n"
expect -exact "Email Address \[\]:"
send -- "zlayine@test.con\n"
expect eof
