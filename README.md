# Backup4Soft

A simple Bash script for backing up source code of important open-source projects and technical specifications.

## Features

- **Git backups** – clones and updates selected repositories.
- **Shallow clones** – limits Git history to the last 10 commits.
- **RFC collection** – downloads selected Internet standards and protocols.
- **Incremental updates** – downloads only missing or modified files.
- **Configurable output** – supports a custom backup directory.

## Requirements

- Bash
- Git
- curl
- ping
- Internet connection

## Usage

```bash
chmod +x backup.sh
./backup.sh
```

## Configuration

By default, backups are stored in the `out/` directory.

To change the output directory, use `OUT_DIR`:

```bash
OUT_DIR=/mnt/storage/backup ./backup.sh
```

## Backup contents

| Directory | Contents |
|---|---|
| `gcc/` | GCC source code |
| `clang/` | LLVM source code |
| `linux/` | Linux kernel source code |
| `wikimedia/` | MediaWiki source code |
| `rfc/` | Selected RFC documents |

## License

The Backup4Soft script is released into the public domain.

Downloaded software and documentation remain subject to their respective licenses and copyright terms.
