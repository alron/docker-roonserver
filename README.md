# docker-roonserver
RoonServer downloading Roon on first run

This little project configures a docker image for running RoonServer.
It downloads RoonServer if not found on an external volume.

Example start:

    docker run -d \
      --net=host \
      -e TZ="Europe/Amsterdam" \
      -v roon-app:/app \
      -v roon-data:/data \
      -v roon-music:/music \
      -v roon-backups:/backup \
      alron/docker-roonserver:latest
  
  * You should set `TZ` to your timezone.
  * You can change the volume mappings to local file system paths if you like.
  * You *must* use different folders for `/app` and `/data`.
    The app will not start if they both point to the same folder or volume on your host.
  * You should set up your library root to `/music` and configure backups to `/backup` on first run.


Example `systemd` service:

    [Unit]
    Description=Roon
    After=docker.service
    Requires=docker.service
    
    [Service]
    TimeoutStartSec=0
    TimeoutStopSec=180
    ExecStartPre=-/usr/bin/docker kill %n
    ExecStartPre=-/usr/bin/docker rm -f %n
    ExecStartPre=/usr/bin/docker pull alron/docker-roonserver
    ExecStart=/usr/bin/docker \
      run --name %n \
      --net=host \
      -e TZ="Europe/Amsterdam" \
      -v roon-app:/app \
      -v roon-data:/data \
      -v roon-music:/music \
      -v roon-backups:/backup \
      steefdebruijn/docker-roonserver
    ExecStop=/usr/bin/docker stop %n
    Restart=always
    RestartSec=10s
    
    [Install]
    WantedBy=multi-user.target


  Don't forget to backup the `roon-backups` *for real* (offsite preferably).

Example `docker-compose` service:

    version: '3.5'
    services:
      roon:
        container_name: roon
        image: alron/docker-roonserver
        restart: unless-stopped
        environment:
          - TZ=America/Los_Angeles
        networks:
          docker-vlan2:
              ipv4_address: 10.0.0.9
        hostname: roon
        devices:
          - /dev/snd
        volumes:
          - roon_app:/app
          - roon_data:/data
          - /media/music:/music:ro
          - /media/roon/backups:/backup
        dns:
          - 1.1.1.1
          - 8.8.8.8
    volumes:
      roon_data:
          external:
              name: roon_data
      roon_app:
          external:
              name: roon_app


  Don't forget to run `docker volume create roon_data && docker volume create roon_app` before starting the compose. 


## Version history

  * 2021-10-19: rebase image to `ubuntu:latest`, install `ksh` for forkers personal preference, and install 
    `libicu66` to support the upcoming Roon Mono to .NET change.
  * 2020-05-24: update base image to `debian-10.9-slim` and check for shared `/app` and `/data` folders.
  * 2019-03-18: Fix example start (thanx @heapxor); add `systemd` example.
  * 2019-01-23: updated base image to `debian-9.6`
  * 2017-08-08: created initial images based on discussion on roonlabs forum

