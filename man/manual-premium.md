---
title: Cppcheck Premium manual
author: Cppcheck Solutions AB
lang: en
documentclass: report
toc-depth: 1
secnumdepth: 1
---

# About this manual {#about .unnumbered}

## Version and build {#about-version .unnumbered}

This manual is for the Cppcheck Premium version shown on the title
page. Use the manual that matches your installed version; check it
with `cppcheck --version`.

The manual covers Cppcheck Premium completely, including the
open-source Cppcheck it is built on. Core content is synced with
Cppcheck 2.22.0.

<!-- TODO(confirm): the synced Cppcheck version is updated by the release process -->

## What's new in this release {#about-whats-new .unnumbered}

This manual has been rewritten. It now covers installation,
licensing, embedded setup, CI and IDE integration, and has a
troubleshooting part and an FAQ.

For changes in the product, see [Changelog](#ref-changelog).

<!-- TODO(confirm): generated from the release notes by the release process -->

## Conventions {#about-conventions .unnumbered}

- Commands are shown in a fixed-width font. Replace `<...>` with your
  own values.
- Examples use `/` in paths and Linux commands. On Windows, use the
  same options with `cppcheck.exe`, and `\` or `/` in paths.
- **Finding** means anything Cppcheck reports: a bug, a coding
  standard violation, or a configuration message.
- Each finding has an **id**, shown in brackets after the message, for
  example `[nullPointer]`. Suppressions use the id.

\part{Get started}\label{part-get-started}

# Introduction {#intro}

## What Cppcheck Premium is {#intro-premium}

Cppcheck Premium is a static analysis tool for C and C++ code. It finds
bugs, undefined behaviour and dangerous coding constructs, and checks
your code against coding standards.

Cppcheck Premium is built on the open-source Cppcheck and includes all
of it. On top of that it adds:

- Coding standards: MISRA C 2012, 2023 and 2025, MISRA C++ 2008 and
  2023, CERT C, CERT C++ and AUTOSAR. See [Coding standards](#standards).
- Compliance reports for these standards. See
  [Compliance reports](#compliance).
- Bug hunting, a more thorough but noisier analysis. See
  [Bug hunting](#bughunting).
- Safety mode, on by default: if the analysis of a file fails,
  Cppcheck exits with an error instead of looking like a clean run.
  See [Safety mode and exit codes](#safety).
- Code metrics. See [Metrics](#metrics).

This manual covers everything you need. You do not need the
open-source Cppcheck manual.

Cppcheck is designed to analyse code even if it has non-standard
syntax, as is common in embedded projects: compiler extensions, inline
assembly and so on.

## About static analysis {#intro-static-analysis}

<!-- oss: manual.md "About static analysis" -->

Static analysis finds:

- undefined behaviour,
- dangerous code patterns,
- coding style issues and coding standard violations.

It cannot know what your program is meant to do. If your program
prints "Helo" instead of "Hello", no static analysis tool will tell
you.

Cppcheck aims to report only real problems, so it avoids guessing.
This means some bugs are not found, and some findings are still false
positives (findings about code that is correct). How to handle false
positives is described in
[Suppressions, justifications and baselines](#suppr).

Use static analysis together with careful design, testing, dynamic
analysis and fuzzing, not instead of them.

## Severities {#intro-severities}

<!-- oss: manual.md "Severities" -->

Every finding has one of these severities:

| Severity | Meaning |
|---|---|
| error | The code has undefined behaviour or another error, such as a memory or resource leak, when it runs. |
| warning | The code might have undefined behaviour when it runs. |
| style | Stylistic issues: unused functions, redundant code, missing `const`, operator precedence, possible mistakes. |
| performance | Suggestions that may make the code faster. A measurable speed-up is not guaranteed. |
| portability | Implementation-defined behaviour, 64-bit portability issues, and undefined behaviour that probably works as you expect. |
| information | Problems with the analysis configuration, not with the code. For example, a header that could not be found. |

<!-- premium-diverges: coding standard findings are not filtered by - -enable -->

Coding standard findings (MISRA, CERT, AUTOSAR) also have one of these
severities, usually style. `--enable` does not filter them: they are
reported whenever the coding standard is enabled. To choose what is
reported, see [Filtering and classification](#standards-filtering).

# Installation {#install}

## System requirements and supported platforms {#install-requirements}

<!-- TODO(confirm): official platform list, and whether other Linux distributions "probably work" with the tar.gz -->

Cppcheck Premium is available for:

| Platform | Package |
|---|---|
| Windows (64-bit) | Installer |
| Ubuntu 22.04, 24.04 and 26.04 (x86-64 and ARM64) | `.deb`, apt repository, `.tar.gz` |
| Debian 12 (x86-64) | `.deb`, `.tar.gz` |
| Red Hat Enterprise Linux 9 and 10, and compatible distributions such as Oracle Linux and Rocky Linux (x86-64) | `.rpm` |
| macOS | Archive |

Download the package for your platform from the link you received
with your license.

<!-- TODO(confirm): where customers download releases (website page, files.cppchecksolutions.com, GitHub Releases) -->

## Windows {#install-windows}

Run the installer and follow the instructions. By default Cppcheck
Premium is installed in `C:\Program Files\Cppcheck Premium`.

To install without user interaction, for example on build machines:

```sh
msiexec /i cppcheckpremium-<version>-x64.msi /qn
```

<!-- TODO(confirm): installer file name, and that silent install with msiexec /qn is supported -->

Then install your license file, see
[Where to put the license file](#license-location).

## Linux {#install-linux}

All Linux packages install Cppcheck Premium in `/opt/cppcheckpremium`.

**Ubuntu and Debian, `.deb` package:**

```sh
sudo apt install ./cppcheckpremium-<version>-amd64.deb
```

Use the package built for your distribution and version. Use `arm64`
instead of `amd64` on ARM.

**Ubuntu, apt repository:** with the repository, `apt upgrade` also
upgrades Cppcheck Premium.

```sh
curl -fsSL <key URL> | sudo tee /etc/apt/keyrings/cppcheck.pgp > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/cppcheck.pgp] https://files.cppchecksolutions.com/linux/ubuntu <codename> stable" \
    | sudo tee /etc/apt/sources.list.d/cppcheck.list
sudo apt update
sudo apt install cppcheckpremium
```

Replace `<codename>` with your Ubuntu release, for example `noble` for
24.04.

<!-- TODO(confirm): key URL, codenames in the repository, package name -->

**Red Hat Enterprise Linux and compatible, `.rpm` package:**

```sh
sudo dnf install ./cppcheckpremium-<version>-1.el9.x86_64.rpm
```

Use `el10` on version 10.

**Any Linux, `.tar.gz` archive:** unpack it anywhere. No installation
is needed:

```sh
tar xzf cppcheckpremium-<version>-amd64.tar.gz
./cppcheckpremium-<version>/cppcheck --version
```

The archive is useful when you can't install packages, or want
several versions side by side.

To run `cppcheck` without typing the full path, add the install folder
to your `PATH`:

```sh
export PATH=/opt/cppcheckpremium:$PATH
```

## macOS {#install-macos}

<!-- TODO(confirm): macOS package format, supported macOS versions and architectures, and the Gatekeeper steps -->

Unpack the archive into a folder of your choice, for example
`/Applications/Cppcheck Premium` or `~/cppcheckpremium`.

macOS may block the programs the first time they run, because they
were downloaded from the internet. Allow them in System Settings,
Privacy & Security.

**Make sure you run the Premium `cppcheck`.** If the open-source
Cppcheck is also installed, for example with Homebrew, the `cppcheck`
found on your `PATH` may be the open-source one. It rejects all
`--premium` options. Check with:

```sh
which cppcheck
cppcheck --version
```

The version should say Cppcheck Premium. If not, put the Premium
folder first in your `PATH`, or use the full path to its `cppcheck`.

## Headless and CLI-only {#install-headless}

On CI runners and in Docker images you usually only need the command
line tools. The `.tar.gz` archive works without the GUI and without
installing Qt:

```sh
tar xzf cppcheckpremium-<version>-amd64.tar.gz
rm cppcheckpremium-<version>/cppcheck-gui
```

The `.deb` and `.rpm` packages depend on Qt, which adds a lot to an
image.

Example Dockerfile:

```dockerfile
FROM ubuntu:24.04
COPY cppcheckpremium-<version>-amd64.tar.gz /tmp/
RUN tar xzf /tmp/cppcheckpremium-<version>-amd64.tar.gz -C /opt \
 && rm /tmp/cppcheckpremium-<version>-amd64.tar.gz
ENV PATH=/opt/cppcheckpremium-<version>:$PATH
```

Don't put the license file in the image. Mount it when the container
runs, see
[Licenses in Docker, dev containers, VMs and CI](#license-containers).

<!-- TODO(confirm): does the tar.gz cppcheck run without Qt libraries installed? Is there an official Docker image? -->

## Offline and air-gapped install {#install-offline}

All packages install without network access. Copy the package and
your license file to the machine and install as described above.

Each release comes with SHA-256 checksums. Check the package before
installing:

```sh
sha256sum cppcheckpremium-<version>-amd64.tar.gz
```

Compare the result with the checksum published for the release.

<!-- TODO(confirm): where the checksums are published, and the file name (e.g. SHA256SUMS) -->

The license check itself needs no network access.

## Verifying the install {#install-verify}

Check the version:

```sh
cppcheck --version
```

It should print `Cppcheck Premium` followed by the version.

Check the license:

```sh
premiumaddon --debug
```

On Windows, run `premiumaddon.exe --debug` from the install folder.
This prints which license files it looks for and whether they are
valid. If something is wrong, see
[License troubleshooting](#trouble-license).

Finally, run a short analysis as described in
[Your first analysis](#first).

# Licensing {#license}

Cppcheck Premium needs a license file to run its Premium checks. The
license file is a small text file with the extension `.lic`. You
receive it from Cppcheck Solutions, or create it with the
registration script.

The license is checked on the machine itself. No network access is
needed.

## License types and license files {#license-types}

<!-- TODO(confirm): which license types are sold today, and how a trial is delivered -->

The name of the license file tells Cppcheck Premium what kind of
license it is. Don't rename it.

| License file | Valid for |
|---|---|
| `cppcheck-premium.lic` | Any machine. Typical for project and enterprise licenses. |
| `cppcheck-premium-git.lic` | Analyses run inside the git repository the license was issued for. |
| `<computer id>.lic` | One machine. Created by the registration script. |

**Trial licenses are license files.** A trial does not use a license
ID: put the `.lic` file you received where Cppcheck Premium looks for
it, as for any other license.

**Registering a machine-bound license.** If you received a license ID,
run the registration script in the install folder and follow the
instructions:

```sh
python3 register.py
```

It creates `<computer id>.lic` in your home folder. Move it to one of
the folders below.

## Where to put the license file {#license-location}

Cppcheck Premium looks for the license file in these folders, in this
order:

| System | Folders |
|---|---|
| Windows | `C:\ProgramData\Cppcheck Solutions AB\` and the install folder |
| Linux and macOS | `/etc/cppcheckpremium/`, `~/.cppcheckpremium/` and the install folder |

<!-- TODO(confirm): macOS paths are the same as Linux (from the code on main); check after the new license format is merged -->

On Windows, `C:\ProgramData` is a hidden folder. Type the path in the
Explorer address bar to open it, and create the `Cppcheck Solutions AB`
folder if it does not exist.

Example on Linux, for all users of the machine:

```sh
sudo mkdir -p /etc/cppcheckpremium
sudo cp cppcheck-premium.lic /etc/cppcheckpremium/
```

**Keep only one license file.** When you get a new license, remove the
old file. An old, expired file in one of these folders can be found
before the new one.

## License file option and shared folders {#license-shared}

To use a license file in any other place, give its path on the command
line:

```sh
cppcheck --premium-license-file=path/to/cppcheck-premium.lic ...
```

Cppcheck Premium then only uses this file and does not look in the
folders above. This is useful when:

- the license is on a shared or network folder,
- you can't write to the folders above,
- you want to be sure which license file is used.

On Windows, put the path in quotes if it contains spaces:

```sh
cppcheck "--premium-license-file=C:\Shared Licenses\cppcheck-premium.lic" ...
```

## Licenses in Docker, dev containers, VMs and CI {#license-containers}

<!-- TODO(confirm): what each license type allows in containers, VMs and on CI runners -->

Keep the license file out of shared images and repositories. Provide
it when the analysis runs instead:

**Docker:** mount the license file into one of the folders Cppcheck
Premium searches:

```sh
docker run -v /path/to/cppcheck-premium.lic:/etc/cppcheckpremium/cppcheck-premium.lic:ro my-image cppcheck ...
```

**Dev containers:** add the same mount to `devcontainer.json`:

```json
"mounts": [
    "source=/path/to/cppcheck-premium.lic,target=/etc/cppcheckpremium/cppcheck-premium.lic,type=bind,readonly"
]
```

**CI runners** (GitHub Actions, GitLab, Azure DevOps, Jenkins): store
the license file content as a secret, write it to a file in the job,
and use `--premium-license-file`:

```sh
echo "$CPPCHECK_LICENSE" > "$RUNNER_TEMP/cppcheck-premium.lic"
cppcheck --premium-license-file="$RUNNER_TEMP/cppcheck-premium.lic" ...
```

See [CI pipelines](#ci) for complete examples.

A machine-bound license (`<computer id>.lic`) is tied to the hardware
it was registered on, so it does not work in containers or on CI
runners that change between runs. Use a `cppcheck-premium.lic` license
there.

## Renewal, expiry and validity across versions {#license-renewal}

<!-- TODO(confirm): whether a license covers all versions released while it is valid, and how renewal is delivered -->

A license is valid until its expiry date. During the last 7 days,
every analysis reports a `licenseExpiresSoon` message with the number
of days left.

When you renew, you get a new license file. Replace the old file with
it in the same place.

When a license has expired, Cppcheck Premium reports "License has
expired". If the license can't be found or is not valid, see
[License troubleshooting](#trouble-license).

# Your first analysis {#first}

## Command line {#first-cli}

<!-- oss: manual.md "Command line" -->

### A first test {#first-cli-test}

Save this code as `file1.c`:

```c
int main()
{
    char a[10];
    a[10] = 0;
    return 0;
}
```

Then run:

```sh
cppcheck file1.c
```

The output is:

```
Checking file1.c ...
file1.c:4:6: error: Array 'a[10]' accessed at index 10, which is out of bounds. [arrayIndexOutOfBounds]
    a[10] = 0;
     ^
```

### Checking a folder {#first-cli-folder}

Give a folder instead of a file, and Cppcheck checks all source files
in it and its subfolders:

```sh
cppcheck src
```

For a real project, it is usually better to give Cppcheck your build
configuration, so it knows the include paths and defines. See
[Choosing and importing a project](#project).

### Adding a coding standard {#first-cli-standard}

Add `--premium` with the standard you want:

```sh
cppcheck --premium=misra-c-2025 src
```

See [Coding standards](#standards) for all standards and options.

### Checking only some files {#first-cli-file-filter}

`--file-filter` checks only the files that match a pattern:

```sh
cppcheck --project=compile_commands.json --file-filter=src/*.c
```

In the pattern:

- `**` matches any characters, including `/`,
- `*` matches any characters except `/`,
- `?` matches one character except `/`.

The pattern must include the folder you gave on the command line. For
example, `cppcheck src/ --file-filter=src/test*` checks `src/test1.cpp`
but not `src/file2.cpp` or `src/test/file1.cpp`.

### Leaving out files and folders {#first-cli-ignore}

`-i` leaves out source files or folders matching a pattern, using the
same wildcards:

```sh
cppcheck --project=compile_commands.json -itest
```

This leaves out `test/somefile.cpp` but still checks `test1.cpp`.

`-i` only leaves out source files. Headers included from other source
files are still analysed, and findings in them are still reported.
To hide findings in third-party headers, see
[Third-party and vendor code](#third-party).

## GUI {#first-gui}

<!-- oss: manual.md "GUI" -->

Start Cppcheck Premium from the start menu on Windows, or run
`cppcheck-gui` on Linux and macOS.

1. Choose **File \> New project file** and save it, for example as
   `myproject.cppcheck` in your project folder.
2. In the project dialog, use **Import project** if you can. The GUI
   can import a Visual Studio solution or project, a compilation
   database (`compile_commands.json`, from CMake and other build
   tools) and a C++Builder 6 project. Otherwise, add your source
   folders, include paths and defines.
3. Choose the coding standards to check on the **Addons** tab.
   <!-- TODO(confirm): tab name for coding standards in the current GUI -->
4. Click **OK**. The analysis starts and the results are listed as
   they come in.

Click a result to see the code. Right-click it to suppress it or
copy it.

## One configuration for GUI, CLI and CI {#first-one-config}

The project file you create in the GUI (`.cppcheck`) can be used on
the command line too:

```sh
cppcheck --project=myproject.cppcheck
```

This way the GUI, your own command line runs and the CI pipeline all
use the same settings: source files, include paths, defines, coding
standards and suppressions. Keep the project file in version control
next to your code.

Options you give on the command line are added to those in the
project file.

<!-- TODO(confirm): a .cppcheck file with <importproject> failed on the CLI (support ticket); is that fixed? -->

\part{Configure your project}\label{part-configure}

# Choosing and importing a project {#project}

## Folder, project file or compilation database {#project-choosing}

You can tell Cppcheck what to analyse in three ways:

| Input | Example | Use when |
|---|---|---|
| A folder or files | `cppcheck src` | Trying Cppcheck out, small projects, or no build system to import. |
| A compilation database | `cppcheck --project=compile_commands.json` | Your build system can produce one (CMake, Make with bear, and others). Recommended. |
| A Visual Studio or C++Builder project | `cppcheck --project=app.sln` | You build with Visual Studio or C++Builder 6. |

**Prefer importing your build.** An imported project gives Cppcheck
the exact files, include paths and defines your compiler uses. This
gives the most accurate results, and analyses one configuration per
file, which is faster.

With a folder, Cppcheck does not know your defines, so it tries
several combinations of them (see
[Preprocessor defines and include paths](#preproc-defines)). This
finds more code paths, but is slower and can report code your build
never compiles.

To keep the same settings for the GUI, the command line and CI, put
them in a Cppcheck project file. See
[Cppcheck GUI project files](#project-gui).

## Cppcheck GUI project files {#project-gui}

<!-- oss: manual.md "Cppcheck GUI project" -->

A Cppcheck project file (`.cppcheck`) is created in the GUI, see
[GUI](#first-gui). Use it on the command line with:

```sh
cppcheck --project=myproject.cppcheck
```

A project file can hold settings that have no command line option,
for example analysing only one Visual Studio configuration. It can
also import a compilation database or a Visual Studio solution, and
add settings on top of it.

To skip source files in a folder:

```sh
cppcheck --project=myproject.cppcheck -ifoo
```

## Compilation database {#project-compdb}

<!-- oss: manual.md "Compilation database (CMake etc.)" -->

A compilation database (`compile_commands.json`) lists the compiler
command for each source file. With CMake, create it with:

```sh
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
```

Then run:

```sh
cppcheck --project=compile_commands.json
```

Cppcheck uses the include paths (`-I`), defines (`-D`, `-U`), forced
includes (`-include`) and language standard from each command.

Only one configuration of each file is checked, the one in the
database. To check more configurations, add `--max-configs=<n>` or
`--force`.

To skip source files, use `-i`, or check only some files with
`--file-filter`:

```sh
cppcheck --project=compile_commands.json -ithird_party
cppcheck --project=compile_commands.json --file-filter=src/*.c
```

### What Cppcheck does not take from the database {#project-compdb-gaps}

- **Compiler predefined macros.** The macros your compiler defines
  itself (`__GNUC__`, `__ARM_ARCH`, `__ICCARM__` and so on) are not in
  the database. Embedded code often needs them. See
  [Compiler predefined macros](#embedded-macros).
- **`-isystem` paths** are not used as include paths. Usually that is
  what you want: system headers slow the analysis down and add little,
  and `--library` gives Cppcheck better information about them (see
  [Library configuration](#library)). If you do want them, convert
  them to `-I` with `tweak-compile-commands.py` from the Cppcheck
  source repository:

    ```sh
    tweak-compile-commands.py compile_commands.json --isystem-to-i -o cppcheck_commands.json
    cppcheck --project=cppcheck_commands.json
    ```

  The script also handles `--sysroot` and can remove include paths.

<!-- TODO(confirm): is tweak-compile-commands.py shipped with Premium, or should the manual tell customers where to download it? -->

- **System folders added with `-I`**, for example `-I/usr/include`
  from `pkg-config`, are used. This can give syntax errors or slow
  analysis. Remove them with the script's `--remove-include-path`.

### One database for several targets {#project-compdb-several}

`--project` takes one file. If you have several databases, run
Cppcheck once per database, or merge them into one file first.

## Visual Studio, C++Builder 6 and other build systems {#project-other}

<!-- oss: manual.md "Visual Studio", "C++ Builder 6", "Other" -->

**Visual Studio.** Give a solution (`.sln`, `.slnx`) or a project
(`.vcxproj`):

```sh
cppcheck --project=app.sln
cppcheck --project=app.vcxproj
```

All configurations in the project are analysed. To analyse one:

```sh
cppcheck --project=app.sln "--project-configuration=Release|x64"
```

**C++Builder 6:**

```sh
cppcheck --project=app.bpr
```

**Make and other build systems.** Generate a compilation database. On
Linux, `bear` records the compiler commands of any build:

```sh
bear -- make
cppcheck --project=compile_commands.json
```

**Bazel, waf and others.** Most build systems can produce a
compilation database, directly or with a plugin. For example
`hedronvision/bazel-compile-commands-extractor` for Bazel, and
`waf clangdb` for waf.

<!-- TODO(confirm): the Bazel and waf tools named above are the ones we recommend -->

# Preprocessor, platform and language {#preproc}

If you import a project (`--project`), Cppcheck takes most of these
settings from it. This chapter is about what to add, and about the
settings you need when you check a folder.

## Preprocessor defines and include paths {#preproc-defines}

<!-- oss: manual.md "Preprocessor settings" -->

### Which configurations are checked {#preproc-configurations}

Without `-D`, Cppcheck finds the `#ifdef` combinations in each file and
checks several of them, up to 12 per file. This finds bugs in code
that one build would not compile.

Take this file:

```c
#ifdef A
    x = 100/0;
    #ifdef B
        y = 100/0;
    #endif
#else
    z = 100/0;
#endif
```

| Command | What is checked | Bugs found |
|---|---|---|
| `cppcheck test.c` | All combinations | All three |
| `cppcheck -DA test.c` | Only `A` defined | `x` |
| `cppcheck -UA test.c` | Combinations without `A` | `z` |
| `cppcheck --force -DA test.c` | All combinations with `A` | `x` and `y` |

The rules:

- `-D<name>` or `-D<name>=<value>` defines a macro. **As soon as you
  give one `-D`, only that one configuration is checked.** Add
  `--max-configs=<n>` or `--force` to check more.
- `-U<name>` says the macro is never defined.
- `--max-configs=<n>` sets the number of configurations per file
  (default 12). `--max-configs=1` is the fastest.
- `--force` checks all configurations, however many.

### Include paths {#preproc-includes}

Add include paths with `-I`:

```sh
cppcheck -Iinclude -Ilib/include src
```

Give the include paths for your own headers. **Don't add the
compiler's or the operating system's header folders**, such as
`/usr/include`. Cppcheck works without them, and is slower and less
accurate with them. Use `--library` instead, see
[Library configuration](#library).

If a header can't be found, Cppcheck reports `missingInclude` or
`missingIncludeSystem` (with `--enable=missingInclude`) and continues.

To include a file before every source file, as the compiler option
`-include` does:

```sh
cppcheck --include=config.h src
```

### Seeing what the preprocessor does {#preproc-e}

`-E` prints the preprocessed code and stops. Use it to check which
branches are active and how macros expand:

```sh
cppcheck -E -DA test.c
```

## C/C++ standard {#preproc-std}

<!-- oss: manual.md "C/C++ standard" -->

By default Cppcheck assumes the latest standard: C23 and C++26. To
set it:

```sh
cppcheck --std=c11 src
cppcheck --std=c++17 src
```

C: `c89`, `c99`, `c11`, `c17`, `c23`. C++: `c++03`, `c++11`, `c++14`,
`c++17`, `c++20`, `c++23`, `c++26`. An imported project sets the
standard from the compiler options.

<!-- premium-diverges: - -std affects which coding standard rules apply -->

Set the standard your code is written for. Some coding standard rules
depend on it, for example rules about features that only exist in
later standards. See [Filtering and classification](#standards-filtering).

## Platform {#preproc-platform}

<!-- oss: manual.md "Platform" -->

The platform tells Cppcheck the sizes of types (`int`, `long`,
pointers) and whether `char` is signed. This matters for overflow,
portability and MISRA essential type rules.

By default Cppcheck uses the sizes of the machine it runs on. For
cross-compiled code, set the target platform:

```sh
cppcheck --platform=unix32 src
```

Built-in platforms: `unix32`, `unix64`, `win32A`, `win32W`, `win64`,
`avr8`, `elbrus-e1cp`, `pic8`, `pic8-enhanced`, `pic16`, `mips32`,
`native` (the default) and `unspecified`.

More platform files are in the `platforms` folder of the install, for
example `arm32-wchar_t4`, `arm64-wchar_t4`, `riscv32`, `riscv64` and
`msp430_eabi_large_datamodel`:

```sh
cppcheck --platform=arm32-wchar_t4 src
```

### A custom platform {#preproc-platform-custom}

If none fits your target, write a platform file:

```xml
<?xml version="1"?>
<platform>
  <char_bit>8</char_bit>
  <default-sign>signed</default-sign>
  <sizeof>
    <short>2</short>
    <int>4</int>
    <long>4</long>
    <long-long>8</long-long>
    <float>4</float>
    <double>8</double>
    <long-double>8</long-double>
    <pointer>4</pointer>
    <size_t>4</size_t>
    <wchar_t>4</wchar_t>
  </sizeof>
</platform>
```

Save it, for example as `my-mcu.xml`, and use it with
`--platform=my-mcu.xml`. Check the sizes in your compiler's
documentation, or let the compiler tell you:

```sh
echo | arm-none-eabi-gcc -E -dM - | grep -E '__SIZEOF_|__CHAR_BIT__'
```

Check `long` carefully: on 64-bit Linux and macOS targets it is 8
bytes (LP64), on 64-bit Windows 4 bytes (LLP64).

<!-- TODO(confirm): built-in arm64 platform files use 4-byte long; support suggested naming platform files by data model. Update when that is done. -->

# Embedded and cross-compiler setup {#embedded}

Embedded code depends on the compiler more than desktop code does.
Device headers check which compiler and architecture is used, and stop
with `#error` if they don't recognise it. This chapter shows how to
give Cppcheck what it needs.

The short version:

1. Import your build (see [Compilation database](#project-compdb)).
2. Give Cppcheck your compiler's predefined macros.
3. Set the platform (see [Platform](#preproc-platform)).
4. Keep vendor code out of the results (see
   [Third-party and vendor code](#third-party)).

## Compiler predefined macros {#embedded-macros}

Every compiler defines macros of its own: `__GNUC__`, `__ARM_ARCH`,
`__ICCARM__`, `__XC16__` and so on. They are not in your build files,
so Cppcheck does not know them. Typical symptoms:

- `#error Unknown compiler` or "Unknown Arm architecture profile",
- an endianness `#error`,
- `premium-misra-config` errors about unknown variables or constants.

Fix it by writing the compiler's macros to a header and including it
before every file.

**GCC and Clang based compilers** (ARM GCC, Microchip XC32, and
others): use the same compiler and the same target options as your
build, because the macros depend on them:

```sh
arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -E -dM -x c /dev/null > cppcheck-macros-c.h
cppcheck --project=compile_commands.json --include=cppcheck-macros-c.h
```

**Remove `__cplusplus` from the file for C code.** If you generate the
macros with a C++ compiler, the header defines `__cplusplus`, and C
files are then preprocessed as C++. If you have both C and C++ code,
generate one header per language with `-x c` and `-x c++`, and run
Cppcheck once per language with `--file-filter`.

<!-- TODO(confirm): is there a per-language - -include, or a better way for mixed C/C++ projects? -->

**Other compilers:** see the compiler documentation for a list of its
predefined macros, or the options to print them (IAR:
`--predef_macros <file>`). Write the ones your headers check into a header, and use it
with `--include`.

Only add the macros you need if the generated list causes problems.
Cppcheck has no use for macros that describe compiler internals.

## ARM GCC, IAR, Microchip, STM32/CMSIS {#embedded-compilers}

<!-- TODO(confirm): settings below; ideally tested on a sample project for each toolchain -->

| Toolchain | Macros | Platform | Notes |
|---|---|---|---|
| ARM GCC (Cortex-M) | `arm-none-eabi-gcc -E -dM` with your `-mcpu` | `arm32-wchar_t4` |  |
| IAR for Arm | `iccarm --predef_macros macros.h` | `arm32-wchar_t4` | IAR language extensions are handled; keywords like `__no_init` may need `-D__no_init=` |
| Microchip XC8 | From the compiler documentation | `pic8` or `pic8-enhanced` |  |
| Microchip XC16 | From the compiler documentation | `pic16` |  |
| Microchip XC32 | `xc32-gcc -E -dM` | `mips32` or `arm32-wchar_t4` |  |
| STM32 with CMSIS | As ARM GCC or IAR | `arm32-wchar_t4` | CMSIS and HAL headers are large: suppress them, see [Third-party and vendor code](#third-party) |

**Large device headers.** Microchip and STM32 device headers can be
thousands of lines of register definitions. Analysing them is slow.
If analysis is slow, see [Finding slow files](#perf-slow-files), and
consider giving Cppcheck a reduced header for the device.

## Zephyr {#embedded-zephyr}

<!-- TODO(confirm): Zephyr steps; tested on a sample application -->

Zephyr applications need three things:

1. **The compilation database** that the Zephyr build writes to
   `build/compile_commands.json` (west builds with CMake).
2. **The generated configuration header.** It is included with
   `-imacros` in the build, which Cppcheck does not read from the
   database. Include it yourself:

    ```sh
    cppcheck --project=build/compile_commands.json \
        --include=build/zephyr/include/generated/zephyr/autoconf.h \
        --include=cppcheck-macros-c.h \
        --library=zephyr
    ```

3. **The toolchain macros**, generated as in
   [Compiler predefined macros](#embedded-macros) with the Zephyr SDK
   compiler.

`--library=zephyr` tells Cppcheck about Zephyr API functions and
macros. Suppress findings in the Zephyr sources and modules as
described in [Third-party and vendor code](#third-party).

## Diagnosing critical errors {#embedded-critical-errors}

Some problems stop the analysis of a file. These are critical errors,
for example:

| Id | Meaning |
|---|---|
| `preprocessorErrorDirective` | An `#error` was reached. Usually a missing compiler macro or define. |
| `syntaxError` | Cppcheck could not parse the code. Often an unknown compiler keyword or a missing macro. |
| `unknownMacro` | A macro is used in a way that needs its definition. |
| `premium-misra-config` | A MISRA check needs a declaration it could not find. Usually a missing include path or macro. |

A file with a critical error is not fully analysed. This also affects
whole-program checks, so it can cause other false positives, for
example an "unused function" that is called from the failed file.

<!-- premium-diverges: safety mode makes critical errors fail the run -->

In safety mode (the default), a critical error makes Cppcheck exit
with code 1, even if you suppress it. Fix the configuration instead.
See [Safety mode and exit codes](#safety).

To find the cause:

1. Read the file and line in the message. With `--template` or XML
   output you always get them, see [Output formats](#output).
2. Check how the code is preprocessed:

    ```sh
    cppcheck -E -DMY_DEFINE file.c
    ```

3. Look for `missingInclude` messages, which are shown with
   `--enable=missingInclude`. A missing header often explains a missing
   macro.
4. Add the missing macro with `-D` or a macro header, or the missing
   include path with `-I`.

For more, see [Common configuration errors](#trouble-config).

# Third-party and vendor code {#third-party}

Most projects contain code you don't maintain: vendor SDKs, device
headers, generated code, open-source libraries. This chapter shows how
to keep it out of your results.

## Exclude or suppress {#third-party-exclude-vs-suppress}

There are two different tools, and they do different things:

|  | Excluding (`-i`) | Suppressing (`--suppress`) |
|---|---|---|
| Works on | Source files (`.c`, `.cpp`) | Findings, in any file |
| Effect | The file is not analysed | The file is analysed, its findings are hidden |
| Headers | **Not affected**: headers included by your files are still analysed and reported | Hides findings in headers too |
| Saves time | Yes | No |

So:

- **To hide findings from vendor headers, suppress them.** `-i` does
  not help, because the headers are analysed as part of your files.
- **To stop analysing vendor source files, exclude them.** This saves
  time.
- For vendor code that has both, do both.

## The recipe {#third-party-recipe}

If the vendor code is in `vendor/` and `third_party/`:

```sh
cppcheck --project=compile_commands.json \
    -ivendor -ithird_party \
    --suppress=*:vendor --suppress=*:third_party
```

- `-ivendor` skips source files in any folder named `vendor`.
- `--suppress=*:vendor` hides all findings (`*`) in files in any
  folder named `vendor`, including headers.

To keep the suppressions with the project, put them in a file, one
per line:

```
*:vendor
*:third_party
```

and use it with `--suppressions-list=vendor-suppressions.txt`. In the
GUI, add them to the project's suppressions.

### Path patterns {#third-party-patterns}

The same patterns work for `-i` and for file names in suppressions:

| Pattern | Matches |
|---|---|
| `vendor` | Anything in a folder named `vendor`, at any depth |
| `vendor/stm32` | Anything in `vendor/stm32`, at any depth |
| `vendor/*.h` | Headers directly in `vendor` |
| `vendor/**.h` | Headers anywhere under `vendor` |
| `./vendor` | Only `vendor` in the current folder |
| `/opt/sdk` | Only this absolute path |

`*` does not match `/`, `**` does.

## Things that don't work {#third-party-limits}

- **Macros from vendor headers.** A finding caused by a vendor macro is
  reported where the macro is used, in your code. Suppressing the
  header does not hide it. Put a `cppcheck-suppress-macro` comment at
  the macro definition, or suppress the id in your own files, see
  [In the code](#suppr-inline).
- **Critical errors in vendor code**, such as `#error` or
  `syntaxError`, are not hidden by `--suppress=*:vendor`, and fail the
  run in safety mode even if suppressed by id. Fix the configuration,
  see [Diagnosing critical errors](#embedded-critical-errors).
- **`-D` and `-U` don't stop headers from being read.** Every
  `#include` that is reached is preprocessed.

## Other options {#third-party-other}

- **Don't give the include path** to large vendor headers you don't
  need. Cppcheck continues without them, and you can describe their
  functions with a `.cfg` file (see [Library configuration](#library)).
- **Define the include guard** of a header to skip it:
  `-D_VENDOR_HUGE_H_`. Use this only for headers whose content
  Cppcheck does not need.

# Library configuration {#library}

<!-- oss: manual.md "Library configuration" -->

Cppcheck does not need to see the headers of the libraries you use.
Instead it uses library configuration files (`.cfg`). They describe
what functions do: which ones allocate memory, which arguments must
not be null, which never return, and so on. Headers only give the
types, so a `.cfg` file gives better results, faster.

The configuration for the C and C++ standard libraries (`std.cfg`) is
always loaded.

## Using a .cfg file {#library-using}

Load a configuration with `--library`:

```sh
cppcheck --library=posix --library=qt src
```

Configurations included with Cppcheck Premium (in the `cfg` folder of
the install):

| Area | Files |
|---|---|
| Operating systems | `posix`, `gnu`, `bsd`, `windows`, `zephyr`, `avr` |
| Microsoft | `mfc`, `microsoft_atl`, `microsoft_gsl`, `microsoft_sal`, `microsoft_unittest` |
| GUI toolkits | `qt`, `gtk`, `wxwidgets`, `kde`, `motif`, `sfml`, `sdl`, `vcl` |
| Test frameworks | `googletest`, `cppunit` |
| Other libraries | `boost`, `cairo`, `libcurl`, `opencv2`, `opengl`, `openmp`, `openssl`, `pcre`, `protobuf`, `sqlite3`, `tinyxml2`, `zlib`, and more |

Give the name without `.cfg`, or a path to your own file:

```sh
cppcheck --library=config/mylib.cfg src
```

In the GUI, choose libraries in the project settings.

**Don't combine a library configuration with the library's headers on
the include path**, for example `--library=posix` with
`-I/usr/include`. The two can conflict and cause wrong results or
syntax errors.

## Writing a .cfg file {#library-writing}

For your own libraries, or a vendor library, you can write a `.cfg`
file. Start with `--check-library`, which reports functions Cppcheck
has no information about:

```sh
cppcheck --check-library --enable=information src
```

A small example. Without configuration, Cppcheck does not know that
`CreatePen()` returns a resource that must be released:

```xml
<?xml version="1.0"?>
<def format="2">
  <resource>
    <alloc>CreatePen</alloc>
    <dealloc>DeleteObject</dealloc>
  </resource>
  <function name="vendor_reset">
    <noreturn>true</noreturn>
  </function>
  <function name="vendor_read">
    <noreturn>false</noreturn>
    <arg nr="1" direction="out">
      <not-null/>
    </arg>
    <arg nr="2" direction="in">
      <not-uninit/>
      <valid>1:64</valid>
    </arg>
  </function>
</def>
```

This says:

- `CreatePen()` allocates a resource that `DeleteObject()` releases,
  so a missing `DeleteObject()` is a leak.
- `vendor_reset()` never returns.
- `vendor_read()` writes to its first argument, which must not be
  null, and reads its second, which must be initialised and between 1
  and 64.

The GUI has a Library Editor for `.cfg` files, in the **View** menu.

<!-- TODO(confirm): include the full .cfg format reference in this manual (as an appendix or chapter), since it can't link to the OSS reference-cfg-format document -->

# Performance {#perf}

If an analysis takes too long, look at these, in this order:

1. Bug hunting is on. It is slow by design, see
   [Bug hunting](#bughunting).
2. Too many configurations per file, see
   [Limiting configurations and ValueFlow](#perf-limit).
3. Large headers on the include path, see
   [Third-party and vendor code](#third-party).
4. One slow file, see [Finding slow files](#perf-slow-files).

Use a build dir for repeated runs, and several jobs (`-j`).

## Check levels {#perf-check-level}

<!-- oss: manual.md "Check level" -->

`--check-level` sets how deep the data flow analysis goes:

| Level | Use for |
|---|---|
| `reduced` | Quick results while you edit code. Finds fewer bugs. |
| `normal` | The default. Good for most CI runs. |
| `exhaustive` | Nightly builds and release testing, when you can wait. Finds the most. |

```sh
cppcheck --check-level=exhaustive src
```

The check level does not turn coding standard checks on or off.

## Build dir and incremental runs {#perf-build-dir}

<!-- oss: manual.md "Cppcheck build folder" and "Cppcheck build dir", merged -->

Use a build dir to store analysis results between runs:

```sh
mkdir cppcheck-build
cppcheck --cppcheck-build-dir=cppcheck-build src
```

The next run only analyses files that have changed. The results for
the other files are read from the build dir and reported again. In the
GUI, the project file has a build dir setting, which is on by default.

A build dir is also needed for whole-program analysis with several
jobs (`-j`). Without it, checks that look at all files together, such
as unused functions and several MISRA rules, don't work with `-j`.

```sh
cppcheck -j8 --cppcheck-build-dir=cppcheck-build src
```

In CI, keep the build dir between runs (for example with a cache) to
get fast incremental runs.

**Clear the build dir** if results look wrong after an upgrade or a
license change: delete its contents and run again.

## Limiting configurations and ValueFlow {#perf-limit}

<!-- oss: manual.md "Speeding up analysis", "Possible speedup analysis of template code" -->

**Configurations.** When you check a folder, Cppcheck checks up to 12
`#ifdef` combinations per file (see
[Preprocessor defines and include paths](#preproc-defines)). To check
just one:

```sh
cppcheck --max-configs=1 src
```

An imported project already checks only one configuration per file.

**Functions with many `if` statements.** Some data flow analysis gets
exponentially slower with the number of `if` statements in a function.
Above a limit, that analysis is reduced for the function. Other
checks still run. You can set the limit:

```sh
cppcheck --performance-valueflow-max-if-count=50 src
```

**Recursive templates.** If Cppcheck reports
`templateRecursion`, it instantiated a recursive template up to its
limit. Add a template specialisation that only Cppcheck sees, to stop
the recursion early:

```cpp
#ifdef __cppcheck__
template<> void a<3>() {}
#endif
```

and run with `-D__cppcheck__`.

**GUI.** The project dialog's **Analysis** tab has more limits. To use
them on the command line too, run the project file with `--project`.

## Finding slow files {#perf-slow-files}

To see which file Cppcheck is working on, and how far it has come:

```sh
cppcheck --report-progress src
```

This only works with one job (no `-j`).

In the GUI, **View \> Thread details** shows which file each thread is
analysing and for how long.

When you have found the slow file, try:

- `--max-configs=1`, if it has many `#ifdef` combinations;
- leaving out large headers it includes, see
  [Third-party and vendor code](#third-party);
- `--check-level=reduced` for that file;
- `-i` to skip it, if it is not your code.

<!-- TODO(confirm): GUI menu name for thread details -->

\part{Coding standards and checks}\label{part-standards}

# Coding standards {#standards}

## The `--premium` option {#standards-option}

Coding standards and other Premium features are turned on with
`--premium`:

```sh
cppcheck --premium=misra-c-2025 src
```

Use the option several times to turn on several things:

```sh
cppcheck --premium=misra-c-2025 --premium=cert-c src
```

| Option | What it does |
|---|---|
| `--premium=misra-c-2012`, `misra-c-2023`, `misra-c-2025` | MISRA C |
| `--premium=misra-c++-2008`, `misra-c++-2023` | MISRA C++ |
| `--premium=cert-c`, `cert-c++` | CERT C and CERT C++ (2016) |
| `--premium=autosar` | AUTOSAR C++14 (partial) |
| `--premium=bughunting` | Bug hunting, see [Bug hunting](#bughunting) |
| `--premium=metrics` | Code metrics in the XML output, see [Metrics](#metrics) |
| `--premium=safety-off` | Turn safety mode off, see [Safety mode and exit codes](#safety) |
| `--premium-cert-c-int-precision=<bits>` | The precision of `int`, for CERT C rule INT35-C. Only needed if it is less than the size of `int`. |
| `--premium-license-file=<path>` | Use this license file, see [License file option and shared folders](#license-shared) |

Add `:all` to a coding standard to check all files, see
[Which files get which rules](#standards-files).

In the GUI, choose coding standards in the project settings.

<!-- TODO(confirm): - -premium=safety-profiles is accepted but not in - -help; document it or not? -->

## Supported standards {#standards-supported}

| Standard | Option | Language |
|---|---|---|
| MISRA C:2012 | `misra-c-2012` | C |
| MISRA C:2023 | `misra-c-2023` | C |
| MISRA C:2025 | `misra-c-2025` | C |
| MISRA C++:2008 | `misra-c++-2008` | C++ |
| MISRA C++:2023 | `misra-c++-2023` | C++ |
| SEI CERT C (2016) | `cert-c` | C |
| SEI CERT C++ (2016) | `cert-c++` | C++ |
| AUTOSAR C++14 | `autosar` | C++ |

Things to know:

- **One version per standard.** If you give two MISRA C versions, only
  the last one is used. Run Cppcheck once per version if you need
  several.
- **CERT includes rules and recommendations.** There is no option to
  check only the rules.
- **No addon needed.** Don't add `--addon=misra`. It runs the
  open-source MISRA C 2012 checks as well, which gives duplicate
  findings. See [MISRA does not need an addon](#addons-misra).

## Which files get which rules {#standards-files}

By default:

- MISRA C and CERT C check C files.
- MISRA C++, CERT C++ and AUTOSAR check C++ files.

A file is C or C++ depending on its extension, or the language in the
imported project. **A header is checked in the language of the file
that includes it.** A header included from a `.cpp` file gets C++
rules, even if it is a C header.

To check all files with a standard, add `:all`:

```sh
# MISRA C on C files only
cppcheck --premium=misra-c-2025 src

# MISRA C on C and C++ files
cppcheck --premium=misra-c-2025:all src
```

If your project has only C++ files and you enable only MISRA C,
nothing is reported.

## Filtering and classification {#standards-filtering}

### Showing guidelines and categories {#standards-report-type}

Many coding standard findings come from Cppcheck's own checks, which
have Cppcheck ids such as `nullPointer`. Add `--report-type` to show
the guideline and its category (for MISRA: mandatory, required or
advisory) instead:

```sh
cppcheck --premium=misra-c-2025 --report-type=misra-c-2025 src
```

In text output the id is replaced by the guideline and the severity by
the category. In XML output they are added as the `guideline` and
`classification` attributes.

Report types: `normal` (the default), `misra-c-2012`, `misra-c-2023`,
`misra-c-2025`, `misra-cpp-2008`, `misra-cpp-2023`, `cert-c-2016`,
`cert-cpp-2016` and `autosar`. The GUI has the same setting in
**View \> Report**.

<!-- TODO(confirm): GUI menu name -->

### Choosing what is reported {#standards-choosing}

<!-- premium-diverges: - -enable does not filter coding standard findings -->

`--enable` does not filter coding standard findings. They are reported
whenever the standard is enabled, whatever their severity.

To leave out guidelines, suppress them, for example all advisory rules
you have decided not to follow:

```sh
cppcheck --premium=misra-c-2025 --report-type=misra-c-2025 \
    --suppress=premium-misra-c-2025-2.3 src
```

To report only coding standard findings, filter the XML output on the
`guideline` attribute, or use the compliance report, which only lists
the standard's guidelines. See [Compliance reports](#compliance).

Coding standard ids have the form `premium-<standard>-<guideline>`,
for example `premium-misra-c-2025-2.3`, `premium-misra-cpp-2023-0.1.2`
or `premium-cert-int30-c`. Findings that come from Cppcheck's own
checks keep their Cppcheck id, such as `nullPointer`.

<!-- TODO(confirm): is there a way to get MISRA-only output? -->

<!-- TODO(confirm): suppressing a guideline doesn't suppress findings with Cppcheck ids mapped to it; how should customers handle that? -->

### Options that change which rules apply {#standards-options-rules}

- `--std` sets the language standard. Rules about features of a newer
  standard, and limits such as identifier length, depend on it. See
  [C/C++ standard](#preproc-std).
- `--platform` sets type sizes, which matter for essential type rules.
  See [Platform](#preproc-platform).
- `--report-type` sets how findings are classified.

Document these options with your analysis configuration if your
process needs a qualified tool setup.

## Rule coverage and undecidable rules {#standards-coverage}

Each release comes with coverage tables that list, for each standard,
which guidelines Cppcheck Premium checks. For MISRA C they also
describe:

- how each directive is covered,
- which rules are undecidable, meaning no tool can always decide
  whether the code complies, and what Cppcheck Premium checks for
  them.

The compliance report shows guidelines Cppcheck Premium does not check
as "Not implemented". Those must be checked another way, for example
by review.

<!-- TODO(confirm): where the coverage tables are published for customers -->

# Safety mode and exit codes {#safety}

## What safety mode does {#safety-mode}

Cppcheck Premium runs in safety mode by default. Safety mode makes sure
that a run where some code could not be analysed is never mistaken for
a clean result:

- If a **critical error** happens, Cppcheck exits with code 1. A
  critical error means some code was not fully analysed, for example
  `syntaxError`, `preprocessorErrorDirective`, `unknownMacro` or
  `premium-invalidLicense`. See
  [Diagnosing critical errors](#embedded-critical-errors).
- **Critical errors can't be hidden with suppressions.** A suppression
  with a wildcard (`*`) does not apply to them. If you suppress one by
  its exact id, the message is hidden, but the exit code is still 1.
- The checkers report lists the critical errors.

Without critical errors, Cppcheck exits with 0, also when it reports
findings. To fail the run on findings, see [Exit codes](#safety-exit-codes).

## Turning safety mode off {#safety-off}

```sh
cppcheck --premium=safety-off ...
```

Then critical errors are reported like other findings and can be
suppressed, and the exit code does not depend on them.

**Turn it off only if you have a reason.** The compliance report marks
results from runs with safety mode off as non-compliant, because
critical errors may have hidden violations.

A typical reason is a first trial on a large code base, where you want
to see results before the configuration is complete.

<!-- TODO(confirm): - -premium=safety (explicitly) makes the addon require a "safety license" (src/license.cpp). Is that intended, and should the manual say not to use it? -->

## Exit codes {#safety-exit-codes}

| Exit code | When |
|---|---|
| 0 | The analysis completed. Findings don't change the exit code, unless you use `--error-exitcode`. |
| 1 | Safety mode is on and a critical error happened, including a license problem. Also for invalid options or no input files. |
| `<n>` | You gave `--error-exitcode=<n>` and there are findings that are not suppressed. |

To fail a CI job when there are findings:

```sh
cppcheck --premium=misra-c-2025 --error-exitcode=2 src
```

Use a value other than 1, so you can tell findings from critical
errors.

`compliance-report` exits with 0 when it has written the report,
whether the code is compliant or not, and with 1 if it fails (unknown
option, missing input file). See [Compliance reports](#compliance).

See also [Exit codes](#ref-exit-codes) in the reference.

# Bug hunting {#bughunting}

Bug hunting is a deeper analysis for when you are looking for bugs and
can accept noise. It finds more bugs than normal analysis, but most of
its findings are false positives. The aim is no more than roughly 5 to
10 false positives per file.

```sh
cppcheck --premium=bughunting src
```

**Use bug hunting for:**

- reviewing a new feature before it is released,
- release testing, on the files that changed,
- looking for the cause of a bug you know exists.

**Don't use it in normal CI or for everyday checks.** It is much
slower than normal analysis, sometimes hours for a large project, and
the noise makes it unsuitable as a gate. Run it on selected files
instead:

```sh
cppcheck --premium=bughunting --file-filter=src/new_feature/*.c --project=compile_commands.json
```

Bug hunting findings are not filtered by `--enable`. Technically, the
analysis is "soundy": it aims to find most bugs while keeping the noise
at a reasonable level, but does not guarantee finding all of them.

If an analysis is unexpectedly slow, check that bug hunting is not
turned on, for example in a GUI project file. See
[Performance](#perf).

# Addons {#addons}

<!-- oss: manual.md "Addons" -->

Addons are Python scripts that run extra checks on the code. Cppcheck
Premium includes a few, and you can write your own.

## Running addons {#addons-running}

Run an addon with `--addon`:

```sh
cppcheck --enable=style --addon=namingng.py src
```

Addon findings are filtered by `--enable` like other Cppcheck
findings. Most are style findings, so add `--enable=style`.

Cppcheck looks for the addon in the current folder first, then in the
`addons` folder of the install. You can also give a path:

```sh
cppcheck --addon=tools/mychecks.py src
```

To pass options to an addon, describe it in a JSON file:

```json
{
    "script": "mychecks.py",
    "args": ["--some-option"],
    "ctu": false
}
```

and run the JSON file:

```sh
cppcheck --addon=mychecks.json src
```

Addons need Python 3 on the machine.

To write your own checks, see [Custom tooling](#tools-custom).

## namingng, threadsafety and y2038 {#addons-oss}

**namingng.py** checks naming conventions. Describe them in
`namingng.config.json`, as regular expressions:

```json
{
    "RE_VARNAME": ["[a-z]*[a-zA-Z0-9_]*\\Z"],
    "RE_FUNCTIONNAME": ["[a-z0-9A-Z]*\\Z"],
    "include_guard": {
        "input": "path",
        "prefix": "GUARD_",
        "case": "upper",
        "required": true
    },
    "var_prefixes": {"uint32_t": "ui32"}
}
```

**threadsafety.py** looks for thread safety issues, such as static
local objects used by several threads.

**y2038.py** looks for code that breaks in 2038, when a signed 32-bit
`time_t` overflows.

## MISRA does not need an addon {#addons-misra}

<!-- premium-diverges: MISRA via - -premium, not misra.py -->

Cppcheck Premium checks MISRA with `--premium`, see
[Coding standards](#standards). Don't use `--addon=misra`.

The open-source Cppcheck has a `misra.py` addon that checks part of
MISRA C 2012. If you use it together with `--premium`, you get its
findings too, with ids like `misra-c2012-10.4`. They duplicate the
Premium findings and can look like the wrong MISRA version is used.
Remove `--addon=misra` from your command line and project files when
you move to Cppcheck Premium.

\part{Results and reports}\label{part-results}

# Suppressions, justifications and baselines {#suppr}

<!-- oss: manual.md "Suppressions" -->

There are three ways to deal with a finding you don't want to fix:

|  | Effect | Use for |
|---|---|---|
| **Suppression** | The finding is hidden. | False positives, and findings in code you don't maintain. |
| **Justification** (`REMARK` comment) | The finding is still reported, with your explanation. The compliance report lists it as an accepted violation. | Deliberate deviations from a coding standard. |
| **Baseline** | All of today's findings are hidden; new ones are reported. | Starting to use Cppcheck on an existing code base. |

If you find a false positive, please also report it to us, see
[Getting help](#help).

## Suppression formats {#suppr-formats}

A suppression has an id, and optionally a file and a line:

```
<id>:<file>:<line>
<id>:<file>
<id>
```

The id is shown in brackets after each finding, for example
`[nullPointer]`. Use `*` as the id to suppress everything in a file.
File names use the patterns described in
[Path patterns](#third-party-patterns). Use `/` as the path separator
on all systems.

### On the command line or in a file {#suppr-text}

```sh
cppcheck --suppress=nullPointer:src/legacy.c src
```

Several suppressions can go in a text file:

```
# Known false positive
nullPointer:src/legacy.c
*:vendor
unusedFunction  // in all files
```

and are used with:

```sh
cppcheck --suppressions-list=suppressions.txt src
```

Lines starting with `#` or `//` are comments, and so is anything after
`//` on a line.

### In an XML file {#suppr-xml}

XML suppressions can also match a symbol name or a hash:

```xml
<?xml version="1.0"?>
<suppressions>
  <suppress>
    <id>uninitvar</id>
    <fileName>src/file1.c</fileName>
    <lineNumber>10</lineNumber>
    <symbolName>var</symbolName>
  </suppress>
  <suppress>
    <id>nullPointer</id>
    <fileName>src/file2.c</fileName>
    <hash>12345678</hash>
  </suppress>
</suppressions>

cppcheck --suppress-xml=suppressions.xml src
```

All elements given in a `<suppress>` must match.

**Hash.** Each finding has a hash, shown in the XML output (see
[XML output](#output-xml)). It depends on the code involved, not on
the line number. A suppression with a hash keeps working when other
lines in the file are added or removed, and stops working when the
code it points at changes. This is what baselines use.

<!-- TODO(confirm): the <macro> element in XML suppressions (support summary says 26.9.0); it is not in Cppcheck 2.22.0 -->

### In the code {#suppr-inline}

Inline suppressions are comments in the code. They are only read with
`--inline-suppr`:

```sh
cppcheck --inline-suppr src
```

Put the comment on the line before the code, or at the end of the
line:

```c
// cppcheck-suppress arrayIndexOutOfBounds
arr[10] = 0;

arr[10] = 0;  // cppcheck-suppress arrayIndexOutOfBounds
```

Several ids, **separated by commas**:

```c
// cppcheck-suppress [arrayIndexOutOfBounds, zerodiv]
arr[10] = arr[10] / 0;
```

A block. **The end comment must repeat the ids**, or the block is
not closed:

```c
// cppcheck-suppress-begin nullPointer
...
// cppcheck-suppress-end nullPointer
```

A whole file:

```c
// cppcheck-suppress-file unusedFunction
```

Everywhere a macro is used. Put the comment just before the
`#define`:

```c
// cppcheck-suppress-macro premium-misra-c-2025-10.4
#define SCALE(x) ((x) * 1.5)
```

Only for one symbol:

```c
// cppcheck-suppress nullPointer symbolName=ptr
```

A comment about the suppression goes after `;` or `//`:

```c
// cppcheck-suppress nullPointer ; checked by the caller
```

The suppression comment and the code may be separated by empty lines
and other comments. A comment at the end of a line only applies to
that line.

### Coding standard ids {#suppr-ids}

Coding standard findings have ids like `premium-misra-c-2025-10.4` and
`premium-cert-int30-c`. See
[Choosing what is reported](#standards-choosing).

## Justification comments {#suppr-justification}

<!-- oss: manual.md "Justifications for warnings in the report" -->

<!-- premium-diverges: justified findings are accepted violations in the compliance report -->

When you deviate from a coding standard on purpose, document why with
a `REMARK` comment, on the line before the code or at the end of the
line:

```c
// REMARK Deviation D12: cast needed for the register interface
*(volatile uint32_t *)0x40021000u = 1u;
```

The finding is still reported, with the remark:

- in XML output as the `remark` attribute,
- in text output with `{remark}` in `--template`, see
  [Text output and templates](#output-text).

The compliance report lists justified findings as **accepted
violations** and does not count them against compliance. See
[Compliance reports](#compliance).

A remark may continue over several comment lines. An empty line ends
it.

<!-- TODO(confirm): multi-line REMARK behaviour (support ticket 97) -->

## Baselines {#suppr-baseline}

<!-- oss: manual.md "Generating and using a baseline" -->

A baseline hides all findings you have today, so that you only see new
ones. It is a suppressions file with one hash-based suppression per
finding.

**1. Analyse the code** with the options you normally use, and write
XML:

```sh
cppcheck --premium=misra-c-2025 --xml-version=3 src 2> baseline-results.xml
```

**2. Convert the results** to a suppressions file:

```sh
python3 generate-baseline-suppressions.py baseline-results.xml baseline.xml
```

<!-- TODO(confirm): is generate-baseline-suppressions.py included with Premium? It is in the Cppcheck source repository (tools/) -->

**3. Use it** in every later run, including CI. Keep `baseline.xml` in
version control.

```sh
cppcheck --premium=misra-c-2025 --suppress-xml=baseline.xml src
```

Only findings that are not in the baseline are reported: new findings
in changed code, and findings from checks or files that were not
analysed when the baseline was made.

**Refresh** the baseline by repeating steps 1 and 2, for example after
fixing a batch of findings.

You don't need to clean up the baseline when code is fixed. Hash-based
suppressions that no longer match are not reported as
`unmatchedSuppression`.

Things to know:

- Critical errors have no hash and can't be put in a baseline. Fix
  them.
- Changing options can give new findings that are not in the
  baseline.
- An upgrade can change the message of a check, and with it the
  hash. Findings from that check then appear again. See
  [Upgrading](#upgrade).

To shrink the baseline over time, fix the most serious findings
(errors, then warnings) first, and leave low-risk style findings in
the baseline longer.

## Premium notes {#suppr-premium-notes}

### Unmatched suppressions {#suppr-unmatched}

`unmatchedSuppression` reports suppressions that did not match any
finding. You only get it with `--enable=information`, and for inline
suppressions only with `--inline-suppr`.

If you use suppressions to turn off checks that never fire in your
code, each of them gives an `unmatchedSuppression`. Suppress those
too:

```sh
--suppress=unmatchedSuppression
```

### Suppressions in reports {#suppr-reports}

XML version 3 output lists all suppressions that were used, in a
`<suppressions>` element, and the compliance report shows them. See
[XML output](#output-xml).

### Known problems {#suppr-known-problems}

<!-- TODO(confirm): which of these are fixed in the current release; remove the fixed ones -->

- With `-j` greater than 1, file and inline suppressions of
  whole-program rules (for example MISRA C 8.7) can be ignored. Use
  `-j1` for those runs, or suppress with `--suppress`.
- With `--relative-paths`, `cppcheck-suppress-macro` can stop working.
- With a build dir that already has results, suppressions you add can
  be ignored for unchanged files. Clear the build dir after changing
  suppressions.
- After an upgrade, `symbolName` suppressions can stop matching if the
  reported symbol changed.

# Output formats {#output}

Cppcheck writes findings to standard error. Choose the format with
`--output-format`, or the options below:

| Format | Option | Use for |
|---|---|---|
| Text | (default) | Reading in a terminal or an IDE |
| XML version 3 | `--xml-version=3` or `--output-format=xmlv3` | Compliance reports, metrics, baselines, your own tools |
| XML version 2 | `--xml` or `--output-format=xmlv2` | The HTML report, older tools |
| SARIF | `--output-format=sarif` | GitHub code scanning, SonarQube and other dashboards |

To write to a file instead of standard error:

```sh
cppcheck --xml-version=3 --output-file=results.xml src
```

or redirect standard error, `2> results.xml`.

## Text output and templates {#output-text}

<!-- oss: manual.md "Reformatting the text output" -->

By default a finding looks like this:

```
src/a.c:6:6: error: Array 'a[2]' accessed at index 2, which is out of bounds. [arrayIndexOutOfBounds]
    a[2] = 0;
     ^
```

Predefined formats: `--template=gcc` and `--template=vs` (Visual
Studio).

Your own format, for example one line per finding as CSV:

```sh
cppcheck --template="{file},{line},{severity},{id},{message}" src
```

Fields for `--template`:

| Field | Value |
|---|---|
| `{file}`, `{line}`, `{column}` | Location |
| `{severity}` | Severity, or the guideline category with `--report-type` |
| `{id}` | Finding id, or the guideline with `--report-type` |
| `{message}` | The message |
| `{code}` | The line of code, with a marker |
| `{callstack}` | All locations, as `[file:line] -> [file:line]` |
| `{cwe}` | CWE number |
| `{remark}` | The justification, see [Justification comments](#suppr-justification) |
| `{inconclusive:text}` | `text` if the finding is inconclusive |
| `\t`, `\n`, `\r` | Tab, newline, carriage return |

Many findings have several locations, for example where a null value
comes from and where it is used. To show them, add
`--template-location`, with the fields `{file}`, `{line}`,
`{column}`, `{info}` and `{code}`:

```sh
cppcheck --template="{file}:{line}: {severity}: {message}\n{code}" \
         --template-location="{file}:{line}: note: {info}\n{code}" src
```

## XML output {#output-xml}

<!-- oss: manual.md "XML output" -->

<!-- premium-diverges: XML version 3 is needed for compliance reports and metrics -->

**Use XML version 3 with Cppcheck Premium.** The compliance report and
metrics need it:

```sh
cppcheck --premium=misra-c-2025 --xml-version=3 src 2> results.xml
```

Each finding is an `<error>` element:

```xml
<error id="nullPointer" severity="warning" msg="Possible null pointer dereference: p"
       verbose="Possible null pointer dereference: p" cwe="476"
       hash="15981348499267524998" file0="a.c">
  <location file="a.c" line="3" column="6" info="Null pointer dereference"/>
  <location file="a.c" line="8" column="7" info="Calling function 'f', 1st argument 'p' value is 0"/>
  <location file="a.c" line="7" column="14" info="Assignment 'p=0', assigned value is 0"/>
  <symbol>p</symbol>
</error>
```

| Attribute | Value |
|---|---|
| `id`, `severity`, `msg`, `verbose` | Id, severity, short and long message |
| `guideline`, `classification` | Guideline and category, with `--report-type` |
| `cwe` | CWE number, if known |
| `hash` | A hash of the code involved, for suppressions and baselines |
| `inconclusive` | `true` if the finding is inconclusive |
| `remark` | The justification, if there is one |
| `file0` | The source file that was analysed. Differs from the location when the finding is in a header. |

Each `<location>` has `file`, `line`, `column` and `info`. The first
location is the main one. `<symbol>` names the variable or function
involved, if there is one.

Version 3 adds, after the findings:

- `<safety/>` if safety mode was on, and `<inline-suppr/>` if inline
  suppressions were read,
- `<suppressions>`: every suppression used in the run,
- the checkers report: which checkers ran, and any critical errors,
- metrics, with `--premium=metrics`.

The compliance report uses the checkers report to tell which
guidelines were checked. Without it, guidelines show as "Not executed".

## HTML report {#output-html}

<!-- oss: manual.md "HTML report" -->

`cppcheck-htmlreport` turns XML output into a browsable HTML report
with the source code:

```sh
cppcheck --xml src 2> results.xml
cppcheck-htmlreport --file=results.xml --report-dir=html --source-dir=.
```

Open `html/index.html`. It needs Python 3 with the `pygments` module.

Instead of copying the source into the report, you can link to it in
GitHub or GitLab. Give the repository URL with the branch:

```sh
cppcheck-htmlreport --file=results.xml --report-dir=html \
    --source-dir=https://github.com/<user>/<repo>/blob/<branch>/
```

This is faster for large projects, and the code stays private, because
access is controlled by the hosting service.

**HTML report or compliance report?** The HTML report shows each
finding with its code, for developers fixing them. The compliance
report summarises compliance with one coding standard, guideline by
guideline, for audits. See [Compliance reports](#compliance).

<!-- TODO(confirm): does cppcheck-htmlreport accept XML version 3, so one run can feed both reports? -->

# Compliance reports {#compliance}

A compliance report shows, guideline by guideline, whether your code
complies with a coding standard. It is an HTML page for audits and
certification.

## Creating a report {#compliance-create}

Analyse with the coding standard and **XML version 3**, then run
`compliance-report` on the result:

```sh
cppcheck --premium=misra-c-2025 --xml-version=3 src 2> results.xml
compliance-report --misra-c-2025 --project-name=Device --project-version=2.3 \
    --output-file=report.html results.xml
```

`compliance-report` is in the install folder. It is a command line
tool; the GUI does not create compliance reports.

Options:

| Option | Meaning |
|---|---|
| `--misra-c-2012`, `--misra-c-2023`, `--misra-c-2025` | MISRA C report |
| `--misra-c++-2008`, `--misra-c++-2023` | MISRA C++ report |
| `--cert-c`, `--cert-c++` | CERT C or C++ report |
| `--cwe-top25` | CWE Top 25 report |
| `--project-name=<name>`, `--project-version=<version>` | Shown in the report |
| `--output-file=<file>` | The HTML file. By default named after the standard, e.g. `misra-c-2025-compliance-report.html` |
| `--files=<file>` | Add a list of analysed files with checksums, see [File list](#compliance-files) |

The coding standard of the report must be the one you analysed with.

## Reading the report {#compliance-reading}

The top of the report says **Compliant** or **Non compliant**, and why.
The code is non-compliant if any of these is true:

- a guideline has findings that are not justified or suppressed,
- a guideline was "Not executed",
- the XML is not version 3 ("Use Cppcheck option `--xml-version=3`"),
- safety mode was off ("Safety has been turned off"),
- for MISRA C, `premium-misra-config` findings were suppressed.

If there were critical errors, the report says that not all files were
fully analysed.

For each guideline, the table shows one of:

| Status | Meaning |
|---|---|
| Compliant | Checked, no findings. |
| "There are N ..." | The number of findings, by id. |
| Suppressed | Findings were suppressed. The suppressions are listed in the report. |
| Not executed | The checker did not run, so compliance is unknown. |
| Not implemented | Cppcheck Premium does not check this guideline. Check it another way, for example by review. |

**Justified findings** (with a `REMARK`, see
[Justification comments](#suppr-justification)) are listed under
**Accepted violations** and don't make the code non-compliant.

## "Not executed" {#compliance-not-executed}

Most often, the XML was written with `--xml` (version 2) instead of
`--xml-version=3`. Version 2 does not record which checkers ran, so
every guideline is "Not executed". Analyse again with
`--xml-version=3`.

Other causes:

- The coding standard was not enabled with `--premium`, or another
  version was enabled than the report is for.
- The files were not analysed for that language. MISRA C rules only
  run on C files, unless you add `:all`. See
  [Which files get which rules](#standards-files).
- Some guidelines need an option. CERT C INT35-C needs
  `--premium-cert-c-int-precision` if `int` has padding bits; without
  it, INT35-C is "Not executed", which does not affect compliance.

## File list {#compliance-files}

To list the analysed files with their checksums in the report, write
them with `md5sum` and pass the file with `--files`:

```sh
md5sum $(git ls-files '*.c' '*.h') > files.txt
compliance-report --misra-c-2025 --files=files.txt results.xml
```

The report then shows the compliance of each file.

<!-- TODO(confirm): Windows equivalent of md5sum for - -files -->

## Exit code {#compliance-exit-code}

`compliance-report` exits with 0 when the report was written, whether
the code is compliant or not, and 1 on errors. To fail a CI job on
non-compliance, use `--error-exitcode` in the Cppcheck run instead.
See [Exit codes](#safety-exit-codes).

# Metrics {#metrics}

## HIS metrics {#metrics-his}

Cppcheck Premium can calculate code metrics, such as the HIS metrics
(cyclomatic complexity, number of calls, parameters, return points,
nesting levels and so on). Turn them on with `--premium=metrics`. They
are written to the XML version 3 output:

```sh
cppcheck --premium=metrics --xml-version=3 src 2> results.xml
```

To get a CSV report, use `HISReport.py` from the install folder:

```sh
python3 HISReport.py -f results.xml -j /opt/cppcheckpremium/cppcheck-id-mapping.json -o metrics.csv
```

| Option | Meaning |
|---|---|
| `-f <file>` | The XML results |
| `-j <file>` | `cppcheck-id-mapping.json` from the install folder |
| `-o <file>` | The CSV file to write |

The report compares each function's metrics with the HIS limits, for
example a cyclomatic complexity of at most 10, and at most 5
parameters.

`HISReport.py` is a short Python script. Change it if you want other
limits, or HTML output.

<!-- TODO(confirm): HISReport.py help says the run should also use - -premium=misra-c-2012; is that needed? -->

## License metrics {#metrics-license}

`git-license-metrics` counts the people who have committed to a git
repository during the last year:

```sh
git-license-metrics path/to/repository
```

Add `--summary` for a short summary. Use it to find out how many
developers work on the code, for example when choosing a license.

<!-- TODO(confirm): what customers should do with the output (e.g. send it to sales), and whether it is related to git-based licenses -->

\part{Integrations}\label{part-integrations}

# CI pipelines {#ci}

Every CI system follows the same pattern:

1. Install Cppcheck Premium, usually from the `.tar.gz` archive (see
   [Headless and CLI-only](#install-headless)).
2. Write the license file from a secret (see
   [Licenses in Docker, dev containers, VMs and CI](#license-containers)).
3. Run Cppcheck with your project file or compilation database.
4. Keep the results: SARIF for code scanning dashboards, XML for the
   compliance report.
5. Fail the job on findings with `--error-exitcode`, if you want a
   gate (see [Exit codes](#safety-exit-codes)).

For fast runs, keep the build dir between runs, see
[Build dir and incremental runs](#perf-build-dir).

The examples below assume:

- `CPPCHECK_PREMIUM_URL`: where your pipeline downloads the
  `.tar.gz` from, for example an internal artifact store,
- `CPPCHECK_LICENSE`: a secret with the content of
  `cppcheck-premium.lic`,
- `project.cppcheck`: your Cppcheck project file.

<!-- TODO(confirm): CI examples tested end to end -->

## GitHub Actions {#ci-github}

This workflow uploads the results to GitHub code scanning, so they
show up in pull requests and the Security tab:

```yaml
name: cppcheck
on: [push, pull_request]
jobs:
  cppcheck:
    runs-on: ubuntu-24.04
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - name: Install Cppcheck Premium
        run: |
          curl -fsSL "${{ vars.CPPCHECK_PREMIUM_URL }}" | tar xz -C "$RUNNER_TEMP"
          echo "$(echo $RUNNER_TEMP/cppcheckpremium-*)" >> "$GITHUB_PATH"
      - name: Analyse
        env:
          CPPCHECK_LICENSE: ${{ secrets.CPPCHECK_LICENSE }}
        run: |
          printf '%s\n' "$CPPCHECK_LICENSE" > "$RUNNER_TEMP/cppcheck-premium.lic"
          cppcheck --premium-license-file="$RUNNER_TEMP/cppcheck-premium.lic" \
            --project=project.cppcheck \
            --output-format=sarif --output-file=cppcheck.sarif
      - uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: cppcheck.sarif
```

## GitLab {#ci-gitlab}

```yaml
cppcheck:
  image: ubuntu:24.04
  script:
    - apt-get update && apt-get install -y curl
    - curl -fsSL "$CPPCHECK_PREMIUM_URL" | tar xz -C /opt
    - export PATH="$(echo /opt/cppcheckpremium-*):$PATH"
    - printf '%s\n' "$CPPCHECK_LICENSE" > /tmp/cppcheck-premium.lic
    - cppcheck --premium-license-file=/tmp/cppcheck-premium.lic
        --project=project.cppcheck --xml-version=3
        --error-exitcode=2 2> cppcheck.xml
  artifacts:
    when: always
    paths:
      - cppcheck.xml
```

Store `CPPCHECK_LICENSE` as a masked CI/CD variable. Turn
`cppcheck.xml` into a compliance report or HTML report in a later
job, see [Compliance reports](#compliance).

## Jenkins {#ci-jenkins}

The Warnings Next Generation plugin reads Cppcheck XML and shows the
findings in Jenkins:

```
pipeline {
    agent any
    environment {
        CPPCHECK_LICENSE = credentials('cppcheck-license-file')
    }
    stages {
        stage('cppcheck') {
            steps {
                sh '''
                    cppcheck --premium-license-file="$CPPCHECK_LICENSE" \
                        --project=project.cppcheck --xml 2> cppcheck.xml
                '''
            }
        }
    }
    post {
        always {
            recordIssues tools: [cppCheck(pattern: 'cppcheck.xml')]
        }
    }
}
```

Here the license is a "secret file" credential, so Jenkins writes it
to a file for you. This example assumes Cppcheck Premium is installed
on the agent.

## Azure DevOps {#ci-azure}

```yaml
steps:
  - script: |
      curl -fsSL "$(CPPCHECK_PREMIUM_URL)" | tar xz -C $(Agent.TempDirectory)
      echo "##vso[task.prependpath]$(echo $(Agent.TempDirectory)/cppcheckpremium-*)"
    displayName: Install Cppcheck Premium
  - script: |
      printf '%s\n' "$CPPCHECK_LICENSE" > $(Agent.TempDirectory)/cppcheck-premium.lic
      cppcheck --premium-license-file=$(Agent.TempDirectory)/cppcheck-premium.lic \
        --project=project.cppcheck \
        --output-format=sarif --output-file=$(Build.ArtifactStagingDirectory)/cppcheck.sarif
    displayName: Analyse
    env:
      CPPCHECK_LICENSE: $(CPPCHECK_LICENSE)
  - task: PublishBuildArtifacts@1
    inputs:
      PathtoPublish: $(Build.ArtifactStagingDirectory)
      ArtifactName: CodeAnalysisLogs
```

With the SARIF SAST Scans Tab extension, findings in the
`CodeAnalysisLogs` artifact are shown in a Scans tab of the build.

# IDE plug-ins {#ide}

<!-- TODO(confirm): which plug-ins support Cppcheck Premium, and how each is configured; this chapter is a draft -->

IDE plug-ins run the `cppcheck` program and show the findings in the
editor. To use Cppcheck Premium, point the plug-in to the Premium
`cppcheck`, not an open-source one, and add your `--premium` options.

**Use the same settings as your CI.** Where the plug-in lets you give
extra options, use `--project=project.cppcheck`, so the IDE, the
command line and CI all use the same project file. See
[One configuration for GUI, CLI and CI](#first-one-config).

## VS Code {#ide-vscode}

The Cppcheck extension for VS Code runs Cppcheck on the files you open
and save, and shows the findings in the Problems panel.

In the extension settings:

- set the path to the Premium `cppcheck`, for example
  `/opt/cppcheckpremium/cppcheck` or
  `C:\Program Files\Cppcheck Premium\cppcheck.exe`,
- add your options, for example
  `--premium=misra-c-2025 --project=project.cppcheck`.

## Eclipse {#ide-eclipse}

The cppcheclipse plug-in runs Cppcheck from Eclipse CDT. Set the path
to the Premium `cppcheck` in **Window \> Preferences \> Cppcheclipse**.

Eclipse may pass the project's include paths to Cppcheck. If you get
findings from system headers, remove those include paths from the
plug-in settings, see [Include paths](#preproc-includes).

## Visual Studio {#ide-visual-studio}

The Cppcheck add-in for Visual Studio runs Cppcheck on the current
project or file. Set the path to the Premium `cppcheck.exe` in the
add-in options, and add your `--premium` options.

You can also add Cppcheck as an external tool: **Tools \> External
Tools**, command `C:\Program Files\Cppcheck Premium\cppcheck.exe`,
arguments `--template=vs --premium=misra-c-2025 $(ItemPath)`, and
**Use Output window** checked. With `--template=vs`, double-click a
finding to go to the code.

## IAR {#ide-iar}

IAR Embedded Workbench can run Cppcheck as a tool. Add it under
**Tools \> Configure Tools**, with the command
`C:\Program Files\Cppcheck Premium\cppcheck.exe` and arguments such as:

```sh
--template=vs --premium=misra-c-2025 --include=iar-macros.h $FILE_PATH$
```

IAR code needs the compiler's predefined macros, see
[Compiler predefined macros](#embedded-macros).

# Other tools {#tools}

## Teamscale {#tools-teamscale}

<!-- TODO(confirm): how Teamscale uses Cppcheck Premium (Teamscale builds of Premium exist), and what the customer has to do -->

Teamscale can run Cppcheck Premium as part of its analysis. A special
build of Cppcheck Premium and a Teamscale license are needed. Contact
us for details, see [Getting help](#help).

## SonarQube {#tools-sonarqube}

SonarQube and SonarCloud import findings from other tools in SARIF
format:

```sh
cppcheck --project=project.cppcheck --output-format=sarif --output-file=cppcheck.sarif
```

Then give the file to the scanner:

```sh
sonar-scanner -Dsonar.sarifReportPaths=cppcheck.sarif
```

The findings show up as external issues. Other dashboards that read
SARIF work the same way.

## Custom tooling {#tools-custom}

### Reading the results {#tools-custom-results}

For your own scripts and dashboards, read the XML version 3 output, see
[XML output](#output-xml). Each finding has its id, severity, guideline,
locations and hash.

### Writing your own checks {#tools-custom-addons}

You can write checks of your own in Python, as addons. An addon
reads a dump file: an XML description of the code after Cppcheck has
parsed it, with tokens, scopes, functions, variables and values.

Create a dump file:

```sh
cppcheck --dump test.c
```

This writes `test.c.dump`. Addons read it with `cppcheckdata.py`,
which is in the `addons` folder of the install:

```python
import cppcheck

@cppcheck.checker
def no_goto(cfg, data):
    for token in cfg.tokenlist:
        if token.str == 'goto':
            cppcheck.reportError(token, 'style', 'Avoid goto', 'noGoto')
```

Save it as `nogoto.py` and run it with Cppcheck:

```sh
cppcheck --enable=style --addon=nogoto.py src
```

The finding is reported as `nogoto-noGoto`: the addon name, then the
id. Addon findings with severity style are only shown with
`--enable=style`. See [Running addons](#addons-running).

<!-- TODO(confirm): include a reference for the dump file format and cppcheckdata.py (OSS writing-addons.md) -->

\part{Maintain}\label{part-maintain}

# Upgrading {#upgrade}

To upgrade, install the new version the same way as the old one (see
[Installation](#install)):

- **Windows:** run the new installer.
- **Linux packages:** install the new `.deb` or `.rpm`, or run
  `sudo apt upgrade` if you use the apt repository.
- **`.tar.gz` and macOS:** unpack the new version and update your
  `PATH`.

Your license file stays where it is.

<!-- TODO(confirm): whether a valid license covers new versions -->

## Before you upgrade {#upgrade-before}

Results can change between versions: checks find more, false positives
are fixed, and messages are reworded. To see what changed, run the old
and the new version on the same code and compare.

Things to check:

- **Baselines.** If a message is reworded, its hash changes, and
  baselined findings from that check come back. Refresh the baseline
  after upgrading, see [Baselines](#suppr-baseline).
- **`symbolName` suppressions.** If the reported symbol changes, they
  stop matching.
- **Build dir.** Clear it, so that all files are analysed with the new
  version, see [Build dir and incremental runs](#perf-build-dir).
- **Release notes.** Read them for changed options and behaviour, see
  [Changelog](#ref-changelog).

# Uninstalling {#uninstall}

**Windows:** uninstall Cppcheck Premium in **Settings \> Apps**.

**Ubuntu and Debian:**

```sh
sudo apt remove cppcheckpremium
```

**Red Hat and compatible:**

```sh
sudo dnf remove cppcheckpremium
```

**`.tar.gz` and macOS:** delete the folder you unpacked, and remove it
from your `PATH`.

<!-- TODO(confirm): package names -->

**License files** are not removed. Delete them yourself if you no
longer need them. See [Where to put the license file](#license-location)
for where they are.

\part{Troubleshooting and FAQ}\label{part-troubleshooting}

# License troubleshooting {#trouble-license}

If Cppcheck Premium reports `invalidLicense`, or the Premium checks
don't run, go through these steps.

## Step 1: check the license {#trouble-license-debug}

Run the license check on its own:

```sh
premiumaddon --debug
```

On Windows, run `premiumaddon.exe --debug` in the install folder. It
works from any folder.

The output shows each license file that was tried, and the result:

```
Validating license file: /etc/cppcheckpremium/cppcheck-premium.lic => License is valid
```

and, if the license is valid, which standards it covers:

```
Licensed features: autosar:1 cert:1 misra:1 ...
```

A `0` means the license does not cover that standard. Its checks are
skipped without an error, and the compliance report shows its
guidelines as "Not executed".

## Step 2: read the message {#trouble-license-messages}

| Message | Cause and fix |
|---|---|
| `Failed to open license file` | No license file found. Put it in one of the folders in [Where to put the license file](#license-location), or use `--premium-license-file`. Check that the file name is unchanged. |
| `License has expired` | The license is past its expiry date. Renew it, see [Renewal, expiry and validity across versions](#license-renewal). If you have renewed, an old file may be found first: remove it. |
| `License is not valid` | The file was changed, renamed, or is for another machine. For a machine-bound license, check that you are on the machine it was registered on. |
| `Git ID not found` | A git-based license (`cppcheck-premium-git.lic`) only works when Cppcheck runs inside the licensed git repository. |
| `Safety license not found` | See [Safety mode and exit codes](#safety). |

## Step 3: clear the build dir {#trouble-license-build-dir}

Results in a build dir can be from an earlier run, before the license
problem was fixed.

- **Command line:** delete the contents of the folder given with
  `--cppcheck-build-dir`, and run again.
- **GUI:** choose **Edit \> Clear results**, or click the brush icon,
  and run again.

## Step 4: remove cppcheck-premium-loc files {#trouble-license-loc}

Remove any `cppcheck-premium-loc` files in your project folders. If
they are created again during analysis, check your scripts for why.

<!-- TODO(confirm): what cppcheck-premium-loc files are, so customers know why they cause problems -->

If the problem remains, contact support with the output of
`premiumaddon --debug`, see [Getting help](#help).

# Common configuration errors {#trouble-config}

These messages usually mean the analysis needs more configuration, not
that the code is wrong.

## \#error Unknown compiler {#trouble-unknown-compiler}

Or "Unknown Arm architecture profile", or an endianness `#error`,
reported as `preprocessorErrorDirective`.

A header checks the compiler's predefined macros and does not find
them. Give Cppcheck the macros, see
[Compiler predefined macros](#embedded-macros).

## preprocessorErrorDirective {#trouble-preprocessor-error}

An `#error` directive was reached. Besides missing compiler macros,
the usual cause is a define your build sets that Cppcheck does not
know, for example a board or configuration macro:

```c
#ifndef BOARD_REV
#error BOARD_REV must be defined
#endif
```

Add it with `-D`, or import your build so Cppcheck gets the defines
from it (see [Choosing and importing a project](#project)). Remember
that one `-D` limits the analysis to one configuration, see
[Preprocessor defines and include paths](#preproc-defines).

## missingInclude {#trouble-missing-include}

`missingInclude` (your headers) and `missingIncludeSystem` (system
headers) say that a header was not found. They are only shown with
`--enable=missingInclude`.

- **For your own headers**, add the include path with `-I`, or import
  the project.
- **For system and compiler headers**, it is normal and usually fine.
  Don't add `/usr/include` or the compiler's folders. Use `--library`
  instead, see [Library configuration](#library).

A missing header often explains other problems, for example a macro
that is not defined. Look for `missingInclude` when you see
`preprocessorErrorDirective`, `unknownMacro` or
`premium-misra-config`.

## unknownMacro {#trouble-unknown-macro}

A macro is used in a way Cppcheck can't parse without its definition,
for example as part of a declaration. Add the header that defines it,
or define it with `-D`:

```sh
cppcheck -D__no_init= -D__packed= src
```

## premium-misra-config {#trouble-misra-config}

A MISRA check needs a declaration it could not find, so it can't
decide whether the rule is followed. The message names the unknown
variable, constant or type.

1. Find where the name is declared, and check that its header is
   found (look for `missingInclude`).
2. Check how the macros around it expand:

    ```sh
    cppcheck -E file.c
    ```

3. Add the missing include path or define.

Don't suppress `premium-misra-config`: the MISRA C compliance report
is then marked non-compliant.

## syntaxError {#trouble-syntax-error}

Cppcheck could not parse the code. Common causes:

- a compiler-specific keyword, such as `__interrupt` or `__far`.
  Define it away: `-D__interrupt=`;
- a missing macro, so the code does not look like C or C++;
- C++ code analysed as C, or the other way round. Check the file
  extension and `--language`.

## unmatchedSuppression {#trouble-unmatched-suppression}

A suppression did not match any finding. This is reported with
`--enable=information`. Either the code no longer has the finding, and
you can remove the suppression, or the suppression is wrong: check the
id and the file pattern. See
[Unmatched suppressions](#suppr-unmatched).

## Results differ between GUI and command line {#trouble-gui-cli}

The GUI and the command line use different settings unless you use
the same project file. Run the GUI's project file on the command line
with `--project`, see
[One configuration for GUI, CLI and CI](#first-one-config).

<!-- TODO(confirm): whole-program MISRA rules missing in the GUI (support ticket 353); fixed? -->

# FAQ {#faq}

Questions customers have asked us, with short answers and links to
the details.

## Getting started {#faq-getting-started}

### How do I check a file against MISRA C and get a report? {#faq-misra-report}

```sh
cppcheck --premium=misra-c-2025 --xml-version=3 file.c 2> results.xml
compliance-report --misra-c-2025 --output-file=report.html results.xml
```

See [Compliance reports](#compliance).

### Should I analyse a folder or a compile\_commands.json? {#faq-folder-or-project}

Use your compilation database if you have one. It gives the exact
include paths and defines, and is faster. See
[Folder, project file or compilation database](#project-choosing).

### How do I create compile\_commands.json? {#faq-create-compdb}

CMake: `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .` Make and others:
`bear -- make`. See [Compilation database](#project-compdb).

### Why do I get missingInclude when the header exists? {#faq-missing-include}

Cppcheck does not know the include path. Add it with `-I`, or import
your build. See [missingInclude](#trouble-missing-include).

### Should I add /usr/include or the compiler's include folders? {#faq-system-includes}

No. It makes the analysis slower and less accurate. Use `--library`
for system libraries. See [Include paths](#preproc-includes).

### Why does one -D change the results so much? {#faq-one-define}

With a `-D`, Cppcheck checks only that one configuration instead of
trying several. See
[Which configurations are checked](#preproc-configurations).

### What does "\#error Unknown compiler" mean? {#faq-unknown-compiler}

Cppcheck does not know your compiler's predefined macros. See
[Compiler predefined macros](#embedded-macros).

### How do I set up an embedded target (ARM GCC, IAR, Microchip, STM32, Zephyr)? {#faq-embedded}

See [Embedded and cross-compiler setup](#embedded).

### When do I need a custom platform file? {#faq-platform}

When your target's type sizes don't match a built-in platform, for
example a 16-bit `int`. See [A custom platform](#preproc-platform-custom).

## Vendor code {#faq-vendor-code}

### Why do I still get warnings from headers in excluded folders? {#faq-excluded-headers}

`-i` only skips source files. Headers they include are still analysed.
Suppress them with `--suppress=*:vendor`. See
[Exclude or suppress](#third-party-exclude-vs-suppress).

### How do I hide all warnings from vendor, SDK or CMSIS headers? {#faq-hide-vendor}

`--suppress=*:<folder>` for each vendor folder. See
[The recipe](#third-party-recipe).

### How do I stop analysing third-party source files? {#faq-skip-vendor-sources}

`-i<folder>`, or `--file-filter` to check only your own files. See
[The recipe](#third-party-recipe).

### How do I suppress warnings caused by a macro from a vendor header? {#faq-vendor-macro}

The finding is reported where the macro is used. Use
`cppcheck-suppress-macro` at the macro definition, or suppress the id
in your files. See [In the code](#suppr-inline).

## Suppressions {#faq-suppressions}

### How do I suppress several ids in one comment? {#faq-several-ids}

Separate them with commas, in brackets:
`// cppcheck-suppress [nullPointer, uninitvar]`. See
[In the code](#suppr-inline).

### Why does my block suppression not work? {#faq-block-suppression}

`cppcheck-suppress-end` must repeat the ids of
`cppcheck-suppress-begin`. Also check that you use `--inline-suppr`.

### Why don't I get unmatchedSuppression? {#faq-no-unmatched}

It needs `--enable=information`, and `--inline-suppr` for inline
suppressions. See [Unmatched suppressions](#suppr-unmatched).

### How do I start with a large number of findings? {#faq-baseline}

Create a baseline, and fix new findings first. See
[Baselines](#suppr-baseline).

### Why does a suppression stop working with -j, a build dir or `--relative-paths`? {#faq-suppression-options}

These are known problems. See [Known problems](#suppr-known-problems).

### Why can't I suppress a critical error? {#faq-suppress-critical}

In safety mode, critical errors always fail the run, because some
code was not analysed. Fix the configuration. See
[Safety mode and exit codes](#safety).

## Coding standards {#faq-standards}

### Do I need `--addon=misra` together with `--premium`? {#faq-addon-misra}

No, and you should remove it. See
[MISRA does not need an addon](#addons-misra).

### Can I check several MISRA versions in one run? {#faq-several-versions}

No. Only the last version given is used. Run once per version.

### Why do some MISRA findings have plain Cppcheck ids? {#faq-plain-ids}

They come from Cppcheck checks that also cover a guideline. Add
`--report-type` to see the guideline. See
[Showing guidelines and categories](#standards-report-type).

### Why doesn't `--enable` hide style findings from MISRA or CERT? {#faq-enable}

`--enable` does not filter coding standard findings. See
[Choosing what is reported](#standards-choosing).

### Which files get MISRA C rules, and which MISRA C++? {#faq-c-or-cpp}

C files get C rules, C++ files C++ rules, and headers follow the file
that includes them. Add `:all` to change this. See
[Which files get which rules](#standards-files).

### How do I check only CERT rules, not recommendations? {#faq-cert-rules}

There is no option for that today. Suppress the recommendations you
don't want.

## Exit codes and safety mode {#faq-exit-codes}

### Why does Cppcheck Premium return exit code 1? {#faq-exit-code-1}

A critical error happened, and safety mode is on. See
[Safety mode and exit codes](#safety).

### What is safety mode, and how do I turn it off? {#faq-safety-off}

It makes critical errors fail the run. Turn it off with
`--premium=safety-off`, but the compliance report then shows the code
as non-compliant. See [Turning safety mode off](#safety-off).

### How do I fail the CI job when there are findings? {#faq-fail-on-findings}

`--error-exitcode=2`. See [Exit codes](#safety-exit-codes).

## Reports {#faq-reports}

### Why does the compliance report say "Not executed"? {#faq-not-executed}

Usually the XML was written with `--xml` instead of `--xml-version=3`.
See ["Not executed"](#compliance-not-executed).

### What is the difference between the HTML report and the compliance report? {#faq-html-vs-compliance}

The HTML report shows each finding with its code, for developers. The
compliance report summarises compliance per guideline, for audits.
See [HTML report](#output-html).

### How do I list suppressions and justifications in a report? {#faq-list-suppressions}

Use XML version 3: it lists the suppressions, and the compliance
report shows them, and justified findings as accepted violations. See
[Justification comments](#suppr-justification).

### How do I export results to SonarQube or another dashboard? {#faq-sarif}

Use SARIF: `--output-format=sarif`. See [SonarQube](#tools-sonarqube).

### Can I create the compliance report in the GUI? {#faq-gui-compliance}

No, use `compliance-report` on the command line. See
[Compliance reports](#compliance).

## Licensing {#faq-licensing}

### Is a trial activated with a license ID or a license file? {#faq-trial}

With a license file. See [License types and license files](#license-types).

### Where do I put the license file? {#faq-license-location}

See [Where to put the license file](#license-location).

### Why do I get "Invalid license"? {#faq-invalid-license}

Run `premiumaddon --debug` to see why. See
[License troubleshooting](#trouble-license).

### How do I use the license in Docker, dev containers or CI? {#faq-license-docker}

Mount it or write it from a secret, don't put it in the image. See
[Licenses in Docker, dev containers, VMs and CI](#license-containers).

## Installation {#faq-installation}

### How do I install without the GUI, for CI or Docker? {#faq-headless}

Use the `.tar.gz` archive. See [Headless and CLI-only](#install-headless).

### Which Linux distributions are supported? {#faq-distributions}

See [System requirements and supported platforms](#install-requirements).

### Why does cppcheck reject `--premium` options on macOS? {#faq-macos-premium}

An open-source `cppcheck` is first on your `PATH`. See [macOS](#install-macos).

## GUI {#faq-gui}

### How do I use the same configuration in the GUI, on the command line and in CI? {#faq-one-config}

Use the GUI project file with `--project`. See
[One configuration for GUI, CLI and CI](#first-one-config).

### Why does the GUI give different results from the command line? {#faq-gui-cli-differ}

They use different settings. See
[Results differ between GUI and command line](#trouble-gui-cli).

### Why are my results classified as style and not by MISRA category? {#faq-classification}

Choose the report type, in the GUI under **View \> Report**, or with
`--report-type`. See [Showing guidelines and categories](#standards-report-type).

# Getting help {#help}

<!-- TODO(confirm): support channel, response times, and where the Known Issues list is published -->

Before you contact us:

- Look in [Part: Troubleshooting and FAQ](#part-troubleshooting).
- Check the Known Issues list for your version.

## Contacting support {#help-contact}

Contact support at `support@cppcheck.atlassian.net`. For licenses and
renewals, contact `sales@cppcheck.com`.

## What to include {#help-what-to-include}

We can help faster if you include:

- the output of `cppcheck --version`,
- your operating system,
- the exact command line, or the project file,
- the message, with its id, file and line,
- for license problems: the output of `premiumaddon --debug`,
- for false positives and false negatives: a small code example that
  shows the problem.

**Reducing a false positive to a small example.** Copy the function
with the false positive to a new file, and remove code as long as the
false positive remains. Replace types and macros from your headers
with simple definitions. Send the result, with the command line.

Don't send code you are not allowed to share. A reduced example
usually does not contain anything confidential.

\part{Reference}\label{part-reference}

# Command-line options {#ref-options}

<!-- oss: cli/cmdlineparser.cpp help text (Cppcheck 2.22.0) -->

`cppcheck --help` lists all options for your version. The tables below
group the common ones, with links to where they are described.

## Input {#ref-options-input}

| Option | Meaning |
|---|---|
| `<files or folders>` | What to analyse. Folders are searched recursively. |
| `--project=<file>` | Import a project: `compile_commands.json`, `.sln`, `.slnx`, `.vcxproj`, `.bpr` or `.cppcheck`. See [Choosing and importing a project](#project). |
| `--project-configuration=<config>` | For Visual Studio: analyse one configuration. See [Visual Studio, C++Builder 6 and other build systems](#project-other). |
| `--file-list=<file>` | Read the files to analyse from a file, one per line. |
| `--file-filter=<pattern>` | Analyse only files matching the pattern. See [Checking only some files](#first-cli-file-filter). |
| `-i <pattern>` | Skip source files matching the pattern. See [Third-party and vendor code](#third-party). |
| `--language=c`, `--language=c++` | Treat all files as C, or as C++. |

## Preprocessor, platform and language {#ref-options-preproc}

| Option | Meaning |
|---|---|
| `-D<name>[=<value>]` | Define a macro. Limits the analysis to one configuration. See [Preprocessor defines and include paths](#preproc-defines). |
| `-U<name>` | The macro is never defined. |
| `-I <dir>` | Add an include path. |
| `--includes-file=<file>` | Read include paths from a file. |
| `--include=<file>` | Include a file before every source file. |
| `--max-configs=<n>` | Configurations to check per file (default 12). |
| `-f`, `--force` | Check all configurations. |
| `--config-exclude=<dir>` | Don't take configurations from headers in this folder. |
| `--std=<standard>` | Language standard, e.g. `c11`, `c++17`. See [C/C++ standard](#preproc-std). |
| `--platform=<name or file>` | Type sizes of the target. See [Platform](#preproc-platform). |
| `--fsigned-char`, `--funsigned-char` | Whether `char` is signed. |
| `--library=<cfg>` | Load a library configuration. See [Library configuration](#library). |
| `-E` | Print the preprocessed code and stop. |

## Checks {#ref-options-checks}

| Option | Meaning |
|---|---|
| `--premium=<option>` | Coding standards and Premium features. See [The `--premium` option](#standards-option). |
| `--premium-cert-c-int-precision=<bits>` | `int` precision for CERT C INT35-C. |
| `--premium-license-file=<path>` | The license file to use. See [License file option and shared folders](#license-shared). |
| `--enable=<list>` | Extra Cppcheck checks: `warning`, `style`, `performance`, `portability`, `information`, `unusedFunction`, `missingInclude`, `all`. Does not affect coding standards. |
| `--disable=<list>` | Turn off checks enabled by default or by `--enable`. |
| `--inconclusive` | Also report findings Cppcheck is not sure about. |
| `--check-level=<level>` | `reduced`, `normal` or `exhaustive`. See [Check levels](#perf-check-level). |
| `--addon=<addon>` | Run an addon. See [Addons](#addons). |
| `--check-library` | Report functions with no library configuration. |
| `--check-config` | Check the configuration (include paths and so on) instead of the code. |
| `--max-ctu-depth=<n>` | Depth of whole-program analysis (default 2). |

## Suppressions {#ref-options-suppressions}

| Option | Meaning |
|---|---|
| `--suppress=<id>[:<file>[:<line>]]` | Suppress findings. See [Suppression formats](#suppr-formats). |
| `--suppressions-list=<file>` | Suppressions from a text file. |
| `--suppress-xml=<file>` | Suppressions from an XML file. |
| `--inline-suppr` | Read suppressions in code comments. |
| `--exitcode-suppress=<id>`, `--exitcode-suppressions=<file>` | Report these findings, but don't let them change the exit code. |

## Output {#ref-options-output}

| Option | Meaning |
|---|---|
| `--output-format=<format>` | `text`, `sarif`, `xmlv2` or `xmlv3`. See [Output formats](#output). |
| `--xml-version=3`, `--xml` | XML output, version 3 or 2. Use version 3. |
| `--output-file=<file>` | Write findings to a file. |
| `--template=<format>`, `--template-location=<format>` | Text output format. See [Text output and templates](#output-text). |
| `--report-type=<type>` | Show guidelines and categories. See [Showing guidelines and categories](#standards-report-type). |
| `--checkers-report=<file>` | Write which checkers ran to a file. |
| `-rp`, `--relative-paths[=<paths>]` | Show paths relative to these folders. |
| `-q`, `--quiet` | Don't show progress. |
| `-v`, `--verbose` | More detail in messages. |
| `--error-exitcode=<n>` | Exit code when there are findings. See [Exit codes](#ref-exit-codes). |

## Performance {#ref-options-performance}

| Option | Meaning |
|---|---|
| `-j <n>` | Analyse with `n` jobs in parallel. |
| `--cppcheck-build-dir=<dir>` | Keep results between runs. See [Build dir and incremental runs](#perf-build-dir). |
| `--report-progress` | Show progress within each file. See [Finding slow files](#perf-slow-files). |
| `--performance-valueflow-max-if-count=<n>` | Limit data flow analysis in functions with many `if`. |
| `--showtime=<mode>` | Show where the time is spent. |

## Other {#ref-options-other}

| Option | Meaning |
|---|---|
| `--dump` | Write dump files for your own tools. See [Custom tooling](#tools-custom). |
| `--errorlist` | Print all possible findings in XML. |
| `--version` | Print the version. |
| `-h`, `--help` | Print all options. |

# File locations {#ref-files}

## Install folder {#ref-files-install}

| System | Folder |
|---|---|
| Windows | `C:\Program Files\Cppcheck Premium` |
| Linux packages | `/opt/cppcheckpremium` |
| `.tar.gz` and macOS | Where you unpacked it |

The install folder contains:

| File or folder | Purpose |
|---|---|
| `cppcheck`, `cppcheck-gui` | The command line tool and the GUI |
| `premiumaddon` | The Premium checks and the license check. `premiumaddon --debug` checks the license. |
| `compliance-report` | Creates compliance reports. See [Compliance reports](#compliance). |
| `cppcheck-htmlreport` | Creates HTML reports. See [HTML report](#output-html). |
| `git-license-metrics` | Counts committers. See [License metrics](#metrics-license). |
| `HISReport.py` | Creates a metrics CSV. See [HIS metrics](#metrics-his). |
| `register.py` | Registers a machine-bound license. See [License types and license files](#license-types). |
| `cppcheck-id-mapping.json` | Maps Cppcheck ids to coding standard guidelines. |
| `cppcheck.cfg` | Product settings, such as safety mode on by default. Don't edit. |
| `premiumaddon.json` | How Cppcheck runs `premiumaddon`. Don't edit. |
| `cfg/` | Library configurations. See [Library configuration](#library). |
| `platforms/` | Platform files. See [Platform](#preproc-platform). |
| `addons/` | Addons and `cppcheckdata.py`. See [Addons](#addons). |

<!-- TODO(confirm): Windows install folder contents match -->

## License files {#ref-files-license}

| System | Folders searched |
|---|---|
| Windows | `C:\ProgramData\Cppcheck Solutions AB\`, the install folder |
| Linux and macOS | `/etc/cppcheckpremium/`, `~/.cppcheckpremium/`, the install folder |

See [Where to put the license file](#license-location).

## Files Cppcheck creates {#ref-files-created}

| File | When |
|---|---|
| Files in the build dir | With `--cppcheck-build-dir`, and in the GUI. See [Build dir and incremental runs](#perf-build-dir). |
| `<file>.dump` | With `--dump`. |
| `<project>-cppcheck-build-dir` | The GUI's default build dir, next to the project file. |

<!-- TODO(confirm): GUI default build dir name -->

# Exit codes {#ref-exit-codes}

## cppcheck {#ref-exit-codes-cppcheck}

| Exit code | When |
|---|---|
| 0 | The analysis completed. Findings don't change the exit code unless `--error-exitcode` is given. |
| 1 | Safety mode is on and a critical error happened, even if it was suppressed. This includes license errors. |
| 1 | Invalid options, or no files to analyse. |
| `<n>` | `--error-exitcode=<n>` was given and there are findings that are not suppressed, or `unmatchedSuppression` findings. |

Findings listed with `--exitcode-suppress` or `--exitcode-suppressions`
are reported but don't cause `<n>`.

See [Safety mode and exit codes](#safety).

## compliance-report {#ref-exit-codes-compliance}

| Exit code | When |
|---|---|
| 0 | The report was written, whether the code is compliant or not. |
| 1 | Unknown option, missing file, or another error. |

## premiumaddon {#ref-exit-codes-premiumaddon}

`premiumaddon` is run by `cppcheck`. When you run it yourself with
`--debug`, read the output, not the exit code.

# Changelog {#ref-changelog}

The release notes for each version list new checks, fixed false
positives and negatives, and changed options.

<!-- TODO(confirm): where release notes are published (GitHub Releases of cppcheckpremium, website); the release process task decides how this chapter is generated -->

When you upgrade, read the release notes of all versions since your
current one. See [Upgrading](#upgrade).
