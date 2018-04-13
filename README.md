# docker-mautic
Run [Mautic](https://github.com/mautic/mautic) Inside Docker

[Live Demo](https://demo.legionx.org/launch)

To make Mautic run better inside a Docker container, I configured it to store all the user configurations and assets in a special directory ```/www/html/app/local```.  This is done using the ```parameters_local.php```.  

Starting this Docker container with a bind mount would effectively make your data persistent, e.g. ```docker run -v `pwd`/local:/www/html/app/local mautic```.

In addition, the Mautic install settings file ```local.php``` is also persisted in the same directory.  This is done using ```paths_local.php```.

Finally Mautic requires a MySql DB to run.  I use this https://github.com/mingfang/docker-mysql.
