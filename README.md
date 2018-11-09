To pull down a sample set of prod data and add it to your local Redis, run ```bundle exec rake db:seed```.

A couple of quick notes about this repo:

Our price database hasn't been compacted yet. This means that every price value we log gets stored along with the timestamp. Hit ```3000/prices/new/all?asins=<ASIN>``` to see an example. In the rank db, we compact the values into month-sized chunks and store those instead, which helps us cut down on db size/aws fees.

The main endpoint in use is the /average one. There's a handful of ones that got tossed together as quick prototypes for some chrome extensions we had in the pipeline months ago (like /extrema and /last-year) that may not even be in use anymore.

The buyback feature was ported over to a different app and isnt currently in use, but the other version (currently in use by zen trade) is even messier and there's a change we may go back to this one.

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
