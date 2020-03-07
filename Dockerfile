FROM ubuntu:18.04

MAINTAINER Yuki Watanabe <watanabe@future-needs.com>

ARG USER_ID
ARG GROUP_ID

ENV HOME /qtum

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${GROUP_ID} qtum \
	&& useradd -u ${USER_ID} -g qtum -s /bin/bash -m -d /qtum qtum

ARG PARENT_QTUM_VERSION=${PARENT_QTUM_VERSION:-0.19.0}
ARG CHILD_QTUM_VERSION=${CHILD_QTUM_VERSION:-0.19.0.1}
ENV QTUM_PREFIX=/opt/qtum-${PARENT_QTUM_VERSION}
ENV QTUM_DATA=/qtum/.qtum
ENV PATH=/qtum/qtum-${CHILD_QTUM_VERSION}/bin:$PATH

RUN set -xe \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        unzip \
        curl \
        && curl -SLO https://github.com/qtumproject/qtum/releases/download/mainnet-ignition-v${PARENT_QTUM_VERSION}/qtum-${CHILD_QTUM_VERSION}-x86_64-linux-gnu.tar.gz \
        && tar -xzf *.tar.gz -C /qtum \
        && rm *.tar.gz \
        && apt-get purge -y \
        ca-certificates \
        curl \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# grab gosu for easy step-down from root
ARG GOSU_VERSION=${GOSU_VERSION:-1.11}
RUN set -xe \
	&& apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y \
		ca-certificates \
		wget \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./bin /usr/local/bin

VOLUME ["/qtum"]

EXPOSE 3888 3889 13888 13889

WORKDIR /qtum

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["qtum_oneshot"]
