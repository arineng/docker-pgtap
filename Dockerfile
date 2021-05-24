FROM postgres:10

RUN apt-get update \
    && apt-get install -y build-essential git-core libv8-dev curl libexpat-dev postgresql-server-dev-$PG_MAJOR \
    && rm -rf /var/lib/apt/lists/*

# install pg_prove
RUN curl -LO http://xrl.us/cpanm \
    && chmod +x cpanm \
    && ./cpanm TAP::Parser::SourceHandler::pgTAP


# install pgtap
ENV PGTAP_VERSION v1.1.0
RUN git clone https://github.com/theory/pgtap.git \
    && cd pgtap && git checkout tags/$PGTAP_VERSION \
    && make

# install junit harness 
RUN cpan App::cpanminus && cpanm TAP::Harness::JUnit

ADD ./test.sh /test.sh
RUN chmod +x /test.sh

WORKDIR /

CMD ["/test.sh"]
ENTRYPOINT ["/test.sh"]
