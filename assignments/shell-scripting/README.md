# System Information Script

This assignment uses shell commands, variables, user input, directory and file creation, and output redirection.

## Run the script

```bash
chmod +x system-info.sh
./system-info.sh
```

The script asks for a name, creates `system-info-output/`, creates `processes.log` with `touch`, and saves the running processes using `ps > system-info-output/processes.log`.

## Commands used

| Command or feature | Use in the script |
| --- | --- |
| `mkdir` | Creates the `system-info-output` directory |
| `touch` | Creates `processes.log` |
| `echo` | Prints headings and stored variable values |
| `df` | Prints disk usage with `df -h` |
| `ps` | Prints and saves running processes |
| `read -p` | Reads the user's name |
| Variables | Stores date, hostname, username, name, and output paths |
| `>` | Redirects process information into `processes.log` |

## Sample output

The process IDs, disk sizes, hostname, username, and date vary by computer and by run.

```text
$ ./system-info.sh
Enter your name: Alex
System Information
------------------
Date: Thu Sep  3 10:15:22 PDT 2026
Hostname: dev-machine
Username: alex

Disk Usage:
Filesystem   Size   Used  Avail Capacity  Mounted on
/dev/disk3s1  460G   120G   330G    27%    /

Running Processes:
  PID TTY           TIME CMD
  101 ttys000    0:00.04 -zsh
  245 ttys000    0:00.01 ps

Hello, Alex.
Process information was saved to system-info-output/processes.log.
```
