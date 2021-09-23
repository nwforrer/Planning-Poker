FROM docker.io/library/httpd:2.4

RUN apt-get update && apt-get install -y unzip wget

RUN useradd -G root -m godot

WORKDIR /opt/server

RUN wget https://downloads.tuxfamily.org/godotengine/3.3.3/Godot_v3.3.3-stable_export_templates.tpz -O Godot_v3.3.3-stable_export_templates.tpz
RUN wget https://downloads.tuxfamily.org/godotengine/3.3.3/Godot_v3.3.3-stable_linux_headless.64.zip -O Godot_v3.3.3-stable_linux_headless.64.zip
RUN mkdir -p /home/godot/.local/share/godot/templates/ && \
    unzip Godot_v3.3.3-stable_export_templates.tpz -d /home/godot/.local/share/godot/templates &&\
    mv /home/godot/.local/share/godot/templates/templates /home/godot/.local/share/godot/templates/3.3.3.stable &&\
    unzip Godot_v3.3.3-stable_linux_headless.64.zip

COPY ./my-httpd.conf /usr/local/apache2/conf/httpd.conf
COPY . .

RUN mkdir /usr/local/apache2/htdocs/public-html &&\
    chown godot:root -R /usr/local/apache2 &&\
    chown godot:root -R /opt/server &&\
    chown godot:root -R /home/godot/.local
USER godot

RUN ./Godot_v3.3.3-stable_linux_headless.64 --export "HTML5" /usr/local/apache2/htdocs/planning-poker.html &&\
    mv /usr/local/apache2/htdocs/planning-poker.html /usr/local/apache2/htdocs/index.html

WORKDIR /usr/local/apache2/htdocs/