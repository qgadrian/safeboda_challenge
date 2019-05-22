# Compiler image
FROM elixir:1.8 as builder

WORKDIR /app

ARG MIX_ENV
ENV MIX_ENV ${MIX_ENV}

RUN \
  mix local.hex --force \
  && mix local.rebar --force \
  && mix hex.info

COPY config ./
COPY deps ./
COPY mix.exs mix.lock ./

RUN mix deps.get
RUN mix deps.compile

RUN rm -rf /app/_build/${MIX_ENV}/rel/safeboda

COPY ./ ./

ENV CLUSTER_DEBUG true

RUN mix release --env=${MIX_ENV} --warnings-as-errors

# Deployment image
FROM elixir:1.8 as release

LABEL maintainer="qgadrian@users.noreply.github.com"

ARG MIX_ENV

ENV REPLACE_OS_VARS true

WORKDIR /app

# nslookup
RUN apt-get update
RUN apt-get install -y dnsutils

COPY --from=builder /app/_build/${MIX_ENV}/rel/safeboda ./

EXPOSE 4000

CMD ["foreground"]
ENTRYPOINT ["./bin/safeboda"]
