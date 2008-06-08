#!/bin/sh

rake doc:app
rsync -e 'ssh -p 2217' -ruvv --delete app/ destiney@destiney.com:/usr/local/apache2/htdocs/railsdb/docs

