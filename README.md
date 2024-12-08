# docker-ubuntu-ansible

A Docker image based on `ubuntu` that runs `systemd` with a minimal set of
services.

Intended for use testing Ansible roles with Molecule

**Development use only. Do not use in production!**


## How to Build

This image is built for all differente ubuntu releases (xenial, bionic, focal) on Docker Hub automatically any time the upstream OS container is rebuilt, and any time a commit is made to the master branch.

|Ubuntu Image tag |Ubuntu Version          |Docker image tag|
|-----------------|----------------------- |----------------|
|latest           |noble numbat (24.04)    |latest          |
|24.04            |noble numbat (24.04)    |24.04
|22.04            |jammy jellyfish (22.04) |22.04           |
|20.04            |focal fossa (20.04)     |20.04           |
|18.04            |bionic beaver (1804)    |18.04           |
|16.04            |xenial xerus (1604)     |16.04           |


But if you need to build the image on your own locally, do the following:

  1. [Install Docker](https://docs.docker.com/install/).
  2. `cd` into this directory.
  3. Run `docker build -t ubuntu-systemd:<tag> --build-arg TAG=<tag> .`. Where `<tag>` is the tag of the base ubuntu image in DockerHub


## How to Use

  1. [Install Docker](https://docs.docker.com/engine/installation/).
  2. Pull this image from Docker Hub: `docker pull ricsanfre/docker-ubuntu-ansible:<tag>` (where `<tag>` can be any of the supported: bionic, xenial, focal e.g. `docker-ubuntu-ansible:bionic`).
  3. Run a container from the image: `docker run -d --name ubuntu-systemd --privileged --rm --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro -t ricsanfre/docker-ubuntu-ansible:latest` 
  4. Connect to the container: `docker exec -it --tty ubuntu-systemd env TERM=xterm /bin/bash`


## Why?

Ansible roles often provide services. Testing these properly requires a service manager.

## Running

You need to add a couple of flags to the `docker run` command to make `systemd`
play nice with Docker.

Container must be started in privileged mode:

    --privileged

Ubuntu's `systemd` expects `/run` and `/run/lock` to be `tmpfs` file systems,
but it can't mount them itself in an unprivileged container:

    --tmpfs /
    --tmpfs /run/lock
    --tmpfs /tmp

`systemd` needs read-only access to the kernel's cgroup hierarchies:

    -v /sys/fs/cgroup:/sys/fs/cgroup:ro

Allocating a pseudo-TTY is not strictly necessary, but it gives us pretty
color-coded logs that we can look at with `docker logs`:

    -t

## Testing

Start a container based on the image:

    docker run -d --name ubuntu-systemd --privileged --rm --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro -t ricsanfre/docker-ubuntu-ansible

Check the logs to see if `systemd` started correctly:

    docker logs ubuntu-systemd

If everything worked, the output should look like this:

    systemd 245.4-4ubuntu3.11 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
    Detected virtualization oracle.
    Detected architecture x86-64.
 
    Welcome to Ubuntu 20.04.2 LTS!

    Set hostname to <21f5899df302>.
    [  OK  ] Reached target Paths.
    [  OK  ] Reached target Slices.
    [  OK  ] Reached target Swap.
    [  OK  ] Listening on Journal Audit Socket.
    [  OK  ] Listening on Journal Socket (/dev/log).
    [  OK  ] Listening on Journal Socket.
             Starting Journal Service...
             Starting Remount Root and Kernel File Systems...
             Starting Create Static Device Nodes in /dev...
    [  OK  ] Finished Remount Root and Kernel File Systems.
    [  OK  ] Finished Create Static Device Nodes in /dev.
    [  OK  ] Reached target Local File Systems (Pre).
    [  OK  ] Reached target Local File Systems.
    [  OK  ] Started Journal Service.
             Starting Create Volatile Files and Directories...
    [  OK  ] Finished Create Volatile Files and Directories.
    [  OK  ] Reached target System Initialization.
    [  OK  ] Started Daily Cleanup of Temporary Directories.
    [  OK  ] Reached target Timers.
    [  OK  ] Listening on D-Bus System Message Bus Socket.
    [  OK  ] Reached target Sockets.
    [  OK  ] Reached target Basic System.
    [  OK  ] Started D-Bus System Message Bus.
             Starting Permit User Sessions...
             Starting Cleanup of Temporary Directories...
    [  OK  ] Finished Permit User Sessions.
    [  OK  ] Reached target Multi-User System.
    [  OK  ] Reached target Graphical Interface.
    [  OK  ] Finished Cleanup of Temporary Directories.

Also check the journal logs:

    docker exec ubuntu-systemd journalctl

The output should look like this:

    Jul 24 15:08:20 21f5899df302 systemd-journald[20]: Journal started
    Jul 24 15:08:20 21f5899df302 systemd-journald[20]: Runtime Journal (/run/log/journal/6cac943681be4356b24d8a0d7bab6dd0) is 8.0M, max 99.6M, 91.6M free.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Starting Create Volatile Files and Directories...
    Jul 24 15:08:20 21f5899df302 systemd[1]: Finished Create Volatile Files and Directories.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Reached target System Initialization.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Started Daily Cleanup of Temporary Directories.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Reached target Timers.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Listening on D-Bus System Message Bus Socket.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Reached target Sockets.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Reached target Basic System.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Started D-Bus System Message Bus.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Starting Permit User Sessions...
    Jul 24 15:08:20 21f5899df302 systemd[1]: Starting Cleanup of Temporary Directories...
    Jul 24 15:08:20 21f5899df302 dbus-daemon[24]: [system] AppArmor D-Bus mediation is enabled
    Jul 24 15:08:20 21f5899df302 systemd[1]: Finished Permit User Sessions.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Reached target Multi-User System.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Reached target Graphical Interface.
    Jul 24 15:08:20 21f5899df302 systemd[1]: systemd-tmpfiles-clean.service: Succeeded.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Finished Cleanup of Temporary Directories.
    Jul 24 15:08:20 21f5899df302 systemd[1]: Startup finished in 5h 31min 30.459s (kernel) + 452ms (userspace) = 5h 31min 30.912s.

To check for clean shutdown, in one terminal run:

    docker exec ubuntu-systemd journalctl -f

And in another shut down `systemd`:

    docker stop ubuntu-systemd

The journalctl logs should look like this on a clean shutdown:

    Mar 16 14:15:49 aad1d41c3a2e systemd[1]: Received SIGRTMIN+3.
    Mar 16 14:15:49 aad1d41c3a2e systemd[1]: Stopped target Multi-User System.
    Mar 16 14:15:50 aad1d41c3a2e systemd[1]: Stopping Permit User Sessions...
    Mar 16 14:15:51 aad1d41c3a2e systemd[1]: Stopping LSB: Set the CPU Frequency Scaling governor to "ondemand"...
    Mar 16 14:15:52 aad1d41c3a2e systemd[1]: Stopped /etc/rc.local Compatibility.
    Mar 16 14:15:53 aad1d41c3a2e systemd[1]: Stopped target Timers.
    Mar 16 14:15:54 aad1d41c3a2e systemd[1]: Stopped Daily Cleanup of Temporary Directories.
    Mar 16 14:15:55 aad1d41c3a2e systemd[1]: Stopped Permit User Sessions.
    Mar 16 14:15:56 aad1d41c3a2e systemd[1]: Stopped LSB: Set the CPU Frequency Scaling governor to "ondemand".
    Mar 16 14:15:57 aad1d41c3a2e systemd[1]: Stopped target Basic System.
    Mar 16 14:15:58 aad1d41c3a2e systemd[1]: Stopped target Slices.
