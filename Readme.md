### Page View Insights

Get Insights on the Pages visited.

### Demo Deployed App

https://morning-forest-67046.herokuapp.com

### Code base Structure

```
.
├── Readme.md
├── build_client_and_copy.rb
├── client
└── server
```

* **Client:** React JS Client Codebase
* **Server:** Rails 5 API Codebase
* **build_client_and_copy.rb:** Script to build client and copy `dist` to `server/public`

### Prerequisites

##### Client (React App)

* <a href='https://yarnpkg.com/en/docs/install'>yarn </a>(`brew install yarn`)

##### Server (Rails App)

* ruby (`2.4.0`)
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

Once database is created update `database.yml` in <a href='https://github.com/ankit8898/page-view-insights/blob/master/server/config/database.yml'>server directory</a>

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

Seed data task will populate 1M rows of data. We use Sequel `multi_insert` API for same.

### Running

You can run the application in development environment by 2 ways:

1) Running Client and Server independently

##### Client (React App)

```bash
 $ cd client
 $ yarn start #this starts webpack-dev-server over localhost:8080

```

Client Application can be accessed on <a href='localhost:8080'>localhost:8080</a>

##### Server (Rails App)

```bash
$ cd server
$ bundle exec rails s #this starts rails server over localhost:3000
```
Server Application can be accessed on <a href='localhost:3000'>localhost:3000</a>

This running mode is best for development as client will be repackaged every time a change is mode.

Only **catch** here is you will run into CORS issues due to port `:8080` trying to access over `:3000` (API). One easy solution to solve this is use the Chrome ADDON <a href='https://www.google.co.in/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwj1_rHU-cXWAhWMrI8KHbjpAR8QFgglMAA&url=https%3A%2F%2Fchrome.google.com%2Fwebstore%2Fdetail%2Fallow-control-allow-origi%2Fnlfbmbojpeacfghkpbjhddihlkkiljbi%3Fhl%3Den&usg=AFQjCNHSUFqc6ylxfxfbWzmmFJ6L5QUvyg'>Allow-Control-Allow-Origin: *</a>.

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
* **config** (`config.js`): Maintains the state of base url for API calls. Base Url's are set in respective `webpack` configs .

##### Server (Rails App)

Server Application is a Rails API based application. It is sliced down further by not including ActiveRecord, ActionMailer, ActionCable and ActionView.

* **seeder** (`lib/seeder`): This class is responsible for seeding test data. Inside `server/lib/tasks/db.rake` a `seed` task is present which calls the `seeder`.
* **controllers**: (`app/controllers`)
  * **concerns**: Includes a concern which is a params validator. We want to make sure that the date parameters which are being passed are valid. Incase they are not we get a error message.
  * ***page_views_controller.rb***: Includes methods for ***top_urls*** and ***top_referrers*** only
* **models**: (`app/models`)
  * **concerns**: Includes the most important `queries` concern.

  Queries concern is responsible for building all the queries which are used by top urls and top referrers.

  * **page_view.rb**: This is the interface exposed to access the queries. Queries module is extended in this class. Also, associations are defined to **url.rb** and **referrer_url.rb***.

* **serializers** (`app/serializers`): These acts as presenter layer. The JSON serialization takes place here in the required format. If we need to restructure the JSON it should be made here.

### Testing

##### Server (Rails App)


```
$ cd server
$ bundle exec rspec .
```

```ruby

FakeController
  .validate
    when valid date only params
      should equal true
    when invalid date only params
      should equal false
      should equal false
    when valid start and end
      should equal true
      should equal true
    when invalid start and end
      should equal false
    when invalid combination of params
      should equal false
      should equal false
      should equal false

PageViewsController
  GET #top_urls
    when looking for a date
      returns http success
      return a JSON response with key as date looked up
      returns a single item
      returns a top url visited to date
      returns a top url visits
    when looking for a invalid date
      returns error message
  GET #top_referrers
    when looking for a date
      returns http success
      return a JSON response with key as date looked up
      returns a collection of urls
    when looking for a invalid date
      returns error message

Queries
  Scopes
    CREATED_AT_SCOPE
      should be a type proc
      should be of type Sequel::LiteralString
      should return the string of where clause
    CREATED_AT_RANGE_SCOPE
      should be a type proc
      should be of type Sequel::LiteralString
      should return the string of where clause
    SELECTED_COLUMNS_SCOPE
      should eq :url_id
      should eq "date_trunc('day', created_at)::DATE"
      should eq :date_visited
      should eq "count(*)"
      should eq :visits
    #top_urls_on_date_query
      should eq "SELECT 'url_id', date_trunc('day', created_at)::DATE AS 'date_visited', count(*) AS 'visits' FROM 'p...('day', created_at)::DATE =  '2017-09-17') GROUP BY 'date_visited', 'url_id' ORDER BY 'visits' DESC"
    #top_urls_between_date_query
      should eq "SELECT 'url_id', date_trunc('day', created_at)::DATE AS 'date_visited', count(*) AS 'visits' FROM 'p...ATE BETWEEN '2017-09-15' AND '2017-09-16') GROUP BY 'date_visited', 'url_id' ORDER BY 'visits' DESC"
    #top_ten_url_ids_on_date_query
      should eq "SELECT 'url_id' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE =  '2017-09-27') GROUP BY 'url_id' ORDER BY count(*) DESC LIMIT 10"
    #top_ten_url_ids_between_date_query
      should eq "SELECT 'url_id' FROM 'page_views' WHERE (date_trunc('day', created_at)::DATE BETWEEN '2017-09-24' AND '2017-09-26') GROUP BY 'url_id' ORDER BY count(*) DESC LIMIT 10"
    #top_referrers_on_date_query
      should eq "SELECT 'url_id', 'referrer_url_id', count(*) AS 'visits', date_trunc('day', created_at)::DATE AS 'da...:DATE =  '2017-09-24')) GROUP BY 'url_id', 'referrer_url_id', 'date_visited' ORDER BY 'visits' DESC"
    #top_referrers_between_date_query
      should eq "SELECT 'url_id', 'referrer_url_id', count(*) AS 'visits', date_trunc('day', created_at)::DATE AS 'da...-24' AND '2017-09-25')) GROUP BY 'url_id', 'referrer_url_id', 'date_visited' ORDER BY 'visits' DESC"

PageView
  #validate
    when valid input
      should have 1 items
      should eq "http://apple.com"
      should eq "www.google.com"
  .after_create
    should update the hash with MD5 (PENDING: Temporarily skipped with xit)
  #top_urls
    Date lookup
      when valid date
        should have 1 items
      when invalid date
        should have 0 items
    Between start and end
      when valid_date range
        should have 6 items

ReferrerUrl
  .errors
    when valid input
      should have no error messages

Url
  .errors
    when invalid input
      should have error messages
    when valid input
      should have no error messages

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) PageView.after_create should update the hash with MD5
     # Temporarily skipped with xit
     # ./spec/models/page_view_spec.rb:27


Finished in 0.30484 seconds (files took 0.88869 seconds to load)
46 examples, 0 failures, 1 pending

```
