EB Commands:

rails console:

$ eb ssh
`ssh> cd /var/app/current && bin/rails c`

rails logs:

$ eb ssh
`ssh> cd /var/app/current && tail -f log/*.log`

deploy:

$ eb deploy

status:

$ eb status
