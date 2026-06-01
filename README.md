# compare-websites-bash

A small tool to capture screenshots of websites and compare them against a previous snapshot to detect visual differences. It uses [CutyCapt](http://cutycapt.sourceforge.net/) to take screenshots and ImageMagick's `compare` command to diff them. A Python wrapper allows you to check multiple sites in one go.

---

## How it works

1. **Capture only** — takes a screenshot of a given domain and saves it to `compare_webs/<domain>/`.
2. **Capture & compare** — takes a new screenshot and compares it pixel-by-pixel against the most recent previous screenshot using ImageMagick's MAE (Mean Absolute Error) metric. If differences are found, a visual diff image is saved alongside the screenshots.

The Bash script outputs a JSON response that can be consumed programmatically (e.g. by the included Python wrapper to trigger alerts or emails).

---

## Requirements

- [CutyCapt](http://cutycapt.sourceforge.net/) — command-line utility for rendering web pages to images
- [ImageMagick](https://imagemagick.org/) — for the `compare` command
- Python 3 (optional, for the `compare_webs.py` wrapper)

Install on Debian/Ubuntu:

```bash
sudo apt-get install cutycapt imagemagick
```

---

## Files

| File | Description |
| --- | --- |
| `compare_webs.sh` | Main Bash script — captures and/or compares website screenshots |
| `compare_webs.py` | Python wrapper — runs the Bash script for a list of domains |

---

## Usage

### Bash script

```bash
bash compare_webs.sh [OPTIONS]
```

| Option | Description |
| --- | --- |
| `-d`, `--domain` | Domain to capture (e.g. `www.example.com`) |
| `-c`, `--compare` | `true` to capture and compare with last screenshot, `false` to only capture |
| `-v`, `--verbose` | `true` to print progress info during execution |
| `-h`, `--help` | Show help message |

**Capture a first screenshot (no comparison):**

```bash
bash compare_webs.sh -d www.example.com -c false
```

**Capture and compare with the previous screenshot:**

```bash
bash compare_webs.sh -d www.example.com -c true
```

**With verbose output:**

```bash
bash compare_webs.sh -d www.example.com -c true -v true
```

### JSON output

The script always prints a JSON object to stdout:

```json
{
  "status": 0,
  "msg": "No differences found",
  "file_new": "compare_webs/www.example.com/20240530120000.png",
  "file_old": "compare_webs/www.example.com/20240529110000.png",
  "file_compared": ""
}
```

| `status` | Meaning |
| --- | --- |
| `0` | OK — no differences found (or first capture) |
| `1` | Differences detected — a diff image has been saved |
| `2` | Error — missing or invalid arguments |

---

### Python wrapper

The Python script takes one or more domains as positional arguments, with optional flags for compare and verbose:

```bash
python3 compare_webs.py [--compare] [--verbose] <site> [<site> ...]
```

| Option | Description |
| --- | --- |
| `--compare` | Compare each site against its last screenshot (omit to capture only) |
| `--verbose` | Print progress info during execution |
| `sites` | One or more domains to check |

**Capture only (no comparison):**

```bash
python3 compare_webs.py www.example.com www.another.com
```

**Capture and compare:**

```bash
python3 compare_webs.py --compare www.example.com www.another.com
```

**Capture, compare, and show verbose output:**

```bash
python3 compare_webs.py --compare --verbose www.example.com www.another.com
```

Running without any arguments prints the help message. It calls `compare_webs.sh` internally for each site, parses the JSON response, and can be extended to send email alerts when differences are detected (see `status == 1` in the `checkSite` function).

> **Note:** `compare_webs.py` must be run from the same directory as `compare_webs.sh`.

---

## Output structure

Screenshots are stored under:

```text
compare_webs/
  └── <domain>/
      ├── 20240530120000.png        ← new screenshot
      ├── 20240529110000.png        ← previous screenshot
      └── compared_20240530120000.png  ← diff image (only if differences found)
```

The workspace directory (`compare_webs/`) is created automatically if it does not exist.

---

## Notes

- CutyCapt captures pages at a minimum size of 1280×2000 px.
- On headless servers, CutyCapt may require a virtual display (e.g. `Xvfb`).
- The comparison uses the **last modified** file in the domain folder as the reference, excluding any previously generated diff images (`compared_*`).
