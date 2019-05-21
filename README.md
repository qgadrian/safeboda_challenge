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

### Considerations

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
