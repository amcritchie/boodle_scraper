# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# boodle_scraper



```

gem install bundler

source ~/.zprofile  
rbenv init 
rbenv install 3.1.0 
bundle
```

```
gem install rails
```


```
brew install postgresql@14 
brew services start postgresql@14 
psql --version  
```


# Create Alex user (seems to be default)
```
createuser -s alex     
```

Checkout databases
```
psql -U alex -h localhost -l  
```

# Create postgres user (special rpostgres role needed for restore)
```
createuser -s postgres 
```

# Restore DB
```
pg_restore -U alex -h localhost -d boodle_scraper_development /Volumes/Untitled/boodle1.dump
```