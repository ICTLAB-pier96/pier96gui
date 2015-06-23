# pier96gui
# What is Pier96?
Pier96 is a docker manager application. The main focus of the application is managing servers, managing docker containers and registering images.

# How to start it?
There are multiple options to start this application
* Clone gitrepo
```
bundle install
rake db:migrate
rails s
```
----
* Install docker
```
docker run -t 3000:8080 pier96/gui
```
