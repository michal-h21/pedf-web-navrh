FROM michalh21/lettersmith

RUN apk --no-cache add discount-dev
# RUN luarocks --server=https://rocks.luarocks.org install --local h5tk discount 
RUN luarocks install h5tk 
RUN luarocks install date

ARG HTML_DIR 
ARG WWW_DIR
ARG DATA_DIR
ENV HTML_DIR /opt/html/
ENV WWW_DIR /opt/www/
ENV DATA_DIR /opt/data/

WORKDIR /opt/pedf_web/
COPY *.lua ./
COPY lib/ ./lib/
COPY trans/ ./trans/
COPY templates/ ./templates/

CMD ["echo", "Build start"]
