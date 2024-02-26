FROM perl:5.34
COPY cpanfile calls_parse.pl /usr/src/myapp/
WORKDIR /usr/src/myapp
RUN cpanm --installdeps .
RUN mkdir /data
WORKDIR /data
