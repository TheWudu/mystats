# Starting the application dockerized


To start the application without installing ruby and any dependencies, just
use the provided docker-compose.yml. You obviously need to have
docker + docker-compose installed. See

https://docs.docker.com/engine/install/

If this is installed, just download docker-compose.yml (or git clone this project)
and run:

```
docker-compose up
```

This will download the images for mongo and mystats application and start it.

After the first `up` you can use 

```
docker-compose start
```

instead to run it in the background.


When the container starts properly, you should be able to access the application
in a browser of your choice under

http://localhost/


If it complains about not being able to start at port 80, change the 80:3000 port
mapping in docker-compose.yml to something else. E.g. 3000:3000 and use

http://localhost:3000/


# Import Data

To be able to import data just enter the container. This for you need
the name of the started container. This can be listed by:

```
docker ps
```

E.g.

```
$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED      STATUS      PORTS                                           NAMES
decbcf640cec   thewudu/mystats:latest   "rails s -b 0.0.0.0"     2 days ago   Up 2 days   0.0.0.0:80->3000/tcp, :::80->3000/tcp           mystats_mystats_1
923ec6c573b5   mongo:latest             "docker-entrypoint.s…"   2 days ago   Up 2 days   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp   mystats_mongodb_1
```

Enter the container then using the NAME. 

```
docker exec -it mystats_mystats_1 bash
```

and run the following command

```
rake import:cities[./public/cities500.txt]
```

This will prepare the cities collection to have proper timezone management.

To ease initial import of gpx files or runtastic-exports you can run some 
rake tasks too.

To have this working you first need to place the files in the appropriate folders, which is
local path (where the docker-compose.yml file lives) + import.

So create a folder named import/gpx and copy the e.g. garmin gpx files there, or a folder
import/ and copy the SportSession folder of a runtastic-export there.

```
rake import:gpx_folder[/data/import/gpx]

# and/or

rake import:runtastic_export[/data/import/SportSessions]
```

