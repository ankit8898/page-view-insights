### Page View Insights

Get Insights on the Pages visited.

### Demo App

https://morning-forest-67046.herokuapp.com

### Code base Structure

```
.
├── Readme.md
├── build_client_and_copy.rb
├── client
└── server
```

* **Client:** React Client Codebase
* **Server:** Rails API
* **build_client_and_copy.rb:** Script to build client and copy dist to server

### Prerequisites

##### Client (React App)

* <a href='https://yarnpkg.com/en/docs/install'>yarn </a>(`brew install yarn`)

##### Server (Rails App)

* ruby (2.4.0)
* bundler (`gem install bundler`)
* Postgres (`brew install postgresql`)

_Note:_ <a href='https://brew.sh/'>homebrew</a> is preferred in these Prerequisites installation.

### Installation

##### Client (React App)

```bash
 $ cd client
 $ yarn install
```

##### Server (Rails App)

```bash
$ cd server
$ bundle install
```

Now create a postgres database. You can use the <a href='https://www.postgresql.org/docs/9.0/static/sql-createdatabase.html'>CLI command</a> OR use a GUI like <a href='http://www.psequel.com/'>PSequel</a> .

Once database is created update `database.yml` in server directory

```yaml
# server/config/database.yml
development:
  adapter: postgres
  host: localhost
  database: <your_database_name>
  user: <your_username (if present)>
  password: <your_password (if present)>
```

Now let's create our Schema by running migrations and importing some seed data
```ruby
$ cd server
$ bundle exec rake db:migrate[3] #3 is the latest migration version
$ bundle exec rake db:seed #to import some dummy data
```

### Running

You can run the application in development 2 ways:

1) Running Client and Server independently

##### Client (React App)

```bash
 $ cd client
 $ yarn start #this starts webpack-dev-server over localhost:8080

```

##### Server (Rails App)

```bash
$ cd server
$ bundle exec rails s #this starts rails server over localhost:3000
```

This running mode is best for development as client will be repackaged every time a change is mode.

Only **catch** here is you will run into CORS issues due to port 8080 trying to access over 3000 (API). One easy solution to solve this is use the Chrome ADDON <a href='https://www.google.co.in/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwj1_rHU-cXWAhWMrI8KHbjpAR8QFgglMAA&url=https%3A%2F%2Fchrome.google.com%2Fwebstore%2Fdetail%2Fallow-control-allow-origi%2Fnlfbmbojpeacfghkpbjhddihlkkiljbi%3Fhl%3Den&usg=AFQjCNHSUFqc6ylxfxfbWzmmFJ6L5QUvyg'>Allow-Control-Allow-Origin: *</a>.

2) Bundle the Client App inside server

This is where `build_client_and_copy.rb` script is useful.

```ruby
# This script is at the root of codebase
$ ruby build_client_and_copy.rb development
```

Above script does a `yarn build:dev` and copies the `dist` content in `server/public`.  Now you can start the standard rails server without starting `webpack-dev-server`.

```
$ cd server
$ bundle exec rails s
```

Access via <a href='localhost:3000'>localhost:3000</a>. You should be seeing the home page.


### Architecture

##### Client (React App)

Client Application is a light weight react js application which has

* **Services** (`src/services`): Services are functions to make REST API calls. It uses <a href='https://github.com/mzabriskie/axios'>axios</a> for making calls.
* **Components** (`src/components`): Standard React components to fetch top urls and referrers. Components also import some of the pre baked react-bootstrap components.
* **config** (`config.js`): Maintains the state of base url for API calls. Base Url's are set in respective `webpack` configs.

##### Server (Rails App)

Server Application is a Rails API based application. It is sliced down further by not including ActiveRecord, ActionMailer, ActionCable and ActionView.

* **controllers**
  * **concerns**: Includes a concern which is a params validator. We want to make sure that the date parameters which are being passed are valid. Incase they are not we get a error message.
  * ***page_views_controller.rb***: Includes methods for ***top_urls*** and ***top_referrers*** only
* ***models***
  * ***concerns***: Includes the most important `queries` concern.

  ```ruby
  module Queries

    extend ActiveSupport::Concern

    included do
      # Created at Scope that converts to YYYY-MM-DD
      # SELECT ... date_trunc('day', created_at)::DATE = '2017-09-14')...
      CREATED_AT_SCOPE       = -> (date) do
        Sequel.lit("date_trunc('day', created_at)::DATE =  '#{date}'")
      end

      # Created at Range Scope that converts to YYYY-MM-DD
      # SELECT ... date_trunc('day', created_at)::DATE BETWEEN '2017-09-13'..'2017-09-14')...
      CREATED_AT_RANGE_SCOPE = -> (start_date, end_date) do
        Sequel.lit("date_trunc('day', created_at)::DATE BETWEEN '#{start_date}' AND '#{end_date}'")
      end

      # Selected Columns Scope
      SELECTED_COLUMNS_SCOPE = -> do
        [
          :url_id,
          Sequel.lit("date_trunc('day', created_at)::DATE").as(:date_visited),
          Sequel.lit("count(*)").as(:visits)
        ]
      end

      #  SELECT 'url', date_trunc('day', created_at)::DATE AS 'date_visited',
      #  count(*) AS 'visits' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE =  '2017-09-17')
      #  GROUP BY 'date_visited', 'url' ORDER BY 'visits' DESC LIMIT 1
      def self.top_urls_on_date_query(date)
        eager(:url)
        .select(&SELECTED_COLUMNS_SCOPE)
        .where(CREATED_AT_SCOPE.call(date))
        .group(:date_visited, :url_id)
        .order(Sequel.desc(:visits))
      end

      # SELECT 'url', date_trunc('day', created_at)::DATE AS 'date_visited', count(*)
      # AS 'visits' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-15'
      # AND '2017-09-16') GROUP BY 'date_visited', 'url'
      def self.top_urls_between_date_query(start_date, end_date)
        eager(:url)
        select(&SELECTED_COLUMNS_SCOPE)
        .where(CREATED_AT_RANGE_SCOPE.call(start_date, end_date))
        .group(:date_visited, :url_id)
        .order(Sequel.desc(:visits))
      end

      # SELECT "url_id" FROM "page_views" WHERE (date_trunc('day', created_at)::DATE =  '2017-09-20')
      # GROUP BY "url_id" ORDER BY count(*) DESC LIMIT 10
      def self.top_ten_url_ids_on_date_query(date)
        eager(:url)
        .select(:url_id)
        .where(CREATED_AT_SCOPE.call(date))
        .group(:url_id)
        .order(Sequel.desc(Sequel.lit("count(*)")))
        .limit(10)
      end

      # SELECT url_id FROM page_views WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-24'
      # AND '2017-09-26') GROUP BY url_id ORDER BY count(*) DESC LIMIT 10
      def self.top_ten_url_ids_between_date_query(start_date, end_date)
        eager(:url)
        .select(:url_id)
        .where(CREATED_AT_RANGE_SCOPE.call(start_date, end_date))
        .group(:url_id)
        .order(Sequel.desc(Sequel.lit("count(*)")))
        .limit(10)
      end

      # SELECT 'url_id', 'referrer_url_id', count(*) AS 'visits',
      # date_trunc('day', created_at)::DATE AS 'date_visited' FROM 'page_views'
      # WHERE (('url_id' IN (SELECT 'url_id' FROM 'page_views'
      # WHERE (date_trunc('day', created_at)::DATE =  '2017-09-24') GROUP BY
      # 'url_id' ORDER BY count(*) DESC LIMIT 10)) AND
      # (date_trunc('day', created_at)::DATE =  '2017-09-24')) GROUP BY 'url_id',
      # 'referrer_url_id', 'date_visited' ORDER BY 'visits' DESC
      def self.top_referrers_on_date_query(date)
        eager(:url,:referrer_url)
        .select(:url_id, :referrer_url_id, Sequel.lit("count(*)").as(:visits), Sequel.lit("date_trunc('day', created_at)::DATE").as(:date_visited))
        .where(url_id: top_ten_url_ids_on_date_query(date))
        .where(CREATED_AT_SCOPE.call(date))
        .group(:url_id,:referrer_url_id, :date_visited).order(Sequel.desc(:visits))
      end

      # SELECT url_id, referrer_url_id, count(*) AS visits, date_trunc('day', created_at)::DATE AS date_visited FROM page_views
      # WHERE ((url_id IN (SELECT url_id FROM page_views WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-24' AND '2017-09-26')
      # GROUP BY url_id ORDER BY count(*) DESC LIMIT 10)) AND (date_trunc('day', created_at)::DATE BETWEEN '2017-09-24' AND '2017-09-26'))
      # GROUP BY url_id, referrer_url_id, date_visited ORDER BY visits DESC
      def self.top_referrers_between_date_query(start_date, end_date)
        eager(:url, :referrer_url)
        .select(:url_id, :referrer_url_id, Sequel.lit("count(*)").as(:visits), Sequel.lit("date_trunc('day', created_at)::DATE").as(:date_visited))
        .where(url_id: top_ten_url_ids_between_date_query(start_date, end_date))
        .where(CREATED_AT_RANGE_SCOPE.call(start_date, end_date))
        .group(:url_id,:referrer_url_id, :date_visited).order(Sequel.desc(:visits))
      end

      # SELECT date_trunc('day', created_at)::DATE AS date_visited from page_views
      def self.dates_query
        select(Sequel.lit("date_trunc('day', created_at)::DATE")
               .as(:date_visited))
        .order(Sequel.desc(:date_visited))
        .distinct(:date_visited)
      end
    end
  end
```
Queries concern is responsible for building all the queries which are used by top urls and top referrers.
  * **page_view.rb**: This is the interface exposed to access the queries. Queries module is extended in this class. Also, associations are defined to **url.rb** and **referrer_url.rb***.
