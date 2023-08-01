# docker-roonserver
`docker-roonserver` for installing and running RoonServer in a docker environment.

This little project configures a docker image for running RoonServer.
It downloads RoonServer if not found on an external volume.

Example start:

    docker run -d \
      --net=host \
      -e TZ="America/Los_Angeles" \
      -v roon_app:/app \
      -v roon_data:/data \
      -v /media/music:/music:ro \
      -v /media/backups:/backup \
      alron/docker-roonserver:latest

  * You should set `TZ` to your timezone.
  * Change `/media/music` and `/media/backups` to your proper media and backup location on the host server.
  * You should set your library root to `/music` and configure backups to `/backup` on first run.
  * You should manually create the volumes used by the docker image to protect them from being automatically 
    removed during a clean. Ex: `docker volume create roon_data && docker volume create roon_app`


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
      -e TZ="America/Los_Angeles" \
      -v roon_app:/app \
      -v roon_data:/data \
      -v /media/music:/music:ro \
      -v /media/backups:/backup \
      alron/docker-roonserver
    ExecStop=/usr/bin/docker stop %n
    Restart=always
    RestartSec=10s
    
    [Install]
    WantedBy=multi-user.target


Example `docker-compose` service running in a vlan environment:

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


  Don't forget to run `docker volume create roon_data && docker volume create roon_app` before starting the compose if
  basing off of this example.


## Version history
  * 2023-07-31: rebased image to `ubuntu:jammy` and added dumb-init to handle signal routing, updated to libicu70, and 
    migrated to using TLS downloads for container.
  * 2021-10-19: fork from `steefdebruijn/docker-roonserver`, rebase image to `ubuntu:latest`, install `ksh` for forkers 
    personal preference, replace `bash` run script with `ksh` for forkers personal preference, update examples, and 
    install `libicu66` to support the upcoming Roon Mono to .NET change.
  * 2020-05-24: update base image to `debian-10.9-slim` and check for shared `/app` and `/data` folders.
  * 2019-03-18: Fix example start (thanx @heapxor); add `systemd` example.
  * 2019-01-23: updated base image to `debian-9.6`
  * 2017-08-08: created initial images based on discussion on roonlabs forum

