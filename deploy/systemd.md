# Systemd

Systemd is a service manager for Linux: https://freedesktop.org/wiki/Software/systemd/

Our production server has it, and we are using it to ensure our application is started if somehow server is shutted down or restarted.

## Usage

It has the common commands to interact with services: `start`, `stop`, `restart`, `status`...

- `systemctl start platform` will start platform on port 3000
- `systemctl stop platform` will stop platform if it was already running
- `systemctl restart platform` will restart platform

When command fails, it shows a error message but if it works it does not output anything, so you will need to run `systemctl status platform` in order to see more information.

Sample:

```
● platform.service - Internet Freedom Festival Platform HTTP Server
   Loaded: loaded (/lib/systemd/system/platform.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2018-10-10 16:17:56 UTC; 16min ago
 Main PID: 24942 (ruby2.3)
   CGroup: /system.slice/platform.service
           └─24942 puma 3.11.0 (tcp://localhost:3000) [plat

Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: => Booting Puma
Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: => Rails 4.2.10 application starting in production on http://localhost:3000
Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: => Run `rails server -h` for more startup options
Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: => Ctrl-C to shutdown server
Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: Puma starting in single mode...
Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: * Version 3.11.0 (ruby 2.3.1-p112), codename: Love Song
Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: * Min threads: 0, max threads: 16
Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: * Environment: production
Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: * Listening on tcp://localhost:3000
Oct 10 16:18:00 platform.internetfreedomfestival.org bash[24942]: Use Ctrl-C to stop
```

## Configuration

```
[Unit]
Description=Internet Freedom Festival Platform HTTP Server
After=network.target

# Uncomment for socket activation (see below)
# Requires=puma.socket

[Service]
# Foreground process (do not use --daemon in ExecStart or config.rb)
Type=simple

# Preferably configure a non-privileged user
# User=

# The path to the puma application root
# Also replace the "<WD>" place holders below with this path.
WorkingDirectory=/opt/frab/platform

# Helpful for debugging socket activation, etc.
# Environment=PUMA_DEBUG=1

# The command to start Puma. This variant uses a binstub generated via
# `bundle binstubs puma --path ./sbin` in the WorkingDirectory
# (replace "<WD>" below)
ExecStart=/bin/bash -lc "RAILS_ENV=production bundle exec rails server -p 3000"

# Variant: Use config file with `bind` directives instead:
# ExecStart=<WD>/sbin/puma -C config.rb
# Variant: Use `bundle exec --keep-file-descriptors puma` instead of binstub

Restart=always

[Install]
WantedBy=multi-user.target
```

## Making changes

Configuration is placed at `/lib/systemd/system/platform.service`.

If you make any change, you will need to reload systemd daemon by running:

- `systemctl daemon-reload`

First time you write a `.service` file, you need to enable it and reload systemd daemon:

- `systemctl enable NAME.service`
- `systemctl daemon-reload`
- `systemctl start NAME.service` (not really needed)
