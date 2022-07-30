# mystats
Small rails application to render stats nicely

# Setup

To setup the application first of all clone it locally and then bundle it.

```
bundle install
```

Then you have to start up mongo, either a local instance or using the provided 
docker-compose file.

First time:

```
docker-compose up
```

Then:

```
docker-compose starte
```

would be sufficient.

To have a better performance, create the indexes:

```
rake setup:create_indexes
```

# Usage

Instead of using [mongo_cpp](https://github.com/TheWudu/mongo_cpp/) to import sessions to 
the database, you can now use the provided rake tasks to import multiple sport-sessions
at once, or import the gpx files separately with the UI.

Before importing sessions, you should import cities into the database. Thisfore a rake
task is provided:

```
rake import:cities[./public/cities500.txt]
```

You may prefer other cities files, you can download them from geonames.org.

http://download.geonames.org/export/dump/

## Import a runtastic export

To easily import a runtastic gdpr export, just download the export from runtastic,
extract it somewhere and then call the rake task providing the path to the 
Sport-sessions folder.

```
rake import:runtastic_export[/home/myuser/Downloads/export-20220704-000/Sport-sessions]
```

## Import multiple GPX files

To import multiple GPX files at once, you can run the following rake task, providing
the folder where those files are located:

```
rake import:gpx_folder[/home/myuser/Downloads/my_gpx_files_folder]
```

## Starting the application

Start rails 

```
rails s
```

# Pages

## Statistics

To view statistics visit

```
http://localhost:3000/charts
```

You should see something like this, depending on your data and your filters:

![stats01](./doc/20220730_stats01.png)
![stats02](./doc/20220730_stats02.png)

## Sport-Sessions

To view sessions overview visit

```
http://localhost:3000/sport_sessions
```

You should see something like this, depending on your data and your filters:

![sessions01](./doc/20220730_sessions01.png)

## Import

To import gpx files to the database, you now can also import it via the
web application. Visit

```
http://localhost:3000/import
```

Browse for the file and press import. It will upload the gpx file,
read and parse the content, refine the elevation using srtm3 data (if available)
and store it to the database.

## Courses

Courses are a feature to group same or similar sport sessions together, and be able
to compare them. A course can be created out of a sport-session. When showing a 
course it lists all assigned sport-sessions and it tries to match not assigned sessions
based on it's duration (+/- X meters) and applying the trace matcher on 
each of them. The match-rate is shown too, and can be clicked. By clicking on it,
the trace matcher page is opened with the course + the session, so you can 
see why it matches more or less. 

![courses](./doc/20220730_courses.png)

## Trace Matching

To compare two sport-sessions with traces, and check how good they match, open the 
trace matcher:

```
http://localhost:3000/trace_matcher
```

This page let you filter the sport-sessions by the known filters. When selecting 
two traces and pressing apply, it shows the traces and the rate of matching. 

Parameters:

* block size: the trace is blockified to block-size in meters, as two traces / gps points rarely 
  match 100 % this abstract the trace to a comparable size. 
* min overlap: how much blocks in % have to have a counterpart in the other trace.

![trace_matcher](./doc/20220730_trace_matcher.png)

## Cities

To view a list of imported cities (which are used for timezone finding) visit

```
http://localhost:3000/cities
```

You can also filter by Name (regex search), lat/lng (nearby), or timezone, or valid
combinations.

![cities01](./doc/20220627_cities.png)

