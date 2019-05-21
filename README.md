# SafeBoda technical challenge

## Introduction

This project contains a [Elixir](https://elixir-lang.org/)
[umbrella](https://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-projects.html)
that solves a [SafeBoda](https://safeboda.com/ug/) challenge.

## Challenge

### Description

SafeBoda want to give out promo codes worth x amount during events so people can
get free rides to and from the event. The flaw with that is people can use the
promo codes without going for the event.

### Features

* Generation of new promo codes for events
* The promo code is worth a specific amount of ride
* The promo code can expire
* Can be deactivated
* Return active promo codes
* Return all promo codes
* Only valid when user’s pickup or destination is within x radius of the event venue
* The promo code radius should be configurable
* To test the validity of the promo code, expose an endpoint that accept origin, destination,
    the promo code. The api should return the promo code details and a polyline using the
    destination and origin if promo code is valid and an error otherwise.

## Tech stack

This project uses [Postgres](https://www.postgresql.org/) as a database and
[Elixir](https://elixir-lang.org/) is the language chosen to build the project
(with the permission of [Erlang](http://www.erlang.org/)).

## Prepare your system

This project uses [asdf](https://github.com/asdf-vm/asdf) for tool version
managing. In order to get your system ready you must:

* [Install asdf](https://github.com/asdf-vm/asdf#setup)
* Install the necessary plugins for this project:
  * Erlang: `asdf plugin-add erlang`
  * Elixir: `asdf plugin-add elixir`
* Install project local versions: `asdf install`

## Architecture

The project contains three main applications:

* `promo_code`: Business logic for promo codes.
* `promo_code_web`: Contains the HTTP server and provides the interface and
    endpoints to interact with the backend.
* `promo_code_store`: Application that contains the model and persists the data.


> There is a fourth application in the umbrella project called
> `promo_code_generator`, which provides helper functions to generate data to be
> used in property based testing.

The following diagram shows the flow of the architecture:

<img src="./static/architecture.png" style="display: block; margin: auto" />


## Running the tests

This application uses [property based testing](https://propertesting.com/) to
try to increase the confidence of the code.

Running the test can be done with:

```
mix test
```

## Running the application

First of all, you should retrieve the dependencies and compile the code.

```
mix deps.get && mix compile
```

Since this project relays on a database, you can start a Postgres docker
image with `docker-compose up postgres` if you don't have a local instance
running.

When Postgres is up, you have to create the database with `mix ecto.create` and
run the migrations with `mix ecto.migrate`.

> The database configuration is the only runtime configuration, in case you are
> running a local Postgres instance you can setup credentials, for example, by
> setting the environment variable (see `SafeBoda.PromoCodeStore.Repo` module for
> more info).

After that, to run the application server just run `mix phx.server` at the root of this
project.

The website application runs on port 4000 by default.

## Release

### Docker

There is a [Docker](https://docs.docker.com/) image provided that allows to
build an image with the runtime tools to run this application. A
`docker-compose` file is as well provided, that will start all the services
dependencies in containers to run the needed integrations.

To build a docker image run: `docker build --build-arg MIX_ENV=prod . -t
sabe_boda`.

To run the `docker compose` just execute `docker-compose up`.

## Deployment

Although this might fall far from the scope of the challenge, there are some
example code of how a _production like_ would show.

## Infrastructure as code

Under `deployment/terraform/` you can find an example template on how VM can be
created in [Google cloud](https://cloud.google.com/). This template provides
[infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code),
keeping an history of the changes an letting the development teams owning their
projects (as the [devops
cycle](https://about.gitlab.com/stages-devops-lifecycle/) suggests).

### Remaining work, considerations...

In order to keep simplicity of the implementation, take note of the following
considerations:

* **There is no pagination** implemented for the feature `get all promo codes`
    to keep the implementation as simple as possible. A production ready
    application **should implement pagination**.
* There geographical calculations are made within the business logic. Depending
    on the requirements, it might be a good option using
    [PostGIS](https://postgis.net/) to work with geo locations.
* The promo code event location is saved into the promotional code itself, to
    avoid having to manage events as well. Depending on the needs, it will be
    better having relations in the database to attach a promo code to an event.
* There are default values hardcoded, they should be provided as an environment
    variable to make then dynamic within different environments and allowing
    changing the configuration at runtime.
* There are no user's management, therefore the **maximum amount of rides** will
    not affect this application. This will be easily solved by creating a
    relation between the users and the promo codes used, for example.
* The front application it's keeping the simplest approach, no field validations
    nor error messaging. Also there is used a CSS framework to keep this layer
    of the project as simple as possible.
* Regarding the front, there are no tests for the views. Critical parts of any
    frontend application **should be always tested**, but because of the lack of
    time it was not possible for this challenge. It's always an interesting
    choice not using server rendering, and go for client running frontend
    applications ([elm](https://elm-lang.org/blog/compilers-as-assistants) is a
    nice functional language for front).
* It will be nice having a cache in front of the database layer, if possible.
    Erlang provides [mnesia](http://erlang.org/doc/man/mnesia.html) in the OTP
    that can be used for this goal. Nothing was implemented to simplify the
    architecture.
* Configuration should be less static, it should rely on environment variable **to
    reuse builds** in any environment, allowing a continuous delivery pipeline
    deploying same release several times.
* This application it was not conceived as a cluster application, although it
    can be quickly modify to create a cluster of Erlang nodes that will run
    distributed work (this will depend of the business needs).
* There is no [Kubernetes](https://kubernetes.io/) template provided, but it
    will trivial, once a Docker image was built, orchestrating container in a
    Kubernetes cluster in the cloud. This has nice perks as zero time
    deployment, canary releases, auto scaling... out of the box, without the
    minimum complexity added to the project.
* There is no [Continuos
    deployment](https://medium.com/orbitdigital/the-continuous-deployment-process-417ad429f325) pipeline example neither. I wanted to play
    around with [Github actions](https://github.com/features/actions) but
    at the time I couldn't a spot to do it. [Gitlab
    CI](https://about.gitlab.com/product/continuous-integration/) also has a
    very good CD tool, very powerful.
* There is missing [tracing](https://en.wikipedia.org/wiki/Tracing_(software)) and [monitoring](https://en.wikipedia.org/wiki/Application_performance_management), and this **would be critical to have** on a running production environment. It could combine a time series database as [InfluxDB](https://www.influxdata.com/products/influxdb-overview/), for example, with a UI as [Grafana](https://grafana.com/).
